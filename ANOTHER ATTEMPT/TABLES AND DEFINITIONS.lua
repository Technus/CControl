data									={}
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
	  meta.log.network					={}
		meta.log.network.packets		={}
		meta.log.network.changes		={}
	  meta.log.meta						={}
	    meta.log.meta.commands			={}
	    meta.log.meta.answers			={}

functions								={}
	functions.timestamp=function() return 1000*(24*os.day()+os.time() end--as Integer

	
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
  self.hierarchy={}--hierarchy
  self.superuser=false
  return o
end

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

--function meta.permission.default:add(name)
--  local o = {name=name}
--  setmetatable(o, self)
--  self.__index = self
--  self.level=0--what can do
--  return o
--end

function meta.permission.state:new(name)
  local o = {name=name}
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

function meta.permission.group:new(name)
  local o = {name=name}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.permission={}--perm mod
    self.permission.single={}
    self.permission.group={}
--self.hierarchy={}--hierarchy
  return o
end

function meta.peripheral.single:new(name)
  local o = {name=name}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.location=nil--connected NIC instance
  self.definition=nil
--self.state={}--info about state of peripheral?
--self.permission={} --linking via name/ID + name from definition
  return o
end

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

function meta.network.nic:new(name)
  local o = {name=name}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.client=nil
  self.route=nil--side/name
  self.type="wired-modem"--router/terminal/factory PC...Etc.
  self.defnition=nil  --data.peripheral.definition.wired-modem  
--self.permission={} --linking via name/ID + name from definition
  return o
end

function meta.network.group:new(name)
  local o = {name=name}
  setmetatable(o, self)
  self.__index = self
  self.description=nil
  self.client=nil
  self.route=nil--side/name
  self.type="wired-modem"--router/terminal/factory PC...Etc.
  self.defnition=nil  --data.peripheral.definition.wired-modem  
--self.permission={} --linking via name/ID + name from definition
  return o
end

--just for reference
function Account:deposit (v)
	if not self then return nil end--detekcja braku tablicy
  self.balance = self.balance + v
end

a = Account:new(nil,"demo")
a:show("after creation")