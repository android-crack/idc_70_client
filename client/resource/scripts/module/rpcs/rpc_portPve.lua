local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local news = require("game_config/news")

function rpc_client_checkpoint_port_info(portId, portInfo)
	local portPveData = getGameData():getPortPveData()
	portPveData:receivePortInfo(portInfo)
end

function rpc_client_checkpoint_stronghold_info(strongHoldInfo)
	local portPveData = getGameData():getPortPveData()
	portPveData:receiveStrongHoldInfo(strongHoldInfo)
end

function rpc_client_checkpoint_all_port_info(portInfos)
	
end

-- class portInfo {
-- 	int portId
--  int status
-- 	int step
--  int complete
--  int checkpointId
--  int isOwner
--  int preIds
-- }

-- class strongHoldInfo {
-- int strongholdId
-- int status
-- int complete  --完成的数次
-- int step
-- }
function rpc_client_checkpoint_all_info(portInfos, strongHoldInfos)
	local portPveData = getGameData():getPortPveData()
	portPveData:receiveAllCpInfo(portInfos, strongHoldInfos)
end

function rpc_client_checkpoint_port_complete(portId)
	local portPveData = getGameData():getPortPveData()
	portPveData:setCompletePort()
end

function rpc_client_arrive_checkpoint(result, error)
	local portPveData = getGameData():getPortPveData()
	if portPveData.askArrivePortCallBack ~= nil then
		portPveData.askArrivePortCallBack()
		portPveData.askArrivePortCallBack = nil
	end
	if result == 0 then
		_msg = error_info[error].message
		Alert:warning({msg = _msg})
		return
	end
end

function rpc_client_arrive_stronghold(result, error)
	local portPveData = getGameData():getPortPveData()
	if portPveData.askArriveShCallBack ~= nil then
		portPveData.askArriveShCallBack()
		portPveData.askArriveShCallBack = nil
	end
	if result == 0 then
		_msg = error_info[error].message
		Alert:warning({msg = _msg})
		return
	end
end