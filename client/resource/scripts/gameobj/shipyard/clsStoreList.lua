--造船厂商店
local RadioBtn = require("gameobj/fleet/RadioBtn")
local Alert = require("ui/tools/alert")
local DataTools = require("module/dataHandle/dataTools")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsUiTools = require("gameobj/uiTools")
local ui_word = require("game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local on_off_info = require("game_config/on_off_info")
local music_info = require("scripts/game_config/music_info")
local port_shop = require("scripts/game_config/shipyard/port_shop")
local black_market = require("game_config/shipyard/black_market_config")
local prestige_shop = require("scripts/game_config/shipyard/prestige_shop")
local ClsStoreTip = require("gameobj/shipyard/clsStoreTip")
local ClsStoreBuy = require("gameobj/shipyard/clsStoreBuy")
local camp_info = require("scripts/game_config/mission/camp_info")
local composite_effect = require("gameobj/composite_effect")
local sailor_info = require("game_config/sailor/sailor_info")
local item_info = require("game_config/propItem/item_info")
local LIST_RECT = CCRect(596, 70, 356, 312)  --376

local STORE_PORT = 1
local STORE_POWER = 2

local PORT_SHOP_GENERAL = 1
local PORT_SHOP_BLACK_MARKET = 2

local POWER_HAIJUN = 4
local POWER_HAIDAO = 3

local SHOW_TIP = 1--显示提示
local SHOW_BUY = 2--显示购买窗口

local MIN_BUY_NUM = 1
local DIAMOND_SCALE = 50

local ClsBaseView = require("ui/view/clsBaseView")
local ClsStoreList = class("ClsStoreList", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsStoreList:getViewConfig()
	return {
		name = "ClsStoreList",
		type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
		is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
	}
end

--页面创建时调用
function ClsStoreList:onEnter(parent)
	self.parent = parent
	self.is_add_guide_b = false
	self.is_have_item = false

	self.plistTab = {
		["ui/shipyard_ui.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/fleet_ui.plist"] = 1,
	}

	LoadPlist(self.plistTab)

	self:initUI()
	self:initEvent()
end

function ClsStoreList:updateLabelCallBack()
	local boat_data = getGameData():getBoatData()
	boat_data:askOpenStore()
end

--势力商店领奖成功
function ClsStoreList:showAward(shopId)
	local item = prestige_shop[shopId]

	local temp = {}
	temp.key = ITEM_TYPE_MAP[item.type]
	temp.id = item.goods_id
	temp.value = item.amount

	Alert:showCommonReward({temp})
end

--港口商店购买成功后 播放动画
function ClsStoreList:buySuccess(shop_id, amount, isBlack)
	if isBlack then
		config_data = black_market[shop_id]
	else
		config_data = port_shop[shop_id]
	end

	if config_data.type ~= ITEM_TYPE_BOAT then
		audioExt.playEffect(music_info.SHIPYARD_DISMANTLE_AWARD.res)
		local param = {
			id = config_data.item_id,
			key = ITEM_TYPE_MAP[config_data.type],
			value = config_data.amount * amount
		}

		Alert:showCommonReward({param}, function()

		end)
	end
end

function ClsStoreList:getItemInfo(config_data)
	local shop_item = {}
	shop_item.key = ITEM_TYPE_MAP[config_data.type]
	shop_item.id = config_data.item_id
	return getCommonRewardIcon(shop_item)
end


function ClsStoreList:enoughMoney(cur_price, price_type)
	local playData = getGameData():getPlayerData()
	if price_type == 0 then
		return playData:getGold() >= cur_price 
	else
		return playData:getCash() >= cur_price        
	end
end

local cell_widget_info = {
	[1] = {name = "btn_item"},
	[2] = {name = "item_bg"},
	[3] = {name = "item"},
	[4] = {name = "item_num"},
	[5] = {name = "item_name"},
	[6] = {name = "item_soldout"},
	[7] = {name = "amount_num"}
}

function ClsStoreList:updateGoodsBase(data, config, is_black)
	self.goods = {}
	--商品index和按钮
	for k, v in pairs(data) do
		local temp = {}
		local config_data = config[v.id]
		local index = config_data.index
		temp.index = index
		temp.data = v

		for k, v in ipairs(cell_widget_info) do
			local name = string.format("%s_%d", v.name, index)
			temp[v.name] = getConvertChildByName(self.panel, name)
		end

		if is_black then
			for i = 1, 6 do
				local name = string.format("sales_txt_%d", index)
				temp.scale = getConvertChildByName(self.panel, name)
			end
			local scale = v.discount
			temp.scale:setText(string.format(ui_word.DISCOUNT, tostring(scale/10)))
		end

		if not is_black then
			local scale = v.discount
			local sales_tip = getConvertChildByName(self.panel, "sales_"..index)
			local sales_txt = getConvertChildByName(self.panel, "sales_txt_"..index)
			if scale > 0 and scale ~= 100 then
				sales_tip:setVisible(true)
				sales_txt:setText(string.format(ui_word.DISCOUNT, tostring(scale/10)))
			else
				sales_tip:setVisible(false)
			end
		end


		local cost_name = string.format("cost_bg_%d", index)
		local cost_icon = string.format("cost_coin_%d", index)
		local cost_num = string.format("cost_num_%d", index)
		temp.cost = getConvertChildByName(self.panel, cost_name)
		temp.cost.icon = getConvertChildByName(temp.cost, cost_icon)
		temp.cost.num = getConvertChildByName(temp.cost, cost_num)

		self.goods[#self.goods + 1] = temp
		--赋值
		local icon_str, amount, scale, config_name, diTuStr, armature_res, color, desc = self:getItemInfo(config_data)
		icon_str = convertResources(icon_str)
		temp.item_bg:changeTexture("shipyard_icon_common.png", UI_TEX_TYPE_PLIST)
		if config_data.type == ITEM_TYPE_BOAT and config_data.money_type == ITEM_TYPE_GOLD and v.amount > 0 then
			temp.item_bg:changeTexture("shipyard_icon_gold.png", UI_TEX_TYPE_PLIST)
		end

		temp.item:changeTexture(icon_str, UI_TEX_TYPE_PLIST)
	
		temp.item_name:setText(config_name)
		local show_txt = string.format("x%d", config_data.amount)
		temp.item_num:setText(show_txt)
		temp.amount_num:setText(v.amount)

		local color = COLOR_CAMEL
		if v.amount < MIN_BUY_NUM then
			color = COLOR_RED
		end
		temp.amount_num:setUILabelColor(color)

		if is_black and (v.amount < MIN_BUY_NUM) and v.type ~= ITEM_INDEX_GOLD then
			local num_str = ui_word.BLACKMARKET_GOODS_LAB
			temp.amount_num:setText(num_str)
			temp.amount_num:setUILabelColor(COLOR_CAMEL)
		end

		local cur_price
		local price_type = 1
		if is_black then
			cur_price = v.value
			if v.type == ITEM_INDEX_GOLD then
				price_type = 0            
				temp.cost.icon:changeTexture("common_icon_diamond.png", UI_TEX_TYPE_PLIST)
			end
		else
			cur_price = config_data.price * v.discount * 0.01
		end

		color = COLOR_RED
		if self:enoughMoney(cur_price, price_type) then
			color = COLOR_WHITE
		end
		temp.cost.num:setUILabelColor(color)
		temp.cost.num:setText(cur_price)

		temp.item_soldout:setVisible((not is_black) and (v.amount < MIN_BUY_NUM))
		
		if not is_black then
			temp.item:setGray(v.amount < MIN_BUY_NUM)
		end

		if is_black and self:isBlackGoodsBuy(v.id) then
			temp.item:setGray(true)
		end

		temp.cost:setVisible(is_black or (v.amount > 0))

		if (not self.is_add_guide_b) and (config_data.type == ITEM_TYPE_BOAT) then
			self.is_add_guide_b = true
		end

		if (not self.is_have_item) and  (config_data.type ~= ITEM_TYPE_BOAT) then
			self.is_have_item = true
		end

		local btn = temp.btn_item
		local origin_node = CCNode:create()
		btn:addCCNode(origin_node)
		btn.origin_node = origin_node
		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local config = {
				icon = icon_str,
				name = config_name,
				desc = desc,
				id = v.id--这个是商品ID
			}

			--黑市买过的商品，点击飘字
			-- if is_black and self:isBlackGoodsBuy(v.id) then
			-- 	--Alert:warning({msg = ui_word.SHIPYARD_BLACK_LAB, size = 26})
			-- 	local boat_data = getGameData():getBoatData()
			-- 	local port_id = getGameData():getPortData():getPortId()
			-- 	boat_data:askBuyBlackGood(port_id, v.id, v.discount)
			-- 	return
			-- end

			if not is_black and v.amount < MIN_BUY_NUM then
				Alert:warning({msg = ui_word.NOT_GOODS, size = 26})
				return
			end

			if is_black and v.type == ITEM_INDEX_GOLD and v.amount < MIN_BUY_NUM then
				Alert:warning({msg = ui_word.NOT_GOODS, size = 26})
				return
			end

			local cur_price
			local price_type = 1
			local text_tip  = ui_word.SHIPYARD_SHOP_BUY
			local tip_window_key = CASH_NOT_ENOUGH

			if is_black then  
				cur_price = v.value
				if v.type == ITEM_INDEX_GOLD then
					price_type = 0
					text_tip  = ui_word.SHIPYARD_SHOP_BUY_DIAMOUD
					tip_window_key = DIAMOND_NOT_ENOUGH
				end
			else
				cur_price = config_data.price * v.discount * 0.01
			end

			if self:enoughMoney(cur_price, price_type) then
				if self.cur_store_type == PORT_SHOP_GENERAL then
					config.amount = config_data.amount
					config.max_partner = v.amount
					config.price_icon = "common_icon_coin.png"
					config.price = config_data.price * v.discount * 0.01
					getUIManager():create("gameobj/shipyard/clsStoreBuy", nil, {config_data = config})
				else
					if self:isBlackGoodsBuy(v.id) then
						local boat_data = getGameData():getBoatData()
						local port_id = getGameData():getPortData():getPortId()
						boat_data:askBuyBlackGood(port_id, v.id, v.discount)
					else
						local tips_text = string.format(text_tip, cur_price, config_name)
						local tips_desc = desc
						self.alert_buy = Alert:showBuyAttention(nil,cur_price,nil, function()
							local boat_data = getGameData():getBoatData()
							if self.cur_store_type == PORT_SHOP_BLACK_MARKET then
								local portData = getGameData():getPortData()
								local port_id = portData:getPortId()
								boat_data:askBuyBlackGood(port_id, v.id, v.discount) --默认1次买1份
							end
						end, nil, nil,true,true,tips_text,tips_desc)					
					end
				end
			else
				Alert:showJumpWindow(tip_window_key, self.parent, {need_cash = cur_price})
			end
		end, TOUCH_EVENT_ENDED)
	end
end

--[[
--创建倒计时定时器
]]

function ClsStoreList:isBlackGoodsBuy(id)
	local boatData = getGameData():getBoatData()
	local have_buy_goods_list = boatData:getBlackShopGoodsBuy()

	if #have_buy_goods_list < 1 then
		return false
	end

	for k,v in pairs(have_buy_goods_list) do
		if v == id then
			return true
		end
	end
	return false
end

function ClsStoreList:createCDTimer(callBack)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self:removeTimeHander()
	self.hander_time = scheduler:scheduleScriptFunc(callBack, 1, false)
end

function ClsStoreList:removeTimeHander()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil 
	end
end

function ClsStoreList:showNpcContent(isShow)
	local delay_time = 0.2
	self.spr_talk_bg:setVisible(true)

	local scale = nil
	local pos = nil
	local array = CCArray:create()
	if isShow then
		scale = 1
		pos = ccp(340, 200)
		array:addObject(CCEaseBackOut:create(CCScaleTo:create(delay_time, scale, scale)))
		array:addObject(CCEaseBackOut:create(CCMoveTo:create(delay_time, pos)))
	else
		scale = 0
		pos = ccp(240, 200)
		array:addObject(CCEaseBackIn:create(CCScaleTo:create(delay_time, scale)))
		array:addObject(CCEaseBackIn:create(CCMoveTo:create(delay_time, pos))) 
		array:addObject(CCDelayTime:create(delay_time + 0.1))
		array:addObject(CCCallFunc:create(function()
			self:closeView()
		end))
	end
	self.spr_talk_bg:runAction(CCSequence:create(array))
end

--黑市
function ClsStoreList:updateBlackStore()
	local player_data = getGameData():getPlayerData()
	if( player_data:getLevel() < OPEN_BLACK_STORE_LEVEL)then
		return
	end

	self:removePowerViewUi()

	self.cur_store_type = PORT_SHOP_BLACK_MARKET

	self.store_panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_darkstore.json")
	self.store_panel_bg:addChild(self.store_panel)

	local boat_data = getGameData():getBoatData()
	self.data = boat_data:getBlackShopList()
	self.is_black = true
	self:updateGoodsBase(self.data, black_market, true)

	--倒计时
	self.remain_time = boat_data:getRemainTime()

	local str = DataTools:getMostCnTimeStr(self.remain_time)

	self.leave_time = getConvertChildByName(self.store_panel, "leave_time")
	self.leave_time:setText(" " .. str)

	---黑市通知商会和好友
	self.btn_tell_guild = getConvertChildByName(self.store_panel, "btn_tell_guild")
	self.btn_tell_friend = getConvertChildByName(self.store_panel, "btn_tell_friend")

	local guild_info_data = getGameData():getGuildInfoData()
	local is_have_guild = guild_info_data:hasGuild()
	if is_have_guild then
		self.btn_tell_guild:active()
	else
		self.btn_tell_guild:disable()
	end

	self.btn_tell_guild:setPressedActionEnabled(true)
	self.btn_tell_guild:addEventListener(function ()
		local is_has_guild = guild_info_data:hasGuild()
		if not is_has_guild then
			Alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_GUILD_TIP, size = 26})
			return 
		end

		if not boat_data:isInBlackPort() then
			Alert:warning({msg = ui_word.BLACKMARKET_ASK_GUILD_FRIEND_FAIL, size = 26})
			return 
		end

		local tell_guild_type = 1
		boat_data:askGuildMemberOrFriend(tell_guild_type)
	end,TOUCH_EVENT_ENDED)

	local friend_data = getGameData():getFriendDataHandler()
	local is_have_friend = friend_data:isHaveFriend() 
	if is_have_friend then
		self.btn_tell_friend:active()
	else
		self.btn_tell_friend:disable()
	end

	self.btn_tell_friend:setPressedActionEnabled(true)
	self.btn_tell_friend:addEventListener(function()
		local is_has_friend = friend_data:isHaveFriend() 
		if not is_has_friend then
			Alert:warning({msg = ui_word.STR_FRIEND_NO, size = 26})
			return 
		end

		if not boat_data:isInBlackPort() then
			Alert:warning({msg = ui_word.BLACKMARKET_ASK_GUILD_FRIEND_FAIL, size = 26})
			return 
		end

		local tell_friend_type = 0
		boat_data:askGuildMemberOrFriend(tell_friend_type)
	end,TOUCH_EVENT_ENDED)

	--遍历每个cell，刷新进度
	self:createCDTimer(function()
		if self.remain_time < 0 then
			self:removeTimeHander()
			return
		end

		self.remain_time = self.remain_time - 1
		local str = DataTools:getMostCnTimeStr(self.remain_time)
		if str == "" then str = "0s" end
		self.leave_time:setText(" " .. str)
	end)
