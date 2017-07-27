-- @date: 2016年12月10日14:13:59
-- @author: mid
-- @desc: 通用物品详情tips

-- usage
-- local data = {}
-- data.id = 223
-- getUIManager():create("gameobj/tips/clsCommonItemTips",nil,data)

local item_info = require("game_config/propItem/item_info")

local clsCommonItemTips = class("clsCommonItemTips",require("ui/view/clsBaseTipsView"))

-- override
function clsCommonItemTips:getViewConfig()
	local data = {}
	data.name = "clsCommonItemTips"
	data.is_back_bg = false
	data.effect = UI_TYPE.NOTICE -- = nil 不行.
	return self.super.getViewConfig(self, name_str,data)
end

function clsCommonItemTips:onEnter(data)
	self.data = data
	self.id = data.id
	self:initUI()
	local function touch_callback()
		self:close()
	end
	self:addBgTouchCloseBg()
end

function clsCommonItemTips:onExit()
	ReleaseTexture(self)
end

function clsCommonItemTips:initUI()
	local item_config = item_info[self.id]
	if(not item_config)then print(" clsCommonItemTips id invalid") return end

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/cityhall_invest_unlock.json")
	convertUIType(panel)

	-- local wgt = UIWidget:create()
	-- wgt:addChild(panel)

	-- self:addWidget(wgt)
	self:addWidget(panel)

	-- panel:setPosition(ccp(display.cx, display.cy))

	local wgts = {
		["bg"]        = "unlock_bg",
		["btn_close"] = "btn_close",
		["desc"]      = "item_info",
		["icon"]      = "icon",
		["name"]      = "title",
		["no_need_1"] = "lock_icon",
		["no_need_2"] = "item_type",
		["no_need_3"] = "item_name",
		["no_need_4"] = "unlock_tips",
	}

	for k,v in pairs(wgts) do
		panel[k] = getConvertChildByName(panel,v)
	end
	panel.icon:changeTexture(convertResources(item_config.res), UI_TEX_TYPE_PLIST)
	panel.name:setText(item_config.name)
	panel.desc:setText(item_config.desc)

	-- self:setIgnoreClosePanel(panel)

	for i=1,4 do
		panel[string.format("no_need_%d",i)]:setVisible(false)
	end

	local function callback()
		self:close()
	end
	panel.btn_close:addEventListener(callback,TOUCH_EVENT_ENDED)

end

return clsCommonItemTips
