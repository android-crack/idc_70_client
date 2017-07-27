--弹框的基类
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

local QUESTION_URL = "http://www.175game.com"

local ClsBaseView = require("ui/view/clsBaseView")
local ClsQuestionUI = class("ClsQuestionUI", ClsBaseView)

local DIAMOND_NUM = 200
--页面参数配置方法，注意，是静态方法
function ClsQuestionUI:getViewConfig()
    return {
        name = "ClsQuestionUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsQuestionUI:onEnter()
    self:setIsWidgetTouchFirst(true)
    self:configUI()
    self:configEvent()
end

function ClsQuestionUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_common.json")
    self:addWidget(self.panel)

	local panel_size = self.panel:getContentSize()
    self.panel:setPosition(ccp(display.cx - panel_size.width / 2, display.cy - panel_size.height / 2))

    local widget_info = {
    	[1] = {name = "text_1"},
    	[2] = {name = "text_2"},
    	[3] = {name = "btn_confirm", label = "btn_text_confirm", kind = BTN},
    	[4] = {name = "btn_cancel", label = "btn_text_cancel", kind = BTN},
    	[5] = {name = "btn_close", kind = BTN},
        [6] = {name = "questionnaire_panel"}
	}

	for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        if v.label then
        	self[v.name].label = getConvertChildByName(self[v.name], v.label)
        end
        if v.kind == BTN then
        	self[v.name]:setPressedActionEnabled(true)
        end
    end
    self.questionnaire_panel:setVisible(true)
    self.text_1:setText(ui_word.QUESTION_TIP)
    self.btn_confirm.label:setText(ui_word.DAILY_ACTIVITY_GO_ON)
    self.coin_num = getConvertChildByName(self.panel, "coin_num")
    self.coin_num:setText(tostring(DIAMOND_NUM))
    self.text_2:setVisible(false)
    local touch_rect = CCRect(display.cx - panel_size.width / 2, display.cy - panel_size.height / 2, panel_size.width, panel_size.height)
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            if  not touch_rect:containsPoint(ccp(x, y)) then
                self:closeView()
            end
        end
    end)
end

function ClsQuestionUI:configEvent()
	self.btn_confirm:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:closeView()
        local module_game_sdk = require("module/sdk/gameSdk")
        local question_data = getGameData():getQuestionPaperData()
        local url = question_data:getUrl()
        module_game_sdk.openURL(url)
    end, TOUCH_EVENT_ENDED)

    self.btn_cancel:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:closeView()
    end, TOUCH_EVENT_ENDED)

    self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

function ClsQuestionUI:closeView()
    self:close()
end

return ClsQuestionUI
