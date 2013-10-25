-- Rednet Tunneling
-- By KillaVanilla
-- pastebin.com/r8AFFkbV

local function downloadAPI(code, name)
	local webHandle = http.get("http://pastebin.com/raw.php?i="..code)
	if webHandle then
		local apiData = webHandle.readAll()
		webHandle.close()
		local apiHandle = fs.open(name, "w")
		apiHandle.write(apiData)
		apiHandle.close()
		return true
	else
		print("Could not retrieve API: "..name.."!")
		print("Ensure that the HTTP API is enabled.")
		return false
	end
end

if (not AES) and (not fs.exists("AES")) then
	downloadAPI("rCYDnCxn", "AES")
end

if (not base64) and (not fs.exists("base64")) then
	downloadAPI("pp3kpb19", "base64")
end

if (not random) and (not fs.exists("random")) then
	downloadAPI("D1th4Htw", "random")
end

if not AES then
	os.loadAPI("AES")
end

if not base64 then
	os.loadAPI("base64")
end

if not random then
	os.loadAPI("random")
end


local connFreq = 15 -- The key exchange is done on this frequency.
local tunnelFreq = 20 -- Encrypted data is sent on this frequency.
local connections = {} -- Temporary keys, for open connections.
handlerRunning = false -- Make sure that we don't have two handler coroutines running at the same time

function mod_exp(base, exp, mod)
	local result = 1
	while exp > 0 do
		if (exp % 2) == 1 then
			result = (result*base) % mod
		end
		exp = math.floor(exp/2)
		base = (base*base) % mod
		os.queueEvent("theres_a_hole_in_the_sky")
		os.pullEvent()
	end
	--term.setCursorPos(x,y+1)
	return result
end

function fermat(n, k)
	for i=1, k do
		local a = random.random(1, n-1)
		local e = mod_exp(a, n-1, n)
		if e ~= 1 then
			--print("a: "..a.." e: "..e)
			return false
		end
		os.queueEvent("theres_a_hole_in_the_sky")
		os.pullEvent()
	end
	return true
end

function miller_rabin(n, k)
	local s, d = 0, 0
	assert(n >= 2)
	if n == 2 then
		return true
	end
	if n%2 == 0 then
		return false
	end
	-- Write n-1 as (2^s)*d, by repeatedly dividing n-1 by two:
	d = n-1
	while true do
		local quot = math.floor(d / 2)
		local rem = d % 2
		if rem == 1 then
			break
		end
		s = s+1
		d = quot
		os.queueEvent("theres_a_hole_in_the_sky")
		os.pullEvent()
	end
	
	-- WitnessLoop:
	for i=1, k do
		a = random.random(2, n-2)
		local x = mod_exp(a, d, n)
		if not (x == 1 or x == n-1) then -- If x == 1 or x == n-1 then continue
			local continuing = false
			for j=1, s-1 do
				x = (x*x) % n
				if x == 1 then -- if x == 1 then return COMPOSITE (false)
					return false
				end
				if x == n-1 then -- If x == n-1 then do next WitnessLoop...
					continuing = true
					break
				end
				os.queueEvent("theres_a_hole_in_the_sky")
				os.pullEvent()
			end
			if not continuing then
				return false
			end
		end
		os.queueEvent("theres_a_hole_in_the_sky")
		os.pullEvent()
	end
	return true
end

function generatePrime(k, debug) -- Generate somewhat-large primes (nowhere near big enough, but using BigInt will just slow things down too much)
	random.generate_isaac()
	local tries = 0
	local x,y = term.getCursorPos()
	while true do
		local current = random.random(10000000, 90000000)
		tries = tries+1
		if debug then
			term.setCursorPos(x,y)
			term.clearLine()
		end
		if current % 2 == 0 then
			current = current+1
		end
		if debug then
			write("Attempt: "..tries..": "..current)
		end
		if fermat(current, k) then
			if debug then
				term.setCursorPos(x,y+3)
				term.clearLine()
				write("Last Fermat Success: "..tries..": "..current)
			end
			if miller_rabin(current, k) then
				if debug then
					term.setCursorPos(1,y+4)
				end
				return current
			else
				if debug then
					term.setCursorPos(x,y+2)
					term.clearLine()
					write("Last Miller-Rabin Failure: "..tries..": "..current)
				end
			end
		else
			if debug then
				term.setCursorPos(x,y+1)
				term.clearLine()
				write("Last Fermat Failure: "..tries..": "..current)
			end
		end
		os.queueEvent("there's_a_hole_in_the_sky")
		os.pullEvent()
	end
