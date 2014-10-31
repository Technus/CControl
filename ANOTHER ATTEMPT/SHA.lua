-- SHA-256
-- By KillaVanilla
-- http://pastebin.com/9c1h7812

k = {
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
}

local function generateShiftBitmask(bits)
	local bitmask = 0
	for i=1, bits do
		bit.bor(bitmask, 0x8000000)
		bit.brshift(bitmask, 1)
	end
	return bitmask
end

local function rrotate(input, shiftAmount)
	if input > (2^32) then
		input = input % (2^32)
	end
	return bit.bor( bit.brshift(input, shiftAmount), bit.blshift(input, 32-shiftAmount) )
end

local function Preprocessing(message)
	local len = #message*8
	local bits = #message*8
	table.insert(message, 1)
	while true do
		if bits % 512 == 448 then
			break
		else
			table.insert(message, 0)
			bits = #message*8
		end
	end
	table.insert(message, len)
	return message
end

local function breakMsg(message)
	local chunks = {}
	local chunk = 1
	for word=1, #message, 16 do
		chunks[chunk] = {}
		table.insert(chunks[chunk], message[word] or 0)
		table.insert(chunks[chunk], message[word+1] or 0)
		table.insert(chunks[chunk], message[word+2] or 0)
		table.insert(chunks[chunk], message[word+3] or 0)
		table.insert(chunks[chunk], message[word+4] or 0)
		table.insert(chunks[chunk], message[word+5] or 0)
		table.insert(chunks[chunk], message[word+6] or 0)
		table.insert(chunks[chunk], message[word+7] or 0)
		table.insert(chunks[chunk], message[word+8] or 0)
		table.insert(chunks[chunk], message[word+9] or 0)
		table.insert(chunks[chunk], message[word+10] or 0)
		table.insert(chunks[chunk], message[word+11] or 0)
		table.insert(chunks[chunk], message[word+12] or 0)
		table.insert(chunks[chunk], message[word+13] or 0)
		table.insert(chunks[chunk], message[word+14] or 0)
		table.insert(chunks[chunk], message[word+15] or 0)
		chunk = chunk+1
	end
	return chunks
end

local function digestChunk(chunk, hash)
	for i=17, 64 do
		local s0 = bit.bxor( bit.brshift(chunk[i-15], 3), bit.bxor( rrotate(chunk[i-15], 7), rrotate(chunk[i-15], 18) ) )
		local s1 = bit.bxor( bit.brshift(chunk[i-2], 10), bit.bxor( rrotate(chunk[i-2], 17), rrotate(chunk[i-2], 19) ) )
		chunk[i] = (chunk[i-16] + s0 + chunk[i-7] + s1) % (2^32)
	end

	local a = hash[1]
	local b = hash[2]
	local c = hash[3]
	local d = hash[4]
	local e = hash[5]
	local f = hash[6]
	local g = hash[7]
	local h = hash[8]
	
	for i=1, 64 do
		local S1 = bit.bxor(rrotate(e, 6), bit.bxor(rrotate(e,11),rrotate(e,25)))
		local ch = bit.bxor( bit.band(e, f), bit.band(bit.bnot(e), g) )
		local t1 = h + S1 + ch + k[i] + chunk[i]
		--d = d+h
		S0 = bit.bxor(rrotate(a,2), bit.bxor( rrotate(a,13), rrotate(a,22) ))
		local maj = bit.bxor( bit.band( a, bit.bxor(b, c) ), bit.band(b, c) )
		local t2 = S0 + maj
		
		h = g
		g = f
		f = e
		e = d + t1
		d = c
		c = b
		b = a
		a = t1 + t2
		
		a = a % (2^32)
		b = b % (2^32)
		c = c % (2^32)
		d = d % (2^32)
		e = e % (2^32)
		f = f % (2^32)
		g = g % (2^32)
		h = h % (2^32)
		
	end
		
	hash[1] = (hash[1] + a) % (2^32)
	hash[2] = (hash[2] + b) % (2^32)
	hash[3] = (hash[3] + c) % (2^32)
	hash[4] = (hash[4] + d) % (2^32)
	hash[5] = (hash[5] + e) % (2^32)
	hash[6] = (hash[6] + f) % (2^32)
	hash[7] = (hash[7] + g) % (2^32)
	hash[8] = (hash[8] + h) % (2^32)
	
	return hash
end

function digest(msg)
	msg = Preprocessing(msg)
	local hash = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}
	local chunks = breakMsg(msg)
	for i=1, #chunks do
		hash = digestChunk(chunks[i], hash)
	end
	return hash
end

function digestStr(input)
	-- transform the input into a table of ints:
	local output = {}
	local outputStr = ""
	for i=1, #input do
		output[i] = string.byte(input, i, i)
	end
	output = digest(output)
	for i=1, #output do
		outputStr = outputStr..string.format("%X", output[i])
	end
	return outputStr, output
end

function hashToBytes(hash)
	local bytes = {}
	for i=1, 8 do
		table.insert(bytes, bit.band(bit.brshift(bit.band(hash[i], 0xFF000000), 24), 0xFF))
		table.insert(bytes, bit.band(bit.brshift(bit.band(hash[i], 0xFF0000), 16), 0xFF))
		table.insert(bytes, bit.band(bit.brshift(bit.band(hash[i], 0xFF00), 8), 0xFF))
		table.insert(bytes, bit.band(hash[i], 0xFF))
	end
	return bytes
end

function hmac(input, key)
	-- HMAC(H,K,m) = H( (K <xor> opad) .. H((K <xor> ipad) .. m))
	-- Where:
	-- H - cryptographic hash function. In this case, H is SHA-256.
	-- K - The secret key.
	--	if length(K) > 256 bits or 32 bytes, then K = H(K)
	--  if length(K) < 256 bits or 32 bytes, then pad K to the right with zeroes. (i.e pad(K) = K .. repeat(0, 32 - byte_length(K)))
	-- m - The message to be authenticated.
	-- .. - byte concentration
	-- <xor> eXclusive OR.
	-- opad - Outer Padding, equal to repeat(0x5C, 32).
	-- ipad - Inner Padding, equal to repeat(0x36, 32).
	if #key > 32 then
		local keyDigest = digest(key)
		key = keyDigest
	elseif #key < 32 then
		for i=#key, 32 do
			key[i] = 0
		end
	end
	local opad = {}
	local ipad = {}
	for i=1, 32 do
		opad[i] = bit.bxor(0x5C, key[i] or 0)
		ipad[i] = bit.bxor(0x36, key[i] or 0)
	end
	local padded_key = {}
	for i=1, #input do
		ipad[32+i] = input[i]
	end
	local ipadHash = hashToBytes(digest(ipad))
	ipad = ipadHash
	for i=1, 32 do
		padded_key[i] = opad[i]
		padded_key[32+i] = ipad[i]
	end
	return digest(padded_key)
end
