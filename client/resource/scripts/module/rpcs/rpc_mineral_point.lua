local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
local ClsAlert = require("ui/tools/alert")
local ClsUiWord = require("game_config/ui_word")
local error_info = require("game_config/error_info")

local function updateExploreShipsCamp()
    local explore_layer = getExploreLayer()
    if not tolua.isnull(explore_layer) then
        local ships_layer = explore_layer:getShipsLayer()
        if not tolua.isnull(ships_layer) then
            ships_layer:updateAllShipStatus()
        end
    end
end

--[[
海域争霸BOSS剩余时间
ctime 服务器当前时间,stime 活动开始时间， lasting 活动持续时间
void rpc_client_contend_left(int uid,int ctime,int stime,int lasting); --]]
function rpc_client_contend_left(ctime, stime, lasting)
    getGameData():getAreaCompetitionData():setEventInfo(ctime, stime, lasting)
    updateExploreShipsCamp()
end

--[[// 海域争霸结束  
void rpc_client_contend_over(int uid); --]]
function rpc_client_contend_over()
    getGameData():getAreaCompetitionData():overEvent()
    updateExploreShipsCamp()
end
--[[
class deposit_hurt {
int portId; 
int hurt; }
// 开战期，查看各海域对矿藏的伤害值
void rpc_server_contend_deposit_check_hurt(object user, int objId); 
void rpc_client_contend_deposit_check_hurt(int uid, int objId, deposit_hurt *hSort); 
--]]
function rpc_client_contend_deposit_check_hurt(obj_id, total_hurt, port_hurt)
    local info = {}
    info.total_hurt = total_hurt
    info.port_hurt = port_hurt
    local mineral_hit_view = getUIManager():get("ClsMineralHitView")
    if not tolua.isnull(mineral_hit_view) then
        mineral_hit_view:updatePortHurtShow(info)
    end
end

function rpc_client_contend_deposit(cfg_id, iat, cat, total_hurt, port_hurt)
    local attr = {}
    for k, v in ipairs(iat) do
        attr[v.key] = v.value
    end
    for k, v in ipairs(cat) do
        attr[v.key] = v.value
    end
    attr.cfg_id = cfg_id
    attr.total_hurt = total_hurt
    local info = {}
    info.attr = attr
    info.port_hurt = port_hurt
    getGameData():getAreaCompetitionData():setMineralAttackData(info)
end

function rpc_client_contend_first_occupy(cfg_id)
    getGameData():getAreaCompetitionData():askMineralAttackData(cfg_id)
end


--[[
    error_code：
        0-成功、
        1-未到开战期、
        2-等级不足、
        3-服务端出问题、
        4-没有商会据点
]]

local tips_error = {
    ClsUiWord.STR_NOT_FIGHT_MINERAL_TIPS,
    ClsUiWord.LV_NOT_ENOUGH_TIPS,
    ClsUiWord.STR_SYSTEM_FAIL_TIPS,
}

function rpc_client_contend_join(error_code)
    local ClsActivityMain = getUIManager():get("ClsActivityMain")
    if error_code ~= 0 then
        ClsAlert:warning({msg = tips_error[error_code]})
        if not tolua.isnull(ClsActivityMain) then
            ClsActivityMain:setTouch(true)
        end
    else
        ClsAlert:warning({msg = ClsUiWord.STR_JOIN_MINERAL_SUCCESS_TIPS})
        local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
        local layer = missionSkipLayer:skipLayerByName("team_mineral_point")
    end
end

function rpc_client_contend_deposit_fetched(mineral_ids)
    getGameData():getAreaCompetitionData():setReceiveMineral(mineral_ids)
end

function rpc_client_contend_challengeed(mineral_ids)
    local area_competition_data = getGameData():getAreaCompetitionData()
    area_competition_data:setRobberyMineral(mineral_ids)
end

function rpc_client_deposit_attack_msg(object_id)
     local explore_layer = getExploreLayer()
    if not tolua.isnull(explore_layer) then
        local explore_npc_layer = explore_layer:getNpcLayer()
        if not tolua.isnull(explore_npc_layer) then
            explore_npc_layer:callNpc(object_id, "fireMineral")
        end
    end
end

function rpc_client_contend_confirm_show(cfg_id)
    ClsAlert:showAttention(ClsUiWord.STR_OCCUPIED_TIPS, function()
        local area_competition_data = getGameData():getAreaCompetitionData()
        area_competition_data:askTryOccupiedMineral(cfg_id, true)
    end)
end

function rpc_client_contend_deposit_port(area_id, mineral_ports)
    local area_competition_data = getGameData():getAreaCompetitionData()
    area_competition_data:setMineralPortInfo(mineral_ports)
end