end

local function listen(timeout)
	local timer = {}
	if timeout then
		timer = os.startTimer(timeout)
	end
	while true do
		local event = {os.pullEvent()}
		if event[1] == "timer" then
			if event[2] == timer then
				return
			end
		elseif event[1] == "modem_message" then
			if textutils.unserialize(event[5]) then
				return event[3], event[4], textutils.unserialize(event[5])
			end
		end
	end
end

local function incrementBlock(blk, incAmt)
	local cpy = {}
	for i=1, 16 do
		cpy[i] = blk[i] or 0
	end
	cpy[1] = cpy[1] + incAmt
	for i=2, 16 do
		if cpy[i-1] <= 255 then
			break
		end
		local carry = cpy[i-1] - 255
		cpy[i] = cpy[i]+carry
	end
	return cpy
end

function getHandlerStatus()
	return handlerRunning
end

-- Connection Establishing:
-- Client sends "Connect" message with a[1-4], base, and p, for Diffie-Hellman Key Exchange.
-- Server calculates b[1-4] and s[1-4] and sends a "Connect_Key" message with b[1-4]. The server also encrypts a "test block" of all 0xFF's using s.
-- Client calculates s[1-4], and encrypts a "test block" of all 0xFF's using s.
-- Server sends the test block, which is checked by the client. If the blocks match, then the client sends a success message. All communications from here are encrypted using s.
-- The server makes an entry in the connection table for the new connection, and sends the client the connection ID.

-- If any side of the connection is held up for more than 30 seconds, the connection is automatically torn down.

