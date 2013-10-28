--added default login root/root

do--Loading all the API's we are going to use here!
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.
  if not COM then os.loadAPI("COM")end
  --COM.timestamp() -- return timestamp
  --COM.authTmake() -- makes auth table
  --COM.authTcheck() -- compares 2 auth tables (and timestamp)
  --COM.send() -- sends data
  --COM.recieve() -- recieves data
end

do--commands definitions
comtable = {
  
  --to/from PC
  
LC={nil,"Login Check", --[[placeholder for function]]},
UR={nil,"User Read",--[[placeholder for function]]},
UQ={nil,"User Query",--[[placeholder for function]]},
UG={nil,"User Global",--[[placeholder for function]]},
UN={nil,"User New",--[[placeholder for function]]},
UM={nil,"User Modify",--[[placeholder for function]]},
UT={nil,"User Trash",--[[placeholder for function]]},
UE={nil,"User Erase",--[[placeholder for function]]},
UD={nil,"User Degrade",--[[placeholder for function]]},

PR={nil,"Pc Read",--[[placeholder for function]]},
PQ={nil,"Pc Query",--[[placeholder for function]]},
PG={nil,"Pc Global",--[[placeholder for function]]},
PN={nil,"Pc New",--[[placeholder for function]]},
PM={nil,"Pc Modify",--[[placeholder for function]]},
PT={nil,"Pc Trash",--[[placeholder for function]]},
PE={nil,"Pc Erase",--[[placeholder for function]]},

RR={nil,"Redstone Read",--[[placeholder for function]]},
RQ={nil,"Redstone Query",--[[placeholder for function]]},
RG={nil,"Redstone Global",--[[placeholder for function]]},
RN={nil,"Redstone New",--[[placeholder for function]]},
RM={nil,"Redstone Modify",--[[placeholder for function]]},
RT={nil,"Redstone Trash",--[[placeholder for function]]},
RE={nil,"Redstone Erase",--[[placeholder for function]]},
RI={nil,"Redstone In from DB",--[[placeholder for function]]},
RO={nil,"Redstone Out to DB",--[[placeholder for function]]},
RP={nil,"Redstone Phisical node read",--[[placeholder for function]]},
RS={nil,"Redstone Set physical node",--[[placeholder for function]]},
RV={nil,"Redstone Value read from node and set in DB",--[[placeholder for function]]},
RW={nil,"Redstone Write to DB and node",--[[placeholder for function]]},

OR={nil,"Redstone Group Read",--[[placeholder for function]]},
OQ={nil,"Redstone Group Query",--[[placeholder for function]]},
OG={nil,"Redstone Group Global",--[[placeholder for function]]},
ON={nil,"Redstone Group New",--[[placeholder for function]]},
OM={nil,"Redstone Group Modify",--[[placeholder for function]]},
OT={nil,"Redstone Group Trash",--[[placeholder for function]]},
OE={nil,"Redstone Group Erase",--[[placeholder for function]]},

DR={nil,"Detector Read",--[[placeholder for function]]},
DQ={nil,"Detector Query",--[[placeholder for function]]},
DG={nil,"Detector Global",--[[placeholder for function]]},
DN={nil,"Detector New",--[[placeholder for function]]},
DM={nil,"Detector Modify",--[[placeholder for function]]},
DT={nil,"Detector Trash",--[[placeholder for function]]},
DE={nil,"Detector Erase",--[[placeholder for function]]},
DR={nil,"Detector Read",--[[placeholder for function]]},
DS={nil,"Detector Set",--[[placeholder for function]]},

IR={nil,"Detector Group Read",--[[placeholder for function]]},
IQ={nil,"Detector Group Query",--[[placeholder for function]]},
IG={nil,"Detector Group Global",--[[placeholder for function]]},
IN={nil,"Detector Group New",--[[placeholder for function]]},
IM={nil,"Detector Group Modify",--[[placeholder for function]]},
IT={nil,"Detector Group Trash",--[[placeholder for function]]},
IE={nil,"Detector Group Erase",--[[placeholder for function]]},

MR={nil,"Map Read",--[[placeholder for function]]},
MQ={nil,"Map Query",--[[placeholder for function]]},
MG={nil,"Map Global",--[[placeholder for function]]},
MN={nil,"Map New",--[[placeholder for function]]},
MM={nil,"Map Modify",--[[placeholder for function]]},
MT={nil,"Map Trash",--[[placeholder for function]]},
ME={nil,"Map Erase",--[[placeholder for function]]},
MS={nil,"Map Scan for players",--[[placeholder for function]]},
MP={nil,"Map Player",--[[placeholder for function]]},
MO={nil,"Map Others",--[[placeholder for function]]},
MA={nil,"Map All",--[[placeholder for function]]},
MF={nil,"Map Friendly",--[[placeholder for function]]},
MT={nil,"Map Targets",--[[placeholder for function]]},

CR={nil,"Config Read",--[[placeholder for function]]},
CQ={nil,"Config Query",--[[placeholder for function]]},
CG={nil,"Config Global",--[[placeholder for function]]},
CN={nil,"Config New",--[[placeholder for function]]},
CM={nil,"Config Modify",--[[placeholder for function]]},
CT={nil,"Config Trash",--[[placeholder for function]]},
CE={nil,"Config Erase",--[[placeholder for function]]},

    --to peripheral PC
}
end

