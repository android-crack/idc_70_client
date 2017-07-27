local error_info=require("game_config/error_info")
local ClsAlert = require("ui/tools/alert")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
-- class port_t {
-- 	int portId
-- 	int rewardTime
-- 	int status
-- 	int open
-- }
function rpc_client_port_list(portList)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:getPortListFromSer(portList)
	local portData = getGameData():getPortData()
	portData:receivePortEffectList(portList)
end 

function rpc_client_single_port(port)
    local mapAttrs = getGameData():getWorldMapAttrsData()
    mapAttrs:getSinglePortFromSer(port)
end

function rpc_client_port_enter(portId, result, err)  --进入港口

    getGameData():getWorldMapAttrsData():setIsAskEnterPort(false)
    
    if result == 0 and err == 0 then -- 同港口有任务可能要战斗， 不让他进港
        local mapAttrs = getGameData():getWorldMapAttrsData()
        return
    end

    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() and result == 1 then
        battle_data:SetData("Already_Enter_Port", portId)
        return
    end

    if result == 1 then      -- 成功
        local is_sample_scene = getGameData():getSceneDataHandler():setSceneInfo(portId, SCENE_TPYE_ID.PORT, portId)
        if is_sample_scene then
            return
        end
        getGameData():getExploreData():setIsExplore(false)
        getGameData():getExploreData():setGoalInfo(nil)
        getGameData():getPortData():changePortId(portId)
        local mapAttrs = getGameData():getWorldMapAttrsData()
        mapAttrs:enterPort(portId)
        getGameData():getExploreMapData():init() --初始化pve，数据
        getGameData():getExplorePlayerShipsData():cleanInfo()
        local mapAttrs = getGameData():getWorldMapAttrsData()
        ClsDialogSequene:pauseQuene("enter_port")
        startMainScene()
    elseif result == 0 then  --出错
        ClsDialogSequene:resumeQuene("enter_port")
        ClsAlert:warning({msg = error_info[err].message})
    end
end

function rpc_client_port_enter_gm(portId)  --进入港口（命令）
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:enterPort(portId)
	startMainScene()
end

function rpc_client_map_hotsell_port(portList)  --流行商品
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:receiveHotsellFromSer(portList)
end