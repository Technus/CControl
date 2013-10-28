--TYPE
--L - login
--U - user
--P - pc
--R - redstone
--O - redstone group
--D - detector
--I - detector group
--M - detector map
--C - config


--ACTIONS
--  DB - cannot overlap
--C - check (ex. just check if login went ok, functions that are required to retrurn T/F/nil)

--R - read (you must specify ID, returns one entry)
--Q - query DB (searches in DB, returns whole entries)
--G - (global) send whole DB 

--N - (new) creates entry(does not require ID)
--M - modify entry (selection by ID)
--T - (trash)removes entry
--E - ERASES DATABASE :O (superuser only)
-- uDB
--D - degrade user ( 0 perms)
--  rDB
--I - (in)reads state from rDB
--O - (out)writes to rDB state
--P - (phisical)gets the signal from physical node
--S - sets physical node
--V - (value) reads the value from table node and writes it to table
--W - writes rDB and Node state
-- drDB
--S - scan area gives players table
--P - scan for player 
--O - others (all - players)
--A - all entites
--N - neutral
--F - friendly
--T - (targets) aggresive mobs
--  dDB
--R - read data
--S - set data ?
--

--BIG LETTERS - com between mainframe-user pc (not doing anything but mainframe interaction)
--small letters - coms that are sent from mainframe to peripheralPC and back - final execution/data transfer



--template to copy paste
if not COM then os.loadAPI("COM")end
comrecieve = {
LI={"Recieved Login command", --[[placeholder for function]]},
LO={"Recieved Logout command",--[[placeholder for function]]},
}

comsend = {
LI={"Sending Login Command",  --[[placeholder for function]]},
LO={"Sending Logout Command", --[[placeholder for function]]},
}
