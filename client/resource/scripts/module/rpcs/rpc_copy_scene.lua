local error_info=require("game_config/error_info")
local ClsAlert = require("ui/tools/alert")--公会创建
local element_mgr = require("base/element_mgr")
local news = require("game_config/news")
local ClsUiWord = require("game_config/ui_word")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local parseMsg = require("module/message_parse")
local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ModuleServerOpt = require("gameobj/copyScene/serverOpt")
local exploreSea = require("gameobj/explore/exploreSea")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")

function rpc_client_copy_scene_start(sid, time_n)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:startRunning(sid, time_n)
end

--[[scene_object:
    id:int
    type:int
    x,y int
    iat, cat
--]]
local function makeSceneObjectInfo(scene_object)
    local i_attr = scene_object.iat or {}
    scene_object.attr = {}
    for k, v in pairs(i_attr) do
        scene_object.attr[v.key] = v.value
    end
    local c_attr = scene_object.cat or {}
    for k, v in pairs(c_attr) do
        scene_object.attr[v.key] = v.value
    end
    return scene_object
end

local function putSceneObj(scene_object)
    if getGameData():getSceneDataHandler():isInExplore() then
        local type_n = scene_object.type
        if type_n == EXPLORE_OBJECT_TYPE.MINERAL_POINT_TYPE_ID then
            scene_object = makeSceneObjectInfo(scene_object)
            local cfg_id = scene_object.attr.cfgId
            attr = scene_object.attr
            scene_object.attr = nil
            attr.scene_object = scene_object
            getGameData():getExploreNpcData():addStandardNpc(scene_object.id, scene_object.id, exploreNpcType.MINERAL_POINT, attr, cfg_id, explore_objects_config[cfg_id])
        end
    else
        ClsSceneManage:addSceneEventData(makeSceneObjectInfo(scene_object))
    end
end

function rpc_client_object_enter_scene(scene_object)
    putSceneObj(scene_object)
end

function rpc_client_objects_enter_scene(scene_objects)
    for _, scene_object in ipairs(scene_objects) do
        putSceneObj(scene_object)
    end
end

-- 增加对象交互协议
-- void rpc_client_object_interactive_result(int uid, int objId, int interactiveType, int result);
function rpc_client_object_interactive_result(obj_id, interactive_type, result)
    if result > 0 then
        ClsAlert:warning({msg = error_info[result].message})
    end
    ClsSceneManage:updataInteractiveResult(obj_id, interactive_type, result)
end

local function getAttrs(iat, cat)
    local attr = {}
    for _, v in pairs(iat) do
        attr[#attr + 1] = v
    end
    for _, v in pairs(cat) do
        attr[#attr + 1] = v
    end
    return attr
end

-- 对象属性变化
-- void rpc_client_object_change_attr(int uid, int objId, object_i_attr_t* iat, object_c_attr_t* cat);
function rpc_client_object_change_attr(obj_id, iat, cat)
    local attrs = getAttrs(iat, cat)
    for _, v in ipairs(attrs) do
        if getGameData():getSceneDataHandler():isInExplore() then
            getGameData():getExploreNpcData():updateNpcAttr(obj_id, v.key, v.value)
        else
            ClsSceneManage:updataEventAttr(obj_id, v.key, v.value)
        end
    end
end

function rpc_client_delete_object(obj_id)
    if getGameData():getSceneDataHandler():isInExplore() then
        getGameData():getExploreNpcData():removeNpc(obj_id)
    else
        ClsSceneManage:deleteSceneEventData(obj_id)
    end
end

function rpc_client_scene_change_attr(iat, cat)
    local attrs = getAttrs(iat, cat)
    for _, v in ipairs(attrs) do
        ClsSceneManage:updateSceneAttr(v.key, v.value)
    end
end

-- void rpc_client_object_action( int uid, int source, int actionId, object_i_attr_t* iat );
-- object_i_attr_t iatTarget = new object_i_attr_t( key:"target", value:target );
-- object_i_attr_t iatSubHp = new object_i_attr_t( key:"sub_hp", value:attackPoint );
-- object_i_attr_t iatHp = new object_i_attr_t( key:"hp", value:data["hp"]);
function rpc_client_object_action(source_id, action_id, iat)
    local params = {}
    for k, v in ipairs(iat) do
        params[v.key] = v.value
    end
    ClsSceneManage:updateSceneAction(source_id, action_id, params)
end

-- 镜头效果
function rpc_client_camera_effect(tx, ty, moveTime, pauseTime )
    ModuleServerOpt.copySceneCameraEffect(tx, ty, moveTime, pauseTime )
end

function rpc_client_fuben_text_tips(msg_str)
    local parse_msg_str = parseMsg.parse(msg_str)
    ClsAlert:warning({msg = parse_msg_str})
end

function rpc_client_fuben_text_gonggao(msg_str)
    local parse_msg_str = parseMsg.parse(msg_str)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("putNoticeMsg", parse_msg_str)
end

-------------------------------------------------------------------------------------------
-- void rpc_client_copy_scene_reward_broadcast(int uid, int target, int eventId, random_reward_t* rewards);
function rpc_client_copy_scene_reward_broadcast(uid, event_type, rewards)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if not tolua.isnull(scene_ui) then 
        scene_ui:callComponent("copy_star_ui", "stopUpdataStar")
    end
    if event_type == SCENE_OBJECT_TYPE_SEA_WRECK then
        local copy_scene_data = getGameData():getCopySceneData()
        copy_scene_data:setWinUid(uid)
        copy_scene_data:setWinReward(rewards)
    end
end

function rpc_client_copy_scene_get_reward(reward) --副本场景奖励
    ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = reward}))
