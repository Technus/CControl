os.pullEvent=os.pullEvenRaw--block ctrl+T

 --cmd type,what,value,where
local meta={}
do--meta organization
	meta.database						={}--main database handler
	meta.config							={}
		meta.config.safety				={}
		meta.config.network				={}
		meta.config.log					={}
	meta.user							={}--'life' being, authed commands
		meta.user.single				={}
		meta.user.group					={}
	meta.client							={}--Pc commands authed by a pc
		meta.client.single				={}
		meta.client.group				={}
	meta.permission						={}--permission
	--	meta.permission.operations		={}--HERE I SHALL DEFINE METHODS TO OPERATE ON PERMISSIONS
		meta.permission.state			={}--state based permission
		meta.permission.group			={}--grouping of perms
	meta.peripheral						={}--connect-able-s
		meta.peripheral.single			={}
		meta.peripheral.group			={}
		meta.peripheral.definition		={}--kind of method holder
	meta.log							={}
		meta.log.log					={}--general purpose
		meta.log.network				={}
			meta.log.network.packet		={}
			meta.log.network.change		={}
		meta.log.data					={}--db changes
	meta.instance						={}
		meta.instance.instance			={}--main instance handler
		meta.instance.parallel			={}
		meta.instance.network			={}
end

do--load apis
	if not AES then os.loadAPI("AES")end
	--AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
	--AES.decrypt_str(data, key, iv) -- Decrypt a string.
	if not SHA then os.loadAPI("SHA")end
	--SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
	if not BigInt then os.loadAPI("BigInt")end
	if not TCP_IP then os.loadAPI("TCP_IP")end
end