function connectionHandler(modem, debug)
	if handlerRunning then
		if debug then
			print("connection_handler: another handler instance is already running!")
		end
		return false
	end
	handlerRunning = true
	modem.open(connFreq)
	modem.open(tunnelFreq)
	while true do
		local tFreq, rFreq, msg = listen()
		if msg[1] == "Tunneling" then
			local id = msg[2]
			--print(msg[1].." : "..msg[3])
			if msg[3] == "Connect" then
				if debug then
					print("connect_server: Incoming connection attempt by ID "..id.."...")
				end
				
				local k1 = random.random()
				local k2 = random.random()
				local k3 = random.random()
				local k4 = random.random()
				
				local iv_k1 = random.random()
				local iv_k2 = random.random()
				local iv_k3 = random.random()
				local iv_k4 = random.random()
				
				local a1 = msg[4]
				local a2 = msg[5]
				local a3 = msg[6]
				local a4 = msg[7]
				
				local iv_a1 = msg[8]
				local iv_a2 = msg[9]
				local iv_a3 = msg[10]
				local iv_a4 = msg[11]
				
				local base = msg[12]
				local p = msg[13]
				
				local b1 = mod_exp(base, k1, p)
				local b2 = mod_exp(base, k2, p)
				local b3 = mod_exp(base, k3, p)
				local b4 = mod_exp(base, k4, p)
				
				local iv_b1 = mod_exp(base, iv_k1, p)
				local iv_b2 = mod_exp(base, iv_k2, p)
				local iv_b3 = mod_exp(base, iv_k3, p)
				local iv_b4 = mod_exp(base, iv_k4, p)
				
				local s = {}
				local s1 = mod_exp(a1, k1, p)
				local s2 = mod_exp(a2, k2, p)
				local s3 = mod_exp(a3, k3, p)
				local s4 = mod_exp(a4, k4, p)
				
				s[1] = bit.brshift(bit.band( s1, 0xFF000000 ), 24)
				s[2] = bit.brshift(bit.band( s1, 0x00FF0000 ), 16)
				s[3] = bit.brshift(bit.band( s1, 0x0000FF00 ), 8)
				s[4] = bit.band( s1, 0x000000FF )
				
				s[5] = bit.brshift(bit.band( s2, 0xFF000000 ), 24)
				s[6] = bit.brshift(bit.band( s2, 0x00FF0000 ), 16)
				s[7] = bit.brshift(bit.band( s2, 0x0000FF00 ), 8)
				s[8] = bit.band( s2, 0x000000FF )
				
				s[9] = bit.brshift(bit.band( s3, 0xFF000000 ), 24)
				s[10] = bit.brshift(bit.band( s3, 0x00FF0000 ), 16)
				s[11] = bit.brshift(bit.band( s3, 0x0000FF00 ), 8)
				s[12] = bit.band( s3, 0x000000FF )
				
				s[13] = bit.brshift(bit.band( s4, 0xFF000000 ), 24)
				s[14] = bit.brshift(bit.band( s4, 0x00FF0000 ), 16)
				s[15] = bit.brshift(bit.band( s4, 0x0000FF00 ), 8)
				s[16] = bit.band( s4, 0x000000FF )
				
				local iv = {}
				local iv1 = mod_exp(iv_a1, iv_k1, p)
				local iv2 = mod_exp(iv_a2, iv_k2, p)
				local iv3 = mod_exp(iv_a3, iv_k3, p)
				local iv4 = mod_exp(iv_a4, iv_k4, p)
				
				iv[1] = bit.brshift(bit.band( iv1, 0xFF000000 ), 24)
				iv[2] = bit.brshift(bit.band( iv1, 0x00FF0000 ), 16)
				iv[3] = bit.brshift(bit.band( iv1, 0x0000FF00 ), 8)
				iv[4] = bit.band( iv1, 0x000000FF )
				
				iv[5] = bit.brshift(bit.band( iv2, 0xFF000000 ), 24)
				iv[6] = bit.brshift(bit.band( iv2, 0x00FF0000 ), 16)
				iv[7] = bit.brshift(bit.band( iv2, 0x0000FF00 ), 8)
				iv[8] = bit.band( iv2, 0x000000FF )
				
				iv[9] = bit.brshift(bit.band( iv3, 0xFF000000 ), 24)
				iv[10] = bit.brshift(bit.band( iv3, 0x00FF0000 ), 16)
				iv[11] = bit.brshift(bit.band( iv3, 0x0000FF00 ), 8)
				iv[12] = bit.band( iv3, 0x000000FF )
				
				iv[13] = bit.brshift(bit.band( iv4, 0xFF000000 ), 24)
				iv[14] = bit.brshift(bit.band( iv4, 0x00FF0000 ), 16)
				iv[15] = bit.brshift(bit.band( iv4, 0x0000FF00 ), 8)
				iv[16] = bit.band( iv4, 0x000000FF )
				
				if debug then
					print("connect_server: Numbers generated...")
				end
				
				local test_block = {}
				
				for i=1, 16 do
					test_block[i] = 0xFF
				end
				
				test_block = AES.encrypt_bytestream(test_block, s, iv)
				if debug then
					print("connect_server: Sending our keys and the test block...")
				end
				modem.transmit( tFreq, rFreq, textutils.serialize({"Tunneling", os.computerID(), "Connect_Key", b1, b2, b3, b4, iv_b1, iv_b2, iv_b3, iv_b4, test_block}) )
				while true do
					local _, __, msg2 = listen(30)
					if msg2 == nil then
						break
					end
					if msg2[1] == "Tunneling" and msg2[2] == id and msg2[3] == "Connection_Established" then
						local newID = random.random()
						while true do
							if not connections[newID] then
								break
							else
								newID = random.random()
							end
						end
						if debug then
							print("connect_server: Connection established. Sending ID...")
						end
						local e_str = textutils.serialize({"Connection_ID", newID})
						local e = {}
						for i=1, #e_str do
							e[i] = string.byte(e_str, i, i)
						end
						e = AES.encrypt_bytestream(e, s, iv)
						e = base64.encode(e)
						modem.transmit( tFreq, rFreq, textutils.serialize({"Tunneling", os.computerID(), e}) )
						connections[ newID ] = {s, iv}
						os.queueEvent("secure_connection_open", id, newID)
						break
					end
				end
			elseif msg[3] == "Data" then
				if debug then
					print("data_server: Incoming data on connection "..msg[5])
				end
				if connections[msg[5]] then
					local data_bytes = AES.decrypt_bytestream(base64.decode(msg[4]), connections[msg[5]][1], connections[msg[5]][2])
					local data_str = ""
					for i=1, #data_bytes do
						data_str = data_str..string.char(data_bytes[i])
					end
					if type(textutils.unserialize(data_str)) == "table" then
						local data_table = textutils.unserialize(data_str)
						local packetType = data_table[1]
						local senderID = data_table[2]
						connections[msg[5]][2] = data_table[3]
						local data1 = data_table[4]
						local data2 = data_table[5]
						local data3 = data_table[6]
						if debug then
							if packetType == "Message" then
								print("data_server: Incoming data from "..senderID.." on connection "..msg[5].." : "..data1)
							elseif packetType == "fakeModemMsg" then
								print("data_server: Incoming fake modem_message from "..senderID.." on connection "..msg[5]..": "..data1)
								print("data_server: tFreq / rFreq: "..data2.."/"..data3)
							elseif packetType == "close" then
								print("data_server: Closing connection: "..msg[5])
							elseif packetType == "newKey" then
								print("data_server: New key sent by other party.")
							elseif packetType == "ack_pos" then
								print("data_server: Positive acknowledgement received.")
							elseif packetType == "ack_neg" then
								print("data_server: Negative acknowledgement received.")
							else
								print("data_server: Unknown packet type: "..packetType)
							end
						end
						if packetType == "Message" then
							os.queueEvent("secure_receive", senderID, msg[5], data1)
						elseif packetType == "fakeModemMsg" then
							os.queueEvent("modem_message", "left", data2, data3, data1)
							os.queueEvent("secure_receive", senderID, msg[5], data1)
						elseif packetType == "close" then
							connections[msg[5]] = nil
							os.queueEvent("secure_connection_close", senderID, msg[5])
						elseif packetType == "newKey" then
							connections[msg[5]] = { data1, data2 }
							os.queueEvent("secure_connection_newKey", senderID, msg[5])
						elseif packetType == "newID" then
							if not connections[data1] then
								if debug then
									print("data_server: Switching connection "..msg[5].." to "..data1)
								end
								sendTunnel_raw(modem, msg[5], "ack_pos")
								local cpy = {connections[msg[5]][1], connections[msg[5]][2]}
								connections[data1] = cpy
								connections[msg[5]] = nil
								os.queueEvent("secure_connection_newID",  senderID, msg[5], data1)
							else
								sendTunnel_raw(modem, msg[5], "ack_neg")
							end
						elseif packetType == "ack_pos" then
							os.queueEvent("secure_connection_ack", msg[5], senderID)
						elseif packetType == "ack_neg" then
							os.queueEvent("secure_connection_nak", msg[5], senderID)
						end
					end
				end
			end
		end
	end
