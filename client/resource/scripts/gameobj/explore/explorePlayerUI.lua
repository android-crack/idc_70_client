--2016/07/05
--create by wmh0497
--用于把这个货封装成控件，给别的地方用

local ClsAlert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")
local role_info = require("game_config/role/role_info")
local Alert = require("ui/tools/alert")
local info_title = require("game_config/title/info_title")
local composite_effect = require("gameobj/composite_effect")

local MEMBER_MAX_COUNT = 3

local ClsExplorePlayerUI = class("ExplorePlayerUI", function()
    return UIWidget:create()
end)

function ClsExplorePlayerUI:ctor(parent, is_hide_plunder_btn, port_icon)
    self.m_is_hide_plunder_btn = is_hide_plunder_btn or false
    self.m_parent = parent
    self.m_port_icon = port_icon
    self.m_cur_uid = 0
    self.m_team_member_uis = {}
    self.m_select_ui = nil
    self.m_select_ui_btns = {}
    self.m_select_ui_btn_order = {}
    self.m_select_ui_head_info = {}
    self.m_port_icon_btn_order = {}
    self.m_get_ship_callback = nil

    self:initUI()
    self:initPortIconUI()
    self:initSelectUI()
end

function ClsExplorePlayerUI:initUI()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_player.json")
    self:addChild(panel)
    local other_player = getConvertChildByName(panel, "other_player")
    self.m_select_ui = other_player
    self.m_select_ui:setPosition(ccp(470, 0))
    self:addChild(ui_layer)
end

function ClsExplorePlayerUI:setGetShipCallback(callback)
    self.m_get_ship_callback = callback
end

function ClsExplorePlayerUI:getShip()
    if self.m_get_ship_callback then
        return self.m_get_ship_callback(self.m_cur_uid)
    end
end

