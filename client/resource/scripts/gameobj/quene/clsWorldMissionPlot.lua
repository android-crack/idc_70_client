
local clsWorldMissionPlot = class("clsWorldMissionPlot", require("gameobj/quene/clsQueneBase"))

function clsWorldMissionPlot:ctor(data)
	self.data = data
end

function clsWorldMissionPlot:getQueneType()
	return self:getDialogType().world_mission_dialog
end

function clsWorldMissionPlot:excTask()

	-- 添加一组剧情对话 plot_str_table剧情对话表
	if self.data.plot_str_table then
		-- 剧情对话结束回调
		self.data.plot_str_table.call_back = function ()
			-- print('------------ 剧情对话结束回调 ')
			if self.data.callback and type(self.data.callback) == 'function' then
				self.data.callback()
			end
			self:TaskEnd()
			-- print(' ------------------ TaskEnd ---------------- ')
		end
		-- print(' --------------- 执行对话')
		getUIManager():create("gameobj/mission/plotDialog", nil, self.data.plot_str_table)
		-- self:TaskEnd()
	end
end

return clsWorldMissionPlot
