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

--requires implementation of
if comrecieve[VAR] then comrecieve[VAR](args) end

--IS EXECUTED AFTER AUTH PROCESS

--template to copy paste
if not COM then os.loadAPI("COM")enddo--commands definitions
  
comrecieve = {
  
LC={"Login Check",true},

UR={"User Read",--[[placeholder for function]]},
UQ={"User Query",--[[placeholder for function]]},
UG={"User Global",--[[placeholder for function]]},
UN={"User New",--[[placeholder for function]]},
UM={"User Modify",--[[placeholder for function]]},
UT={"User Trash",--[[placeholder for function]]},
UE={"User Erase",--[[placeholder for function]]},
UD={"User Degrade",--[[placeholder for function]]},

PR={"Pc Read",--[[placeholder for function]]},
PQ={"Pc Query",--[[placeholder for function]]},
PG={"Pc Global",--[[placeholder for function]]},
PN={"Pc New",--[[placeholder for function]]},
PM={"Pc Modify",--[[placeholder for function]]},
PT={"Pc Trash",--[[placeholder for function]]},
PE={"Pc Erase",--[[placeholder for function]]},

RR={"Redstone Read",--[[placeholder for function]]},
RQ={"Redstone Query",--[[placeholder for function]]},
RG={"Redstone Global",--[[placeholder for function]]},
RN={"Redstone New",--[[placeholder for function]]},
RM={"Redstone Modify",--[[placeholder for function]]},
RT={"Redstone Trash",--[[placeholder for function]]},
RE={"Redstone Erase",--[[placeholder for function]]},
RI={"Redstone In from DB",--[[placeholder for function]]},
RO={"Redstone Out to DB",--[[placeholder for function]]},
RP={"Redstone Phisical node read",--[[placeholder for function]]},
RS={"Redstone Set physical node",--[[placeholder for function]]},
RV={"Redstone Value read from node and set in DB",--[[placeholder for function]]},
RW={"Redstone Write to DB and node",--[[placeholder for function]]},

OR={"Redstone Group Read",--[[placeholder for function]]},
OQ={"Redstone Group Query",--[[placeholder for function]]},
OG={"Redstone Group Global",--[[placeholder for function]]},
ON={"Redstone Group New",--[[placeholder for function]]},
OM={"Redstone Group Modify",--[[placeholder for function]]},
OT={"Redstone Group Trash",--[[placeholder for function]]},
OE={"Redstone Group Erase",--[[placeholder for function]]},

DR={"Detector Read",--[[placeholder for function]]},
DQ={"Detector Query",--[[placeholder for function]]},
DG={"Detector Global",--[[placeholder for function]]},
DN={"Detector New",--[[placeholder for function]]},
DM={"Detector Modify",--[[placeholder for function]]},
DT={"Detector Trash",--[[placeholder for function]]},
DE={"Detector Erase",--[[placeholder for function]]},
DC={"Detector Command",--[[placeholder for function]]},

IR={"Detector Group Read",--[[placeholder for function]]},
IQ={"Detector Group Query",--[[placeholder for function]]},
IG={"Detector Group Global",--[[placeholder for function]]},
IN={"Detector Group New",--[[placeholder for function]]},
IM={"Detector Group Modify",--[[placeholder for function]]},
IT={"Detector Group Trash",--[[placeholder for function]]},
IE={"Detector Group Erase",--[[placeholder for function]]},

MR={"Map Read",--[[placeholder for function]]},
MQ={"Map Query",--[[placeholder for function]]},
MG={"Map Global",--[[placeholder for function]]},
MN={"Map New",--[[placeholder for function]]},
MM={"Map Modify",--[[placeholder for function]]},
MT={"Map Trash",--[[placeholder for function]]},
ME={"Map Erase",--[[placeholder for function]]},
MS={"Map Scan for players",--[[placeholder for function]]},
MP={"Map Player",--[[placeholder for function]]},
MO={"Map Others",--[[placeholder for function]]},
MA={"Map All",--[[placeholder for function]]},
MF={"Map Friendly",--[[placeholder for function]]},
MT={"Map Targets",--[[placeholder for function]]},

CR={"Config Read",--[[placeholder for function]]},
CQ={"Config Query",--[[placeholder for function]]},
CG={"Config Global",--[[placeholder for function]]},
CN={"Config New",--[[placeholder for function]]},
CM={"Config Modify",--[[placeholder for function]]},
CT={"Config Trash",--[[placeholder for function]]},
CE={"Config Erase",--[[placeholder for function]]},

lc={"Login Check", --[[placeholder for function]]},

rp={"Redstone Phisical read", --[[placeholder for function]]},

dc={"Redstone Phisical read", --[[placeholder for function]]},

}

comsend={
rp={"Redstone Phisical read", --[[placeholder for function]]},
dc={"Detector read", --[[placeholder for function]]},
}
end
