local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local relic_info = require("game_config/collect/relic_info")
local composite_effect = require("gameobj/composite_effect")
local dialog = require("ui/dialogLayer")
local ClsRelicActiveUI = class("ClsRelicActiveUI", ClsBaseView)

local MAX_STAR_COUNT = 7

--页面参数配置方法，注意，是静态方法
function ClsRelicActiveUI:getViewConfig()
    return {
        name = "ClsRelicActiveUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
    }
end

function ClsRelicActiveUI:onEnter(relic_id)
	self.relic_id = relic_id or 1
	self:configUI()
end

function ClsRelicActiveUI:configUI()
	--添加基本层
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/relic_active.json")
	self:addWidget(self.panel)

	local relic_info = relic_info[self.relic_id]
	self.relic_name = getConvertChildByName(self.panel, "card_title")
	self.relic_picture = getConvertChildByName(self.panel, "relic_card")
	self.relic_name:setText(relic_info.name)
	local pic = string.format("ui/yiji/%s", relic_info.res)
	self.relic_picture:changeTexture(pic, UI_TEX_TYPE_LOCAL)

	local open_eff = nil
	open_eff = composite_effect.new("tx_0040", 510, 270, self, nil, function()
		open_eff:removeFromParentAndCleanup(true)
		open_eff:removeTexture()
	end)
	open_eff:setZOrder(5)
	audioExt.playEffect(music_info.UNLOCK_RELIC.res)

	self.stars_panel = getConvertChildByName(self.panel, "stars_panel")
	self.stars_panel.stars = {}
	for k = 1, MAX_STAR_COUNT do
		local item = {}
		local star_bg_name = string.format("star_bg_%s", k)
		item.bg = getConvertChildByName(self.stars_panel, star_bg_name)
		item.sp = getConvertChildByName(self.stars_panel, "star")
 		self.stars_panel.stars[#self.stars_panel.stars + 1] = item
	end

	local stars_panel_pos = self.stars_panel:getPosition()
	self.stars_panel.org_pos = {x = stars_panel_pos.x, y = stars_panel_pos.y}

	local stars_panel_width = self.stars_panel:getSize().width
	local single_star_offset = (stars_panel_width * 0.5) / MAX_STAR_COUNT
	self.stars_panel:setPosition(ccp(self.stars_panel.org_pos.x + (MAX_STAR_COUNT - relic_info.max_star) * single_star_offset, self.stars_panel.org_pos.y))
	for i = 1, MAX_STAR_COUNT do
		local item = self.stars_panel.stars[i]
		item.bg:setVisible(i <= relic_info.max_star)
	end

	self.btn_known = getConvertChildByName(self.panel, "btn_known")
	self.btn_known:setVisible(true)
	self.btn_known:setTouchEnabled(true)
	self.btn_known:setPressedActionEnabled(true)
	self.btn_known:addEventListener(function() 
		self:close()
	end, TOUCH_EVENT_ENDED)
end

return ClsRelicActiveUI

