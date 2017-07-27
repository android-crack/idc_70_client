local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCameraFollow = class("ClsAIActionCameraMove", ClsAIActionBase) 

function ClsAIActionCameraFollow:getId()
	return "camera_follow"
end

function ClsAIActionCameraFollow:initAction(target_base_id, trans_type, delay, lock_time)
	self.target_base_id = target_base_id
	self.trans_type = trans_type or 0 -- 过度类型（0移动，1淡入淡出）
	self.delay = delay or 1
	self.lock_time = lock_time or 0
	self.duration = 99999999
end

function ClsAIActionCameraFollow:__beginAction(target_id, delta_time)
	local battleData = getGameData():getBattleDataMt()

	local follow_obj

	if self.target_base_id > 0 then
		follow_obj = battleData:GetShipByBaseId(self.target_base_id)
	else
		follow_obj = battleData:getShipByGenID(target_id)
	end

	if not follow_obj or follow_obj:is_deaded() then return false end

	local battleLayer = battleData:GetTable("battle_layer")
	-- 暂停战斗
	battleLayer.setBattlePaused(true)

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_camera_follow", 
		self.target_base_id, self.trans_type, self.delay, self.lock_time)

	return self:follow(follow_obj, self.trans_type, self.delay, self.lock_time)
end

function ClsAIActionCameraFollow:follow(follow_obj, trans_type, delay, lock_time)
	local battleData = getGameData():getBattleDataMt()

	CameraFollow:StopShake()

	if trans_type == 1 then
		-- 淡入淡出
		self:transformMask(follow_obj, delay, lock_time)
		return true
	end

	local battleLayer = battleData:GetTable("battle_layer")

	-- 镜头旋转效果
	-- 如果持续时间为0，直接将镜头切到目标
	if delay <= 0 then
		local node = follow_obj.body.node
		CameraFollow:LockTarget(node)
		battleLayer.setBattlePaused(false)
		self.duration = 0
		return false 
	end
	
	local scene3D = BattleInit3D:getScene()
	local camNode = scene3D:findNode("Camera")
	if not camNode then
		camNode = scene3D:addNode("Camera")
	end
	
	local sPos = ScreenToVector3(display.cx, display.cy, scene3D:getActiveCamera())
	local ePos = follow_obj:getPosition3D()
	camNode:setTranslation(sPos)
	CameraFollow:LockTarget(camNode)

	local keyCount = 2
	local keyTimes = {0, delay*1000}
	local keyValues = {sPos:x(), 0, sPos:z(), ePos:x(), 0, ePos:z()}

	local anim = camNode:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(),
	keyCount, keyTimes, keyValues, "LINEAR")
	anim:play()

	-- 船体效果
	local ac1 = CCDelayTime:create(delay)
	local ac2 = CCCallFunc:create(function()
		local node = follow_obj.body.node
		CameraFollow:LockTarget(node)
		CameraFollow:setLockLockTarget(lock_time)
		battleLayer.setBattlePaused(false)
		self.duration = 0
	end)
	local ac = CCSequence:createWithTwoActions(ac1, ac2)
	follow_obj.body.acSp:runAction(ac)

	return true
end

-- mask层的播放参数
local tmFadeIn = 500
local tmFadeOut = tmFadeIn 

function ClsAIActionCameraFollow:transformMask(follow_obj, delay, lock_time)
	local battleData = getGameData():getBattleDataMt()
	local battleLayer = battleData:GetTable("battle_layer")

	-- 创建一个遮罩层
	local mask_layer = CCLayerColor:create(ccc4(0,0,0,255))

	-- 加入场景
	battleData:GetLayer("battle_scene"):addChild(mask_layer, 30)
	-- 设置透明度
	mask_layer:setOpacity(0.5)

	local actions = {}
	actions[1] = CCFadeIn:create(tmFadeIn/1000.0)
	actions[2] = CCDelayTime:create(delay)
	actions[3] = CCCallFunc:create( function()
		local node = follow_obj.body.node
		CameraFollow:LockTarget(node)
		CameraFollow:setLockLockTarget(lock_time)
	end)
	actions[4] = CCFadeOut:create(tmFadeOut/1000.0)
	actions[5] = CCCallFunc:create( function()
		mask_layer:removeFromParentAndCleanup(true)
		battleLayer.setBattlePaused(false)
		self.duration = 0
	end)
	
	local action = transition.sequence(actions)
	mask_layer:runAction(action)
end

return ClsAIActionCameraFollow
