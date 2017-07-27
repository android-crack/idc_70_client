local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local goods_info=require("game_config/port/goods_info")
local port_goods_info=require("game_config/port/port_goods_info")
local goods_type_info=require('game_config/port/goods_type_info')
local compositeEffect = require("gameobj/composite_effect")
local music_info = require("scripts/game_config/music_info")
local tool=require("module/dataHandle/dataTools")
local ui_word=require("game_config/ui_word")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsPortMarketQuene = require("gameobj/quene/clsPortMarketQuene")

local scheduler=CCDirector:sharedDirector():getScheduler()
--rpc_server_port_goods_type(portId)
function rpc_client_port_goods_type(portId,ids)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:receiveNeedGoodType(portId,ids,true)
	--[[marketData:receiveNeedGoodType(portId,ids)
	exploreData:receivePortNeedGood(portId,ids)]]
end

-- class port_goods_type_t {
--     int portId;
--     int* types;
-- }
function rpc_client_all_port_goods_type(good_type_infos)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:clearNeedGood()
	for k,v in ipairs(good_type_infos) do
		mapAttrs:receiveNeedGoodType(v.portId,v.types)
	end
end

--function rpc_client_boat_goods_info(boatId,goodsList)  --货仓
--[[
class new_boat_goods_t {
	int index;
	// 显示船只类型
	int boat_type;
	// 最大载重
	int load;
	// 货物ID
	int good_id;
	// 货物类型
	// 区域特产,普通商品,港口特产
	int type;
	// 是否热销
	int is_hot;
	// 购买的基准价格
	int base_price;
	// 价格
	int price;
	// 数量
	int amount;
	// 是否能出售
	int can_sell
}
]]--
function rpc_client_boat_goods_info(boxes)
	local marketData = getGameData():getMarketData()
	marketData:receiveCargo(boxes)
end
--[[
25 class port_goods_t {
26         int goodsId;
27         int amount;
28         int type;
29         int price;
30         int basePrice;
31 }
]]--
function rpc_client_port_goods_list(portId, goodsList, invest_step)  --商店
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:receiveHotPortGoodsList(portId,goodsList)

	local portData = getGameData():getPortData()
	-- local boolValue=(portId==portData:getPortId())
	-- if boolValue then
	local marketData = getGameData():getMarketData()
	marketData:receiveStoreGoods(goodsList, invest_step, portId)
	-- end
end
--[[
--3 class goods_t {
--4         int id;
--5         int amount;
--6 }
--7
--8 class business_t {
--9         int boatId;
--10         goods_t* goods;
--11 }
]]
--rpc_server_business_buy_goods(object oUser, int port, business_t* buy);
function rpc_client_business_buy_goods(result,err)
	if result ==1 then
		local marketData = getGameData():getMarketData()
		marketData:receiveBuyResult()
		local timer=nil
		timer=scheduler:scheduleScriptFunc(function()
			scheduler:unscheduleScriptEntry(timer)
			timer=nil
		end,1,false)
		Alert:warning({msg = news.PORT_MARKET_SUCCESS.msg,tag="PORT_MARKET_SUCCESS",size = 26})
	else
		Alert:warning({msg =error_info[err].message,tag="PORT_MARKET_FAIL", size = 26})
	end
end
--rpc_server_business_sell_goods(object oUser, int port, business_t* sell);
function rpc_client_business_sell_goods(result,err)
	if result ==1 then
		local marketData = getGameData():getMarketData()
		marketData:receiveSellResult()
		local timer=nil
		timer=scheduler:scheduleScriptFunc(function()
			scheduler:unscheduleScriptEntry(timer)
			timer=nil
		end,1,false)
		Alert:warning({msg = news.PORT_MARKET_SOLD.msg,tag="PORT_MARKET_SOLD", size = 26})
	else
		Alert:warning({msg =error_info[err].message,tag="PORT_MARKET_FAIL", size = 26})
	end
end

