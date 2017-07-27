---fmy0570
---航海士升级特效

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsSailorUpLevelEffect = class("ClsSailorUpLevelEffect", ClsQueneBase)

function ClsSailorUpLevelEffect:ctor(data)
	self.data = data
end

function ClsSailorUpLevelEffect:getQueneType()
	return self:getDialogType().sailor_up_level_effect
end

function ClsSailorUpLevelEffect:excTask()

	local ClsPartnerInfoView  = getUIManager():get("ClsPartnerInfoView")
	if not tolua.isnull(ClsPartnerInfoView) then
		ClsPartnerInfoView:updateExpNum(self.data.sailor_data, function ()
			self:TaskEnd()
		end)
	else
		self:TaskEnd()
	end


end

return ClsSailorUpLevelEffect