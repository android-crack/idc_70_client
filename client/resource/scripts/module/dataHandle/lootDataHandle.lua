require("module/gameBases")
local ui_word = require("game_config/ui_word")
local port_info = require("game_config/port/port_info")
local Alert = require("ui/tools/alert")
local ClsLootHandler = class("ClsLootHandler")

function ClsLootHandler:ctor()
	self.loot_report_list = {}
	self.tracing_info = nil
	self.change_objs = {}
end

--设置掠夺战报信息
function ClsLootHandler:setReportList(list)
	if list then
		self.loot_report_list = list
		self:askReportPlayerInfos()
	end
end

function ClsLootHandler:askReportPlayerInfos()
	local ids = {}
	for k, v in ipairs(self.loot_report_list) do
		if not ids[v.target_id] then
			ids[v.target_id] = true
		end
	end
	for k, v in pairs(ids) do
		self:askReportPlayerInfo(k)
	end
end

function ClsLootHandler:getReportUI()
	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end
	local report_ui = main_ui:getPanelByName("ClsReportManagerUI")
	if tolua.isnull(report_ui) then return end
	return report_ui
end

function ClsLootHandler:getPlunderedUi()
	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end
	local report_ui = main_ui:getPanelByName("ClsReportManagerUI")
	if tolua.isnull(report_ui) then return end
	local goal_obj = report_ui:getPanelByName("ClsPlunderedReportUI")
	if tolua.isnull(goal_obj) then return end
	return goal_obj
end

--更新玩家信息，没有就添加，有就更新
function ClsLootHandler:updatePlayerInfo(info, show_warning)
	for k, v in ipairs(self.loot_report_list) do
		if v.target_id == info.target_id then
			for i, j in pairs(info) do
				v[i] = j
				if i == "is_arrest" then
					v[i] = (j ~= 0)
				end
			end
			local report_ui = self:getReportUI()
			if not tolua.isnull(report_ui) then
				report_ui:updateListCell(v)
			end
			if show_warning then
				if self:isTracingById(v.id) then
					local show_txt = ui_word.LOOT_TRACE_ON_LINE
					if info.lastLoginTime ~= ONLINE then
						show_txt = ui_word.LOOT_TRACE_OFF_LINE
					end
					Alert:warning({msg = string.format(ui_word.LOOT_TRACE_LINE_DEC, show_txt)})
				end
			end
		end
	end
end

--更新战报基本信息
function ClsLootHandler:updateReport(report)
	for k, v in ipairs(self.loot_report_list) do
		if report.id == v.id then
			for i, j in pairs(report) do
				v[i] = j
			end
			local report_ui = self:getReportUI()
			if not tolua.isnull(report_ui) then
				report_ui:updateListCell(v)
			end
			break
		end
	end
end

--获得掠夺战报
function ClsLootHandler:getPlunderReport()
	local temp = {}
	for k, v in ipairs(self.loot_report_list) do
		if v.is_sponsor ~= 0 then
			table.insert(temp, v)
		end
	end

	table.sort(temp, function(a, b) 
		return a.id > b.id
	end)

	return temp
end

--获得被掠夺战报
function ClsLootHandler:getPlunderedReport()
	local temp = {}
	for k, v in ipairs(self.loot_report_list) do
		if v.is_sponsor == 0 then
			table.insert(temp, v)
		end
	end

	table.sort(temp, function(a, b) 
		return a.id > b.id
	end)

	return temp 
end

--设置单个正在追踪的人的信息
function ClsLootHandler:setTracingInfo(info)
	if not info then
		self.tracing_info = nil
		return 
	end
	local ui = self:getPlunderedUi()
	if not tolua.isnull(ui) then
		ui:setUpdateObjs(info) 
	end

	for k, v in ipairs(self.loot_report_list) do
		if v.id == info.id then
			info.target_id = v.target_id
			break
		end
	end

	self.tracing_info = info

	if not tolua.isnull(ui) then
		ui:updateChangeObjs(self.change_objs)
	end

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:updateTracePoint(info)
	end
end

function ClsLootHandler:setTraceStatusObjs(objs)
	self.change_objs = objs
end

function ClsLootHandler:getReportInfo(id)
	for k, v in ipairs(self.loot_report_list) do
		if v.id == id then
			return v
		end
	end
