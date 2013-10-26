--Encription API for our passwords and stuff!

local function zfill(N)
  N=string.format("%X",N)
  Zs=""
  if #N==1 then
    Zs="0"
  end
  return Zs..N
end

local function serializeImpl(t)
  local sType = type(t)
  if sType == "table" then
    local lstcnt=0
    for k,v in pairs(t) do
      lstcnt = lstcnt + 1
    end
    local result = "{"
    local aset=1
    for k,v in pairs(t) do
      if k==aset then
        result = result..serializeImpl(v)..","
        aset=aset+1
      else
        result = result..("["..serializeImpl(k).."]="..serializeImpl(v)..",")
      end
    end
    result = result.."}"
    return result
  elseif sType == "string" then
    return string.format("%q",t)
  elseif sType == "number" or sType == "boolean" or sType == "nil" then
    return tostring(t)
  elseif sType == "function" then
    local status,data=pcall(string.dump,t)
    if status then
      return 'func('..string.format("%q",data)..')'
    else
      error()
    end
  else
    error()
  end
end

local function split(T,func)
  if func then
    T=func(T)
  end
  local Out={}
  if type(T)=="table" then
    for k,v in pairs(T) do
      Out[split(k)]=split(v)
    end
  else
    Out=T
  end
  return Out
end

local function serialize( t )
  t=split(t)
  return serializeImpl( t, tTracking )
end

local function unserialize( s )
  local func, e = loadstring( "return "..s, "serialize" )
  local funcs={}
  if not func then
    return e
  end

  setfenv( func, {
  func=function(S)
  local new={}
  funcs[new]=S
  return new
  end,
  })

  return split(func(),function(val)
  if funcs[val] then
  return loadstring(funcs[val])
  else
  return val
  end
  end)

end

local function sure(N,n)
  if (l2-n)<1 then N="0" end
  return N
end

local function splitnum(S)
  Out=""
  for l1=1,#S,2 do
    l2=(#S-l1)+1
    CNum=tonumber("0x"..sure(string.sub(S,l2-1,l2-1),1) .. sure(string.sub(S,l2,l2),0))
    Out=string.char(CNum)..Out
  end
  return Out
end

local function wrap(N)
  return N-(math.floor(N/256)*256)
end

function checksum(S,num)
  local sum=0
  for char in string.gmatch(S,".") do
    for l1=1,(num or 1) do
      math.randomseed(string.byte(char)+sum)
      sum=sum+math.random(0,9999)
    end
  end
  math.randomseed(sum)
  return sum
end

local function genkey(len,psw)
  checksum(psw)
  local key={}
  local tKeys={}
  for l1=1,len do
    local num=math.random(1,len)
      while tKeys[num] do
        num=math.random(1,len)
      end
      tKeys[num]=true
      key[l1]={num,math.random(0,255)}
    end
  return key
end

function encrypt(data,psw)
  data=serialize(data)
  local chs=checksum(data)
  local key=genkey(#data,psw)
  local out={}
  local cnt=1
  for char in string.gmatch(data,".") do
    table.insert(out,key[cnt][1],zfill(wrap(string.byte(char)+key[cnt][2])),chars)
    cnt=cnt+1
  end
  return string.sub(serialize({chs,table.concat(out)}),2,-3)
end

function decrypt(data,psw)
  local oData=data
  data=unserialize("{"..data.."}")
  if type(data)~="table" then
    return oData
  end
  local chs=data[1]
  data=data[2]
  local key=genkey((#data)/2,psw)
  local sKey={}
  for k,v in pairs(key) do
    sKey[v[1]]={k,v[2]}
  end
  local str=splitnum(data)
  local cnt=1
  local out={}
  for char in string.gmatch(str,".") do
    table.insert(out,sKey[cnt][1],string.char(wrap(string.byte(char)-sKey[cnt][2])))
    cnt=cnt+1
  end
  out=table.concat(out)
  if checksum(out or "")==chs then
    return unserialize(out)
  end
  return oData,out,chs
end
