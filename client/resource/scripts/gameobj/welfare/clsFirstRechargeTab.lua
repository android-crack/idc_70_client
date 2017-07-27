-- 首充界面
-- Author: Ltian
-- Date: 2016-07-04 14:49:37
--
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word")
local item_info = require("game_config/propItem/item_info")
local baozang_info = require("game_config/collect/baozang_info")
local recharge_info = require("game_config/activity/recharge")
local recharge_order = require("game_config/activity/recharge_order")
local on_off_info=require("game_config/on_off_info")
local boat_attr = require("game_config/boat/boat_attr")
local ClsDataTools = require("module/dataHandle/dataTools")

local REWARD_NUM = 11
local RECH_REWARD_NUM = 3

local recharge_times = RECHARGE_ALL_TIMES
local SHOP_RECHARGE = 3

local diamound_false_id = 226
local cash_false_id = 227
local honour_false_id = 228

---
local REWARD_ITEM_TYPE_1 = 1
local REWARD_ITEM_TYPE_2 = 2
local REWARD_ITEM_TYPE_3 = 3

local ClsFirstRechargeTab = class("ClsFirstRechargeTab", ClsBaseView)

local first_name = {
	"recharge_btn",
	"get_reward",
	"recharge_text",

}

local recharge_name = {
	"recharge_btn",
	"get_reward",
	"recharge_text",
	"num",
	"recharge_bar",
	"recharge_accumulate",
	"tip_2",
}


local baowu_name = {
	"name",
	"lv_txt",
	"lv_num",
	"info_text",
	"btn_synthetic",
	"btn_use",
	"num_txt",
	"num_num",
	"property_add",
	"property_add_2",
	"property_info",
	"equip_icon_bg",
	"equip_icon",
	"property_info_2",
}

local baouw_pos = {
	[114] = 2,
	[205] = 3,
	[314] = 5,
}

local item_pos = {
	[2] = 4,
	[211] = 7,
	[191] = 8,
	[63] = 10,
	[106] = 11,
}

ClsFirstRechargeTab.getViewConfig = function(self)
	return {is_swallow = false}
end

ClsFirstRechargeTab.onEnter = function(self)
	self.plist = {
		["ui/award_ui.plist"] = 1,
		["ui/baowu.plist"]  = 1,
		["ui/shop_ui.plist"] = 1,
		["ui/title_icon.plist"] = 1,
		["ui/shipyard_ui.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
	}
	LoadPlist(self.plist)

	self:askData()
end

ClsFirstRechargeTab.askData = function(self)
	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:askRechargeRewardPreview()
end


ClsFirstRechargeTab.mkUI = function(self)

	local growth_fund_data = getGameData():getGrowthFundData()
	self.reward_preview = growth_fund_data:getRechargeRewardPreviewInfo()

	self.reward_info = growth_fund_data:getRechargeRewardInfo()

	---冲值数量
	--self.reward_info.amount
	---已经领奖list
	--self.reward_info.taken_list

	if self.reward_info.taken_list and #self.reward_info.taken_list > 0 then ---首冲已领
		self:mkRechargeUI()	
		self:setFristViewTouch(false)

		if self.panel then
			self.panel:setVisible(false)
		end
	else
		self:mkFirstRechargeUI()	
	end

end

ClsFirstRechargeTab.mkRechargeUI = function(self)
	if self.panel_1 then
		self.panel_1:removeFromParentAndCleanup(true)
		self.panel_1 = nil 
	end

	self.panel_1 = GUIReader:shareReader():widgetFromJsonFile("json/award_recharge.json")
	convertUIType(self.panel_1)
	self:addWidget(self.panel_1)

	for k,v in pairs(recharge_name) do
		self[v] = getConvertChildByName(self.panel_1, v)
	end


	self.bg_list = {}
	for i=1,RECH_REWARD_NUM do

		local bg = getConvertChildByName(self.panel_1, "bg_"..i)
		bg:setTouchEnabled(false)
		bg:setVisible(false)
		self.bg_list[i] = bg

		local name = getConvertChildByName(self.panel_1, "name_"..i)
		self.bg_list[i].name = name

		local pic = getConvertChildByName(self.panel_1, "pic_"..i)
		self.bg_list[i].pic = pic

		local num = getConvertChildByName(self.panel_1, "num_"..i)
		self.bg_list[i].num = num

		local label = getConvertChildByName(self.panel_1, "label_"..i)
		label:setVisible(false)
		self.bg_list[i].label = label

		local label_text = getConvertChildByName(self.panel_1, "label_text_"..i)
		self.bg_list[i].label_text = label_text

	end

	local task_data = getGameData():getTaskData()
	task_data:regTask(self.recharge_btn, {on_off_info.RECHARGE_REWARD.value,}, KIND_LONG_RECTANGLE, on_off_info.RECHARGE_REWARD.value, nil, nil, true)

	self:updateRechargeUI()
	self:updatRechargeBtn()
end

ClsFirstRechargeTab.updatRechargeBtn = function(self)
	self.recharge_btn:setPressedActionEnabled(true)
	self.recharge_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local growth_fund_data = getGameData():getGrowthFundData()
		if self.reward_num > recharge_times then
			return 
		end

		if self.deff_reacharge > 0 then
			---商店充值
			local ClsMallMain = getUIManager():get("ClsMallMain")
			if not tolua.isnull(ClsMallMain) then
				ClsMallMain:close()
			end

			getUIManager():create("gameobj/mall/clsMallMain",nil,SHOP_RECHARGE)
		else
			---领奖
			growth_fund_data:getRechargeTakeReward(self.reward_num)
		end

	end,TOUCH_EVENT_ENDED)	
