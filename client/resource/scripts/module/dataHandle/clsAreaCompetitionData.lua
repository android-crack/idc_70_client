--2016/07/14
--create by wmh0497
--海盗信息存储地
require("game_config/battle_config")
local ui_word = require("game_config/ui_word")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local ClsAlert = require("ui/tools/alert")
local explore_mineral_config = require("game_config/explore/explore_mineral_config")

local ClsAreaCompetitionData = class("ClsAreaCompetitionData")

function ClsAreaCompetitionData:ctor()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_npc_data = {}
    self.m_mineral_point_config = nil
    self.m_event_info = nil
    self.m_mineral_attack_data = nil
    self.m_is_wait_mineral_attact_cfg_id = 0
    self.m_fight_open_level = 25
    self.m_wait_open_level = 10
    self.m_receive_mineral = nil
    self.m_robbery_mineral = nil
    self.m_mienral_port_info = {}
end

function ClsAreaCompetitionData:setMineralPortInfo(port_infos)
    for k, v in pairs(port_infos) do
        self.m_mienral_port_info[v.cfgId] = v.portId
    end
    -- local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
    -- if not tolua.isnull(explore_map) then
    --     explore_map:resetPoint(EXPLORE_NAV_TYPE_MINERAL_POINT)
    -- end
end

function ClsAreaCompetitionData:getMineralPortInfoByCfgId(cfg_id)
    return self.m_mienral_port_info[cfg_id] or 0
end

function ClsAreaCompetitionData:setReceiveMineral(mineral_ids)
    self.m_receive_mineral = mineral_ids or {}
end

