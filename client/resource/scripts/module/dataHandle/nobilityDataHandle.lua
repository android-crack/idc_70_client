--
-- Author: lzg0946
-- Date: 2016-07-04 21:16:11
-- Function: 爵位信息存储

local nobility_data = require("game_config/nobility_data")
local nobilityDataHandle = class("nobilityDataHandle")

local MAX_LEVEL_ID = 0

function nobilityDataHandle:ctor()
	self.nobility_id = 0
	self.elite_id = 0 
end

function nobilityDataHandle:setNobilityID(nobility_id)
	self.nobility_id = nobility_id
end

function nobilityDataHandle:getNobilityID()
	return self.nobility_id
end

function nobilityDataHandle:setEliteID(elite_id)
	self.elite_id = elite_id
end

function nobilityDataHandle:getEliteID()
	return self.elite_id
end


function nobilityDataHandle:getCurrentNobilityData()
	return nobility_data[self.nobility_id]
end

function nobilityDataHandle:getNobilityDataByID(nobility_id)
	return nobility_data[nobility_id]
end

function nobilityDataHandle:isFullLevel()
	local data = self:getNobilityDataByID(self.nobility_id)
	if (data.next == MAX_LEVEL_ID) then
		return true
	else
		return false
	end
	--return (data.next == 0)
end

function nobilityDataHandle:setPrestigeInfo(info)
	self.prestige_info = info 
end
function nobilityDataHandle:getPrestigeInfo()
	return self.prestige_info
end
----------------------- 协议请求 -------------------------------------------

function nobilityDataHandle:sendSyncNobilityInfo()
	GameUtil.callRpc("rpc_server_sync_nobility_info", {})
end

function nobilityDataHandle:sendNobilityUpstep()
	GameUtil.callRpc("rpc_server_nobility_upstep", {})
end

--晋升爵位跳里斯本港口
function nobilityDataHandle:askTryJumpPort()
	GameUtil.callRpc("rpc_server_go_to_upstep_nobility", {})
end

---声望提升
function nobilityDataHandle:sendPrestigeInfo()
	GameUtil.callRpc("rpc_server_prestige_progress", {})--,"rpc_client_prestige_progress"
end

----------------------- 协议请求 -------------------------------------------

return nobilityDataHandle
