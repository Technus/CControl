--cmd type,what,value,where


do--data ,meta organization
--local data								={}
--	data.config							={}
--	  data.config.safety				={}
--	  data.config.network				={}
--	  data.config.log					={}
--	data.user							={}--'life' being
--	  data.user.single					={}
--	  data.user.group					={}
--	data.client							={}--Pc
--	  data.client.single				={}
--	  data.client.group					={}
--	data.permission						={}--permission definitions near functions !
--	  data.permission.state				={}--state based permission
--	    data.permission.state.default	={}--state based permission -- to be implemented
--	  data.permission.group				={}--grouping of perms
--	data.peripheral						={}--connect-able-s
--	  data.peripheral.single			={}
--	  data.peripheral.group				={}
--	  data.peripheral.definition		={}--kind of method holder
--	data.network						={}
--	  data.network.nic					={}
--	  data.network.group				={}--aka NIC "groups"
--	  data.network.path					={}--list of network connections
--	data.log							={}
--	  data.log.network					={}
--		data.log.network.packets		={}
--		data.log.network.changes		={}
--	  data.log.data						={}
--	    data.log.data.commands			={}
--	    data.log.data.answers			={}

instance								={}
	instance.network					={}
	  instance.network.packet			={}

		
meta									={}
	meta.database						={}--main database handler
	meta.config							={}
	  meta.config.safety				={}
	  meta.config.network				={}
	  meta.config.log					={}
	meta.user							={}--'life' being, authed commands
	  meta.user.single					={}
	  meta.user.group					={}
	meta.client							={}--Pc commands authed by a pc
	  meta.client.single				={}
	  meta.client.group					={}
	meta.permission						={}--permission
	  meta.permission.operations		={}--HERE I SHALL DEFINE METHODS TO OPERATE ON PERMISSIONS
	  meta.permission.state				={}--state based permission
	  meta.permission.group				={}--grouping of perms
	meta.peripheral						={}--connect-able-s
	  meta.peripheral.single			={}
	  meta.peripheral.group				={}
	  meta.peripheral.definition		={}--kind of method holder
	meta.network						={}--only for networking purposes
	  meta.network.nic					={}--the end of line
	  meta.network.group				={}--aka NIC "groups"
	  meta.network.path					={}--list of network connections
--	  meta.network.packet				={}
	meta.log							={}
	  meta.log.log						={}--general purpose
	  meta.log.network					={}
		meta.log.network.packet			={}
		meta.log.network.change			={}
	  meta.log.data						={}--db changes
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
									return ("Day "..os.day().." Hour "..math.floor(timeValue).." Precision "..((timeValue-math.floor(timeValue))*1000).."/1000 Of Hour") 
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
									if not pcall(temp[1]) then return nil end
									if not temp[1]~="Tec :3" then return nil end
									if temp[1]~="Tec :3" then return nil else return temp[2] end 
								end

	functions.openModems=		function()
									for i = 1,#rs.getSides() do
										if "modem" == peripheral.getType(rs.getSides()[i]) then rednet.open(rs.getSides()[i]) end
									end
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
									if not functions.timeLE(packetTime) 				then return false,"too new" end
									if not inputtedCredentials						then return true,"no credentials"  end
									for key,value in pairs(inputtedCredentials) do
										if not inputtedCredentials[key]==storedCredentials[key] then return false,"wrong credentials" end
									end
									return true,"auth ok"
								end

	functions.permCheck=		function(values)--must be greater than 0
									local store=0--default permission value
									for key,value in pairs(values) do
										if 		values[key]==-math.huge then return false,(-math.huge),"node blocked"
										elseif 	values[key]== math.huge then store=math.huge
										else store=store+tonumber(values[key]) 
										end
									end
									if store>0 then return true,store,"granted" end
									return false,store,"denied"
								end

	functions.permCmp=			function(input,stored)--interpreter of permissions
								end
							
	functions.formatPassword=	function(passphrase)
									if passphrase:upper()==passphrase then 
										return passphrase:lower(),passphrase
									end
									return passphrase:upper(),passphrase
								end
