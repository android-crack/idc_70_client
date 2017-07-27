-- 行走管理

local WalkManager = {}

local explore_layer 
local LAND_OFF = 64

function WalkManager.init(layer)
	explore_layer = layer
end 

-- 碰撞检测
function WalkManager.checkCollision(ship, screen_pos)
	
	local pos = ccp(screen_pos:x(), screen_pos:y())
	local forward = ship.node:getForwardVectorWorld():normalize()
	forward:scale(LAND_OFF)
	local d_pos = gameplayToCocosWorld(forward)
	
	if not WalkManager.checkLand(pos, d_pos) then 
		return false
	
	elseif not WalkManager.checkShip(ship) then 
		return false
	end 
	return true
end 


-- 陆地碰撞检测
function WalkManager.checkLand(pos, d_pos)
	
	if explore_layer.land:checkHit(pos, d_pos) then 
		return false 
	end 
	
	return true 
end 

-- 陆地碰撞检测
function WalkManager.checkLandPosX(screen_pos)
	local pos = ccp(screen_pos:x(), screen_pos:y())
	return explore_layer.land:checkHitPosX(pos) 
end 

-- 陆地碰撞检测
function WalkManager.checkLandPosY(screen_pos)
	local pos = ccp(screen_pos:x(), screen_pos:y())
	return explore_layer.land:checkHitPosY(pos) 
end 

--边界四个角的处理
function WalkManager.getCollisionPos(screen_pos)
	local pos = ccp(screen_pos:x(), screen_pos:y())
	return explore_layer.land:checkCollisionPos(pos) 
end 

--边界处理
function WalkManager.getBoundPos(screen_pos)
	local pos = ccp(screen_pos:x(), screen_pos:y())
	return explore_layer.land:checkBoundPos(pos) 
end 

-- 船之间碰撞
function WalkManager.checkShip(ship_data)
	
	return true 
end

return WalkManager
