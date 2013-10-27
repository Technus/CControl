--[[com protocol

start
out - table - {"LI",auth table{}}--login

in - table - {"OK",testinteger}--loginok
in - table - {"KO"}--loginbad
login bad- lockdown for 10+ 30+ and so on...

if login ok can do ->

out - table - {">command tag<",variables table{...},auth table{},testinteger}

in - table - {"OK"}
or
if not ok then
in - table -{"KO",table{info about thingies}}


command table how to
auth table- meh....
commandtype
LI - login-no variables-will allow that pc to interact with mainframe
LO - logout-no variables-will disable that pc mainframe interactions
LC - login check 
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

-- Comunication and reply table, 1 is messages and 2 is actions
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns tab[1..8]

function timestamp() return(1440*os.day()+os.time()) end--gives time stamp

--
local function XXnum(XX)
    return (bit.blshift(string.byte(XX,1),8)+string.byte(XX,2))
end

function hashpass(pass)--input strings
    if #pass<9 then return false end
    local pass=textutils.serialize(pass)
    local PASS=string.upper(pass)
          pass=SHA.digestStr(pass)
          PASS=SHA.digestStr(PASS)
    for i=1,8 do
        pass[8+i]=PASS[i]
    end
    return(pass)--table of 16 ints [1..16]
end

function authTmake(passhash,stamptime)--table of 16 ints ,timestamp int
    local temp=SHA.digestStr(textutils.serialize(passhash)..textutils.serialize(stamptime))
    temp[9]=stamptime
    return(textutils.serialize(temp))--returns serialized hash[1..8]timestamp[9] - just one string for comparison
end

function LI(UID, user, pass, channel)
  --Tries to login into the server
  local passTE, TimeS = EncPassTime(pass)
  local authT = {UID, user, passTE, TimeS}
  local msgS = textutils.serialize({"LI",authT})
  rednet.send(sendC,msgS)
  --Recives and proccesses the messsage?
end

function LO(SID , channel)
  --Tries to logout of the server
  local passTE, TimeS = EncPassTime(pass)
  local authT = {UID, user, passTE, TimeS}
  local msgS = textutils.serialize({"LO",authT})
  modem.transmit(sendC,receiveC,msgS)
  --Recives and proccesses the messsage?
end

function encrypt(pass,data)
  --Encrypts the message with the time stamp and password
  local passTE, TimeS = EncPassTime(pass)
  local passT = {passTE, TimeS}
  local passS = textutils.serialize(passT)
  local dataE = enc.encript(data, passT)
  return dataE
end

function rednetOn()
  sides =rs.getSides() 
  for i = 1,#sides do
    if "modem" = peripheral.getType(sides[i]) then
    rednet.open(i)
    end
  end
end
