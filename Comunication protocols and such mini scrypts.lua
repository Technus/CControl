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
