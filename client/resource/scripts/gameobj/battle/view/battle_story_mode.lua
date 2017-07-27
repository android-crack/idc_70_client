local ClsBattleShowMiss = class("ClsBattleShowMiss", require("gameobj/battle/view/base"))

function ClsBattleShowMiss:ctor(story_mode)
	self:InitArgs(story_mode)
end

function ClsBattleShowMiss:InitArgs(story_mode)
    self.story_mode = story_mode

    self.args = {story_mode}
end

function ClsBattleShowMiss:GetId()
    return "battle_story_mode"
end

-- 播放
function ClsBattleShowMiss:Show()
	local battle_data = getGameData():getBattleDataMt()
    local ship_obj = battle_data:getShipByGenID(self.ship_id)

    if ship_obj and not ship_obj:is_deaded() then
    	require("gameobj/battle/shipEffectLayer").showMiss(ship_obj)
    end

    local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		if self.story_mode == FV_BOOL_TRUE then
			fight_ui:storyMode()
			return
		end

		fight_ui:normalMode()
	end
end

return ClsBattleShowMiss
