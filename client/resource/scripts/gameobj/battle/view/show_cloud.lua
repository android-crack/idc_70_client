local ClsShowCloud = class("ClsShowCloud", require("gameobj/battle/view/base"))

function ClsShowCloud:ctor(time, begin_x, begin_y, end_x, end_y)
    self:InitArgs(time, begin_x, begin_y, end_x, end_y)
end

function ClsShowCloud:InitArgs(time, begin_x, begin_y, end_x, end_y)
    self.time = time
    self.begin_x = begin_x
    self.begin_y = begin_y
    self.end_x = end_x
    self.end_y = end_y

    self.args = {time, begin_x, begin_y, end_x, end_y}
end

function ClsShowCloud:GetId()
    return "show_cloud"
end

-- 播放
function ClsShowCloud:Show()
	local battle_data = getGameData():getBattleDataMt()
	local effect_layer = battle_data:GetLayer("effect_layer")

	if tolua.isnull(effect_layer) then return end

	effect_layer:showCloud({self.time, {self.begin_x, self.begin_y}, {self.end_x, self.end_y}})
end

return ClsShowCloud
