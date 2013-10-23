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

--List of Fuctions for redstone interactions

--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(ID,name,descr,method,trough,troughside,side,color,dir,remote,negated)
  --1-id - ID in database (on already used line it will overwrite)
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
  local target=1
  local oldlenght=#rDB
  while target<=#rDB+1 do
    if rDB[target][1]==(ID or nil) then
      break
    else
      target=target+1
    end
  end
  table.insert(rDB,target,{ID,name,descr,method,trough,troughside,side,color,dir,remote,negated,0})--inserts new blank entry on 1st free index storing there the ID
  save(rDB,"redstoneDB")
  if oldlenght==#rDB then return(true) else return(false) end--returns true if overwritten something
end

function rmIO(ID,name)--removing redstone IO node
  --ID specify whitch node to delete
  --name = 1 then use name of the node instead ID
  --name = 0 then use the file line from redstoneDB file

end

function readIO(ID)--reading IO node value ! real value
  
end

function freadIO(ID)--reading IO node value ! stored in files
  
end

function setIO(ID,value)--setting IO node value to persistence and real circuit
  
end

function initIO(ID)--sets IO from persistence,works like setIO but no data is used
  
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
  --rDBnew()--function to make new file contents
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
  --12-desired state
  
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