end

function sendTunnel_raw(modem, id, packetType, data1, data2, data3)
	if connections[id] then
		local newIV = {}
		for i=1, 16 do
			newIV[i] = math.random(0, 255)
		end
		local enc_str = ""
		local sec_msg = textutils.serialize({packetType, os.computerID(), newIV, data1, data2, data3})
		local enc_bytes = {}
		for i=1, #sec_msg do
			enc_bytes[i] = string.byte(sec_msg, i, i)
		end
		enc_bytes = AES.encrypt_bytestream(enc_bytes, connections[id][1], connections[id][2])
		enc_str = base64.encode(enc_bytes)
		local data_str = textutils.serialize( {"Tunneling", math.random(1,0xFFFF), "Data", enc_str, id} )
		connections[id][2] = {}
		for i=1, 16 do
			connections[id][2][i] = newIV[i]
		end
		modem.transmit(tunnelFreq, tunnelFreq, data_str)
		return true
	else
		return false
	end
end


function sendTunnel(modem, id, data)
	--[[
	if connections[id] then
		local enc_str = ""
		local sec_msg = textutils.serialize({"Message", os.computerID(), data})
		local enc_bytes = {}
		for i=1, #sec_msg do
			enc_bytes[i] = string.byte(sec_msg, i, i)
		end
		enc_bytes = AES.encrypt_bytestream(enc_bytes, connections[id][1], connections[id][3])
		enc_str = base64.encode(enc_bytes)
		local data_str = textutils.serialize( {"Tunneling", math.random(1,0xFFFF), "Data", enc_str, id} )
		modem.transmit(tunnelFreq, tunnelFreq, data_str)
		return true
	else
		return false
	end
	]]
	return sendTunnel_raw(modem, id, "Message", data)
end

