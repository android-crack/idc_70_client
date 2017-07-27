-- 每日礼包
-- Author: Ltian
-- Date: 2017-01-18 11:11:28
--

local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsDailyGift = class("ClsDailyGift",require("ui/view/clsBaseView"))
local item_info = require("game_config/propItem/item_info")
function ClsDailyGift:getViewConfig()
    return {
        is_swallow = false,
    }
end


function ClsDailyGift:onEnter()
	self:mkUI()
end

local widget_name = {
	"gift_pic_1",
	"gift_pic_2",
	"gift_pic_3",
	"btn_text_1",
	"btn_text_2",
	"btn_text_3",
}
local btn_name = {
	"btn_buy_1",
	"btn_buy_2",
	"btn_buy_3",
}
local key_to_item = {
		234,
		235,
		236
		}

function ClsDailyGift:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_gift.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	for i,v in ipairs(btn_name) do
		self[v] = getConvertChildByName(self.panel, v)
		self[v]:setPressedActionEnabled(true)
		self[v]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:bugGift(i)
		end, TOUCH_EVENT_ENDED)
	end
	
	for i=1,3 do
		self["gift_pic_"..i]:setTouchEnabled(true)
		self["gift_pic_"..i]:addEventListener(function ( )
			self:showItemTip(key_to_item[i])
		end, TOUCH_EVENT_ENDED)
	end
	self:updateView()
	-- self.get_btn:setPressedActionEnabled(true)
	-- self.get_btn:addEventListener(function ()
	-- 	self.get_btn:setTouchEnabled(false)
	-- 	local login_award_data = getGameData():getLoginVipAwardData()
	-- 	login_award_data:askIdleReward()
	-- end, TOUCH_EVENT_ENDED)
	-- self:updateView()
end
local gift_key_tab = {
	"com.tencent.qmdhh.gift1",
	"com.tencent.qmdhh.gift3",
	"com.tencent.qmdhh.gift6"
}


function ClsDailyGift:bugGift(index)
	local gift_key = gift_key_tab[index]
	
	tab = {}
	tab.gift1 = 1
	tab.gift2 = 1
	tab.gift3 = 1
	
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.beginPay(gift_key)
end

function ClsDailyGift:updateView()
	local shop_data = getGameData():getShopData()
    local gift_data = shop_data:getGiftData()
	if type(gift_data) == "table" then
		for i=1,3 do
			if gift_data["gift"..i] == 1 then --已购买
				self["btn_text_"..i]:setText(ui_word.BUY_GITF)
				self["btn_buy_"..i]:disable()
			end
		end
	end
	for i=1,3 do
		local item_config = item_info[key_to_item[i]]	
		self["gift_pic_"..i]:changeTexture(convertResources(item_config.res), UI_TEX_TYPE_PLIST)
	end
end


function ClsDailyGift:showItemTip(item_id)
	
	local item_config = item_info[item_id]	
	
	if(not item_config)then return end
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_tips.json")
	panel:setPosition(ccp(display.cx -100, display.cy - 160))
	local item_icon = getConvertChildByName(panel, "box_icon")
	local item_bg = getConvertChildByName(panel, "box_bg")
	local item_name = getConvertChildByName(panel, "box_name")
	local item_num = getConvertChildByName(panel, "box_tips_num")
	local item_intro = getConvertChildByName(panel, "box_introduce")

	local btn_use = getConvertChildByName(panel, "btn_use")
	btn_use:setVisible(false)
	local consume_panel = getConvertChildByName(panel, "consume_panel")
	consume_panel:setVisible(false)
	local box_tips = getConvertChildByName(panel,"box_tips")
	box_tips:setVisible(false)


	local quality = item_config.quality or item_config.level
	setUILabelColor(item_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	item_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)


	item_icon:changeTexture(convertResources(item_config.res), UI_TEX_TYPE_PLIST)
	item_name:setText(item_config.name)
	item_num:setText("")
	item_intro:setText(item_config.desc)

	getUIManager():create("ui/view/clsBaseTipsView", nil, "ClsDailyGiftTips", {is_back_bg = true}, panel, true)
	return panel	
end
function ClsDailyGift:onExit()
end
return ClsDailyGift