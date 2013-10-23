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
--table search
function getindex(tablename,data,case,row)--search for index --yes row not colum (rotated tables)
  --tablename - table name
  --data what to look for
  --0- SENSItiVe-used for all , 1-NOT case sensitive-strings ONLY, 2-NOT number sign sensitive-numbers ONLY
  --row specifies in which value of DIM2 of table to look for
  local target=1
  local size=#tablename
  if case==0 then
    while target<=size do
      if rDB[target][row]==data then
        return(target)
      else
        target=target+1
      end
    end
  elseif case==1 then
    data=string.lower(data)
    while target<=size do
      if string.lower(rDB[target][row])==data then
        return(target)
      else
        target=target+1
      end
    end
  
  elseif case==2 then
    data=math.abs(data)
    while target<=size do
      if math.abs(rDB[target][row])==data then
        return(target)
      else
        target=target+1
      end
    end
  end
  return false
end


--List of Fuctions for redstone interactions

--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(ID,name,descr,pcID,pcSIDE,method,functorID,functorSIDE,functorCOLOR,negated,state)
  
  --works like modIO for existing ID's
  
  -- 1-id - ID in database (on already used line it will overwrite)
  -- 2-name - short name of the node
  -- 3-descr - longer description of node
  -- 4-pcID - PC used as passtrough ,0 to disable
  -- 5-pcSIDE - of used pc passtrough
  -- 6-method - NEGATIVES ARE FOR INPUT
  --   method - 1basicbool 2basicanalog 3bundlebool 4bundleanalog 5bundleFF(memorized) 6bundlemulti
  --   method - 7rediobool 8redioanalog 9mfrcontrollerbool 10mfr....analog 11mfr....FF 12mrfmulti
  -- 7-functorID - id of finctional block
  -- 8-functorSIDE - functor side
  -- 9-functorCOLOR - functor color
  --10-negated - 1 if the output is negated - allows keeping track of it (will show negated output ie 
  --  -negated - (function returns 1 to check if it is on but the monitor shows 0)
  --11-state - desired state
  
  local oldlenght=#rDB
  if ID==nil then--auto find Free ID
    ID=1
    local i=1
    while i<=oldlenght do
      if ID<rDB[i][1] then ID=rDB[i][1] end
        i=i+1
    end
 
  end
  if negated==nil then negated=false end
  if state==nil then state=0 end
  local target=getindex(rDB,ID,0,1)--looks for ID
  if target then table.remove(rDB,target) else target=#rDB+1 end--not found? meh make new entry
  table.insert(rDB,target,{ID,name,descr,pcID,pcSIDE,method,functorID,functorSIDE,functorCOLOR,negated,state})--inserts new record
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(true) else return(false) end--returns true if overwritten something
end

function modIO(index,ID,name,descr,pcID,pcSIDE,method,functorID,functorSIDE,functorCOLOR,negated,state)-- nil to do not change
  if ID~=nil then            rDB[index][1]=ID end
  if name~=nil then          rDB[index][2]=name end
  if descr~=nil then         rDB[index][3]=descr end
  if pcID~=nil then          rDB[index][4]=pcID end
  if pcSIDE~=nil then        rDB[index][5]=pcSIDE end
  if method~=nil then        rDB[index][6]=method end
  if functorID~=nil then     rDB[index][7]=functorID end
  if functorSIDE~=nil then   rDB[index][8]=functorSIDE end
  if functorCOLOR~=nil then  rDB[index][9]=functorCOLOR end
  if negated~=nil then       rDB[index][10]=negated end
  save(rDB,"redstoneDB")
end

function rmIO(index)--removes entry from rDB
  table.remove(rDB,index)
end

function readIO(index)--reading IO node value ! real value
  if rDB[index][4]~=false then
    --direct
        if rDB[index][6]==1 then--Basic bool
          
    elseif rDB[index][6]==2 then--basic analog
      
    elseif rDB[index][6]==3 then--bundle bool
      
    elseif rDB[index][6]==4 then--bundle analog
      
    elseif rDB[index][6]==5 then--bundle ff
      
    elseif rDB[index][6]==6 then--bundle multi
      
    elseif rDB[index][6]==7 then--redio bool
      
    elseif rDB[index][6]==8 then--redio analog
      
    elseif rDB[index][6]==9 then--mfrc bool
      
    elseif rDB[index][6]==10 then--mfrc analog
      
    elseif rDB[index][6]==11 then--mfrc ff
      
    elseif rDB[index][6]==12 then--mfrc multi
      
    end
  else
    local pcID=math.abs(rDB[index][4])
    --indirect
        if rDB[index][6]==1 then--Basic bool
          
    elseif rDB[index][6]==2 then--basic analog
      
    elseif rDB[index][6]==3 then--bundle bool
      
    elseif rDB[index][6]==4 then--bundle analog
      
    elseif rDB[index][6]==5 then--bundle ff
      
    elseif rDB[index][6]==6 then--bundle multi
      
    elseif rDB[index][6]==7 then--redio bool
      
    elseif rDB[index][6]==8 then--redio analog
      
    elseif rDB[index][6]==9 then--mfrc bool
      
    elseif rDB[index][6]==10 then--mfrc analog
      
    elseif rDB[index][6]==11 then--mfrc ff
      
    elseif rDB[index][6]==12 then--mfrc multi
      
    end
  else
  end
end

function freadIO(index)--reading IO node value ! stored in files
  return(rDB[index][11])
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


