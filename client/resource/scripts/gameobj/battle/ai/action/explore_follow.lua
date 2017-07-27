
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionFollow = class("ClsAIActionFollow", ClsAIActionBase) 

function ClsAIActionFollow:getId()
	return "follow"
end

-- 
function ClsAIActionFollow:initAction( range, duration )
    local battleData = getGameData():getBattleDataMt()
    self.range = range or 100

    -- 设置持续时间无限长
    self.duration = duration or 99999999 

    self.auto_time = 0
    self.time_out = math.random(0, 9)/10 + 5

    -- 设置船只行驶目标点
    local ai_obj = self:getOwnerAI();

    self.follow_uid = ai_obj:getData("__follow_ship_uid")
    self.get_ship_func = ai_obj:getData("__get_ship_func_by_uid")
    self.miss_ship_func = ai_obj:getData("__miss_ship_func_by_uid")
    self.is_call_missing = false
end

local LEVEL2 = 155
local LEVEL3 = 310
local LEVEL_MAX = 1000
local AUTO_MOVE_DIS = 250
local BREAK_MOVE_DIS = 130

local function getChangeSpeedRate(dis_n, l1, l2, l3)
	if dis_n < l1 then
		return dis_n/l1 --(0~1)
	elseif dis_n < l2 then
		return 0.2*(dis_n - l1)/(l2 - l1) + 1 --(1.0 ~ 1.2)
	elseif dis_n < l3 then
		return 0.3*(dis_n - l2)/(l3 - l2) + 1.2
	else
		return 1.7
	end
end

local function lookAtTarget(owner_obj, follow_obj)
	LookAtPoint(owner_obj.node, follow_obj.node:getTranslationWorld())
end

function ClsAIActionFollow:__dealAction( target, delta_time )
	-- 没有followId返回
	if ( not self.follow_uid ) or (not self.get_ship_func) then return false end
	local follow_obj = self.get_ship_func(self.follow_uid)
	local ai_obj = self:getOwnerAI()
	local owner_obj = ai_obj:getOwner();
	if ( not follow_obj) then 
		if not self.is_call_missing then
			self.is_call_missing = true
			owner_obj:setPause(true)
			if self.miss_ship_func then
				self.miss_ship_func()
			end
		end
		return false
	end
	self.is_call_missing = false
	local fx, fy = follow_obj:getPos()
	local ox, oy = owner_obj:getPos()
	local dis_n = Math.distance(fx, fy, ox, oy) --(fx - ox)*(fx - ox) + (fy - oy)*(fy - oy)
	local total_speed = follow_obj:getTargetTotalSpeed()
	local my_speed = follow_obj:getSpeed()
	local normal_rate = total_speed/my_speed * getChangeSpeedRate(dis_n, self.range, LEVEL2, LEVEL3)
	owner_obj:setSpeedRate(normal_rate)
	if dis_n < self.range then
		owner_obj:setSpeedRate(normal_rate)
		if (dis_n < self.range/2) then
			if owner_obj:isAutoRunning() then
				owner_obj:stopAutoHandler()
			end
			owner_obj:setPause(true)
			return false
		else
			owner_obj:setPause(false)
			lookAtTarget(owner_obj, follow_obj)
			return true
		end
	end

	if dis_n >= LEVEL_MAX then
		if owner_obj:isAutoRunning() then
			owner_obj:stopAutoHandler()
		end
		owner_obj:setPause(true)
		owner_obj:setPos(fx, fy)
		return false
	end

	if dis_n < BREAK_MOVE_DIS then
		if owner_obj:isAutoRunning() then
			owner_obj:stopAutoHandler()
		end
		owner_obj:setPause(false)
	elseif dis_n < AUTO_MOVE_DIS then
		if owner_obj:isAutoRunning() then
			self.auto_time = self.auto_time + delta_time
			if self.auto_time >= self.time_out then
				owner_obj:stopAutoHandler()
				owner_obj:setPause(false)
			end
		else
			owner_obj:setPause(false)
		end
	else
		if owner_obj:isAutoRunning() then
			self.auto_time = self.auto_time + delta_time
			if self.auto_time >= self.time_out then
				owner_obj:stopAutoHandler()
				owner_obj:goToDesitinaionWithPos(ccp(fx, fy))
				self.auto_time = 0
			end
		else
			owner_obj:goToDesitinaionWithPos(ccp(fx, fy))
			self.auto_time = 0
		end
	end
	
	if not owner_obj:isAutoRunning() then
		lookAtTarget(owner_obj, follow_obj)
	end
	
	return true
end

return ClsAIActionFollow
