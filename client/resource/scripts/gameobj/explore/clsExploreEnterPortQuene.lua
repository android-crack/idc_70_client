local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsExploreEnterPortQuene = class("ClsExploreEnterPortQuene", ClsQueneBase)

function ClsExploreEnterPortQuene:ctor(data)
	self.data = data
end

function ClsExploreEnterPortQuene:getQueneType()
	return self:getDialogType().explore_enter_port
end

function ClsExploreEnterPortQuene:excTask()
	getUIManager():create("gameobj/pve/clsEnterPortUI", nil, self.data)
	self:TaskEnd()
end

return ClsExploreEnterPortQuene