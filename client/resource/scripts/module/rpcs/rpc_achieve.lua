local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")

-- rpc_server_achieve_list(object oUser) 请求所有的成就
   
--rpc_server_achieve_info(object oUser, int achieveId)
function rpc_client_achieve_info(achieve,oldId)
	
end

function rpc_client_achieve_finish(achstats)
	local achieveData = getGameData():getAchieveData()
	achieveData:receiveAchieveFinishInfo(achstats)
end

--rpc_server_achieve_reward(achieveId)
function rpc_client_achieve_reward(result,error)
	if result==1 then end
end

----------------------------------------新版成就----begin

-- class achieve_t {
--     int event;
--     int finishtime;
--     int rewarded;
-- }

-- class stats_t {
--     int event;
--     int value;
-- }

-- class achievedata_t {
--     int version;
--     string type;
--     stats_t *stats;
--     achieve_t *achieve;
-- }

function rpc_client_achieve_get(who, achievement)
	local achieveData = getGameData():getAchieveData()
	achieveData:receiveAchieveInfo(who, achievement)
end

----------------------------------------新版成就----end

