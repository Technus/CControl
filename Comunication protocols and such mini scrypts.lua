--[[com protocol

start
out - table - {"LI",auth table{}}--login

in - table - {"OK",testinteger}--loginok
in - table - {"KO"}--loginbad
login bad- lockdown for 10+ 30+ and so on...

if login ok can do ->

out - table - {">command tag<",variables table{...},auth table{},testinteger}


command table how to
auth table- meh....
commandtype
LI - login-no variables-will allow that pc to interact with mainframe
LO - logout-novariables-will disable that pc mainframe interactions
RR - rDBread-var1-ID -reads NODE
RF - rDBfread-var1-ID reads node from rDB FILE
RI - reads from NODE andupdates rDB
RW - rDBwrite-var1-ID-var2-value writes state to NODE
RV - rDBfwrite-var1-ID-var2-value writes to rDB FILE
RO - wtites to NODE and updates rDB
RN - rDBnew vartable ->(ID,name,descr,pcID,pcSIDE,method,functorID,functorSIDE,functorCOLOR,negated,state)
    (state is optional, negated is optional - both defaults to 0)
RM -rDB remove var1-ID
RG - recieves whole rDB

rr - redstone read-sent from mainframe to passtrough execution of RR,RI
rs - redstone set- sent from mainframe to passtrough execution of RW,RO
br - back confirmation from passtrough to mainframe for rr
bs - back confirmation from passtrough to mainframe for rs

UR -var1-name,var2-acceslevel-var3[rDB permission nodes],var4[sDB permission noedes],var[uDB permission nodes],reads user entry
UW -var1[2DIM table of changes],writes to user entry
UN -var1[table with required info] adds newuser
UM -var1[userID]removes user


--]]


--PASSWord encryption
--string password->encode..timestamp->encode->cheksum
--               ->string.upper(password)->encode..timestamp>encode->CHECKSUM

--auth table
--[1]userID [2]userNAME [3]checksum [4]CHECKSUM [5]timestamp


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
