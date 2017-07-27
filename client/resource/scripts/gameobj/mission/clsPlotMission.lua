local ClsBaseView = require("ui/view/clsBaseView")
local ClsPlotMission = class("ClsPlotMission", ClsBaseView)
local missionPlot = require("gameobj/mission/missionPlot")

function ClsPlotMission:getViewConfig()
    return {
        name = "ClsPlotMission",
    }
end

function ClsPlotMission:onEnter(info, noSkip)
	self.noSkip = noSkip
	self.data = info 
	self.res_path = self.data[1][1]
	self.voice = self.data[1][2]
	self:mkUI()
end

function ClsPlotMission:mkUI()
	self.bg = display.newSprite(self.res_path, display.cx, display.cy) 
	self.layer = CCLayerColor:create(ccc4(0, 0, 0, 127))
	self.bg:setOpacity(0)
	self.bg:runAction(CCFadeIn:create(3)) 
	self.layer:runAction(CCFadeOut:create(3))
	self:addChild(self.bg, -1)
	self:addChild(self.layer, -1)

	if not self.noSkip then
		local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_skip.json")
		convertUIType(panel)
		self:addWidget(panel)
		panel:setZOrder(10)
		local skip_bg = getConvertChildByName(panel, "skip_bg")
		skip_bg:setPosition(ccp(800, 600))
		skip_bg:addEventListener(function( )
			self:hideView()
		end, TOUCH_EVENT_ENDED)
	end
	self:performWithDelay(1.5, function()
		self:showDialog()
	end)
end

function ClsPlotMission:performWithDelay(time, func)
	local array = CCArray:create()
    array:addObject(CCDelayTime:create(time))
    array:addObject(CCCallFunc:create(function()
        if type(func) == "function" then
        	func()
        end
    end))
    local action = CCSequence:create(array)
    self:runAction(action)
end

function ClsPlotMission:showDialog()
	local time_d = 4
	local array = CCArray:create()
	for i = 2, #self.data do
		local str_text = self.data[i][1]
		local str_time = self.data[i][2]
		local time = str_time -1
		array:addObject(CCCallFunc:create(function()
			local label = createBMFont({fontFile = FONT_CFG_1, text = str_text, color = ccc3(dexToColor3B(COLOR_LOGIN_GLOW)), size = 22, anchor = ccp(0.5,0.5), x = display.cx + 200, y = display.cy -100, parent = self })
			label:runAction(CCSpawn:createWithTwoActions(CCFadeIn:create(time), CCMoveBy:create(time, ccp(0, time *40))))
			local arr = CCArray:create()
			if self.voice ~= "" then
				local music_info = require("game_config/music_info")
				sound = music_info[self.voice].res
  				audioExt.playEffect(sound, false, true)
			end
			arr:addObject(CCDelayTime:create(time))
			arr:addObject(CCCallFunc:create(function()
				label:runAction(CCSpawn:createWithTwoActions(CCFadeOut:create(1.5), CCMoveBy:create(1.5, ccp(0, 60))))
			end))
			arr:addObject(CCDelayTime:create(1.5))
			arr:addObject(CCCallFunc:create(function()
				label:removeFromParentAndCleanup(true)
			end))
			label:runAction(CCSequence:create(arr))
		end))
		array:addObject(CCDelayTime:create(2))
		time_d = time_d + 2
	end
	self:performWithDelay(time_d, function()
		self:hideView()
	end)
	self:runAction(CCSequence:create(array))
end

function ClsPlotMission:hideView()
	self:close()
	missionPlot:hidePlot()
end

return ClsPlotMission