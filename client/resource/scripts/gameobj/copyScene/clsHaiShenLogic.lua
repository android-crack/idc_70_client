-- Author: pyq0639
-- Date: 2016-12-23 20:38:50
-- Function: 海神副本逻辑

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local ClsVSUIComponent = require("gameobj/copyScene/copySceneComponent/clsVSUIComponent")
local haiShenLogic = class("haiShenLogic", copySceneLogicBase)

function haiShenLogic:ctor()
    self.map_land_params = {
        bit_res = "explorer/map/battle_map/sea_god5.bit",
        map_res = "explorer/map/land/copy_sea_god.tmx", --地图资源
        tile_height = 36, --地图高度，格子数目
        tile_width = 52, -- 地图宽度，格子数目
        block_width_count = 0, --地图宽度遮挡
        block_height_count = 0, --地图高度挡住
        block_up_count = 0,
        block_down_count = 0,
        block_left_count = 0,
        block_right_count = 0,
    }

    self.model_count = {}
	self.m_seagod_lv = -1
    for _, event_id in ipairs(SCENE_OBJECT_TYPE_HAISHEN) do
        self.model_count[event_id] = 1
    end

    self.plist = {
        ["ui/buff_icon.plist"] = 1,
    }
    LoadPlist(self.plist)
end

function haiShenLogic:init()
	local scene_ui = ClsSceneManage:getSceneUILayer()
    scene_ui:addComponent("vs_ui", ClsVSUIComponent)

    local exit_func = function()
        local teamData = getGameData():getTeamData()
        local tips_str = ui_word.SEAGOD_STATION_LEVEA_LEADER_TIPS
        if teamData:isLock() then
            tips_str = ui_word.SEAGOD_STATION_LEVEA_TIPS
        end
        ClsAlert:showAttention(tips_str, function()
            if teamData:isInTeam() then
                teamData:askLeaveTeam()
            else
                self:askLeaveCopyScene()
            end
        end, nil, nil, {hide_cancel_btn = true})
    end
    scene_ui:callComponent("vs_ui", "setExitCallBack", exit_func) 

    self.team_mission_ui = getUIManager():create("gameobj/team/clsTeamMissionPortUI")
    self.team_mission_ui:showTeamPanel()
    self.team_mission_ui:setPosition(781, 198)
    self.team_mission_ui:setTouch(false)

    self:createChatComponent()
    ClsSceneManage:setSceneAttr("show_point_map", true)
    -- ClsSceneManage:getSceneLayer():getPlayerShip():setIsCheckCameraFollow(true)
    self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
    self:askUpdateTimer()

    local copySceneData = getGameData():getCopySceneData()
    if copySceneData:getIsNewRound() then
        ClsAlert:warning({msg = ui_word.STR_SEA_GOD_CREATE_TIP})
        return
    end
    if copySceneData:getPopProlusion() then
        self:createProlusion()
        copySceneData:setPopProlusion(false)
    else
        copySceneData:askMoveCamera()
    end
    scene_ui:setEnableEyeBtn(true)

    if copySceneData:getIsSeaGodFail() then
        self:popComfirm()
        copySceneData:setIsSeaGodFail(false)
    end

    if self.end_time then
        self:updateTimeUI(self.end_time)
    end
end

function haiShenLogic:updateSceneAttr(key, value)
	local scene_layer = ClsSceneManage:getSceneLayer()
	if scene_layer then
		if key == "seagod_lv" then
			if self.m_seagod_lv ~= value then
				self.m_seagod_lv = value
				local sea_obj = scene_layer:getSea()
				local copy_scene_sea_cfg = require("game_config/copyScene/copy_scene_sea_cfg")
				local key = "seagod_lv_" .. value
				local sea_cfg_item = copy_scene_sea_cfg[key]
				if sea_cfg_item then
					sea_obj:setUniforms(sea_cfg_item.sea_cfg)
				end
			end
		end
	end
end

local widget_name = {
    {res = "passivity_panel", is_visible = true},
    {res = "info_bg", is_visible = true},
    {res = "btn_close", is_visible = false},
    {res = "tips_text", is_visible = false},
    {res = "invite_text", is_visible = true},
    {res = "btn_accept", is_visible = true},
    {res = "btn_refuse", is_visible = true},
    {res = "btn_text_accept", is_visible = true},
    {res = "btn_text_refuse", is_visible = true},
    {res = "countdown_num", is_visible = true},
}

