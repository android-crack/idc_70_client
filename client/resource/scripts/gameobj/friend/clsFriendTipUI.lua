local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local ClsAlert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

--好友提示类
local ClsBaseView = require("ui/view/clsBaseView")
local ClsFriendTipUI = class("ClsFriendTipUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFriendTipUI:getViewConfig()
    return {
        name = "ClsFriendTipUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

--页面创建时调用
function ClsFriendTipUI:onEnter(parameter)
    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsFriendTipUI:showNoticeTip()
    local widget_info = {
        [1] = {name = "btn_accept"},
        [2] = {name = "btn_refuse"},
        [3] = {name = "btn_close"},
    }
    for k, v in ipairs(widget_info) do
        local item = getConvertChildByName(self.give_panel, v.name)
        item:setTouchEnabled(true)
        item:setPressedActionEnabled(true)
        self[v.name] = item
    end
    local friend_data = getGameData():getFriendDataHandler()
    self.main_text = getConvertChildByName(self.give_panel, "main_text")
    local cur_platform = friend_data:getPlatform()
    local client_name = ui_word.FRIEND_TAB_QQ
    if cur_platform == PLATFORM_WEIXIN then
        client_name = ui_word.FRIEND_TAB_WECHAT
    end

    self.main_text:setText(ui_word.FRIEND_QQ_NOTICE_FRIEND)

    self.btn_accept:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        if type(self.parameter.btnCall) == "function" then
            self.parameter.btnCall()
        end
        self:close()
        if GTab.IS_VERIFY then
            return
        end
        
        local open_id = friend_data:getOpenId(self.parameter.uid)
        if not open_id then
            cclog("open_id为空")
        else
            if cur_platform == PLATFORM_WEIXIN then
                local show_txt = string.format(ui_word.FRIEND_NOTICE_SURE, client_name)
                ClsAlert:showAttention(show_txt, function()
                    local share_data =  getGameData():getShareData()
                    share_data:shareToFriend(open_id, "friend_heart")
                end)
            else
                local share_data =  getGameData():getShareData()
                share_data:shareToFriend(open_id, "friend_heart")
            end
        end
    end, TOUCH_EVENT_ENDED)

    self.btn_refuse:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        if type(self.parameter.btnCall) == "function" then
            self.parameter.btnCall()
        end
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_close:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)
end

function ClsFriendTipUI:showDeleteTip()
    local friend_data_handler = getGameData():getFriendDataHandler()

    local widget_info = {
        [1] = {name = "btn_yes"},
        [2] = {name = "btn_no"},
        [3] = {name = "btn_close"}
    }

    for k, v in ipairs(widget_info) do
        local item = getConvertChildByName(self.delete_panel, v.name)
        item:setTouchEnabled(true)
        item:setPressedActionEnabled(true)
        self[v.name] = item
    end

    self.btn_yes:addEventListener(function() 
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)
        friend_data_handler:askDeleteMyFriendList(self.parameter.uid)
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_no:addEventListener(function() 
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_close:addEventListener(function() 
    	audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)
end

local kind_func = {
    [DELETE_FRIEND_TIP] = ClsFriendTipUI.showDeleteTip,
    [NOITCE_SEND_GIFT_TIP] = ClsFriendTipUI.showNoticeTip,
}

function ClsFriendTipUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_tips.json")
    self:addWidget(self.panel)

    self.bg = getConvertChildByName(self.panel, "bg")
    self.touch_layer = getConvertChildByName(self.panel, "touch_layer")

    local panel_info = {
        [1] = {name = "give_panel", kind = NOITCE_SEND_GIFT_TIP},
        [2] = {name = "delete_panel", kind = DELETE_FRIEND_TIP},
    }

    for k, v in ipairs(panel_info) do
        local panel = getConvertChildByName(self.panel, v.name)
        panel:setVisible(v.kind == self.parameter.kind)
        self[v.name] = panel
    end

    kind_func[self.parameter.kind](self)
end

function ClsFriendTipUI:configEvent()
    self.touch_layer:addEventListener(function()
        local touch_pos = self.touch_layer:getTouchEndPos()
        local size = self.bg:getSize()
        local pos = self.bg:getPosition()
        local anchor_point = self.bg:getAnchorPoint()
        local start_x = pos.x - size.width * anchor_point.x
        local start_y = pos.y - size.height * anchor_point.y

        local offset_x = touch_pos.x - start_x
        local offset_y = touch_pos.y - start_y

        if not (offset_x >= 0 and offset_x <= size.width and offset_y >= 0 and offset_y <= size.height) then
            self:close()
        end 
    end, TOUCH_EVENT_ENDED)
end

return ClsFriendTipUI