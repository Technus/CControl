do--Loading all the API's we are going to use here!
  os.loadAPI("AES")
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  os.loadAPI("SHA")
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.
  os.loadAPI("COM")
  --COM.timestamp() -- return timestamp
end

do--basic functions
function sint()--session integer gen.
  local size=#sDB
  if size>=conf[3] then return false end
  local int=1440*os.day()+os.time()+math.floor((os.clock()+10)*math.random())
  for i=size,1 do
    if int==sDB[i][5] then return sint() end
  end
  return(int) end
end

do--Fle functions
function save(data,name)--saves data to file
  local file = fs.open(name,"w")
  file.write(textutils.serialize(data))
  file.close()
end
function load(name)--loads data from file
  local file = fs.open(name,"r")
  local data = file.readAll()
  file.close()
  return textutils.unserialize(data)--returns contents
end
end

do--send/recieve
function send(pcID,data)
  return( rednet.send(pcID,textutils.serialize(data)) )
end
function recieve(t)
  local id,msg=rednet.recieve(t)
  return id,textutils.unserialize(msg)
end
end

do--table operations
--[[function rmentry(tablename,index)--removes entry from database
  local oldlenght=#tablename
  table.remove(tablename,index)
  if oldlenght==#tablename then return(false) else return(true) end
end
--use table.remove instead
]]
function getindex(tablename,data,case,row)--search for index --yes row not colum (rotated tables)
  --tablename - table name
  --data what to look for
  --0- SENSItiVe-used for all , 1-NOT case sensitive-strings ONLY, 2-NOT number sign sensitive-numbers ONLY
  --row specifies in which value of DIM2 of table to look for
  local size=#tablename
  if case==0 then
    for target=1, size do
      if tablename[target][row]==data then return(target) end
    end
  elseif case==1 then
    data=string.lower(data)
    for target=1, size do
      if string.lower(tablename[target][row])==data then return(target) end
    end
  elseif case==2 then
    data=math.abs(data)
    for target=1, size do
      if math.abs(tablename[target][row])==data then return(target) end
    end
  end
  return false
end
function getindexall(tablename,data,case,row)--search for index --yes row not colum (rotated tables)
  --tablename - table name
  --data what to look for
  --0- SENSItiVe-used for all , 1-NOT case sensitive-strings ONLY, 2-NOT number sign sensitive-numbers ONLY
  --row specifies in which value of DIM2 of table to look for
  local size=#tablename
  local list={}
  if case==0 then
    for target=1, size do
      if tablename[target][row]==data then table.insert(list,target) end
    end
  elseif case==1 then
    data=string.lower(data)
    for target=1, size do
      if string.lower(tablename[target][row])==data then table.insert(list,target) end
    end
  elseif case==2 then
    data=math.abs(data)
    for target=1, size do
      if math.abs(tablename[target][row])==data then table.insert(list,target) end
    end
  end
  return(if list[1]==nil then false else list end)
end
end

do--userDB functions
  --memory map
  --[[
  [ 1] - uID
  [ 2] - username
  [ 3] - descr
  [ 4] - rDB perms read (by ID)--if has can read
  [ 5] - rDB perms set (by ID)
  [ 6] - rDB perms modify node (by ID)--if has can change all but ID
  [ 7] - rgDB perms read (by ID)
  [ 8] - rgDB perms set (by ID)
  [ 9] - rgDB perms modify node (by ID)--cannot edit group contents just the nodes
  [10] - rDB/rgDB bool global perms set/read/add/remove/mod etc.--all perms
  [11] - dDB perms read (by ID)
  [12] - dDB perms set (by ID)
  [13] - dDB perms modify node (by ID)
  [14] - dgDB perms read (by ID)
  [15] - dgDB perms set (by ID)
  [16] - dgDB perms modify node (by ID)
  [17] - dDB/dgDB bool global perms set/read/add/remove/mod etc.
  [18] - drDB perms read (by ID)
  [19] - drDB perms setmode (by ID)
  [20] - drDB perms modify node (by ID)
  [21] - drDB bool global perms set/read/add/remove/mod etc.
  [22] - uDB/sDG bool perms can modify
  [23] - config bool global perms.
  [24] - others
  [25] - bool superuser 
  ]]
