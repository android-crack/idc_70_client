local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local mall_info = require("game_config/shop/mall_info")

local shopData = class("shopData")

function shopData:ctor()
	self.shopList = {}
	self.askBuyShopItemCb = nil
	self.receiveListCb = nil --获得列表的刷新callback
	self:initLimitGoodsInfo()
	self:initNormolGoodsInfo()
	self:initDiamondGoodsInfo()
end

--快速完成    index 加速的类型  id 对应的东西id  kind  金币 还是银币
function shopData:askQuickComplete(index, id, kind)
	if type(id)=="number" then 
		id = tostring(id)
	end
	GameUtil.callRpc("rpc_server_shop_quick_complete", {index,id,kind},"rpc_client_shop_quick_complete")
end

function shopData:askBuyShopItem(good_id, count, callBack)
	if not good_id then
		return
	end
	self.askBuyShopItemCb = callBack
	GameUtil.callRpc("rpc_server_shop_buy",{good_id, count}, "rpc_client_shop_buy")
end

function shopData:askShopList(callBack)
	self.receiveListCb = callBack
	GameUtil.callRpc("rpc_server_shop_list", {}, "rpc_client_shop_list")
end

function shopData:receiveQuickCompleteResult(result, err, index, key, kind)
	local lootDataHandle = getGameData():getLootData()
	if result == 0 then
		if err == 13 then -- [todo]:13...非具名变量，携带的银币不足
			Alert:showJumpWindow(CASH_NOT_ENOUGH)
		elseif err == 3 then
			Alert:showJumpWindow(DIAMOND_NOT_ENOUGH)
		end	
		return
	else
		if index == 4 then -- 清除掠夺CD
			lootDataHandle:SetLootBattleCD(0)
		end
	end
end

function shopData:receiveShopList(datas)
	for k, v in pairs(datas) do
		self.shopList[v.shop_id] = v
	end

	local shop_main_ui = getUIManager():get("ShopMainUI")
	if not tolua.isnull(shop_main_ui) then 
		shop_main_ui:updateView() 
	end

	if self.receiveListCb then
		self.receiveListCb()
		self.receiveListCb = nil
	end
end

function shopData:getNearestShopItem(item_type, id)
	local temp = {}
	--先看可不可以买优惠的
	local limit_goods = self:getLimitGoodsInfo()
	for i,v in ipairs(limit_goods) do
		if item_type == v.goods_type and ((not id) or (id == v.goods_id)) and v.discount_count > 0 then
			temp.num = v.goods_amount --数量
			if item_type == "cash" then  --金币的数量随着等级变化
				local level = getGameData():getPlayerData():getLevel()
				local one_diamand_to_gold = getGameData():getShopData():getOneGoldCount(level)
				local all_gold = one_diamand_to_gold * v.price
				temp.num = all_gold
			end
			local time = #v.discount - v.discount_count + 1
			temp.discount = v.discount[time] / 10
			temp.shop_id = v.id
			temp.value = v.price * temp.discount / 10
			
			return temp
		end
	end

	local normol_good = self:getNormolGoodsInfo()
	for i,v in ipairs(normol_good) do
		if item_type == v.goods_type and ((not id) or (id == v.goods_id)) then
			temp.num = v.goods_amount --数量
			if item_type == "cash" then  --金币的数量随着等级变化
				local level = getGameData():getPlayerData():getLevel()
				local one_diamand_to_gold = self:getOneGoldCount(level)
				local all_gold = one_diamand_to_gold * v.price
				temp.num = all_gold
			end
			local time = #v.discount - v.discount_count + 1
			temp.shop_id = v.id
			temp.value = v.price
			
			return temp
		end
	end
end

--一份金币的数量
function shopData:getOneGoldCount(level)

	return Math.round(math.pow(1.5, (level/10))*6.6) * 200
end

function shopData:receiveShopInfo(data)
	self.shopList[data.shop_id] = data

	local shop_main_ui = getUIManager():get("ShopMainUI")
	if not tolua.isnull(shop_main_ui) then 
		shop_main_ui:updateCellView(data.shop_id) 
	end
end

function shopData:getDataById(shopId)
	return self.shopList[shopId]
end

function shopData:callBuyItemCb(result)
	if self.askBuyShopItemCb ~= nil then
		self.askBuyShopItemCb(result)
		self.askBuyShopItemCb = nil
	end
end


function shopData:updateLimitsInfo(limits_info)
	self:initLimitGoodsInfo()
	for i,v in ipairs(limits_info) do
		self:updateLimitInfo(v)
	end
end

function shopData:updateLimitInfo(limit_info)

	for i,v in ipairs(self.limit_goods_info) do 
		if v.id == limit_info.shopId then
			local discount_count = mall_info[v.id].discount_count
			v.discount_count = tonumber(discount_count) - tonumber(limit_info.times)
		end
	end

	for i,v in ipairs(self.diamand_goods_info) do
		if v.id == limit_info.shopId then
			v.has_charge = tonumber(limit_info.has_charge)
		end
	end
end
local function selectGoods(good_table, good_type)
	for i,v in ipairs(mall_info) do
		if v.type == good_type then
			v.id = i
			good_table[#good_table + 1] = table.clone(v)
		end
	end
	table.sort(good_table, function(a, b)
		return a.sort < b.sort
	end)
end

--初始化优惠信息
function shopData:initLimitGoodsInfo()
	self.limit_goods_info = {}
	selectGoods(self.limit_goods_info, 1)
	
end


function shopData:initNormolGoodsInfo()
	self.normol_goods_info = {}
	selectGoods(self.normol_goods_info, 2)
	
end

function shopData:initDiamondGoodsInfo()
	self.diamand_goods_info = {}
	selectGoods(self.diamand_goods_info, 3)
end

function shopData:getDiamondGoodsInfo()
	local tab = {}
	local player_data = getGameData():getPlayerData()
	local level = player_data:getLevel()
	for i,v in ipairs(self.diamand_goods_info) do
		if v.is_sell == 1 and level >= v.open_level then
			tab[#tab + 1] = v
		end
	end
	return tab
end

function shopData:getNormolGoodsInfo()
	local tab = {}
	local player_data = getGameData():getPlayerData()
	local level = player_data:getLevel()
	for i,v in ipairs(self.normol_goods_info) do
		if v.is_sell == 1 and level >= v.open_level then
			tab[#tab + 1] = v
		end
	end
	return tab
end

function shopData:getLimitGoodsInfo()
	local tab = {}
	local player_data = getGameData():getPlayerData()
	local level = player_data:getLevel()
	for i,v in ipairs(self.limit_goods_info) do
		if v.is_sell == 1 and level >= v.open_level then
			tab[#tab + 1] = v
		end
	end
	return tab
end

function shopData:payGood(shop_id)
	local product_key = mall_info[shop_id].productId
	print("product_key=", product_key)
	local module_game_sdk = require("module/sdk/gameSdk")
    module_game_sdk.beginPay(product_key)
end


----------------------礼包数据------------------------

function shopData:getGiftData()
	return self.gitf_info
end

function shopData:isBuyAllGift()
	
	if not self.gitf_info then return false end
	
	for k,v in pairs(self.gitf_info) do
		if v == 0 then
			return false
		end
	end
	return true
end

function shopData:setGiftData(gift_info)
	self.gitf_info = gift_info
end

return shopData