local functions={}
do--functions
	functions.timestamp=		function() --as string which can be BigInt
									local timeValue=os.time()*1000
									local dayValue=os.day()
									if timeValue<10000 then
										return dayValue.."0"..math.floor(timeValue)
									end
									return dayValue..math.floor(timeValue)
								end

	functions.timeReadable=		function() 
									local timeValue=os.time() 
									return ("Day "..os.day().." Hour "..math.floor(timeValue).." Precision "..((timeValue-math.floor(timeValue))*1000).."/1000")
								end

	functions.timeCMP=			function(packetTime,storedTime,timeToLive)
									if not packetTime or not storedTime then return false,0,"not enough arguments" end
									local actualTime=BigInt.toBigInt(functions.timestamp())
									packetTime=BigInt.toBigInt(packetTime)
									storedTime=BigInt.toBigInt(storedTime)
									if not BigInt.cmp_gt(packetTime,storedTime) then return false,1,"packet too old" end
									if not BigInt.cmp_le(packetTime,actualTime) then return false,2,"packet too new" end
									if timeToLive then
										timeToLive=BigInt.toBigInt(timeToLive)
										timeToLive=BigInt.sub_bigInt(actualTime,timeToLive)
										if not BigInt.cmp_gt(packetTime,timeToLive) then return false,3,"packet dead" end
									end
									return true,nil,"packet ok" 
								end

	functions.tick=				function() return (os.time() * 1000 + 18000)%24000 end--probably useless

	functions.encryptData=		function(data,key,iv)--encrypts anything gives a string
									return(AES.encrypt_str(textutils.serialize({"Tec :3",data}), key, iv)),"encrypted"
								end

	functions.decryptData=		function(data,key,iv)--decrypts anything gives the data back
									local temp=textutils.unserialize(AES.decrypt_str(data, key, iv))
									if type(temp)~="table" then return nil,"decryption error" end
									if temp[1]~="Tec :3" then return nil,"decryption error" else return temp[2],"decryption success" end 
								end

	functions.openModems=		function()
									local sides={}
									for _,v in ipairs(rs.getSides()) do
										if "modem" == peripheral.getType(v) then 
											rednet.open(v)
											table.insert(sides,v)
										end
									end
									return sides
								end

	functions.shaDigest=		function(input) --takes any data returns SHA-256 string
									return SHA.digestStr(textutils.serialize(input)),type(input)
								end

	functions.shaToIntTable=	function(input)--useful for making AES keys or IVs
									local temp={}
									local tooshort=false
									for i=1,32 do
										temp[i]=tonumber(string.sub(input,2*i-1,i*2),16)
										if not temp[i] then 
											temp[i]=0
											tooshort=true 
										end
									end
									if tooshort then
										return temp,tooshort,"done"
									else
										return temp,tooshort,"input was too short"
									end
								end

	functions.authCheck=		function(inputtedCredentials,storedCredentials)
									local missmatch={}
									if type(inputtedCredentials)~="table" then inputtedCredentials={inputtedCredentials} end
									if type(storedCredentials  )~="table" then storedCredentials  ={storedCredentials  } end
									if #inputtedCredentials==0 and #storedCredentials==0 then return true,missmatch,"no credentials" end
									for key,value in pairs(inputtedCredentials) do
										if inputtedCredentials[key]~=storedCredentials[key] then 
											table.insert(missmatch,key)
										end
									end
									if #missmatch>0 then
										return false,missmatch,"credentials incorrect"
									else
										return true,missmatch,"credentials correct"
									end
								end

	functions.permCheck=		function(values)--must be greater than 0
									values=values or {}
									local store=0--default permission value
									for key,value in pairs(values) do
										if 		values[key]==-math.huge then return false,(-math.huge),"blocked"
										elseif 	values[key]== math.huge then store=math.huge
										else store=store+values[key] 
										end
									end
									if store>0 then return true,store,"granted" end
									return false,store,"denied"
								end

	functions.permCmp=			function(input,stored)--interpreter of permissions
									if (input==nil) or (input=="")   then return false,"no permissions inherited" end
									if (stored==nil) or (stored=="") then return false,"no permissions assigned" end
									--convert text.type.permissions to table type :D
									local inputTable =functions.strSeparator(input)
									local storedTable=functions.strSeparator(stored)
									--do the magic
									while #storedTable>#inputTable do 
										if inputTable[#inputTable]=="*" then 
											inputTable[#inputTable+1]="*" 
										else
											inputTable[#inputTable+1]=""
										end
									end
									while #storedTable<#inputTable do 
										if storedTable[#storedTable]=="*" then 
											storedTable[#storedTable+1]="*" 
										else 
											storedTable[#storedTable+1]="" 
										end
									end
									
									for key,value in ipairs(inputTable) do
										if (inputTable[key]~=storedTable[key]) and (inputTable[key]~="*") and (storedTable[key]~="*") then 
											return false,"insufficient permissions" 
										end
									end
									return true,"permission granted"
								end
							
	functions.formatPassword=	function(passphrase)
									if passphrase:upper()==passphrase then 
										return passphrase:lower(),passphrase,"lower"
									end
									return passphrase:upper(),passphrase,"upper"
								end
								
	functions.strSeparator=		function(input,separator)--splits strings to table cells by desired character
									if not input then return nil,"no input" end
									if type(input)=="table" then return input,"it is a table" end
									separator=separator or "."
									outputTable={}
									repeat
										local pos=string.find(input,"%"..separator)
										if pos then
											table.insert(outputTable,string.sub(input,1,pos-1))
											input=string.sub(input,pos+1)
										end
									until not pos
									table.insert(outputTable,input)
									return outputTable,"separated"
								end
								
	functions.deeperPointer=	function(tab,dir,noCopy)--moves into table according to dir table contents
									if not noCopy then dir=functions.duplicate(dir) end
									if not dir or not tab then
										return tab,nil,"arg error" end
									and
									if type(tab)~="table" then return tab,false,dir,"reached max depth" end
									if type(dir)~="table" then dir={dir} end
									local temp=dir[1]
									table.remove(dir,1)
									if #dir~=0 then
										return functions.deeperPointer(tab[temp],dir,true)
									elseif type(tab[temp])=="table" then
										return tab[temp],true,dir,"sending pointer"
									else
										return tab[temp],false,dir,"sending value"
									end
								end
								
	functions.loadstring= 		function(str)--obsolete/debug
									local func=loadstring(str)
									setfenv(func,getfenv())
									return func,"DO NOT USE THAT"
								end

	functions.duplicate=		function(input) return textutils.unserialize(textutils.serialize(input)) end
end


do--DATABASE
	function meta.database:new()--sets table as database object 
		local o = {name=functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.config={}
			self.config.safety={}
			self.config.network={}
			self.config.log={}
			self.config.main={}
		self.user={}
			self.user.single={}
			self.user.group={}
		self.client={}
			self.client.single={}
			self.client.group={}
		self.permission={}
			self.permission.state={}
			self.permission.group={}
		self.peripheral={}
			self.peripheral.single={}
			self.peripheral.group={}
			self.peripheral.definition={}
		self.log={}
			self.log.log={}
			self.log.network={}
				self.log.network.packet={}
				self.log.network.change={}
			self.log.data={}
		return o
	end
	
	function meta.database:init(source)--boots up the database from raw data (also assigns meta-tables)
		source=source or data or nil
		if not source return nil end
		setmetatable(source,self)
		for key,value in ipairs(self:availableType()) do
		--	local dir= functions.loadstring("return self."..value)()
			value=functions.strSeparator(value)
			local dir=functions.deeperPointer(self,value)
			for key1,value1 in ipairs(dir) do
			--	functions.loadstring(dir.."["..key1.."]=meta."..value..":init("dir.."["..key1.."])")()
				dir[key1]=functions.deeperPointer(meta,value):init(dir[key1])
			end
		end
		return source
	end
	
	function meta.database:availableType()--lists all available object types in the database
		return {"user.single","user.group","client.single","client.group","permission.state","permission.group","peripheral.single","peripheral.group","peripheral.definition","log.log","log.network.packet","log.network.change","log.data"}
	end
	
	function meta.database:easyType(value)--adds aliases to types
		if	   value=="user" or value=="[\"user\"][\"single\"]" then 
				return "user.single"
		elseif value=="client" or value=="[\"client\"][\"single\"]" then 
			return "client.single"
		elseif value=="user group" or value=="[\"user\"][\"group\"]" then 
			return "user.group"
		elseif value=="client group" or value=="[\"client\"][\"group\"]" then 
			return "client.group"
		elseif value=="peripheral" or value=="[\"peripheral\"][\"single\"]" then 
			return "peripheral.single"
		elseif value=="peripheral group" or value=="[\"peripheral\"][\"group\"]" then 
			return "peripheral.group"
		elseif value=="peripheral definition" or value=="[\"peripheral\"][\"definition\"]" then 
			return "peripheral.definition"
		elseif value=="state" or value=="[\"permission\"][\"state\"]" then 
			return "permission.state"
		elseif value=="permission group" or value=="[\"permission\"][\"group\"]" then 
			return "permission.group"
		elseif value=="log" or value=="[\"log\"][\"log\"]" then 
			return "log.log"
		elseif value=="log network" or value=="[\"log\"][\"network\"][\"packet\"]" then 
			return "log.network.packet"
		elseif value=="log network change" or value=="[\"log\"][\"network\"][\"change\"]" then 
			return "log.network.change"
		elseif value=="log data" or value=="[\"log\"][\"data\"]" then 
			return "log.data"
		else 
			return value,"no alias"
		end
	end
	
	function meta.database:typeCheckNReturn(input)--checks string to match any type/alias-- returns type,(false/true)
		input=self:easyType(input)
		local check=false
		for key,value in ipairs(self:availableType()) do
			if value==input then check=true break end
		end
		return input,check
	end
	
	function meta.database:newEntry(kind,name)--adds new entry
		local check
		kind,check = self:typeCheckNReturn(kind)
		if check then
			kind=functions.strSeparator(kind)
			name=name or functions.timestamp().."_"..#(functions.deeperPointer(self,kind))+1			
		--	functions.loadstring("table.insert(self."..kind..",meta."..kind..":new("..name.."))")()
			table.insert(functions.deeperPointer(self,kind),
						 functions.deeperPointer(meta,kind):new(name))
		return #(functions.deeperPointer(self,kind)),name,"created"
		else
		return #(functions.deeperPointer(self,kind)),nil,"invalid kind"
		end
	end
	
	function meta.database:deleteEntry(kind,which)--removes entry
		local check
		local deletedAlready=false
		kind,check = self:typeCheckNReturn(kind)
		if check then
			kind=functions.strSeparator(kind)
			if which>#functions.deeperPointer(self,kind) then return nil,"out of bounds" end
		--	functions.loadstring("self."..kind.."["..which.."]:delete()")()
			if functions.deeperPointer(self,kind)[which]["name"]==nil then deletedAlready=true end
			functions.deeperPointer(self,kind)[which]:delete()
		end
		if deletedAlready then
			return deletedAlready,"entry was not present"
		else
			return deletedAlready,"entry was deleted"
		end
	end
	
	function meta.database:editEntry(kind,which,what,operation,input,position)--edit functions handler
		input=functions.duplicate(input)
		local check
		kind,check =self:typeCheckNReturn(kind)
		if check then
			kind=functions.strSeparator(kind)
			what=functions.strSeparator(what)
			if not functions.deeperPointer(self,kind)[which] then return false,"entry does not exist" end
			if self:isDeleted(functions.deeperPointer(self,kind)[which]) then return false,"entry was deleted" end
			
			if 		operation=="set" then 
			--	functions.loadstring("return self."..kind.."["..which.."]."..what)()=input 
				functions.deeperPointer(self,kind)[which][what]=input
			elseif operation=="renew" then
				functions.loadstring("return self."..kind.."["..which.."]")()={}
				functions.loadstring("return self."..kind.."["..which.."]")()=functions.loadstring("return meta."..kind..":new("..input..")")()
			else --operations on tables
				local tab
				local test
				tab,test=functions.deeperPointer(functions.deeperPointer(self,kind)[which],what)
				if test then
					if	operation=="insert" then 
					--	table.insert(functions.loadstring("return self."..kind.."["..which.."]."..what)(),input)
						--if functions.deeperPointer(functions.deeperPointer(self,kind)[which],what)
						table.insert(tab,input)
					elseif	operation=="remove" then
						position= position or input
					--	table.remove(functions.loadstring("return self."..kind.."["..which.."]."..what)(),position)
						if type(position)=="number" and position>0 and position<=#tab then table.remove(tab,position) end
					elseif operation=="edit" then
						if type(tab[position])~="table" then tab[position]=input end
					elseif operation=="assign" then
						if type(input)=="table" then tab[position]=input end
					elseif	operation=="clear" then--to clear a table inside the obj.
						tab={}
					end
				end
			end
			return true,"done"
		end
		return false,"invalid kind"
	end
	
	function meta.database:readEntry(kind,which,what)
		--deleted record handling unnecessary since then all==nil
		local check
		kind,check =self:typeCheckNReturn(kind)
		if check then
			kind=functions.strSeparator(kind)
			what=functions.strSeparator(what)
			if what then
				--return functions.loadstring("return self."..kind.."["..which.."]."..what)()
				return functions.duplicate(functions.deeperPointer(functions.deeperPointer(self,kind)[which],what))
				--textutils allow loss of connection to object so read cannot provide addr for edit
			else
				--return functions.loadstring("return self."..kind.."["..which.."]")()
				return functions.duplicate(functions.deeperPointer(self,kind)[which])
			end
		end
		return nil
	end
	
	function meta.database:isDeleted(kind,which)
		if type(kind)=="table" then
			if which>#kind then 
				return nil,"out of bounds"
			elseif which and kind[which].name==nil then 
				return true,"deleted" 
			elseif kind.name==nil then 
				return true,"deleted" 
			else 
				return false,"present"
			end
		end
		
		local check
		kind,check =self:typeCheckNReturn(kind)
		if check then
			if functions.loadstring("return self."..kind.."["..which.."]")()["name"] then return false,"present" else return true,"deleted" end
		end
	end
	
	function meta.database:query(kind,params,what,field)--search in desired field/type pairs in database
		--{kind in which to search},{what to look for},{1={names on lvl 1},2={names on lvl 2},-1 names on last level}
		if params and type(params)~="table" then params={[params]=true} end
		params=params or {["exact"]=true}
		
		local entryValues={}
		
		if type(kind)~="table" then kind={kind} end	
		if #kind==0 then
			kind=self:availableType()
		end	
		for key,value in ipairs(kind) do
			local check
			kind[key],check=self:typeCheckNReturn(kind[key])
			if check then
				search(functions.deeperPointer(self,kind[key]),kind[key])
			end
		end		
		
		field=functions.duplicate(field) or {}--copy of args in a table		
		for key,value in pairs(field) do
			if type(field[key])~="table" then field[key]={field[key]} end
		end
		
		what=functions.duplicate(what) or functions.duplicate(field[0])
		field[0]=nil
		
		if type(what)~="table" then what={what} end
			--extra args specify field matching
				--structure
				--{ "level"=3 , "name"="cake" or {"cake","wat"} }
				
				--level 1 is user.single etc.
				--level 2 is next depth level
				--level -1 is last depth level, -2 second from last etc.
		
		
		local function search(where,kind,depth,loc)
			local depth=depth or 1
			local loc=loc or {kind}
			
			for key,value in pairs(where) do
				if not depth==1 or where[key]["name"] then
					if type(where[key])=="table" then
						local locDuplicate=functions.duplicate(loc)
						locDuplicate[depth+1]=key
						search(where[key],nil,depth+1,locDuplicate)
					else
						if #what==0 then
							table.insert(entryValues,{loc,nil,where[key]})
						else
							for key1,value1 in ipairs(what) do
								if params.part and not params.exact and string.find(where[key],what[key1]) then
									table.insert(entryValues,{loc,what[key1],where[key]})
								elseif where[key]==what[key1] then
									table.insert(entryValues,{loc,what[key1],where[key]})
								end
							end
						end
					end
				end
			end
		end
		
		for key,value in pairs(field) do
			local key1=1
			while key1<=#entryValues do
				local delete=true
				if #field[key]==0 then 
					delete=false
				elseif key>0 then
					for key2,value2 in ipairs(field[key]) do
						if entryValues[key1][1][key]==field[key][key2] then delete=false end
					end
				elseif key<0 then
					for key2,value2 in ipairs(field[key]) do
						if entryValues[key1][1][#entryValues[key1][1]+key+1]==field[key][key2] then delete=false end
					end
				end	
				if delete then
					table.remove(entryValues,key1)
				else
					key1=key1+1
				end
			end
		end
		return functions.duplicate(entryValues)
	end
	
	function meta.database:testPermission(kind,who,what)--permission tester for user/client
		kind=self:easyType(kind)
		if kind=="user.single" then kind="user" end
		if kind=="client.single" then kind="client" end
		if kind~="user" and kind~="client" then return functions.permCheck() end
		local entryValues={}
		local entryGroups={}
		local groups={}
		--client single perms
		for key,value in ipairs(self[kind]["single"][who]["permission"]["single"]) do
			if functions.permCmp(what,self[kind]["single"][who]["permission"]["single"][key]["node"]) then 
				table.insert(entryValues,self[kind]["single"][who]["permission"]["single"][key]["value"])
			end
		end
		--gaining permissions from perm groups
		for key,value in ipairs(self[kind]["single"][who]["permission"]["group"]) do
			for key1,value1 in ipairs(self.permission.group[value]["permission"]) do
				if self.permission.group[value]["name"] then--check if deleted
					if functions.permCmp(what,self.permission.group[value]["permission"][key1]["node"]) then
						table.insert(entryValues,self.permission.group[value]["permission"][key1]["value"])
					end
				end
			end
		end	
		
		--client group inherited 
		for key,value in ipairs(self[kind]["single"][who]["group"]) do
			local add=false
			if self[kind]["group"][value]["name"] then add=true end
			for key1,value1 in ipairs(groups) do
				if groups[key1]==value then add=false break end
			end
			if add then table.insert(groups,value) end
		end
		--client group inherited from group and from other groups an so on
		for key,value in ipairs(groups) do
		--add entries9
			for key1,value1 in ipairs(self[kind]["group"][value]["group"]) do--look in the already listed groups
				local add=false
				if self[kind]["group"][value1]["name"] then add=true end
				for key2,value2 in ipairs(groups) do--look for repeats
					if groups[key2]==value1 then add=false break end
				end
				if add then table.insert(groups,value1) end
			end
		end
		--from inheritances
		for key,value in ipairs(groups) do
			for key1,value1 in ipairs(self[kind]["group"][value]["permission"]["single"]) do--gaining permissions from groups
				if functions.permCmp(what,self[kind]["group"][value]["permission"]["single"][key1]["node"]) then 
					table.insert(entryValues,self[kind]["group"][value]["permission"]["single"][key1]["value"])
				end
			end
			for key1,value1 in ipairs(self[kind]["group"][value]["permission"]["group"]) do--gaining perm groups from groups
				if self.permission.group[value1]["name"] then
					for key2,value2 in ipairs(self.permission.group[value1]["permission"]) do
							if functions.permCmp(what,self.permission.group[value1]["permission"][key2]["node"]) then
								table.insert(entryValues,self.permission.group[value1]["permission"][key2]["value"])
							end
					end
				end
			end	  
		end
		return functions.permCheck(functions.duplicate(entryValues))
	end
end
local data=meta.database:new()--make DB instance

do--INSTANCE 
	function meta.instance.instance:new()
		functions.openModems()
		local o = {name=functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.parallel={}
		self.network={}
			self.network.in={}
			self.network.out={}
		return o
	end
	
	function meta.instance.instance:packetIn(packet,id)
		table.insert(self.network.in,meta.instance.network:new(packet,id))
	end
	
	function meta.instance.instance:packetOut(packet,id)
		table.insert(self.network.in,meta.instance.network:new(packet,id))
	end
	function meta.instance.instance:packetIn(packet,id)
		table.insert(self.network.in,meta.instance.network:new(packet,id))
	end
	
	function meta.instance
	
	end
	
	instance=meta.instance.instance:new()
end

do--NETWORK INSTANCE
	function meta.instance.network:new(packet,id)
		local o = {packet=packet,id=id}
		setmetatable(o, self)
		self.__index = self
		return o
	end
	
	function meta.instance.network:
	end
end

do--USER
	function meta.user.single:new(name)
		local o = {name=name,lastTimeStamp=functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.photo=nil
		self.password=nil--not recommended
		self.passhashU=nil--upper
		self.passhashL=nil--lower
		self.group={}--user groups inherited
		self.permission={}--what can do
			self.permission.single={}
			self.permission.group={}
		self.client={}--what clients can b used
			self.client.single={}
			self.client.group={}
		self.superuser=false
		return o
	end
	
	function meta.user.single:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.user.single:delete()
		self.__index = nil
		self.name=nil
		self.lastTimeStamp=nil
		self.description=nil
		self.photo=nil
		self.password=nil--not recommended
		self.passhashU=nil--upper
		self.passhashL=nil--lower
		self.group=nil--user groups inherited
		self.permission=nil--what can do
		self.client=nil--what clients can b used
		self.superuser=nil
		--self[1]=true
	end
end

do--USER GROUP
	function meta.user.group:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.group={}--user groups inherited
		self.permission={}--what can do
			self.permission.single={}
			self.permission.group={}
		self.client={}--what clients can b used
			self.client.single={}
			self.client.group={}
		self.hierarchy={}--hierarchy
		self.superuser=false
		return o
	end
	
	function meta.user.group:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.user.group:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.group=nil--user groups inherited
		self.permission=nil--what can do
		self.client=nil--what clients can b used
		self.hierarchy=nil--hierarchy
		self.superuser=nil
		--self[1]=true
	end
end

do--CLIENT
	function meta.client.single:new(name)
		local o = {name=name,lastTimeStamp=functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.password=nil--not recommended
		self.passhashU=nil--upper
		self.passhashL=nil--lower
		self.group={}--client groups inherited
		self.permission={}--what can do
			self.permission.single={}
			self.permission.group={}
		self.hierarchy={}--hierarchy
		self.networkNic={}--connected NICs
		return o
	end
	
	function meta.client.single:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.client.single:delete()
		self.__index = nil
		self.name=nil
		self.lastTimeStamp=nil
		self.description=nil
		self.password=nil--not recommended
		self.passhashU=nil--upper
		self.passhashL=nil--lower
		self.group=nil--client groups inherited
		self.permission=nil--what can do
		self.hierarchy=nil--hierarchy
		self.networkNic=nil--connected NICs
		--self[1]=true
	end
end
	
do--CLIENT GROUP
	function meta.client.group:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.group={}--client groups inherited
		self.permission={}--what can do
			self.permission.single={}
			self.permission.group={}
		self.hierarchy={}--hierarchy
		return o
	end
	
	function meta.client.group:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.client.group:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.group=nil--client groups inherited
		self.permission=nil--what can do
		self.hierarchy=nil--hierarchy
		--self[1]=true
	end
end

do--permission meta
	function meta.permission.operations:new(node,value)
		local o = {node=node,value=value or 0}
		setmetatable(o, self)
		self.__index = self
		return o
	end
	
	--function meta.permission.single:delete()
	--  self.value=nil
	--  self.node=nil
	--  --self[1]=true
	--end
	
	function meta.permission.operations:edit(what,data)
		if what=="value" or what=="node" then
			self[what]=data
		end
	end
end

--do--PERMISSION DEFAULT
--function meta.permission.default:add(name)
--  local o = {name=name}
--  setmetatable(o, self)
--  self.__index = self
--  self.level=0--what can do
--  return o
--end
--end

do--"PERMISSION" STATES
	function meta.permission.state:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.enabled=false
		self.permission={}--perm mod
			self.permission.single={}
			self.permission.group={}
		--self.hierarchy={}--hierarchy
		return o
	end
	
	function meta.permission.state:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.permission.state:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.enabled=nil
		self.permission=nil--perm mod
		--self.hierarchy={}--hierarchy
		--self[1]=true
	end
	
	--data.permission.state.default=meta.permission.state:new("default")
end

do--PERMISSION GROUPS
	function meta.permission.group:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.permission={}--perm mod
		--self.hierarchy={}--hierarchy
		return o
	end
	
	function meta.permission.group:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.permission.group:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.permission=nil--perm mod
		--self.hierarchy={}--hierarchy
		--self[1]=true
	end
end

do--PERIPHERAL
	function meta.peripheral.single:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.nic=nil--connected NIC instance
		self.definition=nil
		self.state={}--info about state of peripheral?
		--self.permission={} --linking via name/ID + name from definition
		return o
	end
	
	function meta.peripheral.single:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.peripheral.single:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.nic=nil--connected NIC instance
		self.definition=nil
		self.state=nil--info about state of peripheral?
		--self.permission={} --linking via name/ID + name from definition
		--self[1]=true
	end
end

do--PERIPHERAL GROUP
	function meta.peripheral.group:new(name)--of the same definition
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.list={}--list of peripherals (from single definitions
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		return o
	end
	
	function meta.peripheral.group:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.peripheral.group:delete()--of the same definition
		self.__index = nil
		awlf.name=nil
		self.description=nil
		self.list=nil--list of peripherals (from single definitions
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		--self[1]=true
	end
end

do--PERIPHERAL DEFINITION
	function meta.peripheral.definition:new(name)
		local o = {name=name}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.method={}--list of peripheral commands + permissions names {...,...}
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		return o
	end
	
	function meta.peripheral.definition:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.peripheral.definition:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.method=nil--list of peripheral commands + permissions names {...,...}
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		--self[1]=true
	end
end

do--LOG
	function meta.log.log:new(name)
		local o = {name=name,day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.content={}--table containing stuff
		return o
	end
	
	function meta.log.log:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.log.log:delete()
		self.__index = nil
		self.name=nil
		self.day=nil
		self.time=nil
		self.tick=nil
		self.description=nil
		self.content=nil--table containing stuff
		--self[1]=true
	end
end

do--LOG network packet
	function meta.log.network.packet:new(name)
		local o = {name=name,day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.nicSource=nil
		self.nicDestination=nil
		self.content={}--table containing stuff
		return o
	end
	
	function meta.log.network.packet:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.log.network.packet:delete()
		self.__index = nil
		self.name=nil
		self.day=nil
		self.time=nil
		self.tick=nil
		self.description=nil
		self.nicSource=nil
		self.nicDestination=nil
		self.content=nil--table containing stuff
		--self[1]=true
	end
end

do--LOG network changes
	function meta.log.network.packet:new(name)
		local o = {name=name,day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.affectedNic=nil
		self.change=nil
		self.content={}--table containing stuff
		return o
	end
	
	function meta.log.network.packet:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.log.network.packet:delete()
		self.__index = nil
		self.name=nil
		self.day=nil
		self.time=nil
		self.tick=nil
		self.description=nil
		self.affectedNic=nil
		self.change=nil
		self.content=nil--table containing stuff
		--self[1]=true
	end
end

do--LOG database commands/changes
	function meta.log.data:new(name)
		local o = {name=name,day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.command=nil
		self.permissionTestResult=nil
		self.content={}--table containing stuff
		return o
	end
	
	function  meta.log.data:init(data)
		setmetatable(data, self)
		return data
	end
	
	function meta.log.data:delete()
		self.__index = nil
		self.name=nil
		self.day=nil
		self.time=nil
		self.tick=nil
		self.description=nil
		self.command=nil
		self.permissionTestResult=nil
		self.content=nil--table containing stuff
		self[1]=nil
	end
end

--EXPOSE SOME STUFF :D
mainframe={}
do
mainframe.timestamp=functions.timestamp								
end

--just for reference
function Account:deposit (v)
	if not self then return nil end--detekcja braku tablicy
	self.balance = self.balance + v
end

a = Account:new(nil,"demo")
a:show("after creation"))