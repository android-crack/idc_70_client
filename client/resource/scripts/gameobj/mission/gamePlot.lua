----  游戏剧情
require("gameobj/mission/missionInfo")

local missionBox   = require("gameobj/mission/missionBox")
local missionGuide = require("gameobj/mission/missionGuide")
local plotDialogue = require("gameobj/mission/missionPlotDialogue")

local missionWorkProtocol = require("gameobj/mission/missionWorkProtocol")

local GamePlot = {}
local queueTab = {}  -- 队列表

-- 剧情加入队列
-- plotTab = {id = mission_id, type = "new" or "complete", callFunc = (回调)}
function GamePlot:insertPlot(plotTab)
	self.callBack = plotTab.callFunc
	if missionWorkProtocol.callBack == nil then
		missionWorkProtocol.callBack = function()
			self:playPlot()
		end
	end
	-- if not self.is_pause and not self.is_running then
	-- 	self:playPlot()
	-- else
	-- 	self:resetPlot()
	-- 	local mission_data_handler = getGameData():getMissionData()
	-- 	mission_data_handler:askGetMissionReward(plotTab.id)
	-- end 
	if not self.is_pause and not self.is_running then
		
	else
		self:resetPlot()
	end 
	table.insert(queueTab, plotTab)
	self:playPlot()
	
end

-- 新任务
function GamePlot:newMission(id)    
	local mission_info = getMissionInfo()
	local mission_tab = mission_info[id]
	mission_tab.id = id
	if type(mission_tab) ~= "table" then
		return 
	end 
	
	local dialog_tab = mission_tab.dialog_new
	local mission_plot = mission_tab.mission_plot
	local mission_plot_new = mission_tab.mission_plot_new
	-- table.print(mission_tab)
	if type(mission_plot_new) == "table" then
		missionWorkProtocol:newSpecialPlot(mission_tab)
	elseif type(mission_plot) == "table" then
		missionWorkProtocol:newMissionPlot(mission_tab)
	else
		if type(dialog_tab) == "table" then
			missionWorkProtocol:newPlotDialog(mission_tab)
		else
			missionWorkProtocol:newPlot(mission_tab)
		end
	end
end

-- 完成任务
function GamePlot:completeMission(id)   
	local mission_info = getMissionInfo()
	local mission_tab = mission_info[id]
	if type(mission_tab) ~= "table" then
		cclog("GamePlot:missionStartPlot(id) id is error")
		return
	end
	
	mission_tab.id = id
	if mission_tab.back_layer ~= 0 then
    	local portLayer = getUIManager():get("ClsPortLayer")
    	if not tolua.isnull(portLayer) then
    		--退出当前层回到主场景中(主场景上添加的层)
    		getUIManager():removeViewOnFront("ClsGuidePortLayer")
			EventTrigger(EVENT_DELETE_ITEMS_LAYER, true)
		else
			--同步港口协议
			local explore_ui = getExploreUI()
			if not tolua.isnull(explore_ui) then
				getUIManager():removeViewOnFront("ClsExploreBackLayer")
			end
    	end
	end

	local dialog_tab = mission_tab.dialog_complete
	if type(dialog_tab) == "table" then
		missionWorkProtocol:completePlotDialog(mission_tab)
	else 
		missionWorkProtocol:completePlot(mission_tab)
	end
end

local PLOT_FUNC_DICT = {
	["new"] = GamePlot.newMission,
	["complete"] = GamePlot.completeMission,
}

----------外部禁止调用(想暂停任务时)
function GamePlot:pausePlot()    -- 暂停
	self.is_pause = true 
end 

----------外部禁止调用(想启动任务时)
function GamePlot:resumePlot()   -- 启动
	self.is_pause = false
	self:playPlot()
end 

function GamePlot:setPausePlot(pause)
	self.is_pause = pause
end

-- 播放剧情入口
function GamePlot:playPlot()   
	if self.is_pause or #queueTab < 1 then
		self:endPlot()
		return 
	end
	self.is_running = true
	EventTrigger(EVENT_MISSION_PLOT_START)
	local plotTab = queueTab[1]
	table.remove(queueTab, 1)    -- 队列
	
	if plotTab.type == "new" then
		PLOT_FUNC_DICT["new"](self, plotTab.id)
	elseif plotTab.type == "complete" then
		PLOT_FUNC_DICT["complete"](self, plotTab.id)
	end
end

function GamePlot:resetPlot()
	queueTab = {}
	self.is_pause = false 
	self.is_running = false
end

function GamePlot:isRunning()
	return self.is_running
end

-- 剧情结束
function GamePlot:endPlot()
	self:resetPlot()
	--任务结束后回调
	if type(self.callBack) == "function" then
		self.callBack()
	end
end

return GamePlot 