end

do--DATABASE
function meta.database:new()
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
	self.log.network={}
	  self.log.network.packets={}
	  self.log.network.changes={}
	self.log.data={}
	  self.log.data.commands={}
	  self.log.data.answers={}
  return o
end

function meta.database:query(what,column,dir)
  dir=loadstring("return self."..dir)
  local entryIDs={}
  for key,value in ipairs(dir()) do
    if dir()[key][column]==what then table.insert(entryIDs,key) end
  end
  return entryIDs
end

function meta.database:testPermission(who,client_user,what)
  if client_user~="user" and client_user~="client" then return functions.permCheck({}) end
  local entryValues={}
  local entryGroups={}
  local groups={}
  --client single perms
  for key,value in ipairs(self[client_user]["single"][who]["permission"]["single"]) do
    if functions.permCmp(what,self[client_user]["single"][who]["permission"]["single"][key]["node"]) then 
	  table.insert(entryValues,self[client_user]["single"][who]["permission"]["single"][key]["value"])
	end
  end
  --gaining permissions from perm groups
  for key,value in ipairs(self[client_user]["single"][who]["permission"]["group"]) do
    for key1,value1 in ipairs(self.permission.group[value]["permission"]) do
	  if functions.permCmp(what,self.permission.group[value]["permission"][key1]["node"]) then
	  table.insert(entryValues,self.permission.group[value]["permission"][key1]["value"])
	  end
	end
  end	
  
  --client group inherited 
  for key,value in ipairs(self[client_user]["single"][who]["group"]["permission"]
	local add=true
	for key1,value1 in ipairs(groups) do
	  if groups[key1]==value then add=false break end
	end
	if add then table.insert(groups,value) end
  end
  --client group inherited from group and from other groups an so on
  for key,value in ipairs(groups) do
  --add entries9
	for key1,value1 in ipairs(self[client_user]["group"][value]["group"]) do--look in the already listed groups
	  local add=true
	  for key2,value2 in ipairs(groups) do--look for repeats
	    if groups[key2]==value1 then add=false break end
	  end
	  if add then table.insert(groups,value1) end
	end
  end
  --from inheritances
  for key,value in ipairs(groups) do
	for key1,value1 in ipairs(self[client_user]["group"][value]["permission"]["single"]) do--gaining permissions from groups
      if functions.permCmp(what,self[client_user]["group"][value]["permission"]["single"][key1]["node"]) then 
	    table.insert(entryValues,self[client_user]["group"][value]["permission"]["single"][key1]["value"])
	  end
    end
    for key1,value1 in ipairs(self[client_user]["group"][value]["permission"]["group"]) do--gaining perm groups from groups
      for key2,value2 in ipairs(self.permission.group[value1]["permission"]) do
	    if functions.permCmp(what,self.permission.group[value1]["permission"][key2]["node"]) then
	    table.insert(entryValues,self.permission.group[value1]["permission"][key2]["value"])
	    end
	  end
    end	  
  end
  return functions.permCheck(entryValues)
end

local data=meta.database:new()--make DB instance

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
  --self.__index = self
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
  self.gone=true
end

function meta.user.single:editName(name)
  self.name=name
end

function meta.user.single:edit(what,data)
  if what=="description" or what=="photo" then
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
  --self.__index = self
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
--  self.gone=true
--end

function meta.permission.operations:edit(what,data)
  if what=="value" or what=="node" then
    self[what]=data
  end
end
end

do--PERMISSION DEFAULT
--function meta.permission.default:add(name)
--  local o = {name=name}
--  setmetatable(o, self)
--  self.__index = self
--  self.level=0--what can do
--  return o
--end
end

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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=true
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
  self.gone=nil
end
end

--just for reference
function Account:deposit (v)
	if not self then return nil end--detekcja braku tablicy
  self.balance = self.balance + v
end

a = Account:new(nil,"demo")
a:show("after creation")