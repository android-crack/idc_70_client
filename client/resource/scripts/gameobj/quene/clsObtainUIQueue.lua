
local clsObtainUIQueue = class("clsObtainUIQueue", require("gameobj/quene/clsQueneBase"))

function clsObtainUIQueue:ctor(data)
	self.data = data or {}
end

function clsObtainUIQueue:getQueneType()
	return self:getDialogType().obtain_ui
end

function clsObtainUIQueue:excTask()
	local target_ui = nil
	local is_exist = false
	target_ui = getUIManager():get('clsPortTownUI')
	is_exist = not tolua.isnull(target_ui)
	if is_exist then
		-- print(' --------- excTask --------- ')
		local function obtain_ui_callback()
			self:TaskEnd()
		end
		local data = {}
		data.is_show_effect = true
		data.callback = obtain_ui_callback
		data.invest_step = self.data.invest_step
		-- target_ui:getTab(1):setIsUpdating(false)
		target_ui:updateUI(1,data)
	end
end

return clsObtainUIQueue
