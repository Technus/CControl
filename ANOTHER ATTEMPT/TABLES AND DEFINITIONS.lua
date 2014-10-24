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
	data.permission						={}--permission
	  data.permission.single			={}
	  data.permission.group				={}
	data.peripheral						={}--connect-able-s
	  data.peripheral.single			={}
	  data.peripheral.group				={}
	  data.peripheral.definition		={}--kind of method holder
	data.network						={}
	  data.network.nic					={}
	  data.network.networks				={}--aka NIc group
	  data.network.paths				={}--list of network connections
	data.log							={}
	  data.log.network					={}
		data.log.network.packets		={}
		data.log.network.changes		={}
	  data.log.data						={}
	    data.log.data.commands			={}
	    data.log.data.answers			={}
	
run										={}
	run.config							={}
	  run.config.safety					={}
	  run.config.network				={}
	  run.config.log					={}
	run.user							={}
	  run.user.single					={}
	  run.user.group					={}
	run.client							={}
	  run.client.single					={}
	  run.client.group					={}
	run.permission						={}
	  run.permission.single				={}
	  run.permission.group				={}
	run.peripheral						={}
	  run.peripheral.single				={}
	  run.peripheral.group				={}
	  run.peripheral.definition			={}
	run.network							={}
	  run.network.nic					={}
	  run.network.networks				={}
	  run.network.paths					={}
	run.log								={}
	  run.log.network					={}
		run.log.network.packets			={}
		run.log.network.changes			={}
	  run.log.data						={}
	    run.log.data.commands			={}
	    run.log.data.answers			={}


User = {}--meta

function User:new (o, name,password)
  o = o or {name=name}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Account:deposit (v)
  self.balance = self.balance + v
end

function Account:withdraw (v)
  if v > self.balance then error("insufficient funds on account "..self.name) end
  self.balance = self.balance - v
end

function Account:show (title)
  print(title or "", self.name, self.balance)
end

a = Account:new(nil,"demo")
a:show("after creation")
a:deposit(1000.00)
a:show("after deposit")
a:withdraw(100.00)
a:show("after withdraw")

-- this would raise an error
--[[
b={}
b [1]= Account:new(nil,"asd")
b[1]:withdraw(100.00)
b[1]:show("after withdraw")
--]]


