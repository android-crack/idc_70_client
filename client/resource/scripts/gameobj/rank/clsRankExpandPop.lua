local ClsCommonMenuPop = require("gameobj/rank/clsCommonMenuPop")
local ClsRankExpandPop = class("ClsRankExpandPop", ClsCommonMenuPop)
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")

ClsRankExpandPop.getViewConfig = function(self)
	return {
		is_swallow = false,
	}
end

ClsRankExpandPop.setBindCell = function(self, cell)
	self.data = cell.m_data

	local world_pos = cell:getWorldPosition()
	local cell_height = cell:getHeight()
	local self_size = self.panel:getSize()

	local pos_x = world_pos.x + 560
	local pos_y = world_pos.y - (self_size.height - cell_height) / 2

	self:setPosition(ccp(pos_x, pos_y))
end

ClsRankExpandPop.checkRoleInfo = function(self)
	local playerData = getGameData():getPlayerData()
	if self.data.uid == playerData:getUid() then
		getUIManager():create("gameobj/playerRole/clsRoleInfoView")
	else
		getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, self.data.uid)
	end
end

ClsRankExpandPop.sendMsg = function(self)
	getUIManager():close("ClsFriendMainUI")
	getUIManager():close("ClsRankMainUI")

	local component_ui = getUIManager():get("ClsChatComponent")
	local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = self.data.uid, name = self.data.name})
	panel_ui:toMainUI({["kind"] = INDEX_PLAYER})
end

ClsRankExpandPop.addFriend = function(self)
	local friend_data_handler = getGameData():getFriendDataHandler()
	local cur_num = friend_data_handler:getFriendNum()
	if cur_num <= FRIENT_MAX_NUM then
		friend_data_handler:askRequestAddFriend(self.data.uid)
	else
		Alert:warning({msg = ui_word.FRIEND_ADD_FAILED})
	end
end

local widget_tab = {
	[1] = {name = "btn_check", event = ClsRankExpandPop.checkRoleInfo,},
	[2] = {name = "btn_chat", event = ClsRankExpandPop.sendMsg,},
	[3] = {name = "btn_friend", event = ClsRankExpandPop.addFriend,},
}

ClsRankExpandPop.onEnter = function(self, close_call_back)
	local params = {
		json_path = "json/rank_prestige_btn_1.json",
		widget_info = widget_tab,
		call_back = close_call_back,
	}

	ClsRankExpandPop.super.onEnter(self, params)
end

return ClsRankExpandPop