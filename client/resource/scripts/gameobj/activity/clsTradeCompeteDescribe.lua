local ClsBaseView = require("ui/view/clsBaseView")
local music_info = require("game_config/music_info")
local tool = require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")

local ClsPortTradeCompeteDescribe = class("ClsPortTradeCompeteDescribe", ClsBaseView)

local touch_rect = CCRect(227, 63, 536, 420)
function ClsPortTradeCompeteDescribe:onEnter()
    
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_trade_rules.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    self:configUI()
    self:configEvent()
end

function ClsPortTradeCompeteDescribe:configUI()
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)


    self:regTouchEvent(self, function(eventType, x, y)
        local touch_point = ccp(x, y)
        is_in = touch_rect:containsPoint(touch_point)
        if not is_in then
            self:closeView()
        end
    end)
end

function ClsPortTradeCompeteDescribe:closeView()
	self:close()
end

function ClsPortTradeCompeteDescribe:configEvent()
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

function ClsPortTradeCompeteDescribe:setTouch(enable)
	self.btn_close:setTouchEnabled(enable)
end

return ClsPortTradeCompeteDescribe
