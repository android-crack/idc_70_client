-- 工具方法

-- 对应的名字生成对应的tag, 特殊情况可能会出现重复，暂时没想到其他方法
---------------------------------------------------------------------
local prime = 11111117  -- 质数
local basenumber = 78  --进制 ， 122-48 （'z' - '0'）

function getTagByName(name)
	local num = stringToNumber(name)
	return math.mod(num, prime)
end

function stringToNumber(str)
	local num = 0
	local len = #str
	for i =1 ,len do
		local m = string.byte(str, i) - 48  
		num = num + m*math.pow(basenumber, len-i)
	end
	return num
end


-- 辅助函数, 切分字符串
----------------------------------------------------------------------
function split(str, pat)
    local t = {}  
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
   	end
   	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
   	end
   	return t
end

-------------------------------------------------------------------------
-- Color to RGB
function decToHex(IN)
	local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
	while IN>0 do
		I=I+1
		IN,D=math.floor(IN/B),math.fmod(IN,B)+1
		OUT=string.sub(K,D,D)..OUT
	end
	return OUT
end

function color3BToDex(color)
	local num = color.r * 256 * 256
	num = num + color.g * 256
	num = num + color.b
	return num
end 

function dexToColor3B(num) --r, g, b
	local b = math.mod(num, math.pow(16,2))
	num = math.floor(num / math.pow(16,2))
	local g = math.mod(num, math.pow(16,2))
	local r = math.floor(num / math.pow(16,2))
	return r,g,b
end

---------------------------------------------------------------------
--判断不是数组的表是否为空
function judgetTabIsNull(info)
  	local is_null = true 
  	for k, v in pairs(info) do
		is_null = false
		break
  	end
  	return is_null
end
