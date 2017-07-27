-- 一些辅助函数

local CommonFuns = {}

function CommonFuns:parserTime(value)  -- 把时间秒 分解成 秒、分、时、天
	local days, hours, minute, sec = 0, 0, 0, 0
	if value > 0 then 
		days = math.floor(value/86400)
		value = math.mod(value, 86400)
		hours = math.floor(value/3600)
		value = math.mod(value, 3600)
		minute = math.floor(value/60)
		value = math.mod(value, 60)
		sec = value	
	end 
	return  days, hours, minute, sec 
end 


return CommonFuns