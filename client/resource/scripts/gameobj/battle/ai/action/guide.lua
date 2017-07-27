
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionGuide = class("ClsAIActionGuide", ClsAIActionBase) 

function ClsAIActionGuide:getId()
	return "guide"
end

-- 
function ClsAIActionGuide:initAction( radius, x, y, rotation, autoRelease )
	local guide_item = {}
	guide_item.radius = radius or 50
	guide_item.pos = {x = x, y = y}
	guide_item.rotation = rotation or 0
	guide_item.autoRelease = autoRelease or true
	guide_item.guideType = 1

	self.guide_item = guide_item

	self.duration = 99999999
end

function ClsAIActionGuide:__beginAction( target )
	local battleData = getGameData():getBattleDataMt()
	local guide_item = self.guide_item

	local battleRecording = require("gameobj/battle/battleRecording")
	battleRecording:recordVarArgs("battle_play_plot")

	local battleLayer = battleData:GetTable("battle_layer")
	battleLayer.setBattlePaused(true)

	guide_item.baseView = "FightUI"
	local guide_layer = createMissionGuideLayer( guide_item )
	local battleUI = battleData:GetLayer("battle_ui")
	battleUI:addChild( guide_layer, 1000)
	battleUI:setTouch(true)

	guide_layer:setCallFunc(function()
		battleRecording:recordVarArgs("battle_play_plot_end")
		battleLayer.setBattlePaused(false)
		self.duration = 0
	end)	
end

function ClsAIActionGuide:__dealAction( target, delta_time )
	return true
end

return ClsAIActionGuide
