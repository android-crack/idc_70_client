local ClsLookAtPointAnimation = class("ClsLookAtPointAnimation", require("gameobj/battle/view/base"))

function ClsLookAtPointAnimation:ctor(params)
	self.args = {}

	if not params then return end

    self:InitArgs(params.attacker_id, params.target_id, params.interval, params.dt)
end

function ClsLookAtPointAnimation:InitArgs(attacker_id, target_id, interval, dt)
    self.attacker_id = attacker_id
    self.target_id = target_id
    self.interval = interval
    self.dt = dt

    self.args = {attacker_id, target_id, interval, dt}
end

function ClsLookAtPointAnimation:GetId()
    return "look_at_point_animation"
end

-- 播放
function ClsLookAtPointAnimation:Show()
	local battle_data = getGameData():getBattleDataMt()
	local attacker = battle_data:getShipByGenID(self.attacker_id)
	local target = battle_data:getShipByGenID(self.target_id)
	if attacker and attacker.body and attacker.body.node and 
		target and target.body and target.body.node then
		LookAtPointAnimation(attacker.body.node, target.body.node:getTranslation(), self.interval, self.dt)
	end
end

return ClsLookAtPointAnimation
