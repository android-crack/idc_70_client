
---首次获取A级航海士tips
---fmy
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local sailor_info = require("game_config/sailor/sailor_info")
local openURLMgr = require("gameobj/openURLMgr")
local ClsSailorFristTips = class("ClsSailorFristTips",ClsBaseView)

function ClsSailorFristTips:getViewConfig()
    return {
        is_back_bg = true, 
    }
end

local widget_name = {
	"sailor_head",
	"sailor_name",
	"btn_comment",
	"btn_close",
}

function ClsSailorFristTips:onEnter(  )
	self.plist = {
		["ui/hotel_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_new_sailor.json")
	self:addWidget(self.panel)

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)	
	end

	self:initUI()
end

function ClsSailorFristTips:initUI()

	local sailor_id = getGameData():getSailorData():getFirstASailor()
	local sailor_data = sailor_info[sailor_id]
	self.sailor_head:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.sailor_name:setText(sailor_data.name)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close() 
		
	end,TOUCH_EVENT_ENDED)

	self.btn_comment:setPressedActionEnabled(true)
	self.btn_comment:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		openURLMgr:openAppEvaluateUrl()
	end,TOUCH_EVENT_ENDED)		
end

function ClsSailorFristTips:onExit(  )
	local sailorData = getGameData():getSailorData()
	sailorData:clearFirstASailor()
	UnLoadPlist(self.plist)
end

return ClsSailorFristTips

