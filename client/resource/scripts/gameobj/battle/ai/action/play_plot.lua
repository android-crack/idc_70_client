local battlePlot = require("gameobj/battle/battlePlot")
local dataTools = require("module/dataHandle/dataTools")
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionPlayPlot = class("ClsAIActionPlayPlot", ClsAIActionBase) 

function ClsAIActionPlayPlot:getId()
	return "play_plot"
end

function ClsAIActionPlayPlot:initAction( plots )
	self.plots = plots;	
	self.duration = 999999999
end

function ClsAIActionPlayPlot:__dealAction( target_id, delta_time )
	local ai_obj = self:getOwnerAI()

	if not self.plots then  return false end
	
	-- 播放完毕，直接返回
	if self.play_end_flg then return false end 

	-- 已经设置了将要播放剧情的话，直接返回，等待剧情结束
	if self.to_play_plot_list then return true end

	local battle_data = getGameData():getBattleDataMt()
	local battle_field_data = battle_data:GetData("battle_field_data")
	if not battle_field_data then return false end

	local data = dataTools:getOldPlotList(battle_field_data.plot_file_name)
	if not data then return false end

	local plot_list = {}

	for k, id in ipairs(self.plots) do
		if data[id] ~= nil then
			table.insert(plot_list, data[id])
		end
	end

	if #plot_list < 1 then return false end
	self.to_play_plot_list = plot_list

	-- 剧情,是否暂停镜头
	local cameraStop = ai_obj:getData( "__camera_stop" ) 

	local end_call_back = function()
		self.play_end_flg = true
		-- self.duration = 0
		-- 推动ai继续
		ai_obj:heartBeat(0)
	end
	battlePlot:playPlot(plot_list, cameraStop, end_call_back, self.plots)

	local sailor_id = battle_data:getCurClientControlShip():getSailorID()
	local sailor_name = battle_data:getCurClientControlShip():getFighterName()
	local role_id = battle_data:getLeaderShip(battle_data:getCurClientUid()):getRole()
	
	require("gameobj/battle/battleRecording"):recordVarArgs("battle_play_plot", self.plots, cameraStop, sailor_id, sailor_name, role_id)

	return true
end

return ClsAIActionPlayPlot
