local ClsBattleGuidePoint = class("ClsBattleGuidePoint", require("gameobj/battle/view/base"))

function ClsBattleGuidePoint:ctor(id, is_visible, x, y, texture)
    self:InitArgs(id, is_visible, x, y, texture)
end

function ClsBattleGuidePoint:InitArgs(id, is_visible, x, y, texture)
	self.id = id
    self.is_visible = is_visible
    self.x = x
    self.y = y
    self.texture = texture

    self.args = {id, is_visible, x, y, texture}
end

function ClsBattleGuidePoint:GetId()
    return "battle_guide_point"
end

-- 播放
function ClsBattleGuidePoint:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.id)
	if ship and ship:getBody() then
		if not self.is_visible then
			ship:getBody():closeShipYellowPathNode(self.is_visible)
			return
		end
		ship:getBody():addTargetPathEffect(cocosToGameplayWorld({x = self.x, y = self.y}), self.texture, true)
	end
end

return ClsBattleGuidePoint
