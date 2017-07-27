local ClsBattlePlayPlot = class("ClsBattlePlayPlot", require("gameobj/battle/view/base"))

function ClsBattlePlayPlot:ctor(plot_list, camera_stop, sailor_id, name, role_id)
    self:InitArgs(plot_list, camera_stop, sailor_id, name, role_id)
end

function ClsBattlePlayPlot:InitArgs(plot_list, camera_stop, sailor_id, name, role_id)
    self.plot_list = plot_list
    self.camera_stop = camera_stop
    self.sailor_id = sailor_id
    self.name = name
    self.role_id = role_id

    self.args = {plot_list, camera_stop, sailor_id, name, role_id}
end

function ClsBattlePlayPlot:GetId()
    return "battle_play_plot"
end

-- 播放
function ClsBattlePlayPlot:Show()
	local battlePlot = require("gameobj/battle/battlePlot")
	local dataTools = require("module/dataHandle/dataTools")

	local battle_data = getGameData():getBattleDataMt()
	local battle_field_data = battle_data:GetData("battle_field_data")
	if not battle_field_data then return end

	local data = dataTools:getOldPlotList(battle_field_data.plot_file_name)
	if not data then return end

	local plot_list = {}

	if not self.plot_list then return end

	for k, id in ipairs(self.plot_list) do
		if data[id] ~= nil then
			table.insert(plot_list, data[id])
		end
	end

	battlePlot:playPlot(plot_list, self.camera_stop, nil, {}, self.sailor_id, self.name, self.role_id)
end

return ClsBattlePlayPlot
