-- require("gameobj/quene/clsDialogQuene"):insertTaskToQuene(require("gameobj/quene/clsObtainNewTitleQueue").new({}))

local clsObtainNewTitleQueue = class("clsObtainNewTitleQueue", require("gameobj/quene/clsQueneBase"))

function clsObtainNewTitleQueue:ctor(data)
	self.data = data
end

function clsObtainNewTitleQueue:getQueneType()
	return self:getDialogType().obtain_ui
end

function clsObtainNewTitleQueue:excTask()
	local function obtain_ui_callback()

	end

	local data = {}
	data.callback = obtain_ui_callback
	getUIManager():create("gameobj/tips/clsObtainNewTitleTips",nil,data)
	self:TaskEnd()
end

return clsObtainNewTitleQueue