end

--正常市场
function ClsStoreList:updatePortStore()
	self:removePowerViewUi()
	self.cur_store_type = PORT_SHOP_GENERAL

	self.store_panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_portstore.json")
	self.store_panel_bg:addChild(self.store_panel)

	self.refresh_tips = getConvertChildByName(self.store_panel, "refresh_tips")
	self.refresh_num = getConvertChildByName(self.store_panel, "refresh_num")
	self.not_here_tips = getConvertChildByName(self.store_panel, "not_here_tips")

	local boat_data = getGameData():getBoatData()
	local all_black_shop_status = boat_data:getAllBlackShopStatus()
	local black_shop_open = 1
	if all_black_shop_status == black_shop_open then
		local player_data = getGameData():getPlayerData()
		if( player_data:getLevel() < OPEN_BLACK_STORE_LEVEL)then
			self.not_here_tips:setText(ui_word.BLACKMARKET_NEED_LEVEL_TIP)
		else
			self.not_here_tips:setText(ui_word.SHOP_BLACK_MARKET_TIPS)
		end
		self.not_here_tips:setVisible(true)
		self.refresh_num:setVisible(false)
		self.refresh_tips:setVisible(false)
	else
		self.not_here_tips:setVisible(false)
		self.refresh_num:setVisible(true) 
		self.refresh_tips:setVisible(true)          
	end

	self.data = boat_data:getPortGoods()
	self.is_black = false
	self:updateGoodsBase(self.data, port_shop)
