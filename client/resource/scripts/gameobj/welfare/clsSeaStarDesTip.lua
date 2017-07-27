--
-- Author: lzg0496
-- Date: 2016-11-08 17:54:44
-- Function: 海上新星玩法说明tip

local ClsBaseView = require("ui/view/clsBaseView")
local music_info=require("game_config/music_info")

local clsSeaStarDescTip = class("clsSeaStarDescTip", ClsBaseView)

function clsSeaStarDescTip:getViewConfig()
    return 
    {
        effect = UI_EFFECT.SCALE,
        is_back_bg = true
    }
end

function clsSeaStarDescTip:onEnter()
    local tips = GUIReader:shareReader():widgetFromJsonFile("json/new_star_tips.json")
    convertUIType(tips)
    self:addWidget(tips)
    
    local btn_close = getConvertChildByName(tips, "btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end,TOUCH_EVENT_ENDED)
end

function clsSeaStarDescTip:onTouch(event, x, y)
    if event == "began" then
        self:close()
        return false
    end
end

return clsSeaStarDescTip