local ClsTradeCompleteDataHandler = class("ClsTradeCompleteDataHandler")

function ClsTradeCompleteDataHandler:ctor()
	self:initData()
end

function ClsTradeCompleteDataHandler:initData()
	self.trade_complete_info = nil
	self.is_open = nil
	self.cd = 0
	self.report_list = nil
end

function ClsTradeCompleteDataHandler:setTradeCompleteInfo(info)
	self.trade_complete_info = info
	self:setReportList(info.reports)
end

function ClsTradeCompleteDataHandler:cleanData()
	self:initData()
end

function ClsTradeCompleteDataHandler:getTradeCompleteInfo()
	return self.trade_complete_info
end

function ClsTradeCompleteDataHandler:isHaveTask()
	if not self.trade_complete_info then return end
	return (self.trade_complete_info.status == TASK_ACCEPTED_STATUS)
end

function ClsTradeCompleteDataHandler:getTaskStatus()
	if not self.trade_complete_info then return end
	return self.trade_complete_info.status
end

function ClsTradeCompleteDataHandler:getTaskLimit()
	if not self.trade_complete_info then return end
	return self.trade_complete_info.limit
end

function ClsTradeCompleteDataHandler:setIsOpen(kind)
	self.is_open = (kind == TRADE_COMPLETE_STATUS_OPEN) or false
end

function ClsTradeCompleteDataHandler:getIsOpen()
	return self.is_open
end

function ClsTradeCompleteDataHandler:setCd(cd)
	self.cd = cd
end

function ClsTradeCompleteDataHandler:getCd()
	return self.cd or 0
end

function ClsTradeCompleteDataHandler:setReportList(list)
	self.report_list = list
end

function ClsTradeCompleteDataHandler:getReportList()
	return self.report_list
end

function ClsTradeCompleteDataHandler:askTimePlunderOpenInfo()
	GameUtil.callRpc("rpc_server_time_plunder_open", {}) 
end

function ClsTradeCompleteDataHandler:askApply()
	GameUtil.callRpc("rpc_server_plunder_time_apply", {}) 
end

function ClsTradeCompleteDataHandler:askTaskInfo()
	GameUtil.callRpc("rpc_server_plunder_time_info", {}) 
end

function ClsTradeCompleteDataHandler:askEnterPort(port_id)
	GameUtil.callRpc("rpc_server_plunder_enter_port", {port_id}) 
end

return ClsTradeCompleteDataHandler