function addUser(uID,name,descr,rDBpermR,rDBpermS,rDBpermM,rgDBpermR,rgDBpermS,rgDBpermM,rDBrgDBperm,
                                dDBpermR,dDBpermS,dDBpermM,dgDBpermR,dgDBpermS,dgDBpermM,dDBdgDBperm,
                                drDBpermR,drDBpermS,drDBpermM,drDBperm,uDBsDBperm,configperm,other,superuser)
  local oldlenght=#uDB
  if uID==nil then--auto find Free ID
    uID=1
    for i=1, oldlenght do
      if uID<uDB[i][1] then uID=uDB[i][1] end
    end
    uID=uID+1
  end
  local target=getindex(uDB,uID,0,1)--looks for ID
  if target then table.remove(uDB,target) else target=#uDB+1 end--not found? meh make new entry,otherwise overwrite
  table.insert(uDB,target,{uID,name,descr,rDBpermR,rDBpermS,rDBpermM,rgDBpermR,rgDBpermS,rgDBpermM,rDBrgDBperm,
                                dDBpermR,dDBpermS,dDBpermM,dgDBpermR,dgDBpermS,dgDBpermM,dDBdgDBperm,
                                drDBpermR,drDBpermS,drDBpermM,drDBperm,uDBsDBperm,configperm,other,superuser})--inserts new record
  save(uDB,"userDB")
  if oldlenght==#uDB then return(true) else return(false) end--returns true if overwritten something
end
end
do--sessionDB functions
  --[[
  mem map:
  [1] - sID
  [2] - uID
  [3] - PC NAME
  [4] - PC ID
  [5] - session integer
  [6] - timestamp
  [7] - (timestamp+alivetime)
  ]]
end

