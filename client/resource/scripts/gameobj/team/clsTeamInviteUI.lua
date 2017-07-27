-- 组队邀请弹框界面
-- Author pyq
-- 2016/11/23 09:56:18
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local team_config = require("game_config/team/team_config")
local port_info = require("game_config/port/port_info")
local area_info = require("game_config/port/area_info")
local ClsAlert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsTeamInviteUI = class("ClsTeamInviteUI", ClsBaseView)

local LIMIT_TIME = 15
local ACCEPT_INVITE = 1
local REFUSE_INVITE = 2

local IS_PORT = 1000
local IS_SEA_SCENE = 10000

function ClsTeamInviteUI:getViewConfig()
    return {
        name = "ClsTeamInviteUI",
        type = UI_TYPE.TIP,
        is_back_bg = true,
        effect = UI_EFFECT.SCALE, 
    }
end

local widget_name = {
	"btn_refuse",
	"btn_accept",
	"time_text",
	"btn_check",
	"info_bg",
	"player_num_text",
}

function ClsTeamInviteUI:onEnter(msg)
	self.data = msg

	self:mkUI()
	self:regEvent()
	self:updateView()
end

function ClsTeamInviteUI:mkUI()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_team_2.json")
	for k, v in ipairs(widget_name) do
		self[v] = getConvertChildByName(panel, v)
	end
	convertUIType(panel)
	self:addWidget(panel)
end

function ClsTeamInviteUI:toRefuseInvite()
	local teamData = getGameData():getTeamData()
	if self.btn_check:getSelectedState() then
		teamData:setAllRefuseInvite(self.data.uid)
	end
	teamData:handleTeamInvite(self.data.teamId, REFUSE_INVITE, self.data.uid)
	local next_invite_msg = teamData:getInvitedMsg()
	if next_invite_msg then
		self.data = next_invite_msg
		self:updateView()
	else
		self:closeView()
	end
end

function ClsTeamInviteUI:toReciveTeamInvite()
	if tolua.isnull(self) then return end
	local teamData = getGameData():getTeamData()
	if self.btn_check:getSelectedState() then
		teamData:setAllRefuseInvite(self.data.uid)
	end
	teamData:handleTeamInvite(self.data.teamId, ACCEPT_INVITE, self.data.uid)
	teamData:cleanAllInvite()
	teamData:resetInvitedUid()
	self:closeView()
end

function ClsTeamInviteUI:toAcceptInvite()
    local function enterCall(go)
       	self:closeView()
       	if type(go) == "function" then
       		go()
       	end
	end
	local address_id = self.data.sceneId --邀请发出地点
	self.tip_layer = getGameData():getTeamData():toEnterOtherTeam(address_id, function()
		self:toReciveTeamInvite()
	end, enterCall)
end

function ClsTeamInviteUI:regEvent()
	self.btn_refuse:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.btn_refuse:setTouchEnabled(false)
		self:toRefuseInvite()
	end, TOUCH_EVENT_ENDED)

	self.btn_accept:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:toAcceptInvite()
	end, TOUCH_EVENT_ENDED)
end

function ClsTeamInviteUI:updateInvitedNum(count)
	if not count then return end
	if not tolua.isnull(self.player_num_text) then
		self.player_num_text:setText(string.format(ui_word.TEAM_INVITED_NUM, count))
	end
end

function ClsTeamInviteUI:updateView()
	self:stopAllActions()
	self.btn_accept:setTouchEnabled(true)
	self.btn_refuse:setTouchEnabled(true)
	self.btn_check:setSelectedState(false)

	local leave_invited_num = getGameData():getTeamData():getInvitedNum()
	self:updateInvitedNum(leave_invited_num + 1)

	if not tolua.isnull(self.invited_send_label) then
		self.invited_send_label:removeFromParentAndCleanup(true)
		self.invited_send_label = nil
	end
	if not tolua.isnull(self.team_activity_label) then
		self.team_activity_label:removeFromParentAndCleanup(true)
		self.team_activity_label = nil
	end

	local sender_name = self.data.leaderName
	local activity_name = team_config[self.data.teamType].name
	if self.data.sceneId < IS_PORT then
		self.port_name = port_info[self.data.sceneId].name
		self.sea_area = port_info[self.data.sceneId].sea_area
	elseif self.data.sceneId < IS_SEA_SCENE then
		self.port_name = area_info[self.data.sceneId - IS_PORT].name
	else
		self.port_name = ui_word.NONE_PEOPLE_SCENE
	end
	local invited_send_text = nil
	if self.sea_area then
		invited_send_text = string.format(ui_word.TEAM_INVITE_PEOPLE_1, sender_name, self.sea_area, self.port_name)
	else
		invited_send_text = string.format(ui_word.TEAM_INVITE_PEOPLE, sender_name, self.port_name)
	end
	local team_activity_text = string.format(ui_word.TEAM_INVITE_MISSION, activity_name)
	self.invited_send_label = createRichLabel(invited_send_text, 350, 38, 14, 3, nil, true)
	self.player_num_text:addCCNode(self.invited_send_label)
	self.team_activity_label = createRichLabel(team_activity_text, 350, 38, 15, 3, nil, true)
	self.player_num_text:addCCNode(self.team_activity_label)
	self:alignRichLabel()

	self.remain_time = LIMIT_TIME
	self.time_text:setText(string.format(ui_word.TEAM_AUTO_REFUSE, self.remain_time))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCCallFunc:create(function()
		self:freashLeaveTime()
	end))
	local action = CCSequence:create(array)
	self:runAction(CCRepeatForever:create(action))
end

function ClsTeamInviteUI:alignRichLabel()
	if not tolua.isnull(self.team_activity_label) then
		local activity_label_size = self.team_activity_label:getSize()
		local activity_label_x = - activity_label_size.width/2
		local activity_label_y = 10
		self.team_activity_label:setPosition(ccp(activity_label_x, activity_label_y))

		if not tolua.isnull(self.invited_send_label) then
			local send_label_size = self.invited_send_label:getSize()
			local send_label_x = - send_label_size.width/2
			local send_label_y = activity_label_y * 2 + activity_label_size.height
			self.invited_send_label:setPosition(ccp(send_label_x, send_label_y))
		end
	end
end

function ClsTeamInviteUI:freashLeaveTime()
	if self.remain_time <= 0 then
		self:stopAllActions()
		self:toRefuseInvite()
	end
	self.remain_time = self.remain_time - 1
	self.time_text:setText(string.format(ui_word.TEAM_AUTO_REFUSE, self.remain_time))
end

function ClsTeamInviteUI:closeView()
	if not tolua.isnull(self.tip_layer) then
		self.tip_layer:close()
	end
	self:close()
	getGameData():getTeamData():setBeInviteShow(false)
end

function ClsTeamInviteUI:onExit()
	getGameData():getTeamData():setBeInviteShow(false)
end

return ClsTeamInviteUI