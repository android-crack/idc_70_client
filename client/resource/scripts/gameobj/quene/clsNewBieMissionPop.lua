local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsNewBieMissionPop = class("ClsNewBieMissionPop", ClsQueneBase)

function ClsNewBieMissionPop:ctor()
end

function ClsNewBieMissionPop:getQueneType()
return self:getDialogType().new_bie_mission_effect
end

function ClsNewBieMissionPop:excTask()
	local call_back = function()
		self:TaskEnd()
	end
	getUIManager():create("gameobj/mission/clsNewBieMissionUI", nil, call_back)
end

return ClsNewBieMissionPop