end

ClsFirstRechargeTab.getMoreRecharge = function(self, more_times,item_type ,item_id)
	local list = recharge_order[more_times].order
	
	for k,v in pairs(list) do
		if v.item_type == item_type and v.id == item_id then
			return v.pos, v.item_level
		end
	end
end



ClsFirstRechargeTab.updateRechargeUI = function(self)
	local reward_num = #self.reward_info.taken_list + 1

	self.reward_num = reward_num

	if reward_num > recharge_times then
		reward_num = recharge_times
	end

	local recharge_rewards = self.reward_preview[reward_num].rewards
	for k,v in pairs(recharge_rewards) do

		local item_pos ,item_level = self:getMoreRecharge(reward_num - 1, v.type, v.id)

		local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(v)
		local plist_type = UI_TEX_TYPE_PLIST
		local scale = 1
		if v.type == ITEM_INDEX_SAILOR then
			plist_type = UI_TEX_TYPE_LOCAL
			scale = 0.5
		end
		self.bg_list[item_pos].pic:changeTexture(convertResources(item_res), plist_type)
		self.bg_list[item_pos].pic:setScale(scale)
		self.bg_list[item_pos].name:setText(name)
		self.bg_list[item_pos].num:setText("X"..amount)

		self.bg_list[item_pos].label:setVisible(item_level ~= 0)
		local str = ui_word.TAB_RECHARGE_ITEM_LEVEL_1
		if item_level == REWARD_ITEM_TYPE_1 then
			str = ui_word.TAB_RECHARGE_ITEM_LEVEL_1
		elseif item_level == REWARD_ITEM_TYPE_2 then
			str = ui_word.TAB_RECHARGE_ITEM_LEVEL_2
		elseif item_level == REWARD_ITEM_TYPE_3 then
			str = ui_word.TAB_RECHARGE_ITEM_LEVEL_3
		end
		self.bg_list[item_pos].label_text:setText(str)

		self.bg_list[item_pos]:setVisible(true)
		self.bg_list[item_pos]:setTouchEnabled(true)
		self.bg_list[item_pos]:addEventListener(function ()
			if v.type == ITEM_INDEX_SAILOR then
				local playerData = getGameData():getPlayerData()
				local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
				mission_skip_layer:skipSailorCollectUI(nil, playerData:getUid(), nil, v.id)
			elseif v.type == ITEM_INDEX_PROP then
				self:showItemTip(v.id)
			elseif v.type == ITEM_INDEX_BAOWU then
				self:showBaoWuTips(v.id)	
			end
		end,TOUCH_EVENT_ENDED)
	end


	local will_reacharge = recharge_info[reward_num].amount
	local have_reacharge = self.reward_info.amount
	local percent = 0 
	local deff_reacharge = 0
	if have_reacharge < will_reacharge then
		deff_reacharge = will_reacharge - have_reacharge
		percent = have_reacharge/will_reacharge*100
	else
		percent = 100
	end

	self.num:setText(deff_reacharge)
	local size = self.num:getContentSize()
	local pos = self.num:getPosition()
	self.tip_2:setPosition(ccp(pos.x+size.width + 7 ,pos.y))

	self.recharge_bar:setPercent(percent)
	self.recharge_accumulate:setText(string.format("%s/%s",have_reacharge,will_reacharge))

	self.get_reward:setVisible(have_reacharge >= will_reacharge)
	self.recharge_text:setVisible(have_reacharge < will_reacharge)
	self.deff_reacharge = deff_reacharge

