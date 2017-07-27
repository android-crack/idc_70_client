local ui_word = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsPlayerTips = class("ClsPlayerTips", ClsBaseView)
local music_info = require("game_config/music_info")

local btn_name = {
	"btn_add",
	"btn_leave",
	"btn_leader",
	"btn_leave_text",
	"btn_add_text",
	"bg",
}

function ClsPlayerTips:getViewConfig()
    return {
        is_swallow = false,
    }
end

function ClsPlayerTips:onEnter(select_uid, lead_uid)
	self:setIsWidgetTouchFirst(true)
	self.plistTab = {
        ["ui/explore_sea.plist"] = 1,
    }
    LoadPlist(self.plistTab)
	self.select_uid = select_uid
	self.lead_uid = lead_uid
	self.my_uid = getGameData():getPlayerData():getUid() or 0	
	self:configUI()

	self:regTouchEvent(self, function(event_type, x, y)
	    local pos_x, pos_y = self:getPosition()
		local size = self.panel:getContentSize()
		local touch_rect = CCRect(pos_x, pos_y, size.width, size.height)
        if event_type == "began" then
        	if not touch_rect:containsPoint(ccp(x, y)) then
        		self:closeView()
        		return false
        	end
        	return true
        end
    end)
end

function ClsPlayerTips:setBindObj(obj)
	self.current_select_obj = obj
	local pos = obj:convertToWorldSpace(ccp(-5, -15))
	self:setPosition(pos)
end

function ClsPlayerTips:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/team_list_btn.json")
	self:addWidget(self.panel)
	for i,v in ipairs(btn_name) do
		self[v]= getConvertChildByName(self.panel, v)
	end
	self:regEvent()
end

function ClsPlayerTips:regEvent()
	local friend_data_handle = getGameData():getFriendDataHandler()
	self.btn_add:setPressedActionEnabled(true)
	self.btn_leave:setPressedActionEnabled(true)
	self.btn_leader:setPressedActionEnabled(true)
	self.btn_leader:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local teamData = getGameData():getTeamData()
		teamData:askPromoteLeader(self.select_uid)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
	self.btn_add:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		friend_data_handle:askRequestAddFriend(self.select_uid)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
	self.btn_leave:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getGameData():getTeamData():tickTeamPlayer(self.select_uid)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
	if self.lead_uid ~= self.my_uid then --队长不是本人
		self.btn_leave:disable()
		self.btn_leader:disable()
		self.btn_leader:setTouchEnabled(false)
		self.btn_leave:setTouchEnabled(false)
	end

	if friend_data_handle:isMyFriend(self.select_uid) then
		self.btn_add:disable()
		self.btn_add_text:setText(ui_word.IS_HAD_FIREND)
		self.btn_add:setTouchEnabled(false)
	end
end

function ClsPlayerTips:closeView()
	self:close("ClsPlayerTips")
end

function ClsPlayerTips:onExit()
	UnLoadPlist(self.plistTab)
end

return ClsPlayerTips