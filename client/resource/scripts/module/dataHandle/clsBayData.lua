--
-- Author: lzg0496
-- Date: 2016-05-24 11:16:15
-- Function: 藏宝海湾数据存储

local clsBayData = class("clsBayData")

function clsBayData:ctor()
	self.responseCallback = nil
end

function clsBayData:setResponseCallback(callback)
	self.responseCallback = callback
end

function clsBayData:getResponseCallback()
	return self.responseCallback
end

------------------------------------------ 请求协议 ---------------------------------------------------------------------

function clsBayData:sendResponse(response)
	GameUtil.callRpc("rpc_server_cangbao_bay_response", {response}, "rpc_client_cangbao_bay_response")
end

--队长请求邀请协议
function clsBayData:sendTeamAsk()
	GameUtil.callRpc("rpc_server_cangbao_bay_team_ask", {}, "rpc_client_cangbao_bay_team_ask")
end

------------------------------------------ ended -------------------------------------------------------------------------

return clsBayData
