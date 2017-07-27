
---fmy0570
---探索界面航海士升级


local exploreShip = require("gameobj/explore/exploreShip3d")
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsExploreSailorUpLevel = class("ClsExploreSailorUpLevel", ClsQueneBase)

function ClsExploreSailorUpLevel:ctor(data)
	self.data = data
end

function ClsExploreSailorUpLevel:getQueneType()
	return self:getDialogType().explore_sailor_up_level
end

function ClsExploreSailorUpLevel:excTask()
	self.data.my_ship:createSailorUpLevelEffect(self.data.sailor_id, function ( )
		if self.data.call_back ~= nil then
			self.data.call_back()
		end
		self:TaskEnd()
	end)
end

return ClsExploreSailorUpLevel