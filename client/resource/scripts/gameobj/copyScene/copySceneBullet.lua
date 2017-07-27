
local ExploreBulletCls = require("gameobj/explore/exploreBullet")

local CopySceneBullet = class("CopySceneBullet", ExploreBulletCls)

function CopySceneBullet:removeHander( ... )
    local bulletModelObject = self.bulletModelObject
    bulletModelObject:removeTimeHander()
end

function CopySceneBullet:update(elapsedTime)
    local bulletModelObject = self.bulletModelObject
    local bulletNode = bulletModelObject.ModelNode
    if bulletNode then
		local targetNode = bulletModelObject.targetNode
		
		local targetTran = targetNode:getTranslation()
		local targetPos = Vector3.new()
		targetPos:set(0, self.down, 0)
		Vector3.add(targetTran, Vector3.new(0, self.down, 0), targetPos)
		LookAtPoint(bulletNode, targetPos)

		local bulletTrans = bulletNode:getTranslation()
		local forward = bulletNode:getForwardVectorWorld():normalize()
		local tmpForward = Vector3.new()
		tmpForward:set(forward:x(), forward:y(), forward:z())
		local speed = bulletModelObject.speed
		tmpForward:scale(speed * elapsedTime)
		local position = Vector3.new()
		Vector3.add(bulletTrans, tmpForward, position)

		local point1 = bulletNode:getTranslationWorld()
		if GetVectorDistance(point1, targetPos) <= tmpForward:length() then
			bulletNode:setTranslation(targetPos)
			self:hitTargetCB()
		else					
			bulletNode:setTranslation(position)
        end
    end	
end

return CopySceneBullet
