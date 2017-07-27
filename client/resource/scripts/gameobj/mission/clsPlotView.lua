local ClsBaseView = require("ui/view/clsBaseView")
local ClsPlotView = class("ClsPlotView", ClsBaseView)
local missionPlot = require("gameobj/mission/missionPlot")

function ClsPlotView:onEnter()
	self:setIsWidgetTouchFirst(true)
end

------------------------------剧情播放------------------------------
function ClsPlotView:showDialog(noSkip, dialog_voice_handler, bg_voice_handle)
	self:regTouchEvent(self, function(eventType, x, y)
		if eventType =="began" then 
			missionPlot:showDialogLayer() 
			return true 
		end
	end)

	if not noSkip or noSkip ~= 1 then
		self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_skip.json")
		self.panel:setVisible(false)
		convertUIType(self.panel)
		self:addWidget(self.panel)
		local skip_bg = getConvertChildByName(self.panel, "skip_bg")
		skip_bg:setPosition(ccp(474, 127))
		skip_bg:addEventListener(function()
			missionPlot:hidePlot()
			if dialog_voice_handler then
				audioExt.stopEffect(dialog_voice_handler)
			end
			if bg_voice_handle then
				audioExt.stopEffect(bg_voice_handle)
			end
			audioExt.resumeMusic()
		end, TOUCH_EVENT_ENDED)
	end
end

function ClsPlotView:onFinish()
	missionPlot:plotEndCallBack()
end

function ClsPlotView:hideDialog()
	self:close("ClsPlotView")
	missionPlot:hideDialogLayer()
	audioExt.resumeMusic()
end

return ClsPlotView