end

local function handlerSceneEnd(result_info, rewards)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()
    if tolua.isnull(scene_layer) then
        print("副本场景不在了-----------------------------")
        return
    end

    ClsSceneManage:doLogic("cancelRecord")

    local resultLayer = ClsSceneManage:getResultLayer()
    if not tolua.isnull(resultLayer) then
        return
    end

    scene_layer:setTouchEnabled(false)
    scene_layer:setVisible(false)
    local scene_ui = ClsSceneManage:getSceneUILayer()
    scene_ui:setTouchEnabled(false)
    scene_ui:setEnabledUI(false)
    scene_ui:setVisible(false)

    if type(result_info) == "table" then
        result_info.rewards = rewards
    end

    setNetPause(true)
    local result_layer = ClsSceneManage:doLogic("getResuleLayer", result_info, function()
        setNetPause(false)
    end)
    ClsSceneManage:setResultLayer(result_layer) 
end

function rpc_client_scene_xunbao_end(sceneId, winner_uid, rewards)
    local copy_scene_data = getGameData():getCopySceneData()
    copy_scene_data:setWinUid(winner_uid)
    copy_scene_data:setWinReward(rewards)
    local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
    copy_scene_manage:setSceneEnd()
    handlerSceneEnd()
end

function rpc_client_copy_scene_complete(sid)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("showCompleteTips", sid)
end

--寻宝副本的某一個玩家的任务列表
-- scene_missioin {
-- 	int uid;
-- 	int type;
-- 	int times;
-- 	int complete;
-- 	int progress;
--  string name
-- }
function rpc_client_copy_scene_missions(mission)
	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:setTreasureMission(mission)

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("updateMissions")
end

--寻宝副本的全部玩家的任务列表
function rpc_client_copy_scene_sync_mission_list(missions)
	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:setTreasureMissions(missions)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("updateMissions")
end

--竞速副本结算
-- class explore_result_info {
--      int star;
--      int winner;
--      random_reward_t* rewards;
-- }
--void rpc_client_scene_explore_end(int uid, int sceneId, explore_result_info info);
function rpc_client_scene_explore_end(sid, info)
    local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
    copy_scene_manage:setSceneEnd()
    handlerSceneEnd(info, info.rewards)
end

--副本提示tips
function rpc_client_fuben_tips(msgs, continuance_time)
    local copy_scene_data = getGameData():getCopySceneData()
    local str_tips = require("module/message_parse").parse(msgs)
    copy_scene_data:addTips(str_tips, continuance_time / 1000)

    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("showKillTips", continuance_time / 1000)

    local battle_data = getGameData():getBattleDataMt()
    if not battle_data:IsBattleStart() then return end

    local battle_ui = getUIManager():get("FightUI")
    if not tolua.isnull(battle_ui) then
        battle_ui:showTipsUI(str_tips, continuance_time / 1000)
    end
end

--大乱斗的排行全部玩家信息
function rpc_client_top_fight_chart(list)
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:setRankList(list)
end

--大乱斗的排行单条玩家信息
function rpc_client_top_fight_rank(player_info)
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:addRankInfo(player_info)
end

--大乱斗的玩家生命值
function rpc_client_top_fight_life(life)
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:setMyLife(life)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateHeart", life)
end

function rpc_client_enter_top_fight(error_code)
    if error_code == 0 then
        return
    end
    ClsAlert:warning({msg = error_info[error_code].message})
end

function rpc_client_top_fight_status(time, error_code)
    if error_code ~= 0 then
        ClsAlert:warning({msg = error_info[error_code].message})
        return
    end
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:setMeleeTime(time)

    local melee_enter_ui = getUIManager():get("clsMeleeEnterUI")
    if not tolua.isnull(melee_enter_ui) then
        melee_enter_ui:updateUI()
    end
end

function rpc_client_seagod_leader_click_pillar(eventId)
    if not eventId then return end
    local event_obj = ClsSceneManage:getEvenObjById(eventId)
    if event_obj then
        event_obj:showEventEffect()
    end
end

function rpc_client_seagod_move_camera(eventId)
    if eventId == 0 then return end
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:setInteractEvent(eventId)
end

function rpc_client_seagod_enter_fuben_tip()
    getGameData():getCopySceneData():setPopProlusion(true)
end

function rpc_client_seagod_new_round_pillar()
    getGameData():getCopySceneData():setIsNewRound(true)
end

function rpc_client_seagod_fight_failed()
    getGameData():getCopySceneData():setIsSeaGodFail(true)
end
