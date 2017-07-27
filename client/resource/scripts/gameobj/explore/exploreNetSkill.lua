--region bullet.lua
--Date
--此文件由[BabeLua]插件自动生成
require("resource_manager")

local clipAni_name = {
     move = "move",
     sousuo = "sousuo"
}

local exploreItemModel = require("gameobj/explore/exploreItemModel")

local ExploreNetSkill = class("ExploreNetSkill")

function ExploreNetSkill:ctor(param)
	param.clipName = clipAni_name
	param.speed = 250
	param.isSea = true
	self.audioCallBack = param.audioEffectCallBack
	local netModelObject = exploreItemModel.new(param)
	self.netModelObject = netModelObject
	local netModelNode = netModelObject.ModelNode
	if netModelObject.animation then
	    local ani_t = netModelObject.animation:getClipsTable()
	    self.moveAni = ani_t["move"]
	    self.EndNetAni = ani_t["sousuo"] --收网动画
		self.moveAni:play()
	end


    local shipPos = netModelObject.shipNode:getTranslationWorld() --
    local blPos = Vector3.new()
    local increment = netModelObject.ship:getShootPos()
    Vector3.add(shipPos, increment, blPos)
    netModelNode:setTranslation(blPos) 
    
    --方向
    local dir = Vector3.new()
    local targetPos = netModelObject.targetNode:getTranslation()
	Vector3.subtract(targetPos, blPos, dir) 
	dir:normalize()
    self.direction = dir

    local function time(dt) 
    	self:update(dt)
    end
	netModelObject:removeTimeHander()
	netModelObject:createCDTimer(time)
end

function ExploreNetSkill:hitTargetCB()
	if self == nil then
		return
	end
	local netModelObject = self.netModelObject
	netModelObject:removeTimeHander()
	if self.audioCallBack then
		self.audioCallBack()  --播放音效
	end
	self.moveAni:stop()
	netModelObject.targetData.spItem.is_pause = true
	self.EndNetAni:play()
	local actions = CCArray:create()
	actions:addObject(CCDelayTime:create(0.2))
	local function callBack()
		self.EndNetAni:stop()
	end
	local funcCallBack = CCCallFunc:create(callBack)
	actions:addObject(funcCallBack)
	--过0.3秒
	actions:addObject(CCDelayTime:create(0.1))
	local function endCallBack()
		netModelObject.targetCallBack()
		netModelObject.targetData.spItem.is_pause = false
		self:Release()
	end
	actions:addObject(CCCallFunc:create(endCallBack))
	local action = CCSequence:create(actions)
	netModelObject.targetData.spItem.ui:runAction(action)
end

function ExploreNetSkill:update(elapsedTime)
	if self == nil then
		return
	end
    local netModelObject = self.netModelObject
    local netNode = netModelObject.ModelNode
    if netNode then
		local targetTran = netModelObject.targetNode:getTranslation()
		local netNodeTrans = netNode:getTranslation()
		local direction = Vector3.new()
		Vector3.subtract(targetTran, netNodeTrans, direction) 
		direction:normalize()

		local tmpForward = Vector3.new()
		tmpForward:set(direction:x(), direction:y(), direction:z())
		local speed = netModelObject.speed
		tmpForward:scale(speed * elapsedTime)
		
		local point1 = netNode:getTranslationWorld()
		netNode:translate(tmpForward)
		if GetVectorDistance(point1, targetTran) <= tmpForward:length() then
			self:hitTargetCB(self)
		end
    end
end

function ExploreNetSkill:Release()
    local netModelObject = self.netModelObject
    if netModelObject then
        netModelObject:removeTimeHander()
        netModelObject:removeNode()
        netModelObject:release()
        netModelObject = nil
        self.moveAni = nil
        self.EndNetAni = nil
        self.netModelObject = nil
        self = nil
    end
end

return ExploreNetSkill
