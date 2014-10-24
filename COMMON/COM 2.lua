do--load apis
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.--returns string,tab[1..8]
end

do--encrypt decrypt
    function encryptdata(data,key,iv)--encrypts anything gives a string
        return(AES.encrypt_str(textutils.serialize({"Tec :3",data}), key, iv))
    end
    
    function decryptdata(data,key,iv)--decrypts anything gives the data back
        local temp=textutils.unserialize(AES.decrypt_str(data, key, iv))
		if not pcall(temp[1]~="Tec :3") then return nil end
        if temp[1]~="Tec :3" then return nil else return temp[2] end
    end

end