local ClsBattleCameRafollow = class("ClsBattleCameRafollow", require("gameobj/battle/view/base"))

function ClsBattleCameRafollow:ctor(base_id, trans_type, delay, lock_time)
	self:InitArgs(base_id, trans_type, delay, lock_time)
end

function ClsBattleCameRafollow:InitArgs(base_id, trans_type, delay, lock_time)
    self.base_id = base_id
    self.trans_type = trans_type
    self.delay = delay
    self.lock_time = lock_time

    self.args = {base_id, trans_type, delay, lock_time}
end

function ClsBattleCameRafollow:GetId()
    return "battle_camera_follow"
end

-- 播放
function ClsBattleCameRafollow:Show()
	local battleData = getGameData():getBattleDataMt()

	local follow_obj = battleData:GetShipByBaseId(self.base_id)

	if not follow_obj or follow_obj:is_deaded() then return false end

	local camera = require("gameobj/battle/ai/action/camera_follow")

	camera:follow(follow_obj, self.trans_type, self.delay, self.lock_time)
end

return ClsBattleCameRafollow
