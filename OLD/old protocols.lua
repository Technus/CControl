    
  function sint()--session integer gen.
    local size=#sDB
    if size>=conf[3] then return false end
    local int=1440*os.day()+os.time()+math.floor((os.clock()+100)*math.random())
    for i=size,1 do
      if int==sDB[i][5] then return sint() end
    end
    return(int) 
  end
  
  
  
  
do--sessionDB functions
  --[[
  mem map:
  [1] - sID
  [2] - uID
  [3] - user name
  [4] - user passHASH
  [5] - PC NAME
  [6] - PC ID
  [7] - session integer
  [8] - timestamp
  [9] - (timestamp+alivetime)"timeout"
  ]]
  function newS(uID,username,userpasshash,pcNAME,pcID,timeextended)
    local size=#sDB
    local temp=0
    local t=COM.timestamp()
    for i=1,size do
    sDB[i][1]>=temp then temp=temp+sDB[i][1] end
    end
    temp=temp+1
    table.insert(sDB,{temp,uID,username,userpasshash,pcNAME,pcID,sint(),t,t+timeextended)
    return({#sDB,temp,t,t+timeextended)
  end
end




if fs.exists("sessionDB") then --checker for file
  sDB=load("sessionDB")
else
  sDB = fs.open("sessionDB","r")
  sDB.close()
  sDB={}
  save(sDB,"sessionDB")
end



do--old com protocol
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
--[1]userID [2]userNAME [3]PAssHAsh [5]timestamp

-- Comunication and reply table, 1 is messages and 2 is actions
end
