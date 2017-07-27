--
-- Author: lzg0496
-- Date: 2017-04-07 15:29:25
-- Function: jjc传奇的排名变化界面

local clsBaseView = require("ui/view/clsBaseView")
local rpc_down_info = require("game_config/rpc_down_info")

local clsArenaLegendRankChange = class("clsArenaLegendRankChange", clsBaseView)

function clsArenaLegendRankChange:getViewConfig()
    return {
        is_swallow = false,
        is_back_bg = true,
        type = UI_TYPE.TIP,
    }
end

function clsArenaLegendRankChange:onEnter(old_rank, new_rank, attack_name)
    self:makeUI()
    self:initUI(old_rank, new_rank, attack_name)
end

function clsArenaLegendRankChange:makeUI()
    self.panel = createPanelByJson("json/arena_rank_change.json")
    self:addWidget(self.panel)

    for i = 1, 3 do
        self["lbl_tips_" .. i] = getConvertChildByName(self.panel, "txt_" .. i)
    end
end

function clsArenaLegendRankChange:initUI(old_rank, new_rank, attack_name)

    self.lbl_tips_1:setText(string.format(rpc_down_info[376].msg, old_rank))

    self.lbl_tips_2:setText(string.format(rpc_down_info[377].msg, attack_name))

    self.lbl_tips_3:setText(string.format(rpc_down_info[378].msg, new_rank))

    self:regTouchEvent(self, function(event, x, y)
        if event == "began" or event == "ended" then
            self:close()
            return true
        end
    end)
end

return clsArenaLegendRankChange
