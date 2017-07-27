----  任务工作代理
local missionBox   = require("gameobj/mission/missionBox")
local plotDialogue = require("gameobj/mission/missionPlotDialogue")
local MissionWorkProtocol = {}

MissionWorkProtocol.callBack = nil

--判断是否显示'任务接收和完成框'
function MissionWorkProtocol:isWipeBox(wipe)
	if wipe == 1 then
		---不显示任务框
		return true
	end
	return false
end

-- 接受任务窗口
function MissionWorkProtocol:newMissionBox(mission_tab)  
	mission_tab.call_back = function()
		if self.callBack ~= nil then
			self.callBack()
		end
	end 
	-- local task_panel = ClsMissionUI.new(mission_tab , TASK_STATUS.get)
	-- local scene = GameUtil.getRunningScene()
	-- scene:addChild(task_panel , ZORDER_MISSION)
	-- missionBox:newMisssion(mission_tab)
	getUIManager():create("gameobj/mission/clsMissionUI", nil, mission_tab , TASK_STATUS.get)
end

-- 完成任务窗口
function MissionWorkProtocol:completeMissionBox(mission_tab)  
	mission_tab.call_back = function()
		if self.callBack ~= nil then
			self.callBack()
		end
	end 
	-- missionBox:completeMission(mission_tab)
	getUIManager():create("gameobj/mission/clsMissionUI", nil, mission_tab , TASK_STATUS.complete)
end

function MissionWorkProtocol:newMissionPlot(mission_tab)
	local missionPlot = require("gameobj/mission/missionPlot") 
	missionPlot.end_call_back = function()
		self:newMissionEvent(mission_tab)
	end
	missionPlot:playPlot(mission_tab.mission_plot, mission_tab.mission_plot_no_skip)
end

function MissionWorkProtocol:newSpecialPlot(mission_tab)
	local missionPlot = require("gameobj/mission/missionPlot")
	missionPlot.end_call_back = function()
		self:newMissionEvent(mission_tab)
	end
	missionPlot:playSpecialPlot(mission_tab.mission_plot_new, mission_tab.mission_plot_no_skip)
end

function MissionWorkProtocol:completeMissionPlot(mission_tab)
end

function MissionWorkProtocol:skipMissionPlot()
	local missionPlot = require("gameobj/mission/missionPlot") 
	missionPlot:hidePlot()
end

function MissionWorkProtocol:newPlotDialog(mission_tab)
	if mission_tab.accept_box and mission_tab.accept_box > 0 then
		mission_tab.dialog_new.call_back = function() 
			self:newMissionBox(mission_tab)
			self:newMissionEvent(mission_tab) 
		end
	else
		mission_tab.dialog_new.call_back = function() 
			self:newMissionEvent(mission_tab) 
		end
	end
	plotDialogue:showPlotDialog(mission_tab, mission_tab.dialog_new)
end

function MissionWorkProtocol:completePlotDialog(mission_tab)  
	if self:isWipeBox(mission_tab.wipe_box) then
		mission_tab.dialog_complete.call_back = function()
			self:completeMissionEvent(mission_tab)
		end 
	else
		mission_tab.dialog_complete.call_back = function() 
			self:completeMissionBox(mission_tab)
		end 
	end

	plotDialogue:showPlotDialog(mission_tab, mission_tab.dialog_complete)
end

function MissionWorkProtocol:newPlot(mission_tab)
	if mission_tab.accept_box and mission_tab.accept_box > 0 then
		self:newMissionBox(mission_tab)
		self:newMissionEvent(mission_tab) 
	else
		self:newMissionEvent(mission_tab) 
	end
end

function MissionWorkProtocol:completePlot(mission_tab)
	if self:isWipeBox(mission_tab.wipe_box) then
		self:completeMissionEvent(mission_tab)
	else
		self:completeMissionBox(mission_tab)
	end
end

function MissionWorkProtocol:newMissionEvent(mission_tab)  
	mission_tab.call_back = function()
		if self.callBack ~= nil then
			self.callBack()
		end
	end 
	missionBox:newMissionEvent(mission_tab)
end

function MissionWorkProtocol:completeMissionEvent(mission_tab)  
	mission_tab.call_back = function()
		if self.callBack ~= nil then
			self.callBack()
		end
	end 
	missionBox:completeMissionEvent(mission_tab)
end

return MissionWorkProtocol