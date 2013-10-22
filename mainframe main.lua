--List of Fuctions for redstone interactions

--adds ON-OFF redstone (analog) and togglable by impulse redstone flipflop, I/O's to database
function addIO(name,descr,method,side,color,dir,remote,negated)
  --REMOVED id - number of line in database
  --name - short name of the node
  --descr -longer description of node
  --method ,0-redIObool 1-redIOm(impulsed flipflop) 2-redIOanalog 3-MFRbool 4-MFRm 5-MFRanalog
  --MOVED memorized - (moved to method)
  --side - to select which side to use for MFRcontroller
  --color - to select which side to use for MFRcontroller
  --dir - direction 0 is output 1 is input
  --remote - allows mainframe to change the state if = 0
  --remote - if = 1 mainframe can only read (other pc is changing that state)
  --negated - 1 ifthe output is negated - allows keeping track of it (will show negated output ie 
  --(function returns 1 to check ifit is on but the monitor shows 0)
  
  local DB = fs.open("redstoneDB","rw")
end
--removing redstone IO node
function rmIO(ID,name)
  --ID specify whitch node to delete
  --name = 1 then use name of the node instead ID
  --name = 0 then use the file line from redstoneDB file
end

--flags,variables andstuff


--init phase
if fs.exists("hashDB")==false then --checker for file
  local hDB = fs.open("hashDB","r")
  hDBnew()--function to make new file contents
  hDB.close()
end
if fs.exists("redstoneDB")==false then --checker for file
  local rDB = fs.open("redstoneDB","r")
  rDBnew()--function to make new file contents
  rDB.close()
end
if fs.exists("config")==false then --checker for file
  conf = fs.open("config","r")
  confnew()--function to make new file contents
  conf.close()
end