function haiShenLogic:popComfirm()
    local WAIT_TIME = 15
    local name_str = "SeaGodPopConfirm"
    local view, ui_layer, panel = ClsAlert:createBaseLayer("json/explore_copy_invite.json", "explore_invite", name_str, nil, nil, nil, false)
    if view then
        view:setIgnoreClosePanel(panel)
    end
    for _, v in ipairs(widget_name) do
        self[v.res] = getConvertChildByName(panel, v.res)
        self[v.res]:setVisible(v.is_visible)
    end
    self.invite_text:setText(ui_word.SEAGOD_FAILED_CONFIRM_CONTENT)
    self.btn_text_refuse:setText(ui_word.SEAGOD_FAILED_CONFIRM_REFUSE_NAME)
    self.btn_text_accept:setText(ui_word.SEAGOD_FAILED_CONFIRM_FIGHT_NAME)
    self.countdown_num:setText(WAIT_TIME)
    self.btn_accept:setPressedActionEnabled(true)
    self.btn_accept:addEventListener(function()
        getUIManager():close(name_str)
        self:autoMoveTo()
    end, TOUCH_EVENT_ENDED)
    self.btn_refuse:setPressedActionEnabled(true)
    self.btn_refuse:addEventListener(function()
        getUIManager():close(name_str)
    end, TOUCH_EVENT_ENDED)

    local arr_action = CCArray:create()
    arr_action:addObject(CCCallFunc:create(function()
        WAIT_TIME = WAIT_TIME - 1
        self.countdown_num:setText(WAIT_TIME)
        local bay_data = getGameData():getBayData()
        if WAIT_TIME == 0 then
            getUIManager():close(name_str)
        end
    end))
    arr_action:addObject(CCDelayTime:create(1))
    self.countdown_num:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function haiShenLogic:autoMoveTo()
    local player_ship = ClsSceneManage:getSceneLayer():getPlayerShip()
    local boss_id = getGameData():getCopySceneData():getSeaGodBossId()
    if not boss_id then return end
    local event_model = ClsSceneManage:getEvenObjById(boss_id)
    if not event_model then return end
    local boss_ship = event_model.item_model
    local copy_land = ClsSceneManage:getSceneLayer():getLand()
    local target_pos = copy_land:cocosToTileSize(ccp(boss_ship:getPos()))
    local call_back = function()
        event_model:sendInteractiveMessage()
    end
    copy_land:moveToTPos(target_pos, call_back)
end

function haiShenLogic:askUpdateTimer()
    GameUtil.callRpc("rpc_server_seagod_refresh_attr", {})
end

function haiShenLogic:createProlusion()
    local haishen_plot = require("game_config/haishen_plot")
    local dialog_tab = haishen_plot[0].dialog
    dialog_tab.call_back = function()
        getGameData():getCopySceneData():askMoveCamera()
    end
    getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)    
end

function haiShenLogic:updateTimeUI(time)
    self.end_time = time
    local function updateTime()        
        local scene_ui = ClsSceneManage:getSceneUILayer()
        if tolua.isnull(scene_ui) then
            if self.updateTimeHandle then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
                self.updateTimeHandle = nil
            end
            return
        end
  
        scene_ui.time_bg:setVisible(true)
        local cur_time = os.time() + getGameData():getPlayerData():getTimeDelta()
        self.remain_time = math.ceil(self.end_time - cur_time)
        if self.remain_time < 0 then 
            self.remain_time = 0
        end
        local time_str = string.format("%02d:%02d", math.floor(self.remain_time/60), self.remain_time - (math.floor(self.remain_time/60)*60))
        scene_ui.time_label:setText(time_str)
    end

    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
    self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

function haiShenLogic:createChatComponent()
    getUIManager():close("ClsChatComponent")
    getUIManager():create("gameobj/chat/clsChatComponent")
end

function haiShenLogic:createPlayerShip(parent)
    local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
    return ClsCopyPlayerShipsLayer.new(parent)
end

function haiShenLogic:onExit()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
    UnLoadPlist(self.plist)
end

function haiShenLogic:setPlayerShipMove(enable)
    if enable then
        self.m_ships_layer:releaseStopShipReason("haiShenLogic")
    else
        self.m_ships_layer:setStopShipReason("haiShenLogic")
    end
end

function haiShenLogic:askLeaveCopyScene()
    ClsSceneManage:sendExitSceneMessage()
end

function haiShenLogic:hideTeamBtn()
    if not tolua.isnull(self.team_mission_ui) then
        self.team_mission_ui:hideTeamBtn()
    end
end

function haiShenLogic:checkAlert()
    local Alert = require("ui/tools/alert")
    Alert:warning({msg = ui_word.SEAGOD_STATION_USE_TIPS})
    return true
end

function haiShenLogic:sumonBoss()
    local event_id = getGameData():getCopySceneData():getInteractEvent()
    if not event_id then return end
    local copy_scene_handle = getGameData():getCopySceneData()
    copy_scene_handle:askClickEvent(event_id)
    copy_scene_handle:setInteractEvent(nil)
end

function haiShenLogic:isInSeaGodScene()
    getGameData():getCopySceneData():setDialogPopSwitch(true)
    return true
end

function haiShenLogic:hideEvent(event_type)
    local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
    if not event_type or not ClsSceneConfig[event_type] then return end
    local config = ClsSceneConfig[event_type].is_radar_hide
    if config and config ~= 0 then
        return true
    end
end

return haiShenLogic