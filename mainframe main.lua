
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
--adds ablity to interact with desired line in file

--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(ID,name,descr,method,trough,troughside,side,color,dir,remote,negated)
  --id - number of line in database (on already used line it will overwrite)
  --name - short name of the node
  --descr -longer description of node
  --method ,0-redIObool 1-redIOm(impulsed flipflop) 2-redIOanalog 3-MFRbool 4-MFRm 5-MFRanalog
  --trough if not = 0 -> send trough pc (value is pc id)  [if non advanced pc - use negative number? ]
  --troughside - side of the passtrough pc that is used 
  --MOVED memorized - (moved to method)
  --side - to select which side to use for MFRcontroller
  --color - to select which side to use for MFRcontroller
  --dir - direction 0 is output 1 is input
  --remote - allows mainframe to change the state if = 0
  --remote - if = 1 mainframe can only read (other pc is changing that state)
  --negated - 1 ifthe output is negated - allows keeping track of it (will show negated output ie 
  --negated - (function returns 1 to check ifit is on but the monitor shows 0)

end

function rmIO(ID,name)--removing redstone IO node
  --ID specify whitch node to delete
  --name = 1 then use name of the node instead ID
  --name = 0 then use the file line from redstoneDB file

end

function readIO()--reading IO node value
  --! not stored in files
end

function setIO()--setting IO node value
  --to persistence and real circuit
end

function initIO()--sets IO from persistence

end

--flags,variables and stuff


--init phase

if fs.exists("hashDB")==false then --checker for file
  local hDB = fs.open("hashDB","r")
  --hDBnew()--function to make new file contents
  hDB.close()
end
if fs.exists("redstoneDB")==false then --checker for file
  local rDB = fs.open("redstoneDB","r")
  --rDBnew()--function to make new file contents
  rDB.close()
end
if fs.exists("config")==false then --checker for file
  conf = fs.open("config","r")
  --confnew()--function to make new file contents
  conf.close()
end


