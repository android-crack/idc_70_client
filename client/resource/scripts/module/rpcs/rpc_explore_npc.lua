local ClsAlert = require("ui/tools/alert")
local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local error_info = require("game_config/error_info")

--[[
// 添加一个没有服务端走路的npc 
// npcid 服务端生成的唯一id
// cfgid 策划配置id
// 活动开始的时候推送信息
void rpc_client_add_virtual_npc(int uid,int npcid,int cfgid); 
void rpc_client_del_virtual_npc(int uid,int npcid);  --]]
local function makeAttr(iat, cat)
    local attr = {}
    for k, v in pairs(iat) do
        attr[v.key] = v.value
    end
    for k, v in pairs(cat) do
        attr[v.key] = v.value
    end
    return attr
end

function rpc_client_add_virtual_npc(npcid, iat, cat)
    local npc_attr = makeAttr(iat, cat)
    local cfgid = npc_attr.cfgId
    local pirate_cfg = explore_objects_config[cfgid]
    local type_n = exploreNpcType.PIRATE
    if pirate_cfg.is_boss > 0 then
        type_n = exploreNpcType.PIRATE_BOSS
    end
    getGameData():getExploreNpcData():addStandardNpc(npcid, npcid, type_n, npc_attr, cfgid, pirate_cfg)
end

function rpc_client_del_virtual_npc(npcid)
    getGameData():getExploreNpcData():removeNpc(npcid)
end

function rpc_client_upt_virtual_npc(npcid, iat, cat)
    local attr = makeAttr(iat, cat)
    for key, value in pairs(attr) do
        getGameData():getExploreNpcData():updateNpcAttr(npcid, key, value)
    end
end

function rpc_client_fight_failure(battle_id, error_n)
    ClsAlert:warning({msg = error_info[error_n].message})
end