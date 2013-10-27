
    
  function sint()--session integer gen.
    local size=#sDB
    if size>=conf[3] then return false end
    local int=1440*os.day()+os.time()+math.floor((os.clock()+100)*math.random())
    for i=size,1 do
      if int==sDB[i][5] then return sint() end
    end
    return(int) 
  end
  
  
  
  
do--sessionDB functions
  --[[
  mem map:
  [1] - sID
  [2] - uID
  [3] - user name
  [4] - user passHASH
  [5] - PC NAME
  [6] - PC ID
  [7] - session integer
  [8] - timestamp
  [9] - (timestamp+alivetime)"timeout"
  ]]
  function newS(uID,username,userpasshash,pcNAME,pcID,timeextended)
    local size=#sDB
    local temp=0
    local t=COM.timestamp()
    for i=1,size do
    sDB[i][1]>=temp then temp=temp+sDB[i][1] end
    end
    temp=temp+1
    table.insert(sDB,{temp,uID,username,userpasshash,pcNAME,pcID,sint(),t,t+timeextended)
    return({#sDB,temp,t,t+timeextended)
  end
end




if fs.exists("sessionDB") then --checker for file
  sDB=load("sessionDB")
else
  sDB = fs.open("sessionDB","r")
  sDB.close()
  sDB={}
  save(sDB,"sessionDB")
end
