local ClsBattleSkipPlot = class("ClsBattleSkipPlot", require("gameobj/battle/view/base"))

function ClsBattleSkipPlot:ctor()
end

function ClsBattleSkipPlot:GetId()
    return "battle_skip_plot"
end

function ClsBattleSkipPlot:gotProtcol()
	require("gameobj/battle/battlePlot"):skipPlot()
end

-- 播放
function ClsBattleSkipPlot:Show()
end

return ClsBattleSkipPlot
