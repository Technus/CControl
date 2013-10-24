--[[com protocol

start

send encryption data

table - auth(name,passchecksum,PASSCHECKSUM,timestamp)

incoming - Boolean value 1-auth succesfull 0-ERROR,wrong   OK(0/1)

login OK - cansend the command 

table - command(authTABLE,commandtype,var1,var2,var3,.... and so on)
in return Bool confirmation 1-OK 0-OFF
login bad- lockdown for 10+ 30+ and so on...


command table how to



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
