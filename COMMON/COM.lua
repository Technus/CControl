do--new com protocol
--[[
    "no auth process" - all msg's needs to be supplied with Auth table
      to have session - just remember hashe of passes and user name (and ID) on local pc
      to make more commands in one second just tabelarize it
      
      universal MainFrame command packet
      {                                                                                     }
        {"Tec",                                     } , {auth table generated in locally  }
               {   command shortcut;            }
                                     {Vars}
      where {"Tec",{[1]=command shortcut;[2]={Vars}  }  } is encrypted using passhash as key and PASSHASH as IV(without timestamp)
      "Tec" is used to check if decryption went ok
      
      
      return msg's from MainFrame
      
      { {"Tec",{[1]=return msg shortcut;[2]={Vars}  }  } , {auth table generated in mainframe} }
      where {"Tec",{[1]=return msg shortcut;[2]={Vars}  }  } is encrypted using passhash as key and PASSHASH as IV(without timestamp)
      "Tec" is used to check if decryption went ok
      
      
      universal MainFrame ->counterPC/passtroughPC packet
      
      {[1]=command shortcuts;[2]={Vars}}
      is encrypted with keypair stored on both sides Key as key and Ivector as IV
      
      
      return msg's from "peripherals"
      
      {[1]=return msg shortcut;[2]={Vars}}
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
        local pass=textutils.serialize(pass)
        return({SHA.digestStr(pass),SHA.digestStr(string.upper(pass))})--table of 16 ints [1..16] 16x32bit integers (256ByteX2)
    end
    
    function authTmake(uID,uNAME,hashes,stamptime)
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
    
    function encryptdata()
    end
    
    function decryptdata()
    end

end

do--communication data thingies
    function XXnum(XX)--changes 2char long string into number 
        return (bit.blshift(string.byte(XX,1),8)+string.byte(XX,2))
    end
    
    function LI(UID, user, pass, channel)
      --Tries to login into the server
      local passTE, TimeS = EncPassTime(pass)
      local authT = {UID, user, passTE, TimeS}
      local msgS = textutils.serialize({"LI",authT})
      rednet.send(sendC,msgS)
      --Recives and proccesses the messsage?
    end
    
    function LO(SID , channel)
      --Tries to logout of the server
      local passTE, TimeS = EncPassTime(pass)
      local authT = {UID, user, passTE, TimeS}
      local msgS = textutils.serialize({"LO",authT})
      modem.transmit(sendC,receiveC,msgS)
      --Recives and proccesses the messsage?
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