do--basic functions
  function authCheck(auth)--check if auth correct
    if auth[1] then
      if not(pcall(tonumber,auth[1])[1]) then return(false) end 
      local index=getindex(uDB,tonumber(auth[1]),0,1)
    elseif auth[2] then
      local index=getindex(uDB,auth[2],0,2)
    else
      return(false)
    end
    if not index then return(false) end
    if conf[5]>=auth[4] or auth[4]>COM.timestamp() then return(false) 
    else conf[5]=COM.timestamp()
    end
    return(COM.authTcheck(auth,COM.authTmake(rDB[index][1],rDB[index][2],rDB[index][26],auth[4]),conf[4]))
  end
  
  
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


do--table operations
  --[[
  function rmentry(tablename,index)--removes entry from database
    local oldlenght=#tablename
    table.remove(tablename,index)
    if oldlenght==#tablename then return(false) else return(true) end
  end
  --use table.remove(...) instead
  ]]
  function copytable(clone,source)
  clone=textutils.unserialize(textutils.serialize(source))
  end
  
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
  [18] - mDB perms read (by ID)
  [19] - mDB perms setmode (by ID)
  [20] - mDB perms modify node (by ID)
  [21] - mDB bool global perms set/read/add/remove/mod etc.
  [22] - uDB/sDG bool perms can modify
  [23] - config bool global perms.
  [24] - others
  [25] - bool superuser 
  [26] - PASSWORD HASH 
  ]]
  function addU(uID,name,descr,rDBpermR,rDBpermS,rDBpermM,rgDBpermR,rgDBpermS,rgDBpermM,rDBrgDBperm,
                                  dDBpermR,dDBpermS,dDBpermM,dgDBpermR,dgDBpermS,dgDBpermM,dDBdgDBperm,
                                  mDBpermR,mDBpermS,mDBpermM,mDBperm,uDBsDBperm,configperm,other,superuser,phash)
    local size=#uDB
    if uID==nil then--auto find Free ID
      uID=1
      for i=1, size do
        if uID<uDB[i][1] then uID=uDB[i][1] end
      end
      uID=uID+1
    end
    local target=getindex(uDB,uID,0,1)--looks for ID
    if target then table.remove(uDB,target) else target=#uDB+1 end--not found? meh make new entry,otherwise overwrite
    table.insert(uDB,target,{uID,name,descr,rDBpermR,rDBpermS,rDBpermM,rgDBpermR,rgDBpermS,rgDBpermM,rDBrgDBperm,
                                  dDBpermR,dDBpermS,dDBpermM,dgDBpermR,dgDBpermS,dgDBpermM,dDBdgDBperm,
                                  mDBpermR,mDBpermS,mDBpermM,mDBperm,uDBsDBperm,configperm,other,superuser,phash})--inserts new record
    save(uDB,"userDB")
    if size==#uDB then return(true) else return(false) end--returns true if overwritten something
  end
end

