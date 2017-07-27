---防沉迷提示框
--clr
--20170216
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsAddictPopQueue = class("ClsAddictPopQueue", ClsQueneBase)

function ClsAddictPopQueue:ctor(data)
	self.data = data
end

function ClsAddictPopQueue:getQueneType()
	return self:getDialogType().addict_tips_pop
end

function ClsAddictPopQueue:excTask()
	local ui_name_str = "ClsAddictPopView"
	local music_info=require("game_config/music_info")
	local error_info = require("game_config/error_info")
	local ui_layer = UIWidget:create()

    local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_addict.json")
    convertUIType(panel)
	ui_layer:addChild(panel)

	ui_layer:setPosition(ccp(242, 126))

   	ui_layer.text = getConvertChildByName(panel, "text_1")
   	ui_layer.text:setText(error_info[self.data].message)

   	ui_layer.btn_close = getConvertChildByName(panel, "btn")
	ui_layer.btn_close:setPressedActionEnabled(true)
	ui_layer.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		getUIManager():close(ui_name_str)
		self:TaskEnd()
	end, TOUCH_EVENT_ENDED)

   	getUIManager():create("ui/view/clsBaseTipsView", nil, ui_name_str, {type = UI_TYPE.TOP}, ui_layer, false)
end

return ClsAddictPopQueue