local tips = require("game_config/tips")
local boat= require("game_config/boat/boat_info")
local sailor = require("game_config/sailor/sailor_info")
local treasure = require("game_config/collect/baozang_info")
local relic= require("game_config/collect/relic_info")
local achievement= require("game_config/collect/achievement_info")

local port_info = require("game_config/port/port_info")
local handle ={ }

--
--[[如果str仅由数字组成，则返回true，否则返回false。失败返回nil和失败信息]]
local function getPortNameById(portId) 
	for key,value in pairs(port_info) do
		if (key == portId) then
			cclog("%s",value.name)
			return value.name
		end
	end
	return ""
end

local function isalnum(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if not (ch >= '0' and ch <= '9') then
			return false
		end
	end
	return true
end

handle.gettips = function (typeName, id, blackMarketInfo)
	local str

	local tipsTable = {}
	if (typeName == "boat") then
		tipsTable = boat
	elseif (typeName == "sailor") then
		tipsTable = sailor
	elseif (typeName == "treasure") then

	elseif (typeName == "relic") then
		tipsTable = relic
	elseif (typeName == "achievement") then
		tipsTable = achievement
		str = tipsTable[id].desc
		return str
	end

	-- treasure return
	if (typeName == "treasure") then

		tipsTable = treasure 

		local	blackStr = ""

		for key,value in pairs(blackMarketInfo) do
			if (value.baowuId == id) then
				blackStr = blackStr .. getPortNameById(value.portId) 

			end
		end


		if (blackStr == "") then --no black market
			if (tipsTable[id].tips == nil) then
				str = "\n"
			elseif (isalnum(tipsTable[id].tips) == true) then
				format = tips[tonumber(tipsTable[id].tips)]['msg']
				str = string.format( format, tipsTable[id].tips_p1, tipsTable[id].tips_p2, tipsTable[id].tips_p3)
			else 
				format = tipsTable[id].tips
				str = string.format( format, tipsTable[id].tips_p1, tipsTable[id].tips_p2, tipsTable[id].tips_p3)
			end
			return str
		else --black market

			format = tips[tonumber(tipsTable[id].tips2)]['msg']
			local arg1 = tipsTable[id].tips2_p1
			local arg2 = tipsTable[id].tips2_p2
			local arg3 = tipsTable[id].tips2_p3
			local arg4 = tipsTable[id].tips2_p4
			local arg5 = tipsTable[id].tips2_p5
			local blackInfo = blackStr --portData:getBlackMarckeInfo()
			if (arg1 == "") then
				arg1 = blackInfo
			elseif (arg2 == "") then
				arg2 = blackInfo
			elseif (arg3 == "") then
				arg3 = blackInfo
			elseif (arg4 == "") then
				arg4 = blackInfo
			elseif (arg5 == "") then
				arg5 = blackInfo
			end
			local str2 = string.format( format,arg1,arg2,arg3,arg4,arg5) 
			return str2
		end
	end

	-- sailor, relic, achievement, boat ,equip
	if (tipsTable[id].tips == nil) then
		str = "\n"
	elseif (isalnum(tipsTable[id].tips) == true) then
		cclog("tipsid:%d",tonumber(tipsTable[id].tips))
		format = tips[tonumber(tipsTable[id].tips)]['msg']
		str = string.format( format, tipsTable[id].tips_p1, tipsTable[id].tips_p2, tipsTable[id].tips_p3, tipsTable[id].tips_p4)
	else 
		format = tipsTable[id].tips
		str = string.format( format, tipsTable[id].tips_p1, tipsTable[id].tips_p2, tipsTable[id].tips_p3, tipsTable[id].tips_p4)
	end

	return str
end
return handle
