local ClsBattleCreateGoal = class("ClsBattleCreateGoal", require("gameobj/battle/view/base"))

function ClsBattleCreateGoal:ctor(txt)
    self:InitArgs(txt)
end

function ClsBattleCreateGoal:InitArgs(txt)
	self.txt = txt

    self.args = {txt}
end

function ClsBattleCreateGoal:GetId()
    return "battle_create_goal"
end

-- 播放
function ClsBattleCreateGoal:Show()
	local battle_data = getGameData():getBattleDataMt()

	local battle_ui = battle_data:GetLayer("battle_ui")

	if tolua.isnull(battle_ui) then return end

	battle_ui:showPrompt(self.txt)
end

return ClsBattleCreateGoal
