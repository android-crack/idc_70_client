---公会任务数据

local tool=require("module/dataHandle/dataTools")
local news=require("game_config/news")
local Alert = require("ui/tools/alert")
local element_mgr = require("base/element_mgr")

local GuildTaskData = class("GuildTaskData")
function GuildTaskData:ctor()
	self.taskList = {}

	self.cur_mission_key = nil --当前要跳转到任务详情的missionKey(点击聊天中别人发起的任务用到)
    self.cur_mission_data = nil--同上
end

--请求任务列表
function GuildTaskData:askMissionList(clearRedPoint)
	GameUtil.callRpc("rpc_server_group_mission_list", {clearRedPoint or 1}, "rpc_client_group_mission_list")
end

--请求多人任务详细信息
function GuildTaskData:askGroupMissionDetails(missionKey)
	GameUtil.callRpc("rpc_server_group_mission_detail", {missionKey})
end

--多人任务，自己参与请求
function GuildTaskData:askGroupMissionJoin(missionKey, sailors)
	GameUtil.callRpc("rpc_server_group_mission_join", {missionKey, sailors}, "rpc_client_group_mission_join")
end

--多人任务，退出请求
function GuildTaskData:askGroupMissionQuit(missionKey)
	GameUtil.callRpc("rpc_server_group_mission_cancel", {missionKey}, "rpc_client_group_mission_cancel")
end

--多人任务，领奖
function GuildTaskData:askguildMissionReward(missionKey)
	GameUtil.callRpc("rpc_server_group_mission_get_reward", {missionKey}, "rpc_client_group_mission_get_reward")
end

function GuildTaskData:askRefreshMsg(missionKey)
	GameUtil.callRpc("rpc_server_group_mission_update_message", {missionKey}, "rpc_client_group_mission_update_message")
end

--多人任务直接打开详情的任务
function GuildTaskData:receiveCurOpenMission(data)
	self.cur_mission_key = data.missionKey
    self.cur_mission_data = data
	self:receiveGuildTask(data)
end

function GuildTaskData:clearCurOpenMissionKey()
	self.cur_mission_key = nil
    self.cur_mission_data = nil
end

function GuildTaskData:getCurOpenMissonKey()
	return self.cur_mission_key
end

function GuildTaskData:getCurOpenMisson()
    return self.cur_mission_data
end

function GuildTaskData:alertSpeedUpView(remainTime, callBack) --任务
	local ui_word = require("game_config/ui_word")
    local ShopRule = require("module/dataHandle/shopRule")

    local gold = ShopRule:getQuickCompleteGold(remainTime)
    local texts = string.format(ui_word.GUILD_TASK_QUICK_COMPLETE, gold)

    local alertLayer = Alert:showAttention(texts, function()
        local playerData = getGameData():getPlayerData()
        if gold > playerData:getGold()  then
        	local task_ui = element_mgr:get_element("ClsGuildTaskPerDetails")
            Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, task_ui)
        else
            callBack()
        end
    end)
    return alertLayer
end

--水手
function GuildTaskData:alertGiveUpView(giveUpFunction)
	local ui_word = require("game_config/ui_word")	
	local alertLayer = Alert:showAttention(ui_word.CAMP_GIVE_UP_TASK, function()
        giveUpFunction()
    end, nil, nil, {ok_text = ui_word.CAMP_GIVE_UP, use_orange_btn = true})
    return alertLayer
end


--退出多人
function GuildTaskData:cancelGroupTask()
	local ui = getUIManager():get("ClsGuildTaskMulDetails")
	if not tolua.isnull(ui) then
		ui:closeView(false)
	end
end


--个人/多人任务领奖
function GuildTaskData:receiveReward(data)
	local ui = getUIManager():get("ClsGuildTaskMain")
	if not tolua.isnull(ui) then
		ui:showReward(data)
	end
end


--多人任务详细信息
function GuildTaskData:receiveMultiTaskDetail(detail)

	local ui = getUIManager():get("ClsGuildTaskMulDetails")
	if not tolua.isnull(ui) then
		ui:updateView(detail)
	end
end

--单个任务
function GuildTaskData:receiveGuildTask(mission)
	self.taskList[mission.missionKey] = mission

	local mulUi = getUIManager():get("ClsGuildTaskMulDetails")
	if not tolua.isnull(mulUi) then
		mulUi:closeView(mission.missionKey)
	end


	-- local ui = element_mgr:get_element("ClsGuildTaskMain")
	-- if not tolua.isnull(ui) then ui:updateCellView(mission) end
end

--所有任务
function GuildTaskData:receiveGuildTasks(datas)
	if not datas then return end

	self.taskList = datas

	local ui = getUIManager():get("ClsGuildTaskMain")
	if not tolua.isnull(ui) then
		ui:updateView()
	end

	-- local ui2 = getUIManager():get("ClsGuildTaskMulDetails")
	-- if not tolua.isnull(ui2) then
 --        if not ui2:tryToCloseView(datas) then
 --            --ui:setTouch(false)
 --        end
	-- end
end


function GuildTaskData:getGuildTaskList()
	if not self.taskList then return nil end

	table.sort(self.taskList, function(a, b)
		if a.missionFlag ~= b.missionFlag then
			return a.missionFlag > b.missionFlag
		end

		if a.status ~= b.status then
			return a.status > b.status
		end
	end)

	return self.taskList
end

function GuildTaskData:getTaskByKey(missionKey)
	for k, v in pairs(self.taskList) do
		if missionKey == v.missionKey then
			return v
		end
	end
end

function GuildTaskData:clearTaskList()
	self.taskList = {}
end

return GuildTaskData