function sendTunnel_withFreq(modem, id, data, tFreq, rFreq) -- Send a "fake" (but still encrypted) modem transmission.
	--[[
	if connections[id] then
		local enc_str = ""
		local sec_msg = textutils.serialize({os.computerID(), data, tFreq, rFreq})
		local enc_bytes = {}
		for i=1, #sec_msg do
			enc_bytes[i] = string.byte(sec_msg, i, i)
		end
		enc_bytes = AES.encrypt_bytestream(enc_bytes, connections[id][1], connections[id][3])
		enc_str = base64.encode(enc_bytes)
		local data_str = textutils.serialize( {"Tunneling", math.random(1,0xFFFF), "Data", enc_str, id} )
		modem.transmit(tunnelFreq, tunnelFreq, data_str)
		return true
	else
		return false
	end
	]]
	return sendTunnel_raw(modem, id, "fakeModemMsg", data, tFreq, rFreq)
end

function listenTunnel(id, timeout)
	local timer = {}
	if not connections[id] then
		return false
	end
	if timeout then
		timer = os.startTimer(timeout)
	end
	while true do
		local event = {os.pullEvent()}
		if event[1] == "timer" and event[2] == timer then
			return nil
		elseif event[1] == "secure_receive" and event[3] == id then
			return event[2], event[4]
		end
	end
end

function closeTunnel(modem, id)
	if connections[id] then
		--modem.transmit(tunnelFreq, tunnelFreq, textutils.serialize( {"Tunneling", os.computerID(), "Close", id} ))
		sendTunnel_raw(modem, id, "close")
		connections[id] = nil
		os.queueEvent("secure_connection_close", id)
		return true
	end
	return false
end

function getAllOpenConnections()
	local ids = {}
	for i, v in pairs(connections) do
		table.insert(ids, i)
	end
	return ids
end

function getConnectionDetails(conn)
	return {connections[conn][1], connections[conn][2]}
end

function installTunnelAsModem(modem, id, side) -- Create a fake (wireless) "modem" peripheral. Cannot override (any) "real" modems.
	if not peripheral.tunnelHijackInPlace then
		peripheral.tunnelHijackInPlace = true
		peripheral.old = {}
		peripheral.tunnels = {}
		for i,v in pairs(peripheral) do
			if i ~= "old" then
				peripheral.old[i] = v
			end
		end
		peripheral.isPresent = function(methodSide)
			return peripheral.old.isPresent(methodSide) or (peripheral.tunnels[methodSide] ~= nil)
		end
		peripheral.getType = function(methodSide)
			if peripheral.old.isPresent(methodSide) then
				return peripheral.old.getType(methodSide)
			elseif peripheral.tunnels[methodSide] ~= nil then
				return "modem"
			end
		end
		peripheral.wrap = function(methodSide)
			if peripheral.old.isPresent(methodSide) then
				return peripheral.old.wrap(methodSide)
			elseif peripheral.tunnels[methodSide] ~= nil then
				local copy = {}
				for i,v in pairs(peripheral.tunnels[methodSide]) do
					copy[i] = v
				end
			end
		end
		peripheral.getMethods = function(methodSide)
			if peripheral.old.isPresent(methodSide) then
				return peripheral.old.getMethods(methodSide)
			elseif peripheral.tunnels[methodSide] ~= nil then
				local copy = {}
				local ctr = 1
				for i,v in pairs(peripheral.tunnels[methodSide]) do
					copy[ctr] = i
					ctr = ctr+1
				end
				return copy
			end
		end
		peripheral.call = function(...)
			local args = {...}
			local side = args[1]
			local method = args[2]
			if peripheral.tunnels[side] ~= nil then
				if peripheral.tunnels[side][method] ~= nil then
					return peripheral.tunnels[side][method](unpack(args, 3))
				end
			elseif peripheral.old.isPresent(side) then
				return peripheral.old.call(unpack(args))
			end
		end
		peripheral.getNames = function()
			local names = peripheral.old.getNames()
			for i,v in pairs(peripheral.tunnels) do
				table.insert(names, i)
			end
			return names
		end
	end
	peripheral.tunnels[side] = {}
	peripheral.tunnels[side].id = id
	peripheral.tunnels[side].modem = modem
	peripheral.tunnels[side].isOpen = function()
		return connections[peripheral.tunnels[side].id] ~= nil
	end
	peripheral.tunnels[side].open = function()
		return true
	end
	peripheral.tunnels[side].close = function()
		closeTunnel(peripheral.tunnels[side].modem, peripheral.tunnels[side].id)
		return true
	end
	peripheral.tunnels[side].closeAll = function()
		closeTunnel(peripheral.tunnels[side].modem, peripheral.tunnels[side].id)
		return true
	end
	peripheral.tunnels[side].isWireless = function()
		return true
	end
	peripheral.tunnels[side].transmit = function(tFreq, rFreq, data)
		sendTunnel_withFreq(peripheral.tunnels[side].modem, peripheral.tunnels[side].id, data, tFreq, rFreq)
	end
	local copy = {}
	for i,v in pairs(peripheral.tunnels[side]) do
		copy[i] = v
	end
	return copy
