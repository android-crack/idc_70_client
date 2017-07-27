local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCameraScale = class("ClsAIActionCameraScale", ClsAIActionBase) 

function ClsAIActionCameraScale:getId()
	return "camera_scale"
end

function ClsAIActionCameraScale:initAction(scale, time, x, y)
	self.scale = scale * BATTLE_SCALE_RATE
	self.time = time or 0
	if x and y then
		self.position = ccp(x, y)
	end
end

function ClsAIActionCameraScale:__dealAction(target_id, delta_time)
	local scheduler = CCDirector:sharedDirector():getScheduler()

	local scale = self.scale

	local battle_data = getGameData():getBattleDataMt()

	--local scale_min = battle_data:GetData("scale_min")
	--local scale_max = battle_data:GetData("scale_max")
	--scale = Math.clamp(scale_min, scale_max, scale)

	local vec
	if self.position then
		vec = cocosToGameplayWorld(self.position)
	else
		local target_obj = battle_data:getShipByGenID(target_id)

		if not target_obj or target_obj:is_deaded() then return end

		local target = target_obj.body.node

		if not target then return end

		vec = target:getTranslationWorld()
	end

	CameraFollow:SetFreeMove(vec)

	local pos = ccp(display.cx, display.cy)
	
	if self.time <= 0 then 
		CameraFollow:ScaleByScreenPos(scale, pos)
	else 
		local battle_layer = battle_data:GetLayer("battle_scene_layer")
		local old_scale = battle_layer:getScale()
		local dscale = (scale - old_scale)/self.time
		local time_count = 0
		local function doScale(dt)
			if time_count >= self.time then 
				local battle_data = getGameData():getBattleDataMt()
				battle_data:StopScheduler("camera_scale")
				return 
			end 
			time_count = time_count + dt*1000
			local new_scale = old_scale + dscale*time_count
			CameraFollow:ScaleByScreenPos(new_scale, pos)
		end
		
		battle_data:SetScheduler("camera_scale", doScale, 0, false)
	end 
end

return ClsAIActionCameraScale