end

--是否有正在追踪的战报
function ClsLootHandler:isHaveTracing()
	if self.tracing_info and self.tracing_info.id > 0 then
		return true
	else
		return false
	end
end

--这个战报能否被追踪
function ClsLootHandler:isCanTrace(id)
	for k, v in ipairs(self.loot_report_list) do
		if v.id == id then
			if type(v.trace_time) == "number" then
				if v.trace_time > 0 then
					return false
				end
			end
			break
		end
	end
	return true
end

--这个战报是否正在追踪
function ClsLootHandler:isTracingById(id)
	if not self.tracing_info then
		return false
	else
		return self.tracing_info.id == id
	end
end

--获得正在追踪的玩家信息
function ClsLootHandler:getTracingInfo()
	return self.tracing_info
end

function ClsLootHandler:getTracingTime()
	return self.tracing_info.trace_time
end

local min_distance = 960
function ClsLootHandler:updateTraceEvent(ship_layer, ship_pos)
	if not self.tracing_info then return end
	local pos = nil
	local goal_pos = nil
	if self.tracing_info.port_id and self.tracing_info.port_id > 0 then
		local port_data = getGameData():getPortData()
		local port_base = port_info[self.tracing_info.port_id]
		pos = ccp(port_base.port_pos[1], port_base.port_pos[2])
		local x, y = ship_layer:tileToCocos(pos.x, pos.y)
		goal_pos = ccp(x, y)
	else
		--在探索直接使用船位置信息
		local ship = ship_layer:getShipByUid(self.tracing_info.target_id)
		if not ship then
			return
		else
			local x, y = ship:getPos()
			goal_pos = ccp(x, y)
		end
	end

	local dis = Math.distance(ship_pos.x, ship_pos.y, goal_pos.x, goal_pos.y)
	dis = math.abs(dis)
	if dis <= min_distance then
		local explore_layer = getExploreLayer()
		if tolua.isnull(explore_layer) then return end
		local ship_layer_base = explore_layer:getShipsLayer()
		if not tolua.isnull(ship_layer_base) then
			local scene_handler = getGameData():getSceneDataHandler()
			local bubble_parameter = {
				direction = DIRECTION_RIGHT,
				sender = scene_handler:getMyUid(),
				show_msg = ui_word.FIND_TRACE_GOAL,
			}
		    ship_layer_base:showShipChatBubble(bubble_parameter)
		end
	end
end

function ClsLootHandler:setRedNameInfo(info)
	self.red_name_info = info
end

function ClsLootHandler:getRedNameInfo()
	return self.red_name_info
end

--回应切换成红名的请求
function ClsLootHandler:askChangeNameStatus(is_agree)
	GameUtil.callRpc("rpc_server_plunder_switch_status_confirm", {is_agree})
end

--请求红名信息
function ClsLootHandler:askRedNameInfo()
	GameUtil.callRpc("rpc_server_plunder_name_status")
end

--转换模式
function ClsLootHandler:askSwitchTradeMode()
	GameUtil.callRpc("rpc_server_plunder_switch_name_status")
end

--贿赂
function ClsLootHandler:askBribeOfficer()
	GameUtil.callRpc("rpc_server_plunder_bribe")
end

function ClsLootHandler:askArrest()
	GameUtil.callRpc("rpc_server_plunder_be_arrest")
end

--请求战报列表
function ClsLootHandler:askReportList()
	GameUtil.callRpc("rpc_server_plunder_report_list", {})
end

--请求追踪的玩家信息id指战报id
function ClsLootHandler:askStartTracePlayer(id)
	GameUtil.callRpc("rpc_server_plunder_report_trace", {id})
end

--请求战报玩家信息
function ClsLootHandler:askReportPlayerInfo(id)
	GameUtil.callRpc("rpc_server_plunder_report_target_info", {id})
end

--请求正在追踪的人的信息
function ClsLootHandler:askTraceingPlayerInfo()
	GameUtil.callRpc("rpc_server_plunder_tracing_info", {})
end

--商会求助
function ClsLootHandler:askGuildHelp(report_id, name)
	GameUtil.callRpc("rpc_server_plunder_report_group_help", {report_id, name})
end

return ClsLootHandler 