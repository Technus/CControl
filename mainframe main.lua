--Loading all the API's we are going to use here!
os.loadAPI("enc")
--Fle functions
function save(table,name)--saves table to file
  local file = fs.open(name,"w")
  file.write(textutils.serialize(table))
  file.close()
end

function load(name)--loads table from file
  local file = fs.open(name,"r")
  local data = file.readAll()
  file.close()
  return textutils.unserialize(data)--returns contents
end
--sendrecieve
function send()
end

function recieve()
end


--table search
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


--List of Fuctions for redstone interactions

--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(rID,name,descr,pcID,method,functorID,functorSIDE,functorCOLOR,negated,state)
  
  --works like modIO for existing ID's
  
  -- 1-rID - ID in database (on already used line it will overwrite)
  -- 2-name - short name of the node
  -- 3-descr - longer description of node
  -- 4-pcID - PC used as passtrough ,0 to disable
  -- 5-method - NEGATIVES ARE FOR INPUT
  --   method - 1basicbool 2basicanalog 3bundlebool 4bundleanalog 5bundleFF(memorized) 6bundlemulti
  --   method - 7rediobool 8redioanalog 9mfrcontrollerbool 10mfr....analog 11mfr....FF 12mrfmulti
  -- 6-functorID - id of functional block(side)
  -- 7-functorSIDE - functor side(side on theblock)
  -- 8-functorCOLOR - functor color(color in the side)
  -- 9-negated - 1 if the output is negated - allows keeping track of it (will show negated output ie 
  --  -negated - (function returns 1 to check if it is on but the monitor shows 0)
  --10-state - desired state
  
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
  table.insert(rDB,target,{rID,name,descr,pcID,method,functorID,functorSIDE,functorCOLOR,negated,state})--inserts new record
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(true) else return(false) end--returns true if overwritten something
end

function modIO(index,rID,name,descr,pcID,method,functorID,functorSIDE,functorCOLOR,negated,state)-- nil to do not change
  if rID~=nil then           rDB[index][1]=rID end
  if name~=nil then          rDB[index][2]=name end
  if descr~=nil then         rDB[index][3]=descr end
  if pcID~=nil then          rDB[index][4]=pcID end
  if method~=nil then        rDB[index][5]=method end
  if functorID~=nil then     rDB[index][6]=functorID end
  if functorSIDE~=nil then   rDB[index][7]=functorSIDE end
  if functorCOLOR~=nil then  rDB[index][8]=functorCOLOR end
  if negated~=nil then       rDB[index][9]=negated end
  save(rDB,"redstoneDB")
end

function rmIO(index)--removes entry from rDB
  local oldlenght=#rDB
  table.remove(rDB,index)
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(false) else return(true) end
end

function readIO(index)--reading IO node value ! real value
  if rDB[index][4]~=false then
    --direct
    local m={
      [  1]=function() return(rs.getOutput(rDB[index][6])) end--basicbool
      [ -1]=function() return(rs.getInput( rDB[index][6])) end
      [  2]=function() return(rs.getAnalogOutput(rDB[index][6])) end--basic analog
      [ -2]=function() return(rs.getAnalogInput( rDb[index][6])) end
      [  3]=function() return(colors.test(rs.getBundledOutput(rDB[index][6]), rDB[index][8])) end--single bundled
      [ -3]=function() return(colors.test(rs.getBundledInput( rDB[index][6]), rDB[index][8])) end
      [  4]=function() return nil end--not implemented in CC
      [ -4]=function() return nil end
      [  5]=function() return(colors.test(rs.getBundledOutput(rDB[index][6]), rDB[index][8]  )) end--bundle ff
      [ -5]=function() return(colors.test(rs.getBundledInput( rDB[index][6]), rDB[index][8]*2)) end
      [  6]=function() return(rs.getBundledOutput(rDB[index][6])) end--multi
      [ -6]=function() return(rs.getBundledInput( rDB[index][6])) end
      [  7]=function() return(peripheral.call(rDB[index][6],"get"))end
      [ -7]=function() return(peripheral.call(rDB[index][6],"get"))end
      [  8]=function() return(peripheral.call(rDB[index][6],"analogGet"))end
      [ -8]=function() return(peripheral.call(rDB[index][6],"analogGet"))end
      [  9]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(if p.getOutputSingle(rDB[index][7],rDB[index][8])>0 then true else false end) end
      [ -9]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(if p.getInputSingle( rDB[index][7],rDB[index][8])>0 then true else false end) end
      [ 10]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(p.getOutputSingle(rDB[index][7],rDB[index][8])) end
      [-10]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(p.getInputSingle( rDB[index][7],rDB[index][8])) end
      [ 11]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(if p.getOutputSingle(rDB[index][7],rDB[index][8]  )>0 then true else false end) end
      [-11]=function() local p=peripheral.wrap(rDB[index][6])
            p.setColorMode(2)
            return(if p.getInputSingle( rDB[index][7],rDB[index][8]*2)>0 then true else false end) end
      [ 12]=function() local enum=0 local temp=peripheral.call(rDB[index][6],"getOutputAll")
            for i=0, 15 do
              if temp[i]>0 then enum=enum+2^i end
            end
            return(enum) end
      [-12]=function() local enum=0 local temp=peripheral.call(rDB[index][6],"getInputAll")
            for i=0, 15 do
              if temp[i]>0 then enum=enum+2^i end
            end
            return(enum) end
      [ 13]=function() local p=peripheral.wrap(rDB[index][6])
            return(p.getOutputAll(rDB[index][7])) end
      [-13]=function() local p=peripheral.wrap(rDB[index][6])
            return(p.getInputAll( rDB[index][7])) end
      }
      return( m[ rDB[index][5] ]() )
  else
    --indirect
    pc=peripheral.wrap(rDB[index][4])
      pc.
  end
end

function freadIO(index)--reading IO node value ! stored in files
  return(rDB[index][10])
end
function fwriteIO(index,value)--writing IO node value ! stored in files
  if value~=nil then rDB[index][10]=value end
end

function setIO(index,value)--setting IO node value to persistence and real circuit
  
end

function initIO(index)--sets IO from persistence,works like setIO but no data is used
  setIO(index,freadIO(index))
end

--flags,variables and stuff


--init phase

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
if fs.exists("config") then --checker for file
  conf=load("config")
else
  conf = fs.open("config","r")
  conf.close()
  conf={}
  --confnew()--function to make new file contents
  --[[database mem. map
  table storing all config variables,constants
  --]]
  conf[name]=0--EXAMPLE
  save(conf,"config")
end


