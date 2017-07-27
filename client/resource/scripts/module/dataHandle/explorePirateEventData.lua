--2016/07/14
--create by wmh0497
--海盗信息存储地
require("game_config/battle_config")
local ui_word = require("game_config/ui_word")
local error_info = require("game_config/error_info")
local on_off_info = require("game_config/on_off_info")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local ClsAlert = require("ui/tools/alert")

local ClsExplorePirateEventData = class("ClsExplorePirateEventData")

function ClsExplorePirateEventData:ctor()
    self.m_time_pirate_config = nil
    self.m_event_info = nil
    self.m_npc_data = {}
    self.m_cd_time = {}
    self.m_is_wait_person_rank = false
    self.m_person_rank_list = {}
    self.m_is_wait_guild_rank = false
    self.m_group_rank_list = {}
end

function ClsExplorePirateEventData:getTimePirateConfig()
    if not self.m_time_pirate_config then
        self.m_time_pirate_config = {}
        for k, v in pairs(explore_objects_config) do
            if v.type == EXPLORE_OBJECT_TYPE.TIME_PIRATE then
                self.m_time_pirate_config[k] = v
            end
        end
    end
    
    return self.m_time_pirate_config
end

local function updatePirateMapPoint()
    local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
    if not tolua.isnull(explore_map_obj) then
        explore_map_obj:resetPoint(EXPLORE_NAV_TYPE_TIME_PIRATE)
    end
end

--同步函数，外部不能调用
function ClsExplorePirateEventData:addPirate(data)
    self.m_npc_data[data.cfg_id] = data
    updatePirateMapPoint()
end

--同步函数，外部不能调用
function ClsExplorePirateEventData:removePirate(data)
    self.m_npc_data[data.cfg_id] = nil
    updatePirateMapPoint()
end

--同步函数，外部不能调用
function ClsExplorePirateEventData:updateAttr(attr_key, data)
    self.m_npc_data[data.cfg_id] = data
    local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
    if not tolua.isnull(explore_map_obj) then
        if attr_key == "cd" or attr_key == "hp" then
            updatePirateMapPoint()
        end
        if explore_map_obj:isShowMax() then
            EventTrigger(EVENT_PORT_SAILOR_FOOD) --更新选中的ui
        end
    end
end

function ClsExplorePirateEventData:getAllPirateInfo(is_check_in_event)
    if is_check_in_event and (not self:isOpen()) then
        return {}
    end
    return self.m_npc_data
end

function ClsExplorePirateEventData:getPirateByCfgId(cfg_id, is_check_in_event)
    if is_check_in_event and (not self:isOpen()) then
        return
    end
    return self.m_npc_data[cfg_id]
end

local os_time = os.time
local math_ceil = math.ceil
function ClsExplorePirateEventData:getPirateCd(cfg_id)
    if self:isOpen() then
        local npc_data = self.m_npc_data[cfg_id]
        if npc_data then
            local server_end_time = npc_data.attr["cd"] or 0
            if server_end_time > 0 then
                local cur_server_time = os_time() + getGameData():getPlayerData():getTimeDelta()
                if cur_server_time < server_end_time then
                    return math_ceil(server_end_time - cur_server_time)
                end
            end
        end
    end
    return 0
end

function ClsExplorePirateEventData:hasPirateByCfgId(cfg_id)
    if self.m_npc_data[cfg_id] then
        return true
    end
    return true
end

function ClsExplorePirateEventData:getPirateHpPercentByCfgId(cfg_id)
    local npc_data = self.m_npc_data[cfg_id]
    if npc_data then
        return Math.floor(100*npc_data.attr.hp/npc_data.cfg_item.fight_time)
    end
end

function ClsExplorePirateEventData:setPirateEventInfo(cur_time, start_time, during_time)
    --延迟两分钟下发奖励，界面显示还是要10分钟
    local delay_time = 120
    local data = {}
    data.cur_time = cur_time
    data.start_time = start_time
    data.during_time = during_time
    data.end_time = during_time + data.start_time - delay_time
    self.m_event_info = data
end

function ClsExplorePirateEventData:getActiveAreaIds()
	local areas = {}
	if self:isOpen() then
		for k, v in pairs(self.m_npc_data) do
			areas[v.cfg_item.area_id] = true
		end
	end
	return areas
end

function ClsExplorePirateEventData:getRemainTime()
    if self.m_event_info then
        local now_time = getGameData():getPlayerData():getCurServerTime()
        if (self.m_event_info.start_time <= now_time) and (now_time <= self.m_event_info.end_time) then
            return Math.ceil(self.m_event_info.end_time - now_time)
        end
    end
    return 0
end

function ClsExplorePirateEventData:overEvent()
    self.m_event_info = nil
    local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
    if not tolua.isnull(explore_map_obj) then
        if explore_map_obj:isShowMax() then
            EventTrigger(EVENT_PORT_SAILOR_FOOD) --更新选中的ui
        end
        updatePirateMapPoint()
    end
end

function ClsExplorePirateEventData:isOpen()
	-- if self:getRemainTime() > 0 then
	if getGameData():getOnOffData():isOpen(on_off_info.WORLD_MISSION.value) then
		if self.m_event_info then
			return true
		end
	end
	return false
end

local open_lv = 20
function ClsExplorePirateEventData:isLvOpen(is_show_tip)
	if getGameData():getOnOffData():isOpen(on_off_info.WORLD_MISSION.value) then return true end
	if is_show_tip then
		ClsAlert:warning({msg = error_info[756].message})
	end
	return false
end

function ClsExplorePirateEventData:cleanRankInfo()
    self.m_person_rank_list = {}
    self.m_group_rank_list = {}
end

function ClsExplorePirateEventData:getPersonRankList()
    return self.m_person_rank_list
end

function ClsExplorePirateEventData:setPersonRankList(info)
    self.m_person_rank_list = info
    EventTrigger(EVENT_PORT_SAILOR_FOOD) --更新选中的ui
    self.m_is_wait_person_rank = false
end

function ClsExplorePirateEventData:getGroupRankList()
    return self.m_group_rank_list
end

function ClsExplorePirateEventData:setGroupRankList(info)
    self.m_group_rank_list = info
    EventTrigger(EVENT_PORT_SAILOR_FOOD) --更新选中的ui
    self.m_is_wait_guild_rank = false
end

function ClsExplorePirateEventData:askPersonRank(area_id)
    if self.m_is_wait_person_rank then
        return
    end
    self.m_is_wait_person_rank = true
    GameUtil.callRpc("rpc_server_area_boss_rank", {area_id}, "rpc_client_area_boss_person_rank")
end

function ClsExplorePirateEventData:askGroupRank()
    if self.m_is_wait_guild_rank then
        return
    end
    self.m_is_wait_guild_rank = true
    GameUtil.callRpc("rpc_server_area_boss_rank", {2}, "rpc_client_area_boss_group_rank")
end

function ClsExplorePirateEventData:askFightPirate(cfg_id)
    local npc_data = self:getPirateByCfgId(cfg_id)
    if npc_data then
        -- GameUtil.callRpc("rpc_server_area_battle", {npc_data.cfg_item.battle_id, npc_data.cfg_item.area_id, npc_data.server_id})
        local attr_str = json.encode({areaId = npc_data.cfg_item.area_id, npcId = npc_data.server_id})
        GameUtil.callRpc("rpc_server_fight_pve", {1200001, battle_config.fight_type_area_boss, attr_str})
    end
end

return ClsExplorePirateEventData