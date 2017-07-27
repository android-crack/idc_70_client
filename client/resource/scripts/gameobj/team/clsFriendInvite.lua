local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local music_info=require("scripts/game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local isNearBy = nil
local LIMIT_TIME = 60

local ClsFriendInviteItem = class("ClsFriendInviteItem", ClsScrollViewItem)

local widget_name = {
	"fri_list_panel",
	"team_list_panel",
	"fri_select",
	"fir_btn_invite",
	"fri_menber_info",
	"fri_level_info",
	"fri_power_info",
	"fri_invited_info",
}

function ClsFriendInviteItem:updateUI(cell_data, panel)
    self.data = cell_data
	panel:setPosition(ccp(0, -3))
    convertUIType(panel)
    for i,v in ipairs(widget_name) do
    	self[v]= getConvertChildByName(panel, v)
    end
    self:mkUi()
end

function ClsFriendInviteItem:mkUi()
    self.fri_list_panel:setVisible(true)
    self.fir_btn_invite:setVisible(true)
    self.fri_select:setVisible(false)
    self:updateView()
end

function ClsFriendInviteItem:clickCallBack()
	self.fir_btn_invite:setVisible(false)
	self.remain_time = LIMIT_TIME
	if not tolua.isnull(self.fri_invited_info) then
		self.fri_invited_info:setVisible(true)
		self.fri_invited_info:setText(ui_word.TEAM_REMAIN_TIME..self.remain_time.."s")
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCCallFunc:create(function()
		self:freashUI()
	end))
	local action = CCSequence:create(array)
	self:runAction(CCRepeatForever:create(action))
end

function ClsFriendInviteItem:updateView()
	self.fri_menber_info:setText(self.data.name)
	self.fri_level_info:setText("Lv."..self.data.level)
	self.fri_power_info:setText(self.data.rank_zhandouli)
	self.fir_btn_invite:setPressedActionEnabled(true)
	self.fir_btn_invite:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local team_data = getGameData():getTeamData()
		if isNearBy then
			team_data:inviteFriend(self.data.uid)
			return
		end

		local count = team_data:getFriendInviteNum()
		if count < 5 then
			count = count + 1
			team_data:setFriendInviteNum(count)
			team_data:inviteFriend(self.data.uid)
			self:clickCallBack()
		else
			ClsAlert:warning({msg = ui_word.TEAM_INVITE_FRIEND_OVER_TIPS})
		end
	end, TOUCH_EVENT_ENDED)
end

function ClsFriendInviteItem:freashUI()
	if self.remain_time <= 0 then
		self:stopAllActions()
		self.fir_btn_invite:setVisible(true)
		self.fri_invited_info:setVisible(false)
	end
	self.remain_time = self.remain_time - 1
	self.fri_invited_info:setText(ui_word.TEAM_REMAIN_TIME..self.remain_time.."s")
end

local ClsFriendInvite = class("ClsFriendInvite", ClsBaseView)

function ClsFriendInvite:getViewConfig()
    return {
        name = "ClsFriendInvite",
        is_back_bg = true,
        effect = UI_EFFECT.SCALE, 
    }
end

function ClsFriendInvite:onEnter()
	self.plist = {
		["ui/guild_ui.plist"] = 1,	
	}
	self.cd_limit_time = 10
	LoadPlist(self.plist)
	self:askFriendData()
end

local weiget_name = {
	"btn_close",
	"team_panel",
	"friend_panel",
	"btn_refresh",
	"btn_guild",
	"team_invited_text_1",
	"team_invited_text_2",	
	"btn_world",
	-- "world_item_num",
}

--获取邀请好友数据
function ClsFriendInvite:askFriendData()
	local sceneDataHandle = getGameData():getSceneDataHandler()
	local team_data = getGameData():getTeamData()
	if sceneDataHandle:isInCopyScene() then
		team_data:askNearByPeople()
	else
		-- 获取在线好友数据
		local friend_data_handler = getGameData():getFriendDataHandler()
		self.friend_data = friend_data_handler:getTotalOnLineFriend()
		self:updateView()
	end
end

function ClsFriendInvite:updateView()
	self:mkUi()
	self:regBtnCB()
end

function ClsFriendInvite:updateNearByView(near_by_list)
	isNearBy = true
	self.near_by_list = near_by_list
	self:mkUi()
	self:regBtnCB()
end

