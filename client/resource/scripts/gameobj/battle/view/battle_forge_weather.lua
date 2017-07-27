local ClsBattleForgeWeather = class("ClsBattleForgeWeather", require("gameobj/battle/view/base"))

function ClsBattleForgeWeather:ctor(duration)
    self:InitArgs(duration)
end

function ClsBattleForgeWeather:InitArgs(duration)
    self.duration = duration

    self.args = {duration}
end

function ClsBattleForgeWeather:GetId()
    return "battle_forge_weather"
end

-- 播放
function ClsBattleForgeWeather:Show()
	local battle_data = getGameData():getBattleDataMt()

	local battle_effect_layer = battle_data:GetLayer("effect_layer")

	battle_effect_layer:showStome(self.duration)
end

return ClsBattleForgeWeather
