
require("resource_manager")

local ExploreBullet = class("ExploreBullet")
local exploreItemModel = require("gameobj/explore/exploreItemModel")

function ExploreBullet:ctor(param)
    param.effectFile = "pd_03.modelparticles"
    param.modelFile = "pd_03"
    param.speed = param.speed or 500
    self.down = param.down
    local bulletModelObject = exploreItemModel.new(param)
    self.bulletModelObject = bulletModelObject
    local bulletNode = bulletModelObject.ModelNode

    bulletModelObject:showEffects()
    
    --local centrePt = Vector3.new()
    --centrePt:set(0,0,0)

    local mat = bulletModelObject.shipNode:getWorldMatrix()
    local blPos = Vector3.new(param.ship:getShootPos())
    mat:transformPoint(blPos)
    
    bulletNode:setTranslation(blPos)
    bulletModelObject.ship:showFireRes()
    bulletModelObject:removeTimeHander()
    local function time(dt) 
        self:update(dt)
    end
    bulletModelObject:createCDTimer(time)
end

function ExploreBullet:hitTargetCB(bullet)
	if self == nil then
		return
	end
	local bulletModelObject = self.bulletModelObject
	local targetCallBack = bulletModelObject.targetCallBack
	targetCallBack()
	self:Release()

end

function ExploreBullet:update(elapsedTime)
    local exploreLayer = getExploreLayer()
    if self == nil then
    	return
    end
    if tolua.isnull(exploreLayer) then
        local bulletModelObject = self.bulletModelObject
        bulletModelObject:removeTimeHander()
        return
    end

    local bulletModelObject = self.bulletModelObject
    local bulletNode = bulletModelObject.ModelNode
    if bulletNode then
		local targetNode = bulletModelObject.targetNode
		
		local targetTran = targetNode:getTranslation()
		local targetPos = Vector3.new()
		Vector3.add(targetTran, Vector3.new(0, self.down, 0), targetPos)
		LookAtPoint(bulletNode, targetPos)

		local bulletTrans = bulletNode:getTranslation()
		local tmpForward = bulletNode:getForwardVectorWorld():normalize()
		local speed = bulletModelObject.speed
		tmpForward:scale(speed * elapsedTime)
		local position = Vector3.new()
		Vector3.add(bulletTrans, tmpForward, position)

		local point1 = bulletNode:getTranslationWorld()
		if GetVectorDistance(point1, targetPos) <= tmpForward:length() then
			bulletNode:setTranslation(targetPos)
			self:hitTargetCB(self)
		else					
			bulletNode:setTranslation(position)
        end
    end	
end

function ExploreBullet:Release()
    local bulletModelObject = self.bulletModelObject
    if bulletModelObject then
        bulletModelObject:removeTimeHander()
        bulletModelObject:hideEffects()
        bulletModelObject:releaseEffect()	
        bulletModelObject:removeNode()
        bulletModelObject:release()
        self.bulletModelObject = nil
        self = nil
    end
end

return ExploreBullet
