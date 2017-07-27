local ClsGainBackData = class("ClsGainBackData")

ClsGainBackData.ctor = function(self)
	self.gain_list = {}
end

ClsGainBackData.getGainList = function(self)
	return self.gain_list
end

ClsGainBackData.setGainList = function(self, tbl)
	self.gain_list = {}
	for _, info in ipairs(tbl) do
		local wanfa_id = info["wanfa"]
		for _, wanfa_info in pairs(info.list) do
			wanfa_info.aid = wanfa_id
			local _type = wanfa_info.type
			if not self.gain_list[_type] then
				self.gain_list[_type] = {}
			end
			local sortReward
			sortReward = function(v1, v2)
				return v1.id > v2.id
			end
			table.fsort(wanfa_info.list, sortReward)
			self.gain_list[_type][#self.gain_list[_type] + 1] = wanfa_info
		end
	end
	--未找回的收益项优化为显示在前面
	local _priority = {
		[LOSE_FOUND_STATUS_UNOPEN] = 0,
		[LOSE_FOUND_STATUS_ENABLE] = 1,
		[LOSE_FOUND_STATUS_FOUND] = 0,
	}
	for _, list in pairs(self.gain_list) do
		table.fsort(list, function(a1, a2)
			return _priority[a1.status] < _priority[a2.status]
		end)
	end
end

ClsGainBackData.isAllFoundBack = function(self, cost_type)
	if not cost_type then return end
	local LOSE_FOUND_STATUS_ENABLE = 2
	for _, info in pairs(self.gain_list[cost_type] or {}) do
		if info.status == LOSE_FOUND_STATUS_ENABLE then
			return false
		end
	end
	return true
end

ClsGainBackData.getAllCostByType = function(self, type)
	if not self.gain_list[type] then return end
	local total_cost = 0
	for _, info in ipairs(self.gain_list[type]) do
		if info.cost then
			total_cost = total_cost + info.cost
		end
	end
	return total_cost
end

--请求所有可找回的奖励
ClsGainBackData.askGainList = function(self)
	GameUtil.callRpc("rpc_server_lose_found_list", {})
end

--一键找回
ClsGainBackData.askGainPrefetGet = function(self, found_type)
	GameUtil.callRpc("rpc_server_lose_found_take_onekey", {found_type})
end

--单个找回
ClsGainBackData.askFindGainAlone = function(self, wanfa_id, found_type)
	GameUtil.callRpc("rpc_server_lose_found_take", {wanfa_id, found_type})
end

return ClsGainBackData