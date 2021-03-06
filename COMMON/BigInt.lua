-- This source file is at version 1 as of the last time I've bothered to update it.
-- KillaVanilla's arbitrary-precision API in Lua. Please don't steal it.

-- All arbitrary precision integers (or "bigInts" or any other capitalization of such) are unsigned. Operations where the result is less than 0 are undefined.
-- BigInts are stored as tables with each digit occupying an entry. These tables store values least-significant digit first.
-- For example, the number 1234 in BigInt format would be {4, 3, 2, 1}. This process is automatically done with bigInt.toBigInt().

-- Several of these functions have multiple names. For example, bigInt.mod(a,b) can also be called as bigInt.modulo(a,b), and bigInt.cmp_lt(a,b) can be called as bigInt.cmp_less_than(a,b).

-- Alternate names:
-- left and right shifts: blshift() and brshift()
-- sub, mul, div, mod, exp: subtract(), multiply(), divide(), modulo(), exponent()
-- <the comparison functions>: cmp_<full name of comparision> (e.g "cmp_greater_than_or_equal_to", "cmp_greater_than_equal_to", or "cmp_gteq")
-- toStr: tostring()
-- bitwise operations (AND, OR, XOR, NOT): band(), bor(), bxor(), bnot().

local function round(i) -- round a float
	if i - math.floor(i) >= 0.5 then
		return math.ceil(i)
	end
	return math.floor(i)
end

local function copy(input)
	if type(input) == "number" then
		return toBigInt(input)
	end
	local t = {}
	for i,v in pairs(input) do
		t[i] = v
	end
	return t
end

function removeTrailingZeroes(a)
	local cpy = copy(a)
	for i=#cpy, 1, -1 do
		if cpy[i] ~= 0 then
			break
		else
			cpy[i] = nil
		end
	end
	return cpy
end

cmp_lt = function(a,b) -- Less Than
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 > #b2 then
		return false
	end
	if #b2 > #a2 then
		return true
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return false
		elseif a2[i] < b2[i] then
			return true
		end
	end
	return false
end

cmp_gt = function(a,b) -- Greater Than
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 < #b2 then
		return false
	end
	if #b2 < #a2 then
		return true
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return true
		elseif a2[i] < b2[i] then
			return false
		end
	end
	return false
end

cmp_lteq = function(a,b) -- Less Than or EQual to
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 > #b2 then
		return false
	end
	if #b2 > #a2 then
		return true
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return false
		elseif a2[i] < b2[i] then
			return true
		end
	end
	return true
end