do--List of Fuctions for redstoneDB+interactions

  
  --works like modIO for existing ID's
  
  -- 1-rID - ID in database (on already used line it will overwrite)
  -- 2-name - short name of the node
  -- 3-descr - longer description of node
  -- 4-pcNAME - name in network
  -- 5-pcID - stores unique pc ID
  -- 6-method - NEGATIVES ARE FOR INPUT
  --   method - 1basicbool 2basicanalog 3bundlebool 4bundleanalog 5bundleFF(memorized) 6bundlemulti
  --   method - 7rediobool 8redioanalog 9mfrcontrollerbool 10mfr....analog 11mfr....FF 12mrfmulti 13mfrmulti analog 14counterPC
  -- 7-functorNAME - id of functional block(side)
  -- 8-functorSIDE - functor side(side on theblock)
  -- 9-functorCOLOR - functor color(color in the side)
  -- 10-negated - 1 if the output is negated - allows keeping track of it (will show negated output ie 
  --  -negated - (function returns 1 to check if it is on but the monitor shows 0)
  --11 - corrector - node that refreshes the rednet wire trough non mfrcontroller
  --12-state - desired state
  
--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(rID,name,descr,pcNAME,pcID,method,functorNAME,functorSIDE,functorCOLOR,negated,corrector,state)
  local oldlenght=#rDB
  if rID==nil then--auto find Free ID
    rID=1
    for i=1, oldlenght do
      if rID<rDB[i][1] then rID=rDB[i][1] end
    end
    rID=rID+1
  end
  if negated==nil then negated=false end
  if state==nil then state=0 end
  local target=getindex(rDB,rID,0,1)--looks for ID
  if target then table.remove(rDB,target) else target=#rDB+1 end--not found? meh make new entry
  table.insert(rDB,target,{rID,name,descr,pcNAME,pcID,method,functorNAME,functorSIDE,functorCOLOR,negated,corrector,state})--inserts new record
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(true) else return(false) end--returns true if overwritten something
end
function modIO(index,rID,name,descr,pcNAME,pcID,method,functorNAME,functorSIDE,functorCOLOR,negated,corrector,state)-- nil to do not change
  if rID~=nil then           rDB[index][1]=rID end
  if name~=nil then          rDB[index][2]=name end
  --if descr~=nil then         rDB[index][3]=descr end
  --if pcNAME=nil then         rDB[index][4]=pcNAME end
  --if pcID~=nil then          rDB[index][5]=pcID end
  if method~=nil then        rDB[index][6]=method end
  if functorNAME~=nil then   rDB[index][7]=functorNAME end
  --if functorSIDE~=nil then   rDB[index][8]=functorSIDE end
  --if functorCOLOR~=nil then  rDB[index][9]=functorCOLOR end
  --if negated~=nil then       rDB[index][10]=negated end
  --if corrector~=nil then     rDB[index][11]=corrector end
  if state~=nil then         rDB[index][12]=state end
  save(rDB,"redstoneDB")
end

function readIO(index)--reading IO node value ! real circuit
  if rDB[index][4]~=false then
    --direct
    local m={
      [  1]=function() return(rs.getOutput(rDB[index][7])) end--basicbool
      [ -1]=function() return(rs.getInput( rDB[index][7])) end
      [  2]=function() return(rs.getAnalogOutput(rDB[index][7])) end--basic analog
      [ -2]=function() return(rs.getAnalogInput( rDb[index][7])) end
      [  3]=function() return(colors.test(rs.getBundledOutput(rDB[index][7]), rDB[index][9])) end--single bundled
      [ -3]=function() return(colors.test(rs.getBundledInput( rDB[index][7]), rDB[index][9])) end
      [  4]=function() return nil end--not implemented in CC
      [ -4]=function() return nil end
      [  5]=function() return(colors.test(rs.getBundledInput(rDB[index][7]), rDB[index][9]  )) end--bundle ff
      [ -5]=function() return(colors.test(rs.getBundledOutput( rDB[index][7]), rDB[index][9]*2)) end
      [  6]=function() return(rs.getBundledOutput(rDB[index][7])) end--multi
      [ -6]=function() return(rs.getBundledInput( rDB[index][7])) end
      [  7]=function() return(peripheral.call(rDB[index][7],"get"))end
      [ -7]=function() return(peripheral.call(rDB[index][7],"get"))end
      [  8]=function() return(peripheral.call(rDB[index][7],"analogGet"))end
      [ -8]=function() return(peripheral.call(rDB[index][7],"analogGet"))end
      [  9]=function() 
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(if peripheral.call(rDB[index][7],"getOutputSingle",rDB[index][8],rDB[index][9])>0 then true else false end) end
      [ -9]=function()
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(if peripheral.call(rDB[index][7], "getInputSingle",rDB[index][8],rDB[index][9])>0 then true else false end) end
      [ 10]=function()
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(peripheral.call(rDB[index][7],"getOutputSingle",rDB[index][8],rDB[index][9])) end
      [-10]=function() 
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(peripheral.call(rDB[index][7], "getInputSingle",rDB[index][8],rDB[index][9])) end
      [ 11]=function()
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(if peripheral.call(rDB[index][7],"getInputSingle",rDB[index][8],rDB[index][9]  )>0 then true else false end) end
      [-11]=function()
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(if peripheral.call(rDB[index][7], "getOutputSingle",rDB[index][8],rDB[index][9]*2)>0 then true else false end) end
      [ 12]=function() local enum=0
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            local temp=peripheral.call(rDB[index][7],"getOutputAll",rDB[index][8])
            for i=0, 15 do
              if temp[i]>0 then enum=enum+2^i end
            end
            return(enum) end
      [-12]=function() local enum=0
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            local temp=peripheral.call(rDB[index][7],"getInputAll",rDB[index][8])
            for i=0, 15 do
              if temp[i]>0 then enum=enum+2^i end
            end
            return(enum) end
      [ 13]=function() local 
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(peripheral.call(rDB[index][7],"getOutputAll",rDB[index][8])) end
      [-13]=function()
            peripheral.call(rDB[index][7],"setColorMode",2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return(peripheral.call(rDB[index][7], "getInputAll",rDB[index][8])) end
      [ 14]=function() return nil end--mainframe does not count things :O
      [-14]=function() return nil end
      }
      return( m[ rDB[index][6] ]() )
  else
    --indirect
    local pc=peripheral.wrap(rDB[index][4])
    pc.turnOn()
    if pc.getID()==rDB[index][5] then 
      send(rDB[index][5],{"rr",{nil,nil,nil,nil,nil,rDB[index][6],rDB[index][7],rDB[index][8],rDB[index][9]}})--sends required data
      local id,msg=recieve(1)
      if id==rDB[index][5] and msg[1]=="br" then 
        return(msg[2])
      else return(nil)
      end
    else return(nil) 
    end
  end
return(nil)
end
function freadIO(index)--reading IO node value ! stored in files
  return(rDB[index][12])
end

function setIO(index,value)--setting IO node value ! real circuit
  if rDB[index][4]~=false then
    --direct
    local m={
      [  1]=function() rs.setOutput(rDB[index][7],value) return true end--basicbool
      [  2]=function() rs.setAnalogOutput(rDB[index][7],value) return true end--basic analog
      [  3]=function() 
            if value==true then
              rs.setBundledOutput(rDB[index][7],colors.combine( rs.getBundledOutput(rDB[index][7]),rDB[index][9] ))
            else
              rs.setBundledOutput(rDB[index][7],colors.subtract( rs.getBundledOutput(rDB[index][7]),rDB[index][9] ))
            end
            return true
            end
      [  4]=function() return nil end--not implemented in CC
      [  5]=function() 
            if value==(colors.test(rs.getBundledInput(rDB[index][7]), rDB[index][9]  )) then
            else
            rs.setBundledOutput(rDB[index][7],colors.combine( rs.getBundledOutput(rDB[index][7]),rDB[index][9]*2 ))
            sleep(conf[1])
            rs.setBundledOutput(rDB[index][7],colors.subtract( rs.getBundledOutput(rDB[index][7]),rDB[index][9]*2 ))
            end--bundle ff
            return true end
      [  6]=function() rs.setBundledOutput(rDB[index][7],value) return true end--multi
      [  7]=function() peripheral.call(rDB[index][7],"set",value) return true end
      [  8]=function() peripheral.call(rDB[index][7],"set",value) return true end
      [  9]=function() local p=peripheral.wrap(rDB[index][7])
            p.setColorMode(2)
            if value then value=15 else value=0 end
            p.setOutputSingle(rDB[index][8],rDB[index][9],value)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return true end
      [ 10]=function() local p=peripheral.wrap(rDB[index][7])
            p.setColorMode(2)
            p.setOutputSingle(rDB[index][8],rDB[index][9],value)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return true end
      [ 11]=function() local p=peripheral.wrap(rDB[index][7])
            p.setColorMode(2)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            if value==p.getInputSingle(rDB[index][8]), rDB[index][9]  )) then
            else
            local temp=getindex(rDB,rDB[index][11],0,1)
            p.setOutputSingle(rDB[index][8],rDB[index][9]*2,15)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            sleep(conf[1])
            p.setOutputSingle(rDB[index][8],rDB[index][9]*2, 0)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            end
            return true end
      [ 12]=function() local p=peripheral.wrap(rDB[index][7])
            p.setColorMode(2)
            local temp={}
            for i=0,15 do
              if bit.blogic_rshift(value,i)%2==1 then temp[i+1]=15 end
            end
            p.setOutputAll(rDB[index][8],temp)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return true end
      [ 13]=function() local local p=peripheral.wrap(rDB[index][7])
            p.setColorMode(2)
            p.setOutputAll(rDB[index][8],value)
            --
            local temp=getindex(rDB,rDB[index][11],0,1)
              setIO(temp,true)
              sleep(conf[2])
              setIO(temp,false)
            --
            return true end
      [ 14]=function() return nil end--mainframe does not count things :O
      }
      return( m[ rDB[index][6] ]() )
  else
    --indirect
    local pc=peripheral.wrap(rDB[index][4])
    pc.turnOn()
    if pc.getID()==rDB[index][5] then 
      send(rDB[index][5],{"rs",{nil,nil,nil,nil,nil,rDB[index][6],rDB[index][7],rDB[index][8],rDB[index][9]}})--sends required data
      local id,msg=recieve(1)
      if id==rDB[index][5] and msg[1]=="bs" then 
        return(true)
      else return(nil)
      end
    else return(nil) 
    end
  end
