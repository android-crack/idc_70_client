-- 用于UI上的3D相关的内容

require("resource_manager")

local ClsModel3D = require("gameobj/model3d")
local Sprite3D = class("Sprite3D", ClsModel3D)

function Sprite3D:ctor(param)
	self.is_pause = false 
	self.path = param.path
	self.ship_ui = param.ship_ui
	self.child_ui = param.child_ui
	self.ani_name = param.ani_name or ""
	self.node_name = param.node_name
	
	-- if param.key then 
		-- local boat_data = getGameData():getBoatData()
		-- local data = boat_data:getBoatDataByKey(param.key)
		-- if data then
			-- param.star_level = data.star -- 星级
		-- end 
	-- end 
	
	Sprite3D.super.ctor(self, param)
	
	if not tolua.isnull(self.ship_ui) then
		self.ui = CCNode:create()
		self.ship_ui:addChild(self.ui, 100)
	end

	if not tolua.isnull(self.child_ui) then
		self.child_2d = CCNode:create()
		self.child_ui:addChild(self.child_2d, 100)
	end
	
	local pos = param.pos
	self:setPos(pos.x, pos.y)
	if pos.angle then 
		self:setAngle(pos.angle)
	end

	if param.hit_radius then 
		self:initCollision()
	end

	self:playAnimation("move", true)
end

function Sprite3D:addChildSprite2d(sprite)
	self.child_2d:addChild(sprite)
end

function Sprite3D:addSprite2d(sprite)
	self.ui:addChild(sprite)
end

function Sprite3D:initCollision()	
	local boundingSphere = self.node:getBoundingSphere()
	self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.sphere(boundingSphere:radius()/2))
	self.node:getCollisionObject():addCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
end

function Sprite3D:removeCollision()
	local collsionObject = self.node:getCollisionObject()
	if collsionObject then 
		collsionObject:removeCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
		self.node:setCollisionObject("NONE")
	end 
end

-- 直接设置角度（规定顺时针为正）
function Sprite3D:setAngle(angle)
	local axis = self.node:getUpVector()
	self.node:setRotation(axis, math.rad(-angle))
end 

function Sprite3D:getAngle()
	local forward = self.node:getForwardVectorWorld()
	local originVec3 = Vector3.new(0,0,-1)
	local angle = math.deg(Vector3.angle(forward, originVec3))
	
	if IsVectorAtRight(self.node, originVec3) then
		angle = -angle 
	end 	
	return angle
end 

function Sprite3D:setPause(pause)
	self.is_pause = pause
end 

function Sprite3D:isPause()
	return self.is_pause
end 

function Sprite3D:setPos(x, y)
	local pos = CameraFollow:cocosToGameplayWorld(ccp(x, y))
	self.node:setTranslation(pos)
	if not tolua.isnull(self.ui) then 
		self.ui:setPosition(x, y)
	end

	if not tolua.isnull(self.child_2d) then
		self.child_2d:setPosition(x, y)
	end
end 

function Sprite3D:getPos()
	local translation = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translation)
	return pos.x, pos.y
end 

function Sprite3D:playAnimation(name, isRepeat)
	local path = self.path 
	local res = self.ani_name 
	
	local animation = self.node:getAnimation("animations")
	if not animation then return end 
	
	local clip = animation:getClip(name)
	if not clip then 
		--clip = animation:getClip(animation[1])
		return 
	end 
	
	if isRepeat then
		clip:setRepeatCount(0)
	else
		clip:setRepeatCount(1)
	end
    if self.curAni then
	    self.curAni:crossFade(clip, 300)
    else
        clip:play()
    end
	self.curAni = clip
end

function Sprite3D:release()
	self.curAni = nil
	self:removeCollision()
	Sprite3D.super.release(self)
	--GameUtil.luaFullGc()
end

return Sprite3D