cmp_gteq = function(a,b) --Greater Than or EQual to
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 < #b2 then
		--print("[debug] GTEQ: a2="..toStr(a2).." b2="..toStr(b2).." #a2="..#a2.." #b2="..#b2.." #a2<#b2")
		return false
	end
	if #b2 < #a2 then
		--print("[debug] GTEQ: a2="..toStr(a2).." b2="..toStr(b2).." #a2="..#a2.." #b2="..#b2.." #b2<#a2")
		return true
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return true
		elseif a2[i] < b2[i] then
			return false
		end
	end
	return true
end

cmp_eq = function(a,b) --EQuality
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 < #b2 then
		return false
	end
	if #b2 < #a2 then
		return false
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return false
		elseif a2[i] < b2[i] then
			return false
		end
	end
	return true
end

cmp_ieq = function(a,b) -- InEQuality
	local a2 = removeTrailingZeroes(a)
	local b2 = removeTrailingZeroes(b)
	
	if #a2 < #b2 then
		return true
	end
	if #b2 < #a2 then
		return true
	end
	
	for i=#a2, 1, -1 do
		if a2[i] > b2[i] then
			return true
		elseif a2[i] < b2[i] then
			return true
		end
	end
	return false
end

local function validateBigInt(a)
	if type(a) ~= "table" then
		return false
	end
	for i=1, #a do
		if type(a[i]) ~= "number" then
			return false
		end
	end
	return true
end

local function add_bigInt(a, b)
	local cpy = copy(a)
	local carry = 0
	if cmp_gt(b, a) then
		return add_bigInt(b,a)
	end
	
	for i=1, #b do
		local n = a[i] or 0
		local m = b[i] or 0
		cpy[i] = n+m+carry
		if cpy[i] > 9 then
			carry = 1 -- cpy[i] cannot be greater than 18
			cpy[i] = cpy[i] % 10
		else
			carry = 0
		end
	end
	if carry > 0 then
		local n = cpy[ #b+1 ] or 0
		cpy[ #b+1 ] = n+carry
	end
	return removeTrailingZeroes(cpy)
end

local function sub_bigInt(a,b)
	local cpy = copy(a)
	local borrow = 0
	
	for i=1, #a do
		local n = a[i] or 0
		local n2 = b[i] or 0
		cpy[i] = n-n2-borrow
		if cpy[i] < 0 then
			cpy[i] = 10+cpy[i]
			borrow = 1
		else
			borrow = 0
		end
	end
	
	return removeTrailingZeroes(cpy)
end

local function mul_bigInt(a,b)
	local sum = {}
	local tSum = {}
	local carry = 0
	
	for i=1, #a do
		carry = 0
		sum[i] = {}
		for j=1, #b do
			sum[i][j] = (a[i]*b[j])+carry
			if sum[i][j] > 9 then
				carry = math.floor( sum[i][j]/10 )
				sum[i][j] = sum[i][j] % 10
				--sum[i][j] = ( (sum[i][j]/10) - carry )*10
			else
				carry = 0
			end
		end
		if carry > 0 then
			sum[i][#b+1] = carry
		end
		for j=2, i do
			table.insert(sum[i], 1, 0) -- table.insert(bigInt, 1, 0) is equivalent to bigInt*10. Likewise, table.remove(bigInt, 1) is equivalent to bigInt/10. table.insert(bigInt, 1, x) is eqivalent to bigInt*10+x, assuming that x is a 1-digit number
		end
	end
	
	for i=1, #a+#b do
		tSum[i] = 0
	end
	for i=1, #sum do
		tSum = add_bigInt(tSum, sum[i])
	end
	return removeTrailingZeroes(tSum)
end

local function div_bigInt(a,b)
	local bringDown = {}
	local quotient = {}
	
	for i=#a, 1, -1 do
		table.insert(bringDown, 1, a[i])
		if cmp_gteq(bringDown, b) then
			local add = 0
			while cmp_gteq(bringDown, b) do -- while bringDown >= b do
				bringDown = sub_bigInt(bringDown, b)
				add = add+1
			end
			table.insert(quotient, 1, add)
		else
			table.insert(quotient, 1, 0)
		end
	end
	return removeTrailingZeroes(quotient), removeTrailingZeroes(bringDown)
end

local function exp_bigInt(a,b) -- exponentation by squaring. This *should* work, no promises though.
	if cmp_eq(b, 1) then
		return a
	elseif cmp_eq(mod(b, 2), 0) then
		return exp_bigInt(mul(a,a), div(b,2))
	elseif cmp_eq(mod(b, 2), 1) then
		return mul(a, exp_bigInt(mul(a,a), div(sub(b,1),2)))
	end
end

function toBinary(a) -- Convert from a arbitrary precision decimal number to an arbitrary-length table of bits (least-significant bit first)
	local bitTable = {}
	local cpy = copy(a)
	
	while true do
		local quot, rem = div_bigInt(cpy, {2})
		cpy = quot
		rem[1] = rem[1] or 0
		table.insert(bitTable, rem[1])
		--print(toStr(cpy).." "..toStr(rem))
		if #cpy == 0 then
			break
		end
	end
	return bitTable
end

function fromBinary(a) -- Convert from an arbitrary-length table of bits (from toBinary) to an arbitrary precision decimal number
	local dec = {0}
	for i=#a, 1, -1 do
		dec = mul_bigInt(dec, {2})
		dec = add_bigInt(dec, {a[i]})
	end
	return dec
end

local function appendBits(i, sz) -- Appends bits to make #i match sz.
	local cpy = copy(i)
	for j=#i, sz-1 do
		table.insert(cpy, 0)
	end
	return cpy
end

function bitwiseLeftShift(a, i)
	return mul(a, exp(2, i))
end

function bitwiseRightShift(a, i)
	local q = div(a, exp(2, i))
	return q
end

function bitwiseNOT(a)
	local b = toBinary(a)
	for i=1, #b do
		if b[i] == 0 then
			b[i] = 1
		else
			b[i] = 0
		end
	end
	return fromBinary(b)
end

function bitwiseXOR(a, b)
	local a2 = toBinary(a)
	local b2 = appendBits(toBinary(b), #a2)
	if #a2 > #b2 then
		return bitwiseXOR(b,a)
	end
	for i=1, #a2 do
		if a2[i] == 1 and b2[i] == 1 then
			a2[i] = 0
		elseif a2[i] == 0 and b2[i] == 0 then
			a2[i] = 0
		else
			a2[i] = 1
		end
	end
	return fromBinary(a2)
end

function bitwiseOR(a, b)
	local a2 = toBinary(a)
	local b2 = appendBits(toBinary(b), #a2)
	if #a2 > #b2 then
		return bitwiseOR(b,a)
	end
	for i=1, #a2 do
		if a2[i] == 1 or b2[i] == 1 then
			a2[i] = 1
		else
			a2[i] = 0
		end
	end
	return fromBinary(a2)
end

function bitwiseAND(a, b)
	local a2 = toBinary(a)
	local b2 = appendBits(toBinary(b), #a2)
	if #a2 > #b2 then
		return bitwiseAND(b,a)
	end
	for i=1, #a2 do
		if a2[i] == 1 and b2[i] == 1 then
			a2[i] = 1
		else
			a2[i] = 0
		end
	end
	return fromBinary(a2)
end

function add(a, b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		return add_bigInt(a,b)
	end
end

function sub(a, b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		return sub_bigInt(a,b)
	end
end

function mul(a, b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		return mul_bigInt(a,b)
	end
end

function div(a, b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		return div_bigInt(a,b)
	end
end

function mod(a, b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		local q, r = div_bigInt(a,b)
		return r
	end
end

function exp(a,b)
	if type(a) == "number" then
		a = toBigInt(a)
	end
	if type(b) == "number" then
		b = toBigInt(b)
	end
	if validateBigInt(a) and validateBigInt(b) then
		return exp_bigInt(a,b)
	end
end

function toStr(a)
	local str = ""
	for i=#a, 1, -1 do
		str = str..string.sub(tostring(a[i]), 1, 1)
	end
	return str
end

function toBigInt(n) -- can take either a string composed of numbers (like "1237162721379627129638372") or a small integer (such as literal 18957 or 4*197163%2)
	local n2 = {}
	if type(n) == "number" then
		while n > 0 do
			 table.insert(n2,  n%10)
			 n = math.floor(n/10)
		end
	elseif type(n) == "string" then
		for i=1, #n do
			local digit = tonumber(string.sub(n, i,i))
			if digit then
				table.insert(n2, 1, digit)
			end
		end
	end
	return n2
end

-- Long names for the functions:
cmp_equality = cmp_eq
cmp_inequality = cmp_ieq
cmp_greater_than = cmp_gt
cmp_greater_than_or_equal_to = cmp_gteq
cmp_greater_than_equal_to = cmp_gteq
cmp_less_than = cmp_lt
cmp_less_than_or_equal_to = cmp_lteq
cmp_less_than_equal_to = cmp_lteq
bor = bitwiseBOR
bxor = bitwiseXOR
band = bitwiseAND
bnot = bitwiseNOT
blshift = bitwiseLeftShift
brshift = bitwiseRightShift
subtract = sub
multiply = mul
divide = div
modulo = mod
exponent = exp