--- 缓动效果相关
local tween={}
local scheduler=require("framework.scheduler")
--local util = require("gameobj.util")

local function init()
	tween.stopShakeFuncs = {}
	local stopShakeFuncs = tween.stopShakeFuncs
	setmetatable(stopShakeFuncs, {__mode="k"})
end

------ 初始化相关 ------------
init()
------------------------------

--------- 震屏效果( 显示对象, 持续时间, 水平振幅, 垂直振幅, 震动次数 ) -----------
function tween.shake(ccNode, duration, x, y, numShakes)
	local stopShakeFuncs = tween.stopShakeFuncs
	local passtime = 0
	local handle = 0
	local initX, initY = ccNode:getPosition()
	local lastOffsetX, lastOffsetY = 0, 0

	local update = function(dt)
		if tolua.isnull(ccNode) then
			scheduler.unscheduleGlobal(handle)
			return
		end

		passtime = passtime +  dt	

		local percent = passtime/duration
		if percent > 1 and stopShakeFuncs[ccNode] then
			stopShakeFuncs[ccNode]()
			return
		end

		local amplitude = math.sin((percent * (2*math.pi)) * numShakes)
		local decrease = 1 - percent
		local offsetX  = (x*amplitude*decrease);
		local offsetY  = (y*amplitude*decrease);
		ccNode:setPositionX( ccNode:getPositionX() - lastOffsetX + offsetX )
		ccNode:setPositionY( ccNode:getPositionY() - lastOffsetY + offsetY )
		lastOffsetX = offsetX
		lastOffsetY = offsetY
	end

	handle = scheduler.scheduleGlobal(update,0)	

	stopShakeFuncs[ccNode] = function()
		scheduler.unscheduleGlobal(handle)
		if not tolua.isnull(ccNode) then
			ccNode:setPosition(initX,initY)	
		end
		stopShakeFuncs[ccNode] = nil
	end
	return handle
end

---- 停止震屏效果( 显示对象 ) ------------
function tween.stopShake(ccNode)
	local stopShakeFuncs = tween.stopShakeFuncs
	if stopShakeFuncs[ccNode] then
		stopShakeFuncs[ccNode]()
	end
end

return tween
