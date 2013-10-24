--[[com protocol

start
out - table - command[auth(name,PassCheckSum,PASSCHECKSUM,timestamp),commandtype,varTABLE]

in - table - return(error codesTABLE,varTABLE)
login bad- lockdown for 10+ 30+ and so on...


command table how to
auth table-meh....
commandtype
LI - login-no variables-will allow that pc to interact with mainframe
LO - logout-novariables-will disable that pc to interact with mainframe
RR - rDBread-var1-ID -reads NODE
RF - rDBfread-var1-ID reads from rDB file
RW - rDBwrite-var1-ID-var2-value writes state to cennected NODE
RF - rDBfwrite-var1-ID-var2-value writes to rDBfile
RN - rDBnew vartable ->(ID,name,descr,pcID,pcSIDE,method,functorID,functorSIDE,functorCOLOR,negated,state)
    (state is optional, negated is optional - both defaults to 0)
RM -rDB remove var1-ID
RG - recieves whole rDB

--]]




--Sending end
--Midway

-- Turn on the modems!
sides = rs.getSides()
for i = 1,sides# do
if "modem" = peripheral.getType(sides[i]) then
rednet.open(i)
end
end


--Reciving end