function ClsFriendInvite:mkUi()
	if self.panel then
		self.panel:removeFromParentAndCleanup(true)
		self.panel = nil
	end
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/team_invite.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    for i,v in ipairs(weiget_name) do
    	self[v]= getConvertChildByName(self.panel, v)
    end

    -- local propDataHandle = getGameData():getPropDataHandler()
    -- local horn_info = propDataHandle:get_propItem_by_id(PROP_ITEM_HORN) or {count = 0}
    -- if horn_info.count < 1 then
    -- 	self.world_item_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
    -- end

    local copy_scene_manager = require("gameobj/copyScene/copySceneManage")
    if copy_scene_manager:doLogic("isCanWorldCall") == false then
        self.btn_world:setVisible(false) 
        self.btn_world:setEnabled(false)
    end

    self.friend_panel:setVisible(true)
    self.team_invited_text_2:setVisible(false)
    self.team_invited_text_1:setVisible(false)
    if isNearBy then
    	self:createListUi(self.near_by_list)
    	self.btn_guild:setVisible(false)
    	self.btn_guild:setTouchEnabled(false)
    	self.team_invited_text_2:setVisible(true)
    else
    	self:createListUi(self.friend_data)
    	self.team_invited_text_1:setVisible(true)
    end
    local guild_info_data = getGameData():getGuildInfoData()
    local guild_id = guild_info_data:getGuildId()

    self.btn_guild:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local team_data_handle = getGameData():getTeamData()
        local guild_cd_time = team_data_handle:getGuildCDTime()
        local cur_time = os.time() + getGameData():getPlayerData():getTimeDelta()
        if guild_cd_time and cur_time - guild_cd_time <= self.cd_limit_time then
        	-- print("cd还剩下的时间： -=-=-:",cur_time - guild_cd_time)
        	local ERROR_INDEX = 602
            local text = require("game_config/error_info")[ERROR_INDEX].message
            ClsAlert:warning({msg = text})
        	return
        end
        team_data_handle:sendInviteByGuild()
        team_data_handle:setGuildCDTime(cur_time)
    end, TOUCH_EVENT_ENDED)

    if guild_id and guild_id ~= 0 then --加入了工会
        -- self.btn_guild:active()
        -- self.btn_guild:setTouchEnabled(true)
        --队伍满人商会按钮灰化无法点击
        local myTeamInfo = getGameData():getTeamData():getMyTeamInfo()
        local bool = myTeamInfo and #myTeamInfo.info < 3
        self.btn_guild:setTouchEnabled(bool)
        if bool then
            self.btn_guild:active()
        else
            self.btn_guild:disable()
        end
    else
        self.btn_guild:disable()
        self.btn_guild:setTouchEnabled(false)
    end
end

function ClsFriendInvite:regBtnCB()
	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_world:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        
     --    local propDataHandle = getGameData():getPropDataHandler()
	    -- local horn_info = propDataHandle:get_propItem_by_id(PROP_ITEM_HORN) or {count = 0}
	    -- if horn_info.count < 1 then
	    -- 	self.world_item_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
	    -- end

        local teamData = getGameData():getTeamData()
        if teamData:isLock() then
        	ClsAlert:warning({msg = ui_word.TEAM_WORLD_MEMBER_TIP})
        	return
        end
        teamData:sendInviteByWorld()         
    end, TOUCH_EVENT_ENDED)
end

function ClsFriendInvite:createListUi(data)
	self.cells = {}
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end
	
	self.list_view = ClsScrollView.new(500, 240, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/team_invite_list.json")
        return cell_ui
    end)
	for i,v in ipairs(data) do
        self.cells[i] = ClsFriendInviteItem.new(CCSize(500, 50), v)
	end
	self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(240, 135))
	self:addWidget(self.list_view)
end

function ClsFriendInvite:getItemIndexById(uid)
	local index = 0
	local data = self.friend_data
	if isNearBy then
		data = self.near_by_list
	end
	for k,v in ipairs(data) do
		if uid == v.uid then
			index = k
			return index
		end
	end
end

function ClsFriendInvite:friendHasInvite(uid)
	local index = 0
	local data = self.friend_data
	if isNearBy then
		data = self.near_by_list
	end
	for k,v in ipairs(data) do
		if uid == v.uid then
			index = k
		end
	end
	if index and index > 0 then
		table.remove(data, index)
		if self.list_view then
			self.list_view:removeCell(self.cells[index])
		end
	end
end

local FAIL_Text = {
	ui_word.TEAM_HAS_IN,     --已在队伍
	ui_word.TEAM_HAS_REFUSE, --被拒绝
	ui_word.TEAM_IS_MEMBER,	 --已是队员
}

function ClsFriendInvite:handleFailInvited(uid, type)
	if not uid then return end
	local item = nil
	local index = self:getItemIndexById(uid)
	if index and index > 0 then
		item = self.cells[index]
	end
	if not tolua.isnull(item) then
		item:stopAllActions()
		if not tolua.isnull(item.fir_btn_invite) then
			item.fir_btn_invite:setEnabled(false)
		end
		if not tolua.isnull(item.fri_invited_info) then
			item.fri_invited_info:setVisible(true)
			item.fri_invited_info:setText(FAIL_Text[type])
		end
		
		local team_data = getGameData():getTeamData()
		local count = team_data:getFriendInviteNum()
		team_data:setFriendInviteNum(count - 1)
	end
end

function ClsFriendInvite:onExit()
	isNearBy = false
	UnLoadPlist(self.plist)
	local team_data = getGameData():getTeamData()
	team_data:setFriendInviteNum(0)
end

return ClsFriendInvite