--cmd type,what,value,where


do--meta organization
meta									={}
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
	meta.network						={}--only for networking purposes
		meta.network.nic				={}--the end of line
		meta.network.group				={}--aka NIC "groups"
		meta.network.path				={}--list of network connections
		meta.network.packet				={}
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
	if not AES then os.loadAPI("AES.lua")end
	--AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
	--AES.decrypt_str(data, key, iv) -- Decrypt a string.
	if not SHA then os.loadAPI("SHA.lua")end
	--SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
	if not BigInt then os.loadAPI("BigInt.lua")end
end

do--functions
functions								={}
	functions.timestamp=		function() --as string which can be BigInt
									timeValue=os.time()*1000
									dayValue=os.day()
									if timeValue<10000 then
										return dayValue.."0"..math.floor(timeValue)
									end
									return dayValue..math.floor(timeValue)
								end

	functions.timeReadable=		function() 
									local timeValue=os.time() 
									return ("Day "..os.day().." Hour "..math.floor(timeValue).." Precision "..((timeValue-math.floor(timeValue))*1000).."/1000") 
								end

	functions.timeCMP=			function(packetTime,storedTime)
									packetTime=BigInt.toBigInt(packetTime)
									storedTime=BigInt.toBigInt(storedTime)
									return BigInt.cmp_gt(packetTime,storedTime) and BigInt.cmp_le(packetTime,BigInt.toBigInt(functions.timestamp()))
								end

	functions.tick=				function() return (os.time() * 1000 + 18000)%24000 end--probably useless

	functions.encryptData=		function(data,key,iv)--encrypts anything gives a string
									return(AES.encrypt_str(textutils.serialize({"Tec :3",data}), key, iv)) 
								end

	functions.decryptData=		function(data,key,iv)--decrypts anything gives the data back
									local temp=textutils.unserialize(AES.decrypt_str(data, key, iv))
									if type(temp)~="table" then return nil end
									if temp[1]~="Tec :3" then return nil else return temp[2] end 
								end
								
	functions.opernModem=		function(protocols,side)
									if "modem"==peripheral.getType(side) then
										rednet.open(side)
									end
									if rednet.host and protocols then
										if type(protocols)=="table" then
											for key,value in ipairs(protocols) do
												rednet.host(value)
											end
										else
											rednet.host(protocols)
										end
									end
								end

	functions.openModems=		function(protocols)
									local sides={}
									for i = 1,#rs.getSides() do
										if "modem" == peripheral.getType(rs.getSides()[i]) then 
											rednet.open(rs.getSides()[i])
											table.insert(sides,rs.getSides()[i])
										end
									end
									if rednet.host and protocols then
										if type(protocols)=="table" then
											for key,value in ipairs(protocols) do
												rednet.host(value)
											end
										else
											rednet.host(protocols)
										end
									end
									return sides
								end

	functions.shaDigest=		function(input) --takes any data returns SHA-256 string
									return SHA.digestStr(textutils.serialize(input)) 
								end

	functions.shaToIntTable=	function(input)--useful for making AES keys or IVs
									local temp={}
									for i=1,32 do
										temp[i]=tonumber(string.sub(str,2*i-1,i*2),16)
										if not temp[i] then temp[i]=0 end
									end
									return temp
								end

	functions.filler64=			function(input) --takes string and expands it to 64 chars--to rework --to rework --to rework --to rework
									local t = {}
									for i = 1, #input do
										t[i] = input:sub(i, i)
									end
									local j=0
									while #t<64 do
										j=j+1
										t[#t+1]=t[j]
									end
									local output=t[1]
									for k=2,64 do
										output=output..t[k]
									end
									return output
								end

	functions.authCheck=		function(packetTime,storedTime,inputtedCredentials,storedCredentials)
									if not functions.timeGT(packetTime,storedTime)	then return false,"too old" end
									if not functions.timeLE(packetTime) 			then return false,"too new" end
									if not inputtedCredentials						then return true,"no credentials"  end
									for key,value in pairs(inputtedCredentials) do
										if not inputtedCredentials[key]==storedCredentials[key] then return false,"wrong credentials" end
									end
									return true,"auth ok"
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
									if (input==nil) or (input=="")   then return false end
									if (stored==nil) or (stored=="") then return false end
									local inputTable={}
									local storedTable={}
									--convert text.type.permissions to table type :D
									repeat
										local pos=string.find(input,"%.")
										if pos then
											table.insert(inputTable,string.sub(input,1,pos-1))
											input=string.sub(input,pos+1)
										end
									until not pos
									table.insert(inputTable,input)
									
									repeat
										local pos=string.find(stored,"%.")
										if pos then
											table.insert(storedTable,string.sub(stored,1,pos-1))
											stored=string.sub(stored,pos+1)
										end
									until not pos
									table.insert(storedTable,stored)
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
											return false 
										end
									end
									return true
								end
							
	functions.formatPassword=	function(passphrase)
									if passphrase:upper()==passphrase then 
										return passphrase:lower(),passphrase
									end
									return passphrase:upper(),passphrase
								end
end

do--DATABASE
	function meta.database:new()--sets table as Satabase object 
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
		self.network={}
			self.network.nic={}
			self.network.group={}
			self.network.path={}
		self.log={}
			self.log.log={}
			self.log.network={}
				self.log.network.packet={}
				self.log.network.change={}
			self.log.data={}
		return o
	end
	
	function meta.database:availableType()--lists all available object types in the database
		return {"user.single","user.group","client.single","client.group","permission.state","permission.group","peripheral.single","peripheral.group","peripheral.definition","network.nic","network.group","network.path","log.log","log.network.packet","log.network.change","log.data"}
	end
	
	function meta.database:easyType(value)--adds aliases to types
			if value=="user" then return "user.single"
		elseif value=="client" then return "client.single"
		elseif value=="user group" then return "user.group"
		elseif value=="client group" then return "client.group"
		elseif value=="peripheral" then return "peripheral.single"
		elseif value=="peripheral group" then return "peripheral.group"
		elseif value=="peripheral definition" then return "peripheral.definition"
		elseif value=="nic" then return "network.nic"
		elseif value=="network" then return "network.group"
		elseif value=="path" then return "network.path"
		elseif value=="state" then return "permission.state"
		elseif value=="permission group" then return "permission.group"
		elseif value=="log" then return "log.log"
		elseif value=="log network" then return "log.network.packet"
		elseif value=="log network change" then return "log.network.change"
		elseif value=="log data" then return "log.data"
		else return value end
	end
	
	function meta.database:typeCheckNReturn(input)--checks string to match any type/alias-- returns type,(false/true)
		input=self:easyType(input)
		local check=false
		for key,value in ipairs(self:availableType()) do
			if value==input then check=true break end
		end
		return input,check
	end
	
	function meta.database:init(source)--boots up the database from raw data (also assigns metatables)
		source=source or data
		setmetatable(source,self)
		for key,value in ipairs(self:availableType()) do
			local dir=loadstring("return self."..value)()
			for key1,value1 in ipairs(dir) do
				loadstring("self."..value.."["..key1.."]=meta."..value..":init(self."..value.."["..key1.."])")()
			end
		end
		return source
	end
	
	function meta.database:newEntry(kind,name)--adds new entry
		local check
		kind,check = self:typeCheckNReturn(kind)
		if check then
			loadstring("table.insert(self."..kind..",meta."..kind..":new("..name.."))")()
		end
	end
	
	function meta.database:deleteEntry(kind,what)--removes entry
		local check
		kind,check = self:typeCheckNReturn(kind)
		if check then
			loadstring("self."..kind.."["..what.."]:delete()")()
		end
	end
	
	function meta.database:editEntry(kind,which,what,operation,input,position)--edit functions handler
		local check
		kind,check =self:typeCheckNReturn(kind)
		kind=loadstring("return self."..kind)()
		if check then
			if 		operation=="set" then kind[which][what]=input 
			elseif	operation=="add" then 
				table.insert(loadstring("return self."..kind.."["..which.."]."..what)(),input)
			elseif	operation=="remove" then
				table.remove(loadstring("return self."..kind.."["..which.."]."..what)(),input)
			elseif	operation=="purge" then
				loadstring("return self."..kind.."["..which.."]."..what)()={}
			elseif operation=="edit" then
				local where=
				loadstring("return self."..kind.."["..which.."]."..what)()[position]=input
			elseif operation=="clear" then
				loadstring("return self."..kind.."["..which.."]")()=nil
				loadstring("return self."..kind.."["..which.."]")()=loadstring("return meta."..kind..":new("..input..")")()
			end
		end
	end
	
	function meta.database:readEntry(kind,which,what)
		local check
		kind,check =self:typeCheckNReturn(kind)
		if check then
			local where
			if what then
				where=loadstring("return self."..kind.."["..which.."]."..what)()
			else
				where=loadstring("return self."..kind.."["..which.."]")()
			end
			return where
		end
		return nil
	end
	
	function meta.database:isDeleted(kind,which)
		local check
		kind,check =self:typeCheckNReturn(kind)
		if check then
			if loadstring("return self."..kind.."["..which.."]")()["name"] then return false else return true end
		end
	end
	
	function meta.database:query(kind_where,field,what,deepField)--search in desired field/type pairs in database--REWORK
		local check
		local dataType
		kind_where,check=self:typeCheckNReturn(kind_where)
		
		if check then
			dataType=loadstring("return type(meta."..kind_where..":new()."..field..")")
		else
			dataType=loadstring("return type(self."..kind_where..")")
		end
		kind_where=loadstring("return self."..kind_where)
		local entryIDs={}		
		
		if dataType=="table" then
			for key,value in ipairs(kind_where()) do
				for key1,value1 in ipairs(kind_where()[key][field]) do
					if kind_where()[key][field][key1]==what then table.insert(entryIDs,key) break end
				end
			end
		else
			for key,value in ipairs(kind_where()) do
				if kind_where()[key][field]==what then table.insert(entryIDs,key) end
			end
		end
		return entryIDs
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
		return functions.permCheck(entryValues)
	end
	
	local data=meta.database:new()--make DB instance
	
end

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
		local o = {name=name or functions.timestamp(),lastTimeStamp=functions.timestamp()}
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
	
	function meta.user.single:editName(name)
		self.name=name
	end
	
	function meta.user.single:edit(what,data)
		if (what=="description") or (what=="photo") then
			self[what]=data
		end
	end
	
	function meta.user.single:editPass(word,hashL,hashU)
		if word then self.password=word end
		if hashL and hashU then 
			self.passhashL=hashL
			self.passhashU=hashU
		end
	end
	
	function meta.user.single:editGroup(what,data1,data2,data3)
		if what=="purge" then
			self.group={}
		elseif what=="new" then
			table.insert(self.group,data1)
		elseif what=="delete" then
			table.remove(self.group,data1)
		elseif what=="edit" then
			self.group[data3][data1]=data2
		end
	end
	
	function meta.user.single:editPermissionSingle(what,data1,data2,data3)
		if what=="purge" then
			self.permission.single={}
		elseif what=="new" then
			table.insert(self.permissission.single,meta.permission.single:new(data1,data2))
		elseif what=="delete" then
			table.remove(self.permissission.single,data1)--delete() equivalent
		elseif what=="edit" then
			self.permission.single[data3]:edit(data1,data2)
		end
	end
	
	function meta.user.single:editPermissionGroup(what,data1,data2,data3)
		if what=="purge" then
			self.permission.group={}
		elseif what=="new" then
			table.insert(self.permissission.group,data1)
		elseif what=="delete" then
			table.remove(self.permissission.group,data1)
		elseif what=="edit" then
			self.permission.group[data3][data1]=data2
		end
	end
	
	function meta.user.single:editClientSingle(what,data1,data2,data3)
		if what=="purge" then
			self.client.single={}
		elseif what=="new" then
			table.insert(self.client.single,data1)
		elseif what=="delete" then
			table.remove(self.client.single,data1)
		elseif what=="edit" then
			self.client.single[data3][data1]=data2
		end
	end
	
	function meta.user.single:editClientGroup(what,data1,data2,data3)
		if what=="purge" then
			self.client.group={}
		elseif what=="new" then
			table.insert(self.client.group,data1)
		elseif what=="delete" then
			table.remove(self.client.group,data1)
		elseif what=="edit" then
			self.client.group[data3][data1]=data2
		end
	end
	
	function meta.user.single:editSuperuser(value)
		self.superuser=value
	end
end

do--USER GROUP
	function meta.user.group:new(name)
		local o = {name=name or functions.timestamp()}
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
		local o = {name=name or functions.timestamp(),lastTimeStamp=functions.timestamp()}
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
		local o = {name=name or functions.timestamp()}
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
		local o = {name=name or functions.timestamp()}
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
	--data.permission.state.default=meta.permission.state:new("default")
	
	function meta.permission.state:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.enabled=nil
		self.permission=nil--perm mod
		--self.hierarchy={}--hierarchy
		--self[1]=true
	end
end

do--PERMISSION GROUPS
	function meta.permission.group:new(name)
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.permission={}--perm mod
		--self.hierarchy={}--hierarchy
		return o
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
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.nic=nil--connected NIC instance
		self.definition=nil
		self.state={}--info about state of peripheral?
		--self.permission={} --linking via name/ID + name from definition
		return o
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
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.list={}--list of peripherals (from single definitions
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		return o
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
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.method={}--list of peripheral commands + permissions names {...,...}
		self.definition=nil --for faster linking
		--self.permission={} --linking via name/ID + name from definition
		return o
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

do--NETWORK NIC
	function meta.network.nic:new(name)
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.client=nil--what pc (nil for direct) connections ??
						--(the one sending peripheral ctrl msg)??
		self.network=nil--connected network instance
		self.location=nil--side/name
		self.type=nil--router/terminal/factory PC...Etc.
		self.passtrough=nil--is pass-trough capable?
		self.defnition=nil  --data.peripheral.definition.wired-modem  
		return o
	end
	
	function meta.network.nic:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.client=nil--what pc (nil for direct) connections ??
						--(the one sending peripheral ctrl msg)??
		self.network=nil--connected network instance
		self.location=nil--side/name
		self.type=nil--router/terminal/factory PC...Etc.
		self.passtrough=nil--is pass-trough capable?
		self.defnition=nil  --data.peripheral.definition.wired-modem  
		--self[1]=true
	end
end

do--NETWORK GROUP
	function meta.network.group:new(name)
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.path={}--table of paths
		self.type=nil--router/terminal/factory PC...Etc. (nil==direct)
		self.defnition=nil  --data.peripheral.definition.wired-modem  
		return o
	end
	
	function meta.network.group:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.path=nil--table of paths
		self.type=nil--router/terminal/factory PC...Etc. (nil==direct)
		self.defnition=nil  --data.peripheral.definition.wired-modem  
		--self[1]=true
	end
end

do--NETWORK PATH
	function meta.network.path:new(name)
		local o = {name=name or functions.timestamp()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.hop={}--table containing {nic}
		return o
	end
	
	function meta.network.path:delete()
		self.__index = nil
		self.name=nil
		self.description=nil
		self.hop=nil--table containing {nic}
		--self[1]=true
	end
end

do--LOG
	function meta.log.log:new(name)
		local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.content={}--table containing stuff
		return o
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
		local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.nicSource=nil
		self.nicDestination=nil
		self.content={}--table containing stuff
		return o
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
		local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.affectedNic=nil
		self.change=nil
		self.content={}--table containing stuff
		return o
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
		local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
		setmetatable(o, self)
		self.__index = self
		self.description=nil
		self.command=nil
		self.permissionTestResult=nil
		self.content={}--table containing stuff
		return o
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

--just for reference
function Account:deposit (v)
	if not self then return nil end--detekcja braku tablicy
	self.balance = self.balance + v
end

a = Account:new(nil,"demo")
a:show("after creation")