--修改后的买卖
function rpc_client_boat_goods_sell_and_buy(result,error,rewards,profit_info,is_auto)
	if result == 1 then
		local marketData = getGameData():getMarketData()
		marketData:receiveBuyResult()

		if #rewards > 0 then
			local function call_back()
				local rewards_tab = {}
				for i=1,#rewards do
					table.insert(rewards_tab,{key = rewards[i].type,value = tonumber(rewards[i].amount),id = rewards[i].id})
				end
				Alert:showCommonReward(rewards_tab)
			end

			if is_auto == 0 then ----非自动经商
				local is_pay_off = false
				for k,v in pairs(rewards) do
				   if v.type == ITEM_INDEX_CASH then
						is_pay_off = true
				   end
				end

				if is_pay_off then
					--ClsDialogSequene:insertTaskToQuene(ClsPortMarketQuene.new({reward= rewards, profit_info = profit_info, call_back = call_back}))
					getUIManager():create("gameobj/port/clsPortMarketAccountView", {}, rewards, profit_info, call_back)

					return
				end
			else
				local port_market_ui = getUIManager():get("ClsPortMarket")
				if not tolua.isnull(port_market_ui) then
					port_market_ui:closeMySelf()
				end
			end
			call_back()
		else
			Alert:warning({msg = news.PORT_MARKET_SUCCESS.msg,tag="PORT_MARKET_SUCCESS", size = 26})
			local port_market_ui = getUIManager():get("ClsPortMarket")
			if not tolua.isnull(port_market_ui) then
				port_market_ui:checkUIClose()
			end
		end
	else
		Alert:warning({msg =error_info[error].message,tag="PORT_MARKET_FAIL", size = 26})
		local port_market_ui = getUIManager():get("ClsPortMarket")
		if not tolua.isnull(port_market_ui) then
			port_market_ui:closeMySelf()
		end
	end
end

local function get_msg(goodsId, news_msg)
	if goods_info[goodsId] then
		return string.format(news_msg, goods_info[goodsId].name)
	else
		return ""
	end
end

-- class port_goods_info_t {
--     int portId;
--     int investStep;
--     port_goods_t* list;
-- }
-- class port_goods_t {
--     int goodsId;
--     int amount;
--     int max;
--     int type;
--     int price;
--     int basePrice;
-- }
function rpc_client_select_port_goods_list(port_good_infos)
	local marketData = getGameData():getMarketData()
	marketData:receivePortGoodInfos(port_good_infos)
end

----弹出对话框，提示热销物品获得
function rpc_client_port_hotsell_tips(goods_id, production)
	local marketData = getGameData():getMarketData()
	marketData:showMarketHotDialog(goods_id, production)
end

----弹出对话框，提示热销物品获得
function rpc_client_port_hot_sell_share(err)
	if err > 0 then
		if err == 235 then --提示商会不存在的
			Alert:showAttention(news.PORT_MARKET_NO_GUILD.msg, function()
				-- local clsGuildMainUI = require("ui/clsGuildMainUI")
				local port_layer = getUIManager():get("ClsPortLayer")
				if not tolua.isnull(port_layer) then
					-- port_layer:addItem(clsGuildMainUI.new())
					getUIManager():create("ui/clsGuildMainUI")
				end
			end, nil, nil, {ok_text = ui_word.STR_GUILD_APPLY_BTN_NAME, hide_cancel_btn = true})
		else
			Alert:warning({msg = error_info[err].message, size = 26})
		end
	end
end