do--computerDB functions
  --[[
  [1]-cDB (cID)
  [2]-pc name
  [3]-pc descr
  [4]-pc network name
  [5]-pcID
  [6]-pc auth HASH pair
  ]]
  function addPC(cID,name,descr,netname,pcid,hash)
  
  end
  
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
    local size=#rDB
    if rID==nil then--auto find Free ID
      rID=1
      for i=1, size do
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
    if size==#rDB then return(true) else return(false) end--returns true if overwritten something
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
        COM.send(rDB[index][5],{"rr",{nil,nil,nil,nil,nil,rDB[index][6],rDB[index][7],rDB[index][8],rDB[index][9]}})--sends required data
        local id,msg=COM.recieve(1)
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
        COM.send(rDB[index][5],{"rs",{nil,nil,nil,nil,nil,rDB[index][6],rDB[index][7],rDB[index][8],rDB[index][9]}})--sends required data
        local id,msg=COM.recieve(1)
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
[4] - elements table (of rDB ID's)
]]
  function addIOg(rgID,name,descr,elements)
    local size=#rgDB
    if rgID==nil then--auto find Free ID
      rgID=1
      for i=1, size do
        if rgID<rgDB[i][1] then rgID=rgDB[i][1] end
      end
      rgID=rgID+1
    end
    local target=getindex(rgDB,rgID,0,1)--looks for ID
    if target then table.remove(rgDB,target) else target=#rgDB+1 end--not found? meh make new entry
    table.insert(rgDB,target,{rgID,name,descr,elements})--inserts new record
    save(rgDB,"redstoneGroupsDB")
    if size==#rgDB then return(true) else return(false) end--returns true if overwritten something
  end
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
--[[
mem map:
[1] - detector group ID
[2] - name
[3] - descr
[4] - elements table of rDB ID's
]]
  
  function addDg(dgID,name,descr,elements)
    local size=#dgDB
    if dgID==nil then--auto find Free ID
      dgID=1
      for i=1, size do
        if dgID<dgDB[i][1] then dgID=dgDB[i][1] end
      end
      dgID=dgID+1
    end
    local target=getindex(dgDB,dgID,0,1)--looks for ID
    if target then table.remove(dgDB,target) else target=#dgDB+1 end--not found? meh make new entry
    table.insert(dgDB,target,{dgID,name,descr,elements})--inserts new record
    save(dgDB,"detectorGroupsDB")
    if size==#dgDB then return(true) else return(false) end--returns true if overwritten something
  end
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
  uDB={{1,"root","change the pass",[25]=true,[26]={"42CF4F3F9451F66E13A62D3E14D3C72C4C02A79AF924E5F671303851EDCE40A9","D366194F6AF8D3BF7EA3C040F6EF7462BEB9B122779D702F2DB9E93274EF90A8"}},}
  save(uDB,"userDB")
  --hDBnew()--function to make new file contents
  --[[database memory map
  [INDEX of tables inside] uDB ->[INDEX is in every one] user,lhash,UHASH,accesslevel,superuser,mainframeaccess,table of extra privilages to certain redstone I/O's
  --]]
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
if fs.exists("mapDB") then --checker for file
  mDB=load("mapDB")
else
  mDB = fs.open("mapDB","r")
  mDB.close()
  mDB={}
  save(mDB,"mapDB")
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
if fs.exists("computersDB") then --checker for file
  cDB=load("computersDB")
else
  cDB = fs.open("computersDB","r")
  cDB.close()
  cDB={}
  save(cDB,"computersDB")
end
if fs.exists("config") then --checker for file
  conf=load("config")
else
  conf = fs.open("config","r")
  conf.close()
  conf={[1]=1,[2]=0.15,[3]=32,[4]=2,[5]=COM.timestamp()}
  --[1] ff toggle impulse lenght
  --[2] corrector impulse lenght
  --[3] max connections
  --[4] max time diff. from curren time to timestamp in recieved packet
  --[5] stores timestamp of last recv. msg.
  --confnew()--function to make new file contents
  --[[database mem. map
  table storing all config variables,constants
  --]]
  --conf[name]=0--EXAMPLE
  save(conf,"config")
end
end