end

function ClsStoreList:removePowerViewUi()
	if not tolua.isnull(self.store_panel_bg) then
		self:removeTimeHander()
		self.store_panel_bg:removeAllChildren()
	end

	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.cells = {}
	end
end

function ClsStoreList:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_storebg.json")
	self:addWidget(self.panel)
	--商品panel
	self.store_panel_bg = getConvertChildByName(self.panel, "store_panel")
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.btn_close:setPressedActionEnabled(true)
	self:updateTabSelected(STORE_PORT)
end

function ClsStoreList:updateTabSelected(tag)
	self:selectTab(tag)
end

function ClsStoreList:selectTab(tag)
	if not self.last_select_store or self.last_select_store ~= tag then
		--清楚所有的panel
		if not tolua.isnull(self.store_panel_bg) then
			self.store_panel_bg:removeAllChildren()
			self:removeTimeHander()
		end

		if not tolua.isnull(self.list_view) then
			self.list_view:removeFromParentAndCleanup(true)
			self.cells = {}
		end

		local boatData = getGameData():getBoatData()
		if tag == STORE_PORT then
			boatData:askOpenStore()
			self.cur_select_store = STORE_PORT
		elseif tag == STORE_POWER then
			boatData:askPowerStoreList()
			self.cur_select_store = STORE_POWER
		end
		self.last_select_store = tag
	end