return(nil)
end
function fsetIO(index,value)--writing IO node value ! stored in files
  if value~=nil then rDB[index][12]=value end
end

function initIO(index)--sets IO from persistence,works like setIO but no data is used
  setIO(index,freadIO(index))
end
end
do--redstone groupsDB functions
--[[
mem map:
[1] - redstone group ID
[2] - name
[3] - descr
[4] - table of contens rDB ID's
]]
end
do--detectorDB functions
  --[[
  mem map:
  [1] - dID
  [2] - name
  [2] - descr
  [3] - .................................................................................
  ]]
end
do--detectorgroupsDB functions
end

do--detectormapDB functions
end


--flags,variables and stuff


do--init phase
if fs.exists("userDB") then --checker for file
  uDB=load("userDB")
else
  uDB = fs.open("userDB","r")
  uDB.close()
  uDB={}
  save(uDB,"userDB")
  --hDBnew()--function to make new file contents
  --[[database memory map
  [INDEX of tables inside] uDB ->[INDEX is in every one] user,lhash,UHASH,accesslevel,superuser,mainframeaccess,table of extra privilages to certain redstone I/O's
  --]]
end
if fs.exists("sessionDB") then --checker for file
  sDB=load("sessionDB")
else
  sDB = fs.open("sessionDB","r")
  sDB.close()
  sDB={}
  save(sDB,"sessionDB")
