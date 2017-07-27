local Alert = require("ui/tools/alert")
local news = require("game_config/news")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

local ClsFriendExpand = require("gameobj/friend/clsFriendExpand")
local ClsQQWechatExpand = class("ClsQQWechatExpand", ClsFriendExpand)
function ClsQQWechatExpand:getViewConfig()
    return {
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsQQWechatExpand:onEnter()
	self:setIsWidgetTouchFirst(true)

	self:configUI()
	self:regTouch()
end

function ClsQQWechatExpand:sendMsg()
	getUIManager():close("ClsFriendExpand")
	getUIManager():close("ClsFriendMainUI")

	local component_ui = getUIManager():get("ClsChatComponent")
	local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = self.data.uid, name = self.data.gameName})
	panel_ui:toMainUI({["kind"] = INDEX_PLAYER})
end

function ClsQQWechatExpand:configUI()
	local widget_info = {--一定存在的控件的名称
		[1] = {name = "btn_captain_info", event = self.checkRoleInfo},
		[2] = {name = "btn_send_message", event = self.sendMsg},
		[3] = {name = "btn_add_friend", event = self.addFriend},
	}

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_expand_wechat.json")
    self:addWidget(self.panel)

    for k, v in ipairs(widget_info) do
    	local item = getConvertChildByName(self.panel, v.name)
    	item.name = v.name
    	item:setPressedActionEnabled(true)
		item:setTouchEnabled(true)

		item:addEventListener(function()
    		audioExt.playEffect(music_info.COMMON_BUTTON.res)
    		self:close()
    		v.event(self)
    	end, TOUCH_EVENT_ENDED)

    	self[v.name] = item
    end
end

function ClsQQWechatExpand:checkTouchEnable()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local is_my_friend = friend_data_handler:isMyFriend(self.data.uid)

	if is_my_friend then
		self.btn_add_friend:disable()
	end
end

return ClsQQWechatExpand