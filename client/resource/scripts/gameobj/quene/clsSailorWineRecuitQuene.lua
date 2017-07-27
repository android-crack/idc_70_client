---朗姆酒招募
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsSailorWineRecuitQuene = class("ClsSailorWineRecuitQuene", ClsQueneBase)

function ClsSailorWineRecuitQuene:ctor(data)
	self.data = data
end

function ClsSailorWineRecuitQuene:getQueneType()
	return self:getDialogType().wine_recruit_reward
end

function ClsSailorWineRecuitQuene:excTask()
	getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, self.data.sailor_id, nil, function ( )
		if self.data.call_back ~= nil then
			self.data.call_back()
		end
		self:TaskEnd()
	end)
end

return ClsSailorWineRecuitQuene