function ClsAreaCompetitionData:addReceiveMineral(mineral_id)
    if not self.m_receive_mineral then
        self.m_receive_mineral = {}
    end
    
    for k, v in ipairs(self.m_receive_mineral) do
        if v == mineral_id then
            return
        end
    end

    self.m_receive_mineral[#self.m_receive_mineral + 1] = mineral_id
end

function ClsAreaCompetitionData:isReceiveMineral(mineral_id)
    self.m_receive_mineral = self.m_receive_mineral or {}
    for k, v in pairs(self.m_receive_mineral) do
        if v == mineral_id then
            return false
        end
    end
    return true
end

function ClsAreaCompetitionData:setRobberyMineral(mineral_ids)
   self.m_robbery_mineral = mineral_ids or {}
end

function ClsAreaCompetitionData:isRobberyMineral(mineral_id)
    self.m_robbery_mineral = self.m_robbery_mineral or {}
    for k, v in pairs(self.m_robbery_mineral) do
        if v == mineral_id then
            return false
        end
    end
    return true
end

function ClsAreaCompetitionData:getMineralPointConfig()
    if not self.m_mineral_point_config then
        self.m_mineral_point_config = {}
        for k, v in pairs(explore_objects_config) do
            if v.type == EXPLORE_OBJECT_TYPE.MINERAL_POINT then
                self.m_mineral_point_config[k] = v
            end
        end
    end
    return self.m_mineral_point_config
end

--同步函数，外部不能调用
function ClsAreaCompetitionData:addMineralPoint(data)
    self.m_npc_data[data.cfg_id] = data
end

--同步函数，外部不能调用
function ClsAreaCompetitionData:removeMineralPoint(data)
    self.m_npc_data[data.cfg_id] = nil
end

--同步函数，外部不能调用
function ClsAreaCompetitionData:updateAttr(attr_key, data, old_value)
    self.m_npc_data[data.cfg_id] = data
end

function ClsAreaCompetitionData:isOpen()
    if self.m_event_info then
        return true
    end
    return false
end

function ClsAreaCompetitionData:setEventInfo(cur_time, start_time, during_time)
    local data = {}
    data.cur_time = cur_time
    data.start_time = start_time
    data.receive_clock = os.clock()
    data.during_time = during_time
    data.end_time = during_time + data.start_time
    self.m_event_info = data
end

function ClsAreaCompetitionData:overEvent()
    self.m_event_info = nil
end

function ClsAreaCompetitionData:getRemainTime()
    if self.m_event_info then
        local now_time = os.clock() - self.m_event_info.receive_clock + self.m_event_info.cur_time
        if (self.m_event_info.start_time <= now_time) and (now_time <= self.m_event_info.end_time) then
            return Math.ceil(self.m_event_info.end_time - now_time)
        end
    end
    return 0
end

function ClsAreaCompetitionData:setMineralAttackData(data)
    self.m_mineral_attack_data = data
    EventTrigger(EVENT_PORT_SAILOR_FOOD) --更新选中的ui

    local mineral_defend_view = getUIManager():get("clsMineralDefendView")
    if not tolua.isnull(mineral_defend_view) then
        mineral_defend_view:updateUI()
    end

    self:tryToUpdataMineralUI(data.attr.cfg_id)

    self.m_is_wait_mineral_attact_cfg_id = 0

end

local tab = {
    ["material"] = ITEM_INDEX_MATERIAL,
    ["darwing"] = ITEM_INDEX_DARWING,
    ["keepsake"] = ITEM_INDEX_KEEPSAKE,
    ["item"] = ITEM_INDEX_PROP,
    ["equip"] = ITEM_INDEX_EQUIP,
    ["exp"] = ITEM_INDEX_EXP,
    ["cash"] = ITEM_INDEX_CASH,
    ["gold"] = ITEM_INDEX_GOLD,
    ["tili"] = ITEM_INDEX_TILI,
    ["honour"] = ITEM_INDEX_HONOUR,
    ["sailor"] = ITEM_INDEX_SAILOR,
    ["status"] = ITEM_INDEX_STATUS,
    ["food"] = ITEM_INDEX_FOOD,
    ["baowu"] = ITEM_INDEX_BAOWU,
    ["contribute"] = ITEM_INDEX_CONTRIBUTE,
    ["prestige"] = ITEM_INDEX_DONATE,
    ["prosper"] = ITEM_INDEX_PROSPER,
    ["boat"] = ITEM_INDEX_BOAT,
}

--获取某个矿物的奖励信息和资源图
function ClsAreaCompetitionData:getMineralRewardInfo(cfg_id)
    local mineral_object = explore_objects_config[cfg_id]
    if not mineral_object then return end

    local info = {mineral_res = "", 
                    reward_res = "",
                    reward_count = 0}
  
    local player_data = getGameData():getPlayerData()
    local player_level = player_data:getLevel()
    local mineral_config = explore_mineral_config[mineral_object.mineral_type]
    info.mineral_res = mineral_config.res

    local function getRewardInfo(reward_tab)
        local temp = {} 
        temp["key"] = tab[reward_tab[1]]
        temp["id"] = reward_tab[2]
        temp["value"] = reward_tab[#reward_tab]
        return getCommonRewardIcon(temp)
    end

    local reward_info = mineral_config.reward
    if type(reward_info[1]) == "table" then
        reward_info = reward_info[math.ceil(player_level / 10)]
        if player_level >= 60 then
            reward_info = mineral_config.reward[#mineral_config.reward]
        end
    end
    
    info.reward_res, info.reward_count = getRewardInfo(reward_info)
    return info
end

function ClsAreaCompetitionData:getMineralAttackData()
    return self.m_mineral_attack_data
end

function ClsAreaCompetitionData:tryToCallMineral(cfg_id)
    local npc_data = self.m_npc_data[cfg_id]
    if npc_data then
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local explore_npc_layer = explore_layer:getNpcLayer()
            explore_npc_layer:callNpc(npc_data.id, "touchMineral")
        end
    end
end

function ClsAreaCompetitionData:tryToUpdataMineralUI(cfg_id)
    local npc_data = self.m_npc_data[cfg_id]
    if npc_data then
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local explore_npc_layer = explore_layer:getNpcLayer()
            explore_npc_layer:callNpc(npc_data.id, "updataUI")
        end
    end
end

function ClsAreaCompetitionData:tryToMineralInteractive()
    local player_data = getGameData():getPlayerData()
    local player_level = player_data:getLevel()
    if self:isOpen() then
        return tonumber(player_level) >= self.m_fight_open_level
    else
        return player_level >= self.m_wait_open_level
    end
end

function ClsAreaCompetitionData:getFightOpenLevel()
    return self.m_fight_open_level
end

function ClsAreaCompetitionData:getWaitOpenLevel()
    return self.m_wait_open_level
end

----------------------------------------------------------------------------------------

function ClsAreaCompetitionData:askSubHp(obj_id)
    GameUtil.callRpc("rpc_server_contend_deposit_attack", {obj_id})
end

function ClsAreaCompetitionData:askDefendMineral(cfg_id)
    GameUtil.callRpc("rpc_server_contend_deposit_defense", {cfg_id})
end

function ClsAreaCompetitionData:askMineralPortHurt(obj_id)
    GameUtil.callRpc("rpc_server_contend_deposit_check_hurt", {obj_id})
end

function ClsAreaCompetitionData:askMineralAttackData(cfg_id)
    if not self.m_receive_mineral then
        self.m_receive_mineral = {}
        self:askTryReceiveMineral()
    end

    if self.m_is_wait_mineral_attact_cfg_id == cfg_id then
        return
    end
    GameUtil.callRpc("rpc_server_contend_deposit", {cfg_id})
    self.m_is_wait_mineral_attact_cfg_id = cfg_id
end

function ClsAreaCompetitionData:askTryOccupiedMineral(cfg_id, is_forcibly)
    GameUtil.callRpc("rpc_server_contend_challenge", {cfg_id, is_forcibly and 1 or 0})
end

function ClsAreaCompetitionData:askTryHarvestMineral(cfg_id)
    self:addReceiveMineral(cfg_id)
    GameUtil.callRpc("rpc_server_contend_deposit_harvest", {cfg_id})
end 

function ClsAreaCompetitionData:askTryJoinMineral()
    GameUtil.callRpc("rpc_server_contend_join", {})
end

--查询已经领取过的矿产
function ClsAreaCompetitionData:askTryReceiveMineral()
    GameUtil.callRpc("rpc_server_contend_deposit_fetched", {})
end

--查询已经掠夺过的矿产
function ClsAreaCompetitionData:askTryRobberyMineral()
    GameUtil.callRpc("rpc_server_contend_challengeed", {})
end

--转发矿产攻击包
function ClsAreaCompetitionData:askTryRelayAttackMineral(cfg_id)
    GameUtil.callRpc("rpc_server_deposit_attack_msg", {cfg_id})
end

--请求某个海域的矿产归属
function ClsAreaCompetitionData:askAreaMineralPort(area_id)
     GameUtil.callRpc("rpc_server_contend_deposit_port", {area_id}, "rpc_client_contend_deposit_port")
end

----------------------------------------------------------------------------------------


return ClsAreaCompetitionData