function ClsExplorePlayerUI:initPortIconUI()
	if not self.m_port_icon then
		return
	end
	--按钮有关的信息
	local btn_config = {
		[1] = { 
			name = "btn_title", json_name = "btn_title",
			index_pos = {start_pos = ccp(416, 162), end_pos = ccp(321, 162)},
			},
		[2] = { 
			name = "btn_staff", json_name = "btn_staff",
			index_pos = {start_pos = ccp(218, 50), end_pos = ccp(50, 50)},
			},
		[3] = { 
			name = "btn_skill", json_name = "btn_skill",
			index_pos = {start_pos = ccp(302, 50), end_pos = ccp(134, 50)},},
		[4] = { 
			name = "btn_backpack", json_name = "btn_backpack",
			index_pos = {start_pos = ccp(386, 50), end_pos = ccp(218, 50)},
			},
	}
	for k, v in ipairs(btn_config) do
		local btn = getConvertChildByName(self.m_port_icon, v.json_name)
		btn.index_pos = v.index_pos
		self.m_port_icon_btn_order[#self.m_port_icon_btn_order + 1] = btn
	end
end

function ClsExplorePlayerUI:initSelectUI()
    --按钮有关的信息
    local btn_config = {
        [1] = { 
            name = "check_btn", json_name = "btn_check",
            func = function() self:clickBtnCheckEvent() end,
            index_pos = {start_pos = ccp(199, 53), end_pos = ccp(269, 53)},},
        [2] = { 
            name = "friend_btn", json_name = "btn_friend",
            func = function() self:clickBtnFriendEvent() end,
            index_pos = {start_pos = ccp(129, 53), end_pos = ccp(199, 53)},
            img = "btn_friend_icon", available = {["friend"] = false}},
        [3] = { 
            name = "team_btn", json_name = "btn_join_team",
            func = function() self:clickBtnTeamEvent() end, on_off_key = on_off_info.ORGANIZETEAM.value, available = {["open"] = true}, img = "btn_team_icon",
            index_pos = {start_pos = ccp(60, 53), end_pos = ccp(129, 53)}},
    }
    for k, v in ipairs(btn_config) do
        local btn = getConvertChildByName(self.m_select_ui, v.json_name)
        btn.is_normal = true
        btn.on_off_key = v.on_off_key
        btn.available = v.available
        btn:setPressedActionEnabled(true)
        btn.index_pos = v.index_pos
        if v.img then
            btn.img_spr = getConvertChildByName(btn, v.img)
        end
        btn.func = v.func
        btn:addEventListener(function() 
            btn.func()
        end, TOUCH_EVENT_ENDED)
        if self.m_is_hide_plunder_btn and v.is_plunder then
            btn:removeFromParentAndCleanup(true)
        else
            self.m_select_ui_btns[v.name] = btn
            self.m_select_ui_btn_order[#self.m_select_ui_btn_order + 1] = btn
        end
    end
    self.team_btn_text = getConvertChildByName(self.m_select_ui, "btn_team_text")    
    self.m_select_ui_bar = getConvertChildByName(self.m_select_ui, "player_bar")
    
    self.player_head_bg = getConvertChildByName(self.m_select_ui, "player_head_bg")
    self.player_head_bg:setPressedActionEnabled(true)
    self.player_head_bg:addEventListener(function()
        self:hideSelectUI()
    end, TOUCH_EVENT_ENDED)
    
    self.m_select_ui_head_info.head_spr = getConvertChildByName(self.player_head_bg, "player_head")
    self.m_select_ui_head_info.name_lab = getConvertChildByName(self.player_head_bg, "player_name")
    self.m_select_ui_head_info.level_lab = getConvertChildByName(self.player_head_bg, "player_level")
    self.m_select_ui_head_info.player_title = getConvertChildByName(self.player_head_bg , "player_title")
    
	self.m_select_ui_head_info.effect_spr = display.newSprite()
	self.m_select_ui_head_info.player_title:addCCNode(self.m_select_ui_head_info.effect_spr)

    self:hideSelectUI()
    self.m_select_ui:setEnabled(false)
end

function ClsExplorePlayerUI:updateShipPlayerInfo()
    local ship = self:getShip()
    if not ship then
        return
    end
    local sailor_info = require("game_config/sailor/sailor_info")
    local sailor_id = ship:getIconId()
    if sailor_id < 1 then sailor_id = 1 end
    local icon = sailor_info[sailor_id].res
	local role_id = ship:getRoleId()
    local role_cfg_item = role_info[role_id]
	if not role_cfg_item then return end

    self.m_select_ui_head_info.head_spr:changeTexture(icon, UI_TEX_TYPE_LOCAL)
    autoScaleWithLength( self.m_select_ui_head_info.head_spr, 65)
    
    local job_id = role_cfg_item.job_id
    local job_bg_tab = SAILOR_JOB_BG[job_id]
    
    self.player_head_bg:changeTexture(job_bg_tab.normal, job_bg_tab.pressed, job_bg_tab.normal, UI_TEX_TYPE_PLIST)
    self.m_select_ui_head_info.name_lab:setText(ship:getPlayerName())
    self.m_select_ui_head_info.level_lab:setText(string.format("Lv.%s", tostring(ship:getPlayerLevel())))
	
	self.m_select_ui_head_info.effect_spr:removeAllChildrenWithCleanup(true)

    -- 初始化用户爵位称号
    local playersDetailData = getGameData():getPlayersDetailData()
    local nobility_id = playersDetailData:getPlayerInfoNobility(self.m_cur_uid)
    if not nobility_id then
        return
    end
    local nobility_data = getGameData():getNobilityData()
    local nobility_info = nobility_data:getNobilityDataByID(nobility_id)
	if not nobility_info then return end
	
    local file_name = nobility_info.peerage_before
    file_name = convertResources(file_name)
    local effect
    if file_name ~= "title_name_knight.png" then
        -- 如果称号是骑士，则没有特效
        effect = composite_effect.new("tx_0197" , - 50, 1 , self.m_select_ui_head_info.effect_spr, nil , nil , nil , nil , true)
    end
    self.m_select_ui_head_info.player_title:changeTexture(file_name , UI_TEX_TYPE_PLIST)

    self.team_btn_text:setText(ui_word.ACTIVITY_TEAM)
    local ClsExplorePlayerShipsData = getGameData():getExplorePlayerShipsData()
    if ClsExplorePlayerShipsData:isInTeam(self.m_cur_uid) then
        self.team_btn_text:setText(ui_word.EXPLORE_TEAM_TEXT)
    end
end

function ClsExplorePlayerUI:showSelectUI(uid)
	self:hidePortIcon()
	self.m_cur_uid = uid
	self:updateShipPlayerInfo()

	for k, v in ipairs(self.m_select_ui_btn_order) do
		self:btnShowJudge(v)
	end

	if self.m_select_ui:isEnabled() then return end
	self.m_select_ui:setEnabled(true)
	self.m_select_ui:stopAllActions()

	self.m_select_ui_bar:setOpacity(0)
	self.m_select_ui_bar:runAction(CCEaseBackOut:create(CCScaleTo:create(0.4, 1)))
	self.m_select_ui_bar:runAction(CCFadeIn:create(0.4))

	local move_time = 0.1
	local array = CCArray:create()
	for k, target_btn in ipairs(self.m_select_ui_btn_order) do
		target_btn:stopAllActions()
		target_btn:setTouchEnabled(false)
		target_btn:setVisible(false)
		array:addObject(CCCallFunc:create(function() 
				target_btn:setVisible(true)
				target_btn:runAction(CCMoveTo:create(move_time, target_btn.index_pos.end_pos))
			end))
		array:addObject(CCDelayTime:create(move_time))
	end
	array:addObject(CCCallFunc:create(function() 
		for k, target_btn in ipairs(self.m_select_ui_btn_order) do
			target_btn:setTouchEnabled(true)
		end
		self.player_head_bg:setTouchEnabled(true)
	end))
	self.player_head_bg:setTouchEnabled(false)
	self.m_select_ui:runAction(CCSequence:create(array))
end

function ClsExplorePlayerUI:hideSelectUI()
	self.m_select_ui:setEnabled(false)
	self.m_select_ui:stopAllActions()
	self.m_select_ui_bar:setScaleX(0)
	for k, v in ipairs(self.m_select_ui_btn_order) do
		v:setPosition(v.index_pos.start_pos)
	end
	self.m_cur_uid = 0

	if type(self.m_parent.getIsShowDetailUI) == "function" and self.m_parent:getIsShowDetailUI() then
		self:showPortIcon()
	end
end

function ClsExplorePlayerUI:hidePortIcon()
	if not self.m_port_icon then
		return
	end
	self.m_port_icon:setEnabled(false)
	self.m_port_icon:stopAllActions()
	for k, v in ipairs(self.m_port_icon_btn_order) do
		v:setPosition(v.index_pos.start_pos)
	end
end

function ClsExplorePlayerUI:showPortIcon()
	if not self.m_port_icon then
		return
	end
	
	local move_time = 0.1
	local array = CCArray:create()
	for k, target_btn in ipairs(self.m_port_icon_btn_order) do
		target_btn:stopAllActions()
		target_btn:setTouchEnabled(false)
		target_btn:setVisible(false)
		array:addObject(CCCallFunc:create(function()
				target_btn:setVisible(not target_btn.not_open)
				target_btn:setTouchEnabled(not target_btn.not_open)
				target_btn:runAction(CCMoveTo:create(move_time, target_btn.index_pos.end_pos))
			end))
		array:addObject(CCDelayTime:create(move_time))
	end
	array:addObject(CCCallFunc:create(function() 
		for k, target_btn in ipairs(self.m_port_icon_btn_order) do
			target_btn:setTouchEnabled(true)
		end
	end))
	self.m_port_icon:setEnabled(true)
	self.m_port_icon:stopAllActions()
	self.m_port_icon:runAction(CCSequence:create(array))
end

function ClsExplorePlayerUI:hideSelectUiByUid(uid)
    if self.m_cur_uid == uid then
        self:hideSelectUI()
    end
end

function ClsExplorePlayerUI:btnShowJudge(v)
    local on_off_data = getGameData():getOnOffData()
    local is_open = on_off_data:isOpen(v.on_off_key)

    local friend_data_handler = getGameData():getFriendDataHandler()
    local is_friend = friend_data_handler:isMyFriend(self.m_cur_uid)

    local judge_result = {
        ["open"] = is_open,
        ["friend"] = is_friend,
    }

    if v.available then
        v.case = nil
        local is_available = true
        for i, j in pairs(v.available) do
            if judge_result[i] ~= j then
                is_available = false
                v.case = i
                break
            end
        end
        self:setSelectUiBtnIsNormal(v, is_available)
    end
end

function ClsExplorePlayerUI:setSelectUiBtnIsNormal(target, is_normal)
    if (not target.img_spr) or (target.is_normal == is_normal) then
        return
    end
    target.is_normal = is_normal
    target:setPressedActionEnabled(is_normal)
    target.img_spr:setGray(not is_normal)
end

function ClsExplorePlayerUI:clickBtnPlunderEvent()
    local case = self.m_select_ui_btns.plunder_btn.case
    if not case then
        local explore_data_handler = getGameData():getExploreData()
        explore_data_handler:askLootPlayer(self.m_cur_uid)
    else
        local show_txt = nil
        if case == "open" then
            show_txt = ui_word.TIPS_PLUNDER_UNOPEN
        end
        ClsAlert:warning({msg = show_txt, color = ccc3(dexToColor3B(COLOR_RED))})
    end
end

function ClsExplorePlayerUI:clickBtnCheckEvent()
    if not tolua.isnull(self.role_info_ui) then return end

    local playerData = getGameData():getPlayerData()
    if self.m_cur_uid == playerData:getUid() then
        self.role_info_ui = getUIManager():create("gameobj/playerRole/clsRoleInfoView")
    else
        self.role_info_ui = getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,self.m_cur_uid)
    end
end

function ClsExplorePlayerUI:clickBtnFriendEvent()
    local case = self.m_select_ui_btns.friend_btn.case
    if not case then
        local friend_data_handler = getGameData():getFriendDataHandler()
        friend_data_handler:askRequestAddFriend(self.m_cur_uid)
    else
        local show_txt = nil
        if case == "friend" then
            show_txt = ui_word.EXPLORE_ALREADY_MY_FRIEND
        end
        ClsAlert:warning({msg = show_txt, color = ccc3(dexToColor3B(COLOR_RED))})
    end
end

function ClsExplorePlayerUI:clickBtnTeamEvent()
    local case = self.m_select_ui_btns.team_btn.case
    if not case then
        local ClsExplorePlayerShipsData = getGameData():getExplorePlayerShipsData()
        local team_data = getGameData():getTeamData()
        if ClsExplorePlayerShipsData:isInTeam(self.m_cur_uid) then
            team_data:askJoinTeamInScene(self.m_cur_uid)
        else
            team_data:inviteFriend(self.m_cur_uid)
        end
    else
        local show_txt = ""
        if case == "open" then
            show_txt = ui_word.NOT_OPEN_TEAM
        end
        ClsAlert:warning({msg = show_txt, color = ccc3(dexToColor3B(COLOR_RED))})
    end
end

return ClsExplorePlayerUI