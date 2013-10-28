--propertiary COMmunication protocols


do--new com protocol
--[[
    "no auth process" - all msg's needs to be supplied with Auth table
      to have session - just remember hashe of passes and user name (and ID) on local pc
      to make more commands in one second just tabelarize it
      
      universal MainFrame command packet
      {                                                                           }
        {   command shortcut;            } , {auth table generated in locally  }
                               {Vars}
      where {command shortcut; {Vars} } is encrypted using passhash as key and PASSHASH as IV(without timestamp)

      
      
      return msg's from MainFrame
      
      { {return msg shortcut;{Vars};{newVars}  } , {auth table generated in mainframe} }
      where {return msg shortcut;{Vars};{newVars}  } is encrypted using passhash as key and PASSHASH as IV(without timestamp)


            invalid auth return msg
        {nil,nil}
        

      universal MainFrame ->counterPC/passtroughPC packet (no auth just keypair)
      
      {command shortcuts;{Vars}}
      is encrypted with keypair stored on both sides Key as key and Ivector as IV
      
      
      return msg's from "peripherals"
      
      {return msg shortcut;{Vars};{newVars}}
      is encrypted with keypair stored on both sides Key as key and Ivector as IV
      
    ]]    
end



do--load apis
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
end

do--send/recieve/communication
  function send(pcID,data)
    return( rednet.send(pcID,textutils.serialize(data)) )
  end
  function recieve(t)
    local id,msg=rednet.recieve(t)
    return id,textutils.unserialize(msg)
  end
end

do--auth process help
    function timestamp() return(1440*os.day()+os.time()) end--gives time stamp int
    
    function formatbytes(str)--formats HASH into AES 32byte key or IV (table of 32 chars 0-255 )
      if not(str) then return false end
      local temp={}
      for i=1,32 do
          temp[i]=tonumber(string.sub(str,2*i-1,i*2),16)
          if not temp[i] then temp[i]=255 end
      end
      return temp 
    end
    
    function hashpass(pass)--input string output string that is a HASH 2Xlonger
        if #pass<4 then return false end
        pass=textutils.serialize(pass)
        pass={SHA.digestStr(pass),SHA.digestStr(string.upper(pass))}
            for i=1,64 do--filler to 64 signs   --REQUIRES REWORK :O
                if not(string.sub(pass[1],i,i)) then 
                    pass[1]=string.sub(pass[1],1,i-1).."0"..string.sub(pass[1],i+1,64)
                end
                if not(string.sub(pass[2],i,i)) then 
                    pass[2]=string.sub(pass[2],1,i-1).."0"..string.sub(pass[2],i+1,64)
                end
            end
        return(pass)
    end
    
    function authTmake(uID,uNAME,hashes,stamptime)--makes auth table
        return(
            {uID,uNAME,
             SHA.digestStr(hashes[1]..textutils.serialize(stamptime))..
             SHA.digestStr(hashes[2]..textutils.serialize(stamptime)),
             stamptime}
              )--returns - [1]uID[2]uNAME[3]string for comparison[4]timestamp
    end

  function authTcheck(authin,authstored,tdiff)--compares auth tables,tdiff is optional
      if authin[1] then if authin[1]~=authstored[1] then return(false) end end
      for i=2,4 do
          if authin[i]~=authstored[i] then return false end
      end
      if tdiff then if timestamp()-authin[4]>tdiff then false end end
      return(true)
  end
end

do--encrypt decrypt
    function encryptdata(data,key,iv)--encrypts anything gives a string
        return(AES.encrypt_str(textutils.serialize({"Tec :3",data}), key, iv))
    end
    
    function decryptdata(data,key,iv)--decrypts anything gives the data back
        local temp=textutils.unserialize(AES.decrypt_str(data, key, iv))
        if temp[1]~="Tec :3" then return false else return temp[2] end 
    end

end

do--communication thingies
    
    function execrecv(data,msgtable)
        local size=#data
        for i=1,size do
            data[i][3]=msgtable[ data[i][1] ][2] ( data[i][2] )
        end
        return data
    end  
    
    function rednetOn()
      sides =rs.getSides() 
      for i = 1,#sides do
        if "modem" = peripheral.getType(sides[i]) then
        rednet.open(i)
        end
      end
    end
    
end
