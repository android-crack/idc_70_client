-- 风云大赛
-- Author: Ltian
-- Date: 2016-07-08 10:22:53
--
local ClsFarArenaData = class("ClsFarArenaData")


function ClsFarArenaData:ctor()
	-- 用于储存风云大赛数据信息
	self.arena_info = 0
	self.team_info = {}
	self.is_join_team = false
	-- 战报列表
	self.report_list = nil
end

--判断是否加入队伍
function ClsFarArenaData:getStatus()
	return self.arena_info
end

--风云大赛活动信息  
-- arena_info
-- {
	-- 	["remainTime"] = 0.000000,
	-- 	["round"] = 4.000000,
	-- 	["status"] = 4.000000,
	-- 	["totalRemainTime"] = 0.000000,
	-- 	["totalRound"] = 6.000000,
	-- 	["win"] = 0.000000,
-- }
function ClsFarArenaData:updateStatus(arena_info)
	self.arena_info = arena_info
end

function ClsFarArenaData:getTeamInfo()
	return self.team_info
end

function ClsFarArenaData:updateTeamInfo(team_info)
	self.team_info = team_info
end

--判断是否加入队伍
function ClsFarArenaData:isJoinTeam()
	return self.is_join_team
end

function ClsFarArenaData:updateIsJoinTeam(is_join_team)
	self.is_join_team = is_join_team
end

-- 进入港口时，根据当前状态，判断是否需要
-- 自动弹出竞技场结算界面
function ClsFarArenaData:autoPopView()
	-- zhuling todo
	if self.arena_info == 0 then
		return
	end
	local round = self.arena_info.round
	local total_round = self.arena_info.totalRound
	if self.is_join_team then
		local port_layer = getUIManager():get("ClsPortLayer")
        if not tolua.isnull(port_layer) then
            local view = require("gameobj/farArena/clsFarArenaMain")
            port_layer:addItem(view.new(true), nil, true, 0)
        end
	end
end

function ClsFarArenaData:setReportData(report_list)
	self.report_list = report_list
end

function ClsFarArenaData:getReportData()
	return self.report_list
end

-- 向服务器请求战报数据
function ClsFarArenaData:reqReportData()
	GameUtil.callRpc("rpc_server_team_arena_report", {})
end

--尝试打开风云大赛界面
function ClsFarArenaData:tryOpenActivity()
	GameUtil.callRpc("rpc_server_team_arena_enter", {})
end

--加入竞技场
function ClsFarArenaData:joinFarArena()
	GameUtil.callRpc("rpc_server_team_arena_join", {})
end

--请求竞技场数据
function ClsFarArenaData:askFarArenaInfo()
	GameUtil.callRpc("rpc_server_team_arena_status", {})
end


return ClsFarArenaData