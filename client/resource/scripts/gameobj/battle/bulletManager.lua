local bulletCls = require("gameobj/battle/bullet")

-- 创建炮弹
local function createBullets(params, delayTm)
	delayTm = delayTm or 150
	delayTm = delayTm/1000
	local array = CCArray:create()
	
	for i = 1, #params do
		local param = params[i]
		
		local callback =  function()
				bulletCls.new(param)
			end
		local callFunc = CCCallFunc:create(callback)
		array:addObject(callFunc) 
		local delay = CCDelayTime:create(delayTm)
		array:addObject(delay)
	end
	display.getRunningScene():runAction(CCSequence:create(array))
end

local bulletEntity = {
	createBullets = createBullets,
}

return bulletEntity