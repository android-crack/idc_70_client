----- 任务事件
local math_floor = math.floor
local MissionEvent = {}

--进入港口
function MissionEvent.enter_port(param)
	
	local port_id = param.portId
	getGameData():getWorldMapAttrsData():tryToEnterPort(port_id)
end

--进入战斗
function MissionEvent.enter_battle(param)
	-- local battle_id = param.battleId
	-- GameUtil.callRpc("rpc_server_fight_start", {battle_id}, "rpc_client_fight_start")
end

return MissionEvent