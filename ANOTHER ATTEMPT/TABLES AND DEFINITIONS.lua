local data								={}
	data.config							={}
	  data.config.safety				={}
	  data.config.network				={}
	  data.config.log					={}
	data.user							={}--'life' being
	  data.user.single					={}
	  data.user.group					={}
	data.client							={}--Pc
	  data.client.single				={}
	  data.client.group					={}
	data.permission						={}--permission definitions near functions !
	  data.permission.default			={}--no auth permissions 
	  data.permission.state				={}--state based permission
	    data.permission.state.default	={}--state based permission -- to be implemented
	  data.permission.group				={}--grouping of perms
	data.peripheral						={}--connect-able-s
	  data.peripheral.single			={}
	  data.peripheral.group				={}
	  data.peripheral.definition		={}--kind of method holder
	data.network						={}
	  data.network.nic					={}
	  data.network.networks				={}--aka NIC "groups"
	  data.network.paths				={}--list of network connections
	data.log							={}
	  data.log.network					={}
		data.log.network.packets		={}
		data.log.network.changes		={}
	  data.log.data						={}
	    data.log.data.commands			={}
	    data.log.data.answers			={}

meta									={}
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
	  meta.permission.default			={}--no auth permissions 
	  meta.permission.state				={}--state based permission
	  meta.permission.group				={}--grouping of perms
	meta.peripheral						={}--connect-able-s
	  meta.peripheral.single			={}
	  meta.peripheral.group				={}
	  meta.peripheral.definition		={}--kind of method holder
	meta.network						={}--only for networking purposes
	  meta.network.nic					={}--the end of line
	  meta.network.group				={}--aka NIC "groups"
	  meta.network.paths				={}--list of network connections
--	  meta.network.packet				={}
	meta.log							={}
	  meta.log.log						={}--general purpose
	  meta.log.network					={}
		meta.log.network.packet			={}
		meta.log.network.change			={}
	  meta.log.data						={}--db changes

do--load apis
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
end

functions								={}
	functions.timestamp=function() return 1000*(24*os.day()+os.time() end--as Integer
	functions.tick=function() return (os.time() * 1000 + 18000)%24000 end
	
	functions.encryptData=function(data,key,iv)--encrypts anything gives a string
						  return(AES.encrypt_str(textutils.serialize({"Tec :3",data}), key, iv)) end
						  
	functions.decryptData=function(data,key,iv)--decrypts anything gives the data back
						  local temp=textutils.unserialize(AES.decrypt_str(data, key, iv))
						  if not pcall(temp[1]~="Tec :3") then return nil end
						  if not temp[1]~="Tec :3" then return nil end
						  if temp[1]~="Tec :3" then return nil else return temp[2] end end
						  
	functions.openModems=function()
						  sides =rs.getSides() 
						  for i = 1,#sides do
						  	if "modem" = peripheral.getType(sides[i]) then rednet.open(i) end
						  end end
	
	
--USER
function meta.user.single:new(name)
  local o = {name=name or functions.timestamp(),lastTimeStamp=functions.timestamp()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.photo=nil
  self.password_u=nil--not recommended
  self.password_m=nil--not recommended
  self.passhashUu=nil--upper
  self.passhashLu=nil--lower
  self.passhashUm=nil--upper
  self.passhashLm=nil--lower
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
--USER GROUP
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
--CLIENT
function meta.client.single:new(name)
  local o = {name=name or functions.timestamp(),lastTimeStamp=functions.timestamp()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.password_c=nil--not recommended
  self.password_m=nil--not recommended
  self.passhashUc=nil--upper
  self.passhashLc=nil--lower
  self.passhashUm=nil--upper
  self.passhashLm=nil--lower
  self.group={}--client groups inherited
  self.permission={}--what can do
    self.permission.single={}
    self.permission.group={}
  self.hierarchy={}--hierarchy
  self.networkNic={}--connected NICs
  return o
end
--CLIENT GROUP
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
==PERMISSION DEFAULT
--function meta.permission.default:add(name)
--  local o = {name=name}
--  setmetatable(o, self)
--  self.__index = self
--  self.level=0--what can do
--  return o
--end
--"PERMISSION" STATES
function meta.permission.state:new(name)
  local o = {name=name or functions.timestamp()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.permission={}--perm mod
    self.permission.single={}
    self.permission.group={}
--self.hierarchy={}--hierarchy
  return o
end
--data.permission.state.default=meta.permission.state:new("default")
--PERMISSION GROUPS
function meta.permission.group:new(name)
  local o = {name=name or functions.timestamp()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.permission={}--perm mod
    self.permission.single={}
    self.permission.group={}
--self.hierarchy={}--hierarchy
  return o
end
--PERIPHERAL
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
--PERIPHERAL GROUP
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
--PERIPHERAL DEFINITION
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
--NETWORK NIC
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
--NETWORK GROUP
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
--NETWORK PATH
function meta.network.path:new(name)
  local o = {name=name or functions.timestamp()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.hop={}--table containing {nic}
  return o
end
--LOG
function meta.log.log:new(name)
  local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.content={}--table containing stuff
  return o
end
--LOG network packet
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
--LOG network changes
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
--LOG database commands/changes
function meta.log.data:new(name)
  local o = {name=name or functions.timestamp(),day=os.day(),time=os.time(),tick=functions.tick()}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.command=nil
  self.permissionTestResult=nil
  self.result={}--table containing stuff
  return o
end

--just for reference
function Account:deposit (v)
	if not self then return nil end--detekcja braku tablicy
  self.balance = self.balance + v
end

a = Account:new(nil,"demo")
a:show("after creation")