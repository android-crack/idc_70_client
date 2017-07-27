local skill_warning = require("game_config/skill/skill_warning")
local ClsBattleSetBuff = class("ClsBattleSetBuff", require("gameobj/battle/view/base"))

local BUFF = {}
BUFF[battle_config.chaofeng] = skill_warning.CHAOFENG.msg
BUFF[battle_config.tuji] = skill_warning.STATUS_LIMIT.msg

function ClsBattleSetBuff:ctor(id, key, flg)
	self:InitArgs(id, key, flg)
end

function ClsBattleSetBuff:InitArgs(id, key, flg)
	self.id = id

	self.key = key

	self.flg = tonumber(flg) == 1

	self.args = {id, key, flg}
end

function ClsBattleSetBuff:GetId()
    return "battle_set_buff"
end

function ClsBattleSetBuff:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		local v = nil
		if self.flg then
			v = BUFF[self.key]
		end
	end
end

return ClsBattleSetBuff