end

function ClsStoreList:initEvent()
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	RegTrigger(CASH_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateCashCallBack()
	end)
end

function ClsStoreList:updateCashCallBack()
	local config = port_shop
	if self.is_black then
		config = black_market
	end
	
	if not self.goods then return end

	for k, v in ipairs(self.goods) do
		local config_data = config[v.data.id]
		local cur_price
		local price_type = 1
		if self.is_black then
			cur_price = v.data.value
			if v.data.type == ITEM_INDEX_GOLD then
				price_type = 0
				v.cost.icon:changeTexture("common_icon_diamond.png", UI_TEX_TYPE_PLIST)
			end
		else
			cur_price = config_data.price * v.data.discount * 0.01
		end
		local color = COLOR_RED
		if self:enoughMoney(cur_price, price_type) then
			color = COLOR_WHITE
		end
		v.cost.num:setUILabelColor(color)
	end
end

function ClsStoreList:closeView()
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.cells = {}
	end

	local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
	if not tolua.isnull(shipyard_main_ui) then 
		shipyard_main_ui:closeView()
	end
end

function ClsStoreList:getBtnClose()
	return self.btn_close
end

function ClsStoreList:onExit()  -- 退出处理
	self:removeTimeHander()
	UnLoadPlist(self.plistTab)
	ReleaseTexture(self)
	UnRegTrigger(CASH_UPDATE_EVENT)
end

return ClsStoreList