end



ClsFirstRechargeTab.mkFirstRechargeUI = function(self)

	if self.panel then
		self.panel:removeFromParentAndCleanup(true)
		self.panel = nil 
	end

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_first_recharge.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	for k,v in pairs(first_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.first_recharge_btn = getConvertChildByName(self.panel, "recharge_btn")
	self.ship_touch = getConvertChildByName(self.panel, "ship_touch")

	self.reward_panel_list = {}
	for i=1,REWARD_NUM do

		local reward_panel = getConvertChildByName(self.panel, "reward_"..i)
		self.reward_panel_list[i] = reward_panel

		local reward_num = getConvertChildByName(self.panel, "num_"..i)
		self.reward_panel_list[i].reward_num = reward_num

		local reward_pic = getConvertChildByName(self.panel, "pic_"..i)
		self.reward_panel_list[i].reward_pic = reward_pic

	end

	if self.reward_info.amount > 0 then
		self.get_reward:setVisible(true)
		self.recharge_text:setVisible(false)
	end

	self:updateUI()
	self:updatBtn()

	local task_data = getGameData():getTaskData()
	task_data:regTask(self.first_recharge_btn, {on_off_info.RECHARGE_REWARD.value,}, KIND_LONG_RECTANGLE, on_off_info.RECHARGE_REWARD.value, nil, nil, true)
end


ClsFirstRechargeTab.updatBtn = function(self)

	self.first_recharge_btn:setPressedActionEnabled(true)
	self.first_recharge_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local growth_fund_data = getGameData():getGrowthFundData()
		if self.reward_info.amount > 0 then
			growth_fund_data:getRechargeTakeReward(1)
			local ClsWefareMain = getUIManager():get("ClsWefareMain")
			if not tolua.isnull(ClsWefareMain) then
				ClsWefareMain:updateMkUI()
			end
		else
			----打开商城
			local ClsMallMain = getUIManager():get("ClsMallMain")
			if not tolua.isnull(ClsMallMain) then
				ClsMallMain:close()
			end

			getUIManager():create("gameobj/mall/clsMallMain",nil,SHOP_RECHARGE)
		end

	end,TOUCH_EVENT_ENDED)
end

ClsFirstRechargeTab.updateUI = function(self)

	local first_recharge_reward = self.reward_preview[1].rewards
	local tag = 1	

	for k,v in pairs(first_recharge_reward) do
		local item_type = 1		
		if v.type ~= ITEM_INDEX_BOAT then
			local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(v)
			if v.type == ITEM_INDEX_GOLD then --钻石
				tag = 1
				v.id = diamound_false_id
			elseif v.type == ITEM_INDEX_BAOWU then
				tag = baouw_pos[v.id]
				item_type = 2
			elseif v.type == ITEM_INDEX_PROP then --道具
				tag = item_pos[v.id]
			elseif v.type == ITEM_INDEX_CASH then ---金币
				tag = 9
				v.id = cash_false_id
			elseif v.type == ITEM_INDEX_HONOUR then ---朗姆酒
				tag = 6
				v.id = honour_false_id
			end

			self.reward_panel_list[tag].reward_num:setVisible(amount ~= 1)
			if amount > 10000 then
				amount =  string.format(ui_word.AMOUNT_CASH, amount/10000)  
			end
			self.reward_panel_list[tag].reward_num:setText(amount)
			self.reward_panel_list[tag].reward_pic:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
			self.reward_panel_list[tag]:setTouchEnabled(true)
			self.reward_panel_list[tag]:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				if not tolua.isnull(self.tip) then
					self.tip:removeFromParentAndCleanup(true)
					self.tip = nil 
				end
				if item_type == 1 then
					self.tip = self:showItemTip(v.id)
				else
					self.tip = self:showBaoWuTips(v.id)	
				end

			end, TOUCH_EVENT_ENDED)
		else
			self.boat_id = v.id 
		end
	end

	self.ship_touch:setTouchEnabled(true)
	self.ship_touch:addEventListener(function (  )
		getUIManager():create("gameobj/welfare/clsRechargeBoatTips", nil, self.boat_id)
	end,TOUCH_EVENT_ENDED)