end

function switchConnectionID(modem, oldID, newID)
	sendTunnel_raw(modem, oldID, "newID", newID)
	local timer = os.startTimer(30)
	while true do
		local event, t = os.pullEvent()
		if event == "timer" and t == timer then
			return false
		elseif event == "secure_connection_nak" and t == oldID then
			return false
		elseif event == "secure_connection_ack" and t == oldID then
			connections[newID] = {connections[oldID][1], connections[oldID][2]}
			connections[oldID] = nil
			os.queueEvent("secure_connection_newID",  senderID, oldID, newID)
			return true
		end
	end
	return false
end

function switchKey(modem, id, key, iv)
	sendTunnel_raw(modem, id, "newKey", key, iv)
	connections[id] = {key, iv}
	os.queueEvent("secure_connection_newKey", id)
end

function openConnectionRaw(connID, key, iv)
	--[[
	local tempID = openTunnel(modem, compID)
	if switchConnectionID(modem, tempID, connID) then
		sendTunnel_raw(modem, "newKey", key, iv)
		return true
	end
	return false
	]]
	connections[connID] = {key, iv}
end

function openTunnel(modem, id, debug)
	modem.open(connFreq)
	modem.open(tunnelFreq)
	local base = math.random(1, 3)
	if base == 1 then
		base = 2
	elseif base == 2 then
		base = 3
	else
		base = 5
	end
	-- Generate 8 different numbers, because AES needs 16 bytes of key, as well as 16 bytes for the IV.
	-- We're running 8 different D-H exchanges with the same base.
	local p = generatePrime(100, debug)
	
	local k1 = random.random()
	local k2 = random.random()
	local k3 = random.random()
	local k4 = random.random()
	
	local iv1 = random.random()
	local iv2 = random.random()
	local iv3 = random.random()
	local iv4 = random.random()
	
	local s1 = 0
	local s2 = 0
	local s3 = 0
	local s4 = 0
	
	local iv_s1 = 0
	local iv_s2 = 0
	local iv_s3 = 0
	local iv_s4 = 0
	
	local a1 = mod_exp(base, k1, p)
	local a2 = mod_exp(base, k2, p)
	local a3 = mod_exp(base, k3, p)
	local a4 = mod_exp(base, k4, p)
	
	local iv_a1 = mod_exp(base, iv1, p)
	local iv_a2 = mod_exp(base, iv2, p)
	local iv_a3 = mod_exp(base, iv3, p)
	local iv_a4 = mod_exp(base, iv4, p)
	if debug then
		print("connect: Numbers generated...")
	end
	modem.transmit(connFreq, connFreq, textutils.serialize({"Tunneling", os.computerID(), "Connect", a1, a2, a3, a4, iv_a1, iv_a2, iv_a3, iv_a4, base, p}))
	while true do
		local tFreq, rFreq, msg = listen(30)
		if tFreq == nil then
			return false
		else
			if tFreq == connFreq then
				if msg then
					if msg[1] == "Tunneling" and msg[2] == id and msg[3] == "Connect_Key" then
						if debug then
							print("connect: Server has sent its keys...")
						end
						s1 = mod_exp(msg[4], k1, p)
						s2 = mod_exp(msg[5], k2, p)
						s3 = mod_exp(msg[6], k3, p)
						s4 = mod_exp(msg[7], k4, p)
						
						iv_s1 = mod_exp(msg[8], iv1, p)
						iv_s2 = mod_exp(msg[9], iv2, p)
						iv_s3 = mod_exp(msg[10], iv3, p)
						iv_s4 = mod_exp(msg[11], iv4, p)
						local serv_test_block = msg[12]
						local our_test_block = {}
						for i=1, 16 do
							our_test_block[i] = 0xFF
						end
						
						local s = {}
						local iv = {}
						
						s[1] = bit.brshift(bit.band( s1, 0xFF000000 ), 24)
						s[2] = bit.brshift(bit.band( s1, 0x00FF0000 ), 16)
						s[3] = bit.brshift(bit.band( s1, 0x0000FF00 ), 8)
						s[4] = bit.band( s1, 0x000000FF )
						
						s[5] = bit.brshift(bit.band( s2, 0xFF000000 ), 24)
						s[6] = bit.brshift(bit.band( s2, 0x00FF0000 ), 16)
						s[7] = bit.brshift(bit.band( s2, 0x0000FF00 ), 8)
						s[8] = bit.band( s2, 0x000000FF )
						
						s[9] = bit.brshift(bit.band( s3, 0xFF000000 ), 24)
						s[10] = bit.brshift(bit.band( s3, 0x00FF0000 ), 16)
						s[11] = bit.brshift(bit.band( s3, 0x0000FF00 ), 8)
						s[12] = bit.band( s3, 0x000000FF )
						
						s[13] = bit.brshift(bit.band( s4, 0xFF000000 ), 24)
						s[14] = bit.brshift(bit.band( s4, 0x00FF0000 ), 16)
						s[15] = bit.brshift(bit.band( s4, 0x0000FF00 ), 8)
						s[16] = bit.band( s4, 0x000000FF )
						
						iv[1] = bit.brshift(bit.band( iv_s1, 0xFF000000 ), 24)
						iv[2] = bit.brshift(bit.band( iv_s1, 0x00FF0000 ), 16)
						iv[3] = bit.brshift(bit.band( iv_s1, 0x0000FF00 ), 8)
						iv[4] = bit.band( iv_s1, 0x000000FF )
						
						iv[5] = bit.brshift(bit.band( iv_s2, 0xFF000000 ), 24)
						iv[6] = bit.brshift(bit.band( iv_s2, 0x00FF0000 ), 16)
						iv[7] = bit.brshift(bit.band( iv_s2, 0x0000FF00 ), 8)
						iv[8] = bit.band( iv_s2, 0x000000FF )
						
						iv[9] = bit.brshift(bit.band( iv_s3, 0xFF000000 ), 24)
						iv[10] = bit.brshift(bit.band( iv_s3, 0x00FF0000 ), 16)
						iv[11] = bit.brshift(bit.band( iv_s3, 0x0000FF00 ), 8)
						iv[12] = bit.band( iv_s3, 0x000000FF )
						
						iv[13] = bit.brshift(bit.band( iv_s4, 0xFF000000 ), 24)
						iv[14] = bit.brshift(bit.band( iv_s4, 0x00FF0000 ), 16)
						iv[15] = bit.brshift(bit.band( iv_s4, 0x0000FF00 ), 8)
						iv[16] = bit.band( iv_s4, 0x000000FF )
						
						if debug then
							print("connect: Testing key..")
						end
						our_test_block = AES.encrypt_bytestream(our_test_block, s, iv)
						for i=1, 16 do
							if our_test_block[i] ~= serv_test_block[i] then
								return false
							end
						end
						modem.transmit(connFreq, connFreq, textutils.serialize({"Tunneling", os.computerID(), "Connection_Established"}))
						if debug then
							print("connect: Connection established...")
						end
						while true do
							local _, __, msg2 = listen(30)
							if msg2 == nil then
								return false
							elseif msg2[1] == "Tunneling" and msg2[2] == id then
								local d = AES.decrypt_bytestream(base64.decode(msg2[3]), s, iv)
								local d_str = ""
								for i=1, #d do
									d_str = d_str..string.char(d[i])
								end
								if textutils.unserialize(d_str) then
									d = textutils.unserialize(d_str)
									if d[1] == "Connection_ID" then
										if debug then
											print("connect: Recieved connection ID.")
										end
										connections[ d[2] ] = {s, iv}
										os.queueEvent("secure_connection_open", id, d[2])
										return d[2]
									else
										return false
									end
								else
									return false
								end
							end
						end
					end
				end
			end
		end
	end
end
