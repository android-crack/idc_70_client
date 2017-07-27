-- 其加载lua脚本机制和cocos 不同

local walkManager = require("gameobj/battle/walkManager")

-- 碰撞事件处理
function shipCollisionEvent(collidtype, colliderpair, vec1, vec2)
    if collidtype == "COLLIDING" then 
		local objA = colliderpair:objectA()
		local objB = colliderpair:objectB()
		local nodeA = objA:getNode()
		local nodeB = objB:getNode()
		walkManager.addCollisionObj(nodeA, nodeB, true, vec1, vec2)
		walkManager.addCollisionObj(nodeB, nodeA, true, vec2, vec1)
	elseif collidtype == "NOT_COLLIDING" then 
		local objA = colliderpair:objectA()
		local objB = colliderpair:objectB()
		local nodeA = objA:getNode()
		local nodeB = objB:getNode()
		walkManager.addCollisionObj(nodeA, nodeB, false, vec1, vec2)
		walkManager.addCollisionObj(nodeB, nodeA, false, vec2, vec1)
    end
end

--探索升降范动画
function exploreShipAnimationEnd(clip, type)
	local tempLayer = getExploreLayer()
	if not tolua.isnull(tempLayer) then
		tempLayer.player_ship:playAnimation("move2", true, true)
	end
end

function exploreShipAnimationEndUp(clip, type)
	local tempLayer = getExploreLayer()
	if not tolua.isnull(tempLayer) then
		tempLayer.player_ship:playAnimation("move", true, true)
	end
end

--打捞动画结束
function animationClipPlayEnd(clip, type) --动画播放完，调用
	local ExploreSalvageSkill = require("gameobj/explore/exploreSalvageSkill")
	EventTrigger(EVENT_EXPLORE_SET_SALVAGE_DATA)
end