end

ClsFirstRechargeTab.setFristViewTouch = function(self, enable)
	if self.first_recharge_btn then
		self.first_recharge_btn:setTouchEnabled(enable)
	end
	if self.reward_panel_list and #self.reward_panel_list > 0  then
		for k,v in pairs(self.reward_panel_list) do
			if v then
				v:setTouchEnabled(enable)
			end
		end
	end
end


ClsFirstRechargeTab.showItemTip = function(self, itemId)
	local item_config = item_info[itemId]	
	
	if(not item_config)then return end
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_tips.json")
	panel:setPosition(ccp(260, 70))
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

	getUIManager():create("ui/view/clsBaseTipsView", nil, "FirestRechargeItemTip", {is_back_bg = true}, panel, true)
	return panel	
end


ClsFirstRechargeTab.showBaoWuTips = function(self, itemId)

	local baozang_config = baozang_info[itemId]
	local layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_tips.json")
	panel:setPosition(ccp(260, 70))
	layer:addChild(panel)

	for k,v in pairs(baowu_name) do
		layer[v]= getConvertChildByName(panel, v)
		layer[v]:setVisible(false)
	end

	layer.name:setVisible(true)
	layer.name:setText(baozang_config.name)

	layer.lv_txt:setVisible(true)
	layer.lv_num:setVisible(true)
	local lv = baozang_config.limitLevel
	if baozang_config.owner == "boat" then
		lv = baozang_config.level
	end
	layer.lv_num:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, lv))

	layer.info_text:setVisible(true)
	layer.info_text:setText(baozang_config.desc)

	
	local attr_labels = {
		layer.property_info,
		layer.property_info_2,
	}
	local attr_add_labels = {
		layer.property_add,
		layer.property_add_2,
	}

	local item_bg_res = "item_box_4.png"   ---航海士装备背景，名字颜色写死
	local quality = 4
	if baozang_config.type == "weapon" or 
		baozang_config.type == "armor" or 
		baozang_config.type == "book" 
	then
		local baowu_attr = ui_word.BAOWU_TYPE_BOOK
		if baozang_config.type == "weapon" then
			baowu_attr = ui_word.BAOWU_TYPE_WEAPON
		elseif baozang_config.type == "armor" then
			baowu_attr = ui_word.BAOWU_TYPE_ARMOR
		end
		layer.property_info:setVisible(true)
		layer.property_info:setText(baowu_attr)
		--layer.equip_icon_bg:changeTexture(convertResources("item_box_4.png"), UI_TEX_TYPE_PLIST)
	else
		local base_attr_info = require("game_config/base_attr_info")
		for i,v in ipairs(baozang_config.base_attrs) do
			attr_labels[i]:setVisible(true)
			attr_labels[i]:setText(base_attr_info[v].name)
			attr_add_labels[i]:setVisible(true)
			local attr_num = ClsDataTools:getBoatBaowuAttr(v,baozang_config[v])
			attr_add_labels[i]:setText(attr_num)
		end
		quality = baozang_config.star
		
		item_bg_res = string.format("item_box_%s.png", quality)

	end
	layer.equip_icon:setVisible(true)
	layer.equip_icon:changeTexture(convertResources(baozang_config.res), UI_TEX_TYPE_PLIST)

	setUILabelColor(layer.name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	layer.equip_icon_bg:setVisible(true)
	layer.equip_icon_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)


	getUIManager():create("ui/view/clsBaseTipsView", nil, "FirestRechargeBaoWuTip", {is_back_bg = true}, layer, true)
	return panel		
end


ClsFirstRechargeTab.onExit = function(self)
	UnLoadPlist(self.plist)
end

return ClsFirstRechargeTab
