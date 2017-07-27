

----爵位升级后特效

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsNobilityUpEffect = class("ClsNobilityUpEffect", ClsQueneBase)

function ClsNobilityUpEffect:ctor(data)
	self.data = data
end

function ClsNobilityUpEffect:getQueneType()
	return self:getDialogType().nobility_up_effect
end

function ClsNobilityUpEffect:excTask()
	
	getUIManager():create("scripts/ui/clsNobilityUpLevelEffect",nil,function (  )
		self:TaskEnd()
	end)

end

return ClsNobilityUpEffect