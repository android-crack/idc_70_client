local ClsBattlePlayPlotEnd = class("ClsBattlePlayPlotEnd", require("gameobj/battle/view/base"))

function ClsBattlePlayPlotEnd:ctor(plot_list, camera_stop)
end

function ClsBattlePlayPlotEnd:GetId()
    return "battle_play_plot_end"
end

return ClsBattlePlayPlotEnd
