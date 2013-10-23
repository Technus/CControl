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
function addIO(ID,name,descr,method,trough,troughside,side,color,dir,remote,negated,state)
  
  --works like modIO for existing ID's
  
  -- 1-id - ID in database (on already used line it will overwrite)
  -- 2-name - short name of the node
  -- 3-descr -longer description of node
  -- 4-method ,0-redIObool 1-redIOm(impulsed flipflop) 2-redIOanalog 3-MFRbool 4-MFRm 5-MFRanalog
  -- 5-trough if not = 0 -> send trough pc (value is pc id)  [if non advanced pc - use negative number? ]
  -- 6-troughside - side of the passtrough pc that is used 
  -- 7-side - to select which side to use for MFRcontroller
  -- 8-color - to select which side to use for MFRcontroller
  -- 9-dir - direction 0 is output 1 is input
  --10-remote - allows mainframe to change the state if = 0
  --  -remote - if = 1 mainframe can only read (other pc is changing that state)
  --11-negated - 1 if the output is negated - allows keeping track of it (will show negated output ie 
  --  -negated - (function returns 1 to check if it is on but the monitor shows 0)
  
  --12-state - desired state is NOT necessary (defaults to 0)
  
  local oldlenght=#rDB
  if ID==nil then--auto find Free ID
    ID=1
    local i=1
    while i<=oldlenght do
      if ID<rDB[i][1] then ID=rDB[i][1] end
        i=i+1
    end
 
  end  --conditions
  if state==nil then state=0 end
  local target=getindex(rDB,ID,0,1)--looks for ID
  if target then table.remove(rDB,target) else target=#rDB+1 end--not found? meh make new entry
  table.insert(rDB,target,{ID,name,descr,method,trough,troughside,side,color,dir,remote,negated,state})--inserts new record
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(true) else return(false) end--returns true if overwritten something
end

function modIO(index,name,descr,method,trough,troughside,side,color,dir,remote,negated,ID)-- ID change optional
  rDB[index][2]=name
  rDB[index][3]=descr
  rDB[index][4]=method
  rDB[index][5]=trough
  rDB[index][6]=troughside
  rDB[index][7]=side
  rDB[index][8]=color
  rDB[index][9]=dir
  rDB[index][10]=remote
  rDB[index][11]=negated
  if ID~=nil then rDB[index][1]=ID end
end

function rmIO(index)--removes entry from rDB
  table.remove(rDB,index)
end

function readIO(index)--reading IO node value ! real value
  
end

function freadIO(index)--reading IO node value ! stored in files
  
end

function setIO(index,value)--setting IO node value to persistence and real circuit
  
end

function initIO(index)--sets IO from persistence,works like setIO but no data is used
  --freadIO->setIO
  setIO(data,idaddrname,freadIO(data,idaddrname))
end

--flags,variables and stuff


--init phase

if fs.exists("userDB") then --checker for file
  uDB=load("userDB")
else
  uDB = fs.open("userDB","r")
  uDB.close()
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
  
  --ID is always connected to one certain task - if you move a machine you MUST use the same id to not change every other pc
  
  
  --[[database memory map
  OLD--[INDEX of tables inside] rDB ->[INDEX is in every one] ID,name,descr,method,trough,troughside,side,color,dir,remote,negated,(actual/desired status)
  OLD--so rDB is array of 12 tables which store all RS interaction info
  DIM1-INDEX    DIM2-ID,name descr and stuff
  DIM2 deobfuscted
  --1-id - number of line in database (on already used line it will overwrite)
  --2-name - short name of the node
  --3-descr -longer description of node
  --4-method ,0-redIObool 1-redIOm(impulsed flipflop) 2-redIOanalog 3-MFRbool 4-MFRm 5-MFRanalog
  --5-trough if not = 0 -> send trough pc (value is pc id)  [if non advanced pc - use negative number? ]
  --6-troughside - side of the passtrough pc that is used 
  ---MOVED memorized - (moved to method)
  --7-side - to select which side to use for MFRcontroller
  --8-color - to select which side to use for MFRcontroller
  --9-dir - direction 0 is output 1 is input
  --10-remote - allows mainframe to change the state if = 0
  ---remote - if = 1 mainframe can only read (other pc is changing that state)
  --11-negated - 1 ifthe output is negated - allows keeping track of it (will show negated output ie 
  ---negated - (function returns 1 to check ifit is on but the monitor shows 0)
  --12-state - desired state - of the output !ignore negated when thinking about it it is connected to command not the functional state
  
  negated=1    computer(state)->functoinalblock(state)->negating torch(!negated state,so  not just state)->output(not State)
  negated=0    computer(state)->functoinalblock(state)->output(state)
  state - always stores things that should be before negating torch 
  negated - stores info if the signal is used as negated or not
  --]]
end
if fs.exists("config") then --checker for file
  conf=load("config")
else
  conf = fs.open("config","r")
  conf.close()
  --confnew()--function to make new file contents
  --[[database mem. map
  table storing all config variables,constants
  --]]
  conf[name]=0--EXAMPLE
  save(conf,"config")
end


