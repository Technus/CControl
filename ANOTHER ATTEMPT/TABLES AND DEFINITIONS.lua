do--data ,meta organization
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
end

do--load apis
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
end

do--functions
functions								={}
	functions.timestamp=function() return 1000*(24*os.day()+os.time()) end--as Integer
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
end	

do--USER
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

function meta.user.single:delete()
  self.__index = nil
  self.name=nil
  self.lastTimeStamp=nil
  self.description=nil
  self.photo=nil
  self.password_u=nil--not recommended
  self.password_m=nil--not recommended
  self.passhashUu=nil--upper
  self.passhashLu=nil--lower
  self.passhashUm=nil--upper
  self.passhashLm=nil--lower
  self.group=nil--user groups inherited
  self.permission=nil--what can do
  self.client=nil--what clients can b used
  self.hierarchy=nil--hierarchy
  self.superuser=nil
  self.gone=true
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

function meta.client.single:delete()
  self.__index = nil
  self.name=nil
  self.lastTimeStamp=nil
  self.description=nil
  self.password_c=nil--not recommended
  self.password_m=nil--not recommended
  self.passhashUc=nil--upper
  self.passhashLc=nil--lower
  self.passhashUm=nil--upper
  self.passhashLm=nil--lower
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
    self.permission.single={}
    self.permission.group={}
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