-- @date: 2016年10月18日20:26:12
-- @author: mid
-- @desc: 世界随机任务协议

local alert = require("ui/tools/alert")
local cfg = require("game_config/world_mission/world_mission_info")
local twm_conf = require("game_config/world_mission/world_mission_team")
local ui_word = require("game_config/ui_word")
local dialog_quene = require("gameobj/quene/clsDialogQuene")

--[[
server code

class world_mission_t {
	int id;
	int startTime;
	int remainTime;
	int pos;
	string data;
	int status;
	mission_progress_t* progress;
}

void rpc_server_world_mission_list(object oUser);
void rpc_client_world_mission_list(int uid ,world_mission_t* list);
void rpc_server_world_mission_accept(object oUser int id);
void rpc_client_world_mission_accept(int uid,world_mission_t info);
void rpc_server_world_mission_cancel(object oUser, int id);
void rpc_client_world_mission_cancel(int uid, int ;
void rpc_server_world_mission_complete(object oUser, int id);
void rpc_client_world_mission_complete(int uid, int id);
void rpc_server_world_mission_fight(object oUser, int id);
void rpc_client_world_mission_fight(int uid, int id);
void rpc_client_world_mission_fight_reward(int uid, random_reward_t* rewards);
]]

-- 下发任务列表(需要主动请求 服务端当有数据变动时候主动下发的)
function rpc_client_world_mission_list(list)
	-- 缓存数据
	local data = getGameData():getWorldMissionData()
	data:setWorldMissionList(list)
	data:whenChangeData()
end

-- 客户端请求接受任务后 如果接受成功 则返回接受的那条任务信息 item
function rpc_client_world_mission_accept(item)
	-- 飘字提示
	alert:warning({msg = ui_word.WORLDMISSION_DEAL_TIPS_ACCEPT})

	local data = getGameData():getWorldMissionData()

	-- 更新缓存数据
	data:setItemAcceptedWorldMission(item)
	-- 战斗类型特殊处理
	local callback = nil
	local mission_conf = cfg[item.id] or twm_conf[item.id]
	if mission_conf.type == data:getType().battle then
		-- 不移除npc
		data:setIsRemoveNpc(false)
		-- 对话结束后直接请求进入战斗
		callback = function()
			data:askFigt(item.id)
		end
	else
		data:setIsRemoveNpc(true)
	end
	-- 播放对话框
	data:showPlot(mission_conf.mission_accept_dialog,callback)
	data:whenChangeData()
end

-- 下发一条要更新的item
function rpc_client_world_mission_update(item)
	local data = getGameData():getWorldMissionData()
	data:updateWorldMissionList(item)
	data:whenChangeData()
end

-- 删除任务 下发要删除的id列表 (完成时候发)
-- [S->C][rpc_client_world_mission_del{ ['1']={ ['1']=23,} ,} ]
function rpc_client_world_mission_del(ids)
	local data = getGameData():getWorldMissionData()
	data:delItemOfWorldMissionList(ids)
	data:whenChangeData()
end

--[[
[C->S][rpc_server_world_mission_cancel]{ ['1']=23,}
[S->C][rpc_client_world_mission_cancel{ ['1']=23,} ]
]]

-- 取消任务 当前客户端请求放弃当前任务的时候 下发的协议 返回的参数是 取消的id
function rpc_client_world_mission_cancel(id)
	-- 飘字提示
	local data = getGameData():getWorldMissionData()
	data:cancelById(id)
	data:whenChangeData()
	alert:warning({msg = ui_word.WORLDMISSION_DEAL_TIPS_GIVEUP})
end

--放弃组队世界任务
function rpc_client_team_world_mission_cancel(id)
	local data = getGameData():getWorldMissionData()
	data:cancelById(id)
	data:whenChangeData()
	alert:warning({msg = ui_word.WORLDMISSION_DEAL_TIPS_GIVEUP})
end

-- 请求进入战斗结果
function rpc_client_world_mission_fight(id)
	-- 飘字提示
	local is_show = true
	-- 队员状态不能进入战斗并且屏蔽消息
	local teamData = getGameData():getTeamData()
	if teamData:isTeamLeader() == false and teamData:isInTeam() == true then
		is_show = false
	end
	if is_show then
		alert:warning({msg = ui_word.WORLDMISSION_DEAL_TIPS_FIGHT})
	end
end

-- 世界任务奖励信息 如果是在战斗场景中,则延迟播放.
function rpc_client_world_mission_fight_reward(rewards)
	local data = getGameData():getWorldMissionData()
	data:setfightRewardCache(rewards)
end

--组队世界任务接受弹框
function rpc_client_team_world_mission_create(world_mission_info)
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	local ClsPanelPopView = require("gameobj/quene/clsPanelPopView")
	ClsDialogSequence:insertTaskToQuene(ClsPanelPopView.new("team_world_mission", {data = world_mission_info}))
end

--组队世界任务战斗奖励
function rpc_client_team_world_mission_fight_reward(rewards)
	if getGameData():getTeamData():isTeamLeader() then
		local data = getGameData():getWorldMissionData()
		data:setfightRewardCache(rewards)
	else
		local data = {reward = rewards}
		dialog_quene:insertTaskToQuene(require("gameobj/quene/clsAutoTradeRewardPopViewQuene").new(data))
	end
end

function rpc_client_team_world_mission_del(ids_tbl)
	local data = getGameData():getWorldMissionData()
	data:delItemOfWorldMissionList(ids_tbl)
	data:whenChangeData()
end

function rpc_client_team_world_mission_update(world_mission_info)
	local data = getGameData():getWorldMissionData()
	data:updateWorldMissionList(world_mission_info)
	data:whenChangeData()
end

function rpc_client_team_world_mission_accept(item)
	-- 飘字提示
	alert:warning({msg = ui_word.WORLDMISSION_DEAL_TIPS_ACCEPT})
	local data = getGameData():getWorldMissionData()
	data:setItemAcceptedWorldMission(item)
	local callback = nil
	local mission_conf = cfg[item.id] or twm_conf[item.id]
	if mission_conf.type == data:getType().teambattle then
		-- 不移除npc
		data:setIsRemoveNpc(false)
		callback = function()
			local m_info = {}
			m_info.type = EXPLORE_NAV_TYPE_WORLD_MISSION
			m_info.id = item.id
			m_info.is_has_accepted = true
			data:popTeamMissionTip(m_info)
		end
	else
		data:setIsRemoveNpc(true)
	end
	-- 播放对话框
	data:showPlot(mission_conf.mission_accept_dialog,callback)
	data:whenChangeData()
end

function rpc_client_team_world_mission(world_mission_list, schedule)
	local data = getGameData():getWorldMissionData()
	data:setTeamWorldMissionSchedule(schedule)
	data:insertTeamMission2List(world_mission_list)
	data:whenChangeData()
end