----------------------------------自动委任经商---------------------------------------------
-- 请求开始自动委任经商
function rpc_client_business_auto_online_start(result, error)

	local auto_trade_ui = getUIManager():get("ClsAppointTradeUI")
	if not tolua.isnull(auto_trade_ui) then
		auto_trade_ui:setTouch(true)
	end
	if result == 1 then
		local auto_trade_data = getGameData():getAutoTradeAIHandler()
		if not tolua.isnull(auto_trade_ui) then
			auto_trade_ui:closeView(function()
				auto_trade_data:startTradeAI()
			end)
		else
			auto_trade_data:startTradeAI()
		end
		local player_data = getGameData():getPlayerData()
		local role_id = player_data:getRoleId()
		local role_info = require("game_config/role/role_info")
		local role_config = role_info[role_id]
		local voice_info = getLangVoiceInfo()
		if role_config.sex == 1 then
			audioExt.playEffect(voice_info.VOICE_PLOT_1020.res)
		else
			audioExt.playEffect(voice_info.VOICE_PLOT_1021.res)
		end
	-- elseif result == 2 then --队员状态
	--     local auto_trade_data = getGameData():getAutoTradeAIHandler()
	--     auto_trade_data:showAIMaskLayer()
	else
		if(error == 41)then
			Alert:showJumpWindow(POWER_NOT_ENOUGH, nil, {ignore_sea = false})
		elseif error > 0 then
			Alert:warning({msg =error_info[error].message, size = 26})
		end
	end
end

-- 查看委任经商信息数据
-- class business_auto_online_info_t {
--  44         int status;
--  45         int remainTimes;
--  46         int remainTime;
--  47 }
function rpc_client_business_auto_online_info(info)
	local auto_trade_handler = getGameData():getAutoTradeAIHandler()
	auto_trade_handler:setTradeData(info)
end

--主动下发自动委任经商状态
function rpc_client_business_auto_online_status(info)
	local auto_trade_handler = getGameData():getAutoTradeAIHandler()
	auto_trade_handler:setTradeData(info)
end

--停止自动委任经商状态
function rpc_client_business_auto_online_stop(info)
	local auto_trade_handler = getGameData():getAutoTradeAIHandler()
	auto_trade_handler:setTradeData(info)

	getUIManager():close("ClsChatComponent")
	local port_layer = getUIManager():get("ClsPortLayer")
	local explore_ui = getUIManager():get("ExploreUI")
	if not tolua.isnull(port_layer) then
		port_layer:createChatComponent()
	elseif not tolua.isnull(explore_ui) then
		explore_ui:createChatComponent()
	end
end

--主动下发自动委任经商状态
function rpc_client_business_auto_online_buy(result, error, cur_times)
	if result == 1 then
		local auto_trade_data = getGameData():getAutoTradeAIHandler()
		auto_trade_data:updateTradeData(cur_times)
	else
	   Alert:warning({msg = error_info[error].message, size = 26})
	end
end

--自动经商下发奖励
function rpc_client_business_auto_online_profit(rewards)
	local ClsialogQuene = require("gameobj/quene/clsDialogQuene")
	local ClsAutoTradeRewardQuene = require("gameobj/quene/clsAutoTradeRewardQuene")
	ClsialogQuene:insertTaskToQuene(ClsAutoTradeRewardQuene.new(rewards))
end


--队长请求了开启组队经商后之后
function rpc_client_auto_business_team_ask(is_leader)
	local WAIT_TIME = 5
	local tips_str = ui_word.AUTI_TRADE_TEAM_INVEST_TIPS
	if is_leader == 1 then
		tips_str = ui_word.AUTI_TRADE_TEAM_INVEST_TIPS_LEADER
		Alert:showBayInvite(nil, nil, nil, nil, nil, WAIT_TIME, nil, nil, nil, nil, nil, tips_str)
		return
	end
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	Alert:showBayInvite(nil, function()
		auto_trade_data:teamTradeInviteResponse(1)    
		end, function()
			auto_trade_data:teamTradeInviteResponse(2)    
	end, function() auto_trade_data:teamTradeInviteResponse(1) end, nil, WAIT_TIME, tips_str, nil, nil, nil, nil, ui_word.AUTI_TRADE_TEAM_INVEST_TIPS_LEADER)
end

function rpc_client_auto_business_delete_ask()
	getUIManager():close("AlertShowBayInvite")
end

-------------------------------------------------------------------------------------------

