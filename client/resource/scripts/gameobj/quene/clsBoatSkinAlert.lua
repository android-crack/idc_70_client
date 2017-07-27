--
-- Author: Ltian
-- Date: 2017-03-27 18:54:13
--
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsBoatSkinAlert = class("ClsBoatSkinAlert", ClsQueneBase)
function ClsBoatSkinAlert:ctor(data)
	self.item_id = data
end

function ClsBoatSkinAlert:getQueneType()
	return self:getDialogType().boat_skin_alert
end

function ClsBoatSkinAlert:excTask()
	local ui_word = require("game_config/ui_word")
	local item_info = require("game_config/propItem/item_info")
	local Alert = require("ui/tools/alert")
	local item_name = item_info[self.item_id].name
	local tips = item_name..ui_word.SKIN_IS_END_TIPS
	Alert:showAttention(tips)
	self:TaskEnd()
end

return ClsBoatSkinAlert