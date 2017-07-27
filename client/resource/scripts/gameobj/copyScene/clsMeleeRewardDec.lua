--
-- Author: lzg0496
-- Date: 2017-01-02 17:43:23
-- Function: 显示乱斗副本的奖励描述

local clsBaseView = require("ui/view/clsBaseView")

local clsMeleeRewardDec = class("clsMeleeRewardDec", clsBaseView)

function clsMeleeRewardDec:onEnter()
    self:askBaseData()
    self:mkUI()
    self:initUI()
    self:configEvent()
    self:updataUI()
end

function clsMeleeRewardDec:askBaseData()
end

function clsMeleeRewardDec:mkUI()
    self.panel = createPanelByJson("json/explore_copy_melee_info.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    local need_widget_name = {
        btn_close = "btn_close",
    }

    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(self.panel, v)
    end
end


function clsMeleeRewardDec:initUI()
end

function clsMeleeRewardDec:configEvent()
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        self:close()
    end, TOUCH_EVENT_ENDED)
end

function clsMeleeRewardDec:updataUI()

end


function clsMeleeRewardDec:onExit()

end

return clsMeleeRewardDec