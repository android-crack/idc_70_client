local Alert = require("ui/tools/alert")
local news = require("game_config/news")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

local ClsFriendExpand = require("gameobj/friend/clsFriendExpand")
local ClsCommonExpand = class("ClsCommonExpand", ClsFriendExpand)
function ClsCommonExpand:getViewConfig()
    return {
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsCommonExpand:onEnter()
	self:setIsWidgetTouchFirst(true)

	self:configUI()
	self:regTouch()
end

function ClsCommonExpand:configUI()
	local widget_info = {--一定存在的控件的名称
		[1] = {name = "btn_captain_info", event = self.checkRoleInfo},
		[2] = {name = "btn_pk", event = self.pkFriend},
		[3] = {name = "btn_send_message", event = self.sendMsg},
		[4] = {name = "btn_delete", event = self.deleteObj},
	}

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_expand_panel.json")
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

function ClsCommonExpand:checkTouchEnable()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local is_my_friend = friend_data_handler:isMyFriend(self.data.uid)

	if not is_my_friend then
		self.btn_delete:disable()
		self.btn_pk:disable()
		self.btn_send_message:disable()
	else
		self.btn_delete:active()
		self.btn_pk:active()
		self.btn_send_message:active()
	end
end

return ClsCommonExpand