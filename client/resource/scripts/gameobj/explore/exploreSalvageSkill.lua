
--Date
--此文件由[BabeLua]插件自动生成
require("resource_manager")

local clipAni_name = {
    zhaoshou = "zhaoshou",
    jump = "jump"
}
local boat_info = require("game_config/boat/boat_info")
local exploreItemModel = require("gameobj/explore/exploreItemModel")
local commonBase = require("gameobj/commonFuns")

local netModels = {}

local function createDelayAction(time, callBack)
	local actions = CCArray:create()
	actions:addObject(CCDelayTime:create(time))
	local funcCallBack = CCCallFunc:create(callBack)
	actions:addObject(funcCallBack)
	local action = CCSequence:create(actions)
	return action
end

local ExploreSalVageSkill = class("ExploreSalVageSkill")

function ExploreSalVageSkill:ctor(param)
	param.isSea = true
	param.clipName = clipAni_name
	param.effectFile = "salvage.modelparticles"
	local ModelObject = exploreItemModel.new(param)
	self.ModelObject = ModelObject
	local duration = 0
	self.m_is_play_jump_clip = true
	if self.ModelObject.animation then
	    local ani_t = self.ModelObject.animation:getClipsTable()
	    self.curAni = ani_t["jump"]
		self.jumpClip = ani_t["zhaoshou"]
		self.jumpClip:play()
		duration = self.jumpClip:getDuration()
		self.jumpClip:addEndListener("scripts/gameobj/gameplayFunc.lua#animationClipPlayEnd")
		netModels[#netModels + 1] = self
		self.jumpClip:setRepeatCount(1)
	end

    local shipPos = ModelObject.shipNode:getTranslationWorld() --船模型
    self.shipLeftNode = ModelObject.shipNode:findNode("left", true)
	self.shipRightNode = ModelObject.shipNode:findNode("right", true)
	--决定用哪个挂点
	local exploreItemPos = ModelObject.targetNode:getTranslationWorld()
	local leftPos = self.shipLeftNode:getTranslation()  --左边挂点
	local rightPos = self.shipRightNode:getTranslation() --右边挂点
	local posNode = nil
	local trueLeftPos = Vector3.new()
    Vector3.add(shipPos, leftPos, trueLeftPos)
    local trueRightPos = Vector3.new()
    Vector3.add(shipPos, rightPos, trueRightPos)
	if GetVectorDistance(exploreItemPos, trueLeftPos) < GetVectorDistance(exploreItemPos, trueRightPos) then
		posNode = self.shipLeftNode
	else
		posNode = self.shipRightNode
	end
	--模型的位置
	local modelPos = Vector3.new()
    local increment = posNode:getTranslation()
    Vector3.add(shipPos, increment, modelPos)
    ModelObject.ModelNode:setTranslation(modelPos)
 	self.modelStartPos = modelPos
 	local actualJumpRange = 0
 	local dis = GetVectorDistance(exploreItemPos, modelPos)
 	local exploreData = getGameData():getExploreData()
 	local shipInfo = exploreData:getShipInfo()
	local boatInfo = boat_info[shipInfo.id]
	local jumpRange = boatInfo.jump_range
 	if dis < jumpRange then
 		actualJumpRange = dis / 6
 	else
 		actualJumpRange = jumpRange / 6
 	end
 	ModelObject.speed = actualJumpRange / duration * 1000
    --
    local targetPos = Vector3.new()
	local direction = Vector3.new()
	Vector3.subtract(exploreItemPos, modelPos, direction)	
	direction:normalize()
	local positiveDir = Vector3.new(direction:x(), direction:y(), direction:z())
	self.positiveDirection = positiveDir
	direction:scale(actualJumpRange)
	Vector3.add(modelPos, direction, targetPos)
	self.targetPos = targetPos
	--旋转角度
	local directionZ = Vector3.new(0, 0, -1)
	local normalDirection = Vector3.new(self.positiveDirection:x(), 0, self.positiveDirection:z())
	local angle = Vector3.angle(directionZ, normalDirection)
	if modelPos:x() < exploreItemPos:x() then
		angle = -angle
	else
		angle = angle
	end
	self.rotateAngle = angle
	ModelObject.ModelNode:rotateY(angle)
	--创建CD
    self.ModelObject:removeTimeHander()
    local function time(dt) 
    	self:update(dt)
    end
	self.ModelObject:createCDTimer(time)
	--延迟0.95秒, 播放水花特效 
	local function callBack()
		local modelPos = self.ModelObject.ModelNode:getTranslationWorld()
		local vec = Vector3.new(modelPos:x(), 0, modelPos:z())
		local parent = Explore3D:getLayerSea3d()
		local waterNode, particle = commonBase:addNodeEffect(parent, "tx_shuihua", vec)
		self.WaterParticle = particle
		local direction = self.positiveDirection
		local tmpForward = Vector3.new()
		tmpForward:set(direction:x(), direction:y(), direction:z())
		tmpForward:scale(60)
		waterNode:translate(tmpForward)
		particle:Start()
	end
	local action = createDelayAction(0.95, callBack)
	self.ModelObject.targetData.spItem.ui:runAction(action)
end

function ExploreSalVageSkill:hitTargetCB()
	if self == nil then
		return
	end
	
	local ModelObject = self.ModelObject
	ModelObject:removeTimeHander()

	
	local function callBack()
		ModelObject.ModelNode:setActive(false)
		self.jumpClip:stop()

		local function endFunc( )
			ModelObject:hideEffects()
			ModelObject:releaseEffect()
			ModelObject:removeNode()
			ModelObject:release()
			ModelObject.targetCallBack()
			--
			if self.WaterParticle then
				self.WaterParticle:Stop() --删除水花特效
				self.WaterParticle:Release()
				self.WaterParticle = nil
			end
			ModelObject = nil
		end
		
		if not ModelObject.targetData.spItem.node then
			endFunc()
			return
		end

		local endPos = ModelObject.targetData.spItem.node:getTranslation()
		ModelObject.ModelNode:setTranslation(endPos)
		
		local function removeCallBack()
			ModelObject.ModelNode:setActive(true)
			ModelObject.targetData.spItem:hideAllEffect()
			--设置角度
			ModelObject.ModelNode:rotateY(-self.rotateAngle)
			local directionZ = Vector3.new(0, 0, -1)
			local normalDirection = Vector3.new()
			Vector3.subtract(self.modelStartPos, endPos, normalDirection)
			local angle = Vector3.angle(directionZ, normalDirection)
			if self.modelStartPos:x() < endPos:x() then
				angle = angle
			else
				angle = -angle
			end
			ModelObject.ModelNode:rotateY(angle)
			--
			ModelObject.targetData.spItem.ui:stopAllActions()
			--
			self.curAni:play()
			ModelObject:showEffects()
			ModelObject.tipCallBack()
			local function endBack()
				ModelObject.targetData.spItem.ui:stopAllActions()
				local action = createDelayAction(0.5, endFunc)
				ModelObject.targetData.spItem.ui:runAction(action)
			end
			local action = createDelayAction(0.5, endBack)
			ModelObject.targetData.spItem.ui:runAction(action)
		end
		
		local action = createDelayAction(1.0, removeCallBack)
		ModelObject.targetData.spItem.ui:runAction(action)
	end
	callBack()
end

function ExploreSalVageSkill:update(elapsedTime)
	if self == nil then
		return
	end

	if self.m_is_play_jump_clip and not self.jumpClip:isPlaying() then
		self.m_is_play_jump_clip = false
		self:hitTargetCB()
	end

	local ModelObject = self.ModelObject
    local modelNode = ModelObject.ModelNode
    if modelNode then
		local targetTran = self.targetPos
		local direction = self.positiveDirection
		local tmpForward = Vector3.new()
		tmpForward:set(direction:x(), direction:y(), direction:z())
		local speed = ModelObject.speed
		tmpForward:scale(speed * elapsedTime)
		
		local point1 = modelNode:getTranslationWorld()
		modelNode:translate(tmpForward)
		if GetVectorDistance(point1, targetTran) <= tmpForward:length() then
			--self:hitTargetCB(self)
		end
    end


end

return ExploreSalVageSkill