end
if fs.exists("detectorDB") then --checker for file
  dDB=load("detectorDB")
else
  dDB = fs.open("detectorDB","r")
  dDB.close()
  dDB={}
  save(dDB,"detectorDB")
end
if fs.exists("detectorGroupsDB") then --checker for file
  dgDB=load("detectorGroupsDB")
else
  dgDB = fs.open("detectorGroupsDB","r")
  dgDB.close()
  dgDB={}
  sgve(dgDB,"detectorGroupsDB")
end
if fs.exists("detectorRadarDB") then --checker for file
  drDB=load("detectorRadarDB")
else
  drDB = fs.open("detectorRadarDB","r")
  drDB.close()
  drDB={}
  save(drDB,"detectorRadarDB")
end
if fs.exists("redstoneDB") then --checker for file
  rDB=load("redstoneDB")
else
  rDB = fs.open("redstoneDB","r")
  rDB.close()
  rDB={}
  save(rDB,"redstoneDB")
  --ID is always connected to one certain task - if you move a machine you MUST use the same id to not change every other pc
  
  
  --[[database memory map
  OLD--[INDEX of tables inside] rDB ->[INDEX is in every one] ID,name,descr,method,trough,troughside,side,color,dir,remote,negated,(actual/desired status)
  OLD--so rDB is array of 12 tables which store all RS interaction info
  DIM1-INDEX    DIM2-ID,name descr and stuff
  DIM2 deobfuscted is in ADDIO function
  --]]
end
if fs.exists("redstoneGroupsDB") then --checker for file
  rgDB=load("redstoneGroupsDB")
else
  rgDB = fs.open("redstoneGroupsDB","r")
  rgDB.close()
  rgDB={}
  save(rgDB,"redstoneGroupsDB")
end
if fs.exists("config") then --checker for file
  conf=load("config")
else
  conf = fs.open("config","r")
  conf.close()
  conf={[1]=1,[2]=0.15,[3]=32}
  --[1] ff toggle impulse lenght
  --[2] corrector impulse lenght
  --[3] max connections
  --confnew()--function to make new file contents
  --[[database mem. map
  table storing all config variables,constants
  --]]
  --conf[name]=0--EXAMPLE
  save(conf,"config")
end
end

