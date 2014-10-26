--added default login root/root

do--Loading all the API's we are going to use here!
  if not AES then os.loadAPI("AES")end
  --AES.encrypt_str(data, key, iv) -- Encrypt a string. If an IV is not provided, the function defaults to ECB mode.
  --AES.decrypt_str(data, key, iv) -- Decrypt a string.
  if not SHA then os.loadAPI("SHA")end
  --SHA.digestStr(string) -- Produce a SHA256 digest of a string. Uses digest() internally.
  if not COM then os.loadAPI("COM")end
  --COM.timestamp() -- return timestamp
  --COM.authTmake(uID,uNAME,hashes,stamptime) -- makes auth table
  --COM.authTcheck(authin,authstored,tdiff) -- compares 2 auth tables (and timestamp)
  --COM.send(pcID,data) -- sends data
  --COM.recieve(t) -- recieves data
  --COM.execrecieve(data,msgtable) -- executes data using table (comrecieve) 
  --COM.formatbytes(str) --formats string to byte long integers
  --COM.hashpass(pass) --converts password to {Hash,HASH}
  --COM.encryptdata(data,key,iv) -- encrypts
  --COM.decryptdata(data,key,iv) -- decrypts
end
