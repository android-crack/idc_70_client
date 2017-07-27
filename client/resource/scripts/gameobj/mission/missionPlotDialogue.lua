---------任务剧情------------
local missionGuide = require("gameobj/mission/missionGuide")

local PlotConfig = {
	treasureMap = "treasure_map",
}

local PlotDialogue = {}

--展示剧情(任务info，剧情info)
function PlotDialogue:showPlotDialog(mission_tab, dialog_tab)	
	self.callFunc = dialog_tab.call_back
	self.completeLayer = mission_tab.complete_condition
	
	if self.completeLayer ~= nil and type(self.completeLayer) == "string" and string.len(self.completeLayer) > 0 then
		dialog_tab.call_back = function()			
			missionGuide:openGuideByMission(mission_tab)
		end
	end
	
	self.dialog_layer = getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)
end

---手动调用完成此任务
function PlotDialogue:completeMission(plotName)
	if plotName == self.completeLayer then
		self:CallBack()
	end
end

function PlotDialogue:CallBack()
	if type(self.callFunc) == "function" then
		self.callFunc()
	end
end

function PlotDialogue:getPlotConfig()
	return PlotConfig
end

function PlotDialogue:hidePlotDialog()
	if tolua.isnull(self.dialog_layer) then return end
	self.dialog_layer:hideDialog()
end

return PlotDialogue