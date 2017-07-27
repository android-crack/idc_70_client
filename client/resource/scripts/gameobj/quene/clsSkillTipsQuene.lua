----航海士战斗外技能触发提示框

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local SkillDialogView = require("gameobj/skillDialog")
local ClsSkillTipsQuene = class("ClsSkillTipsQuene", ClsQueneBase)

function ClsSkillTipsQuene:ctor(data)
	self.data = data
end

function ClsSkillTipsQuene:getQueneType()
	return self:getDialogType().skillDialog
end

function ClsSkillTipsQuene:excTask()
	
	SkillDialogView:showDialog(self.data.sailor_id, self.data.skillId, function ( )
		if self.data.call_back ~= nil then
			self.data.call_back()
		end
		self:TaskEnd()
	end)
end

return ClsSkillTipsQuene