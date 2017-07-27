local tool = require("module/dataHandle/dataTools")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local EquipFormula = require("module/dataHandle/equipFormula")
local port_shop= require("scripts/game_config/shipyard/port_shop")
local black_market= require("scripts/game_config/shipyard/black_market_config")
local prestige_shop= require("scripts/game_config/shipyard/prestige_shop")
local ui_word = require("game_config/ui_word")
local boat_attr = require("game_config/boat/boat_attr")

local BoatData = class("BoatData")

local PORT_SHOP_GENERAL = 1
local PORT_SHOP_BLACK_MARKET = 2

local CONFIG = {
	[PORT_SHOP_GENERAL] = port_shop,
	[PORT_SHOP_BLACK_MARKET] = black_market
}
function BoatData:ctor()
	self.cur_boat_key = nil        --玩家的旗舰key
	self.ownBoats = {}             --玩家所有船
	self.boat_list = {}            --玩家key-id键值对
	self.port_goods = {}            --港口商店列表
	self.black_goods = {}           --黑市商店列表

	self.blackStore = false        --是否触发黑市
	self.remain_time = 0           --黑市倒计时时间
	self.next_fresh_need_cash = 0  --下次刷新需要的银币
	self.first_pop = true          --黑市弹框只能出现一次

	self.cur_camp = 1            --当前阵营
	self.cur_prestige = 0         --当前声望
	self.shopIds = {}             --未领的势力商店
	self.new_boat = {}   --新船列表（获得新船 还未打开船舶列表为新船）


	self.max_num_limit = 1         -- 玩家的船只上限

	self.buildingBoats = {}
	self.startBuildTime = nil
	self.buildRemainTime = nil

	self.black_shop_status = 0   ---单个港口黑市商人状态
	self.shop_list = {}    ---黑市商人的港口list
	self.all_black_shop_status = 0  ---黑市商人活动全程的状态
	self.elite_reward_boat = {}  ---精英战役获得船

	self.black_goods_buy = {} --黑市商品购买信息
	self.black_cash_goods_scale = 0 --黑市金币商品折扣

	local port_data = getGameData():getPortData()
	port_data:setEnterPortCallBack(function() 
		self:tryDispacthDarkRedPoint()
	end, true)
end

---精英战役获得船
function BoatData:setEliteRewardBoat(boat)
	self.elite_reward_boat[1] = boat 
end

function BoatData:getEliteRewardBoat(  )
	return self.elite_reward_boat
end

function BoatData:clearEliteRewardBoat()
	self.elite_reward_boat = {}
end

---判断本港口黑市商人是否开放
function BoatData:getBlackShopIsOpen()
	local portData = getGameData():getPortData()
	local port_id = portData:getPortId()

	local is_open_black_shop = false
	for k,v in pairs(self.shop_list ) do
		if v == port_id then
			is_open_black_shop = true
		end
	end 
	return is_open_black_shop   
end

---黑市商人活动全程状态
function BoatData:setAllBlackShopStatus(status)
	self.all_black_shop_status = status
end

function BoatData:getAllBlackShopStatus()
   return self.all_black_shop_status
end

---单个港口黑市商人状态
function BoatData:setBlackShopStatus(status)
	self.black_shop_status = status
end

function BoatData:getBlackShopStatus()
   return self.black_shop_status
end

function BoatData:tryDispacthDarkRedPoint(is_open)
	if is_open == nil then
		is_open = (self.all_black_shop_status == 1)
		if is_open then
			is_open = self:isInBlackPort()
		end
	elseif is_open then
		is_open = self:isInBlackPort()
	end

	local taskData = getGameData():getTaskData()
	local on_off_info = require("game_config/on_off_info")
	taskData:setTask(on_off_info["DARK_MARKET"].value, is_open)
end

function BoatData:isInBlackPort()
	local portData = getGameData():getPortData()
	local port_id = portData:getPortId()
	for k, v in ipairs(self.shop_list) do
		if v == port_id then
			return true
		end
	end
	return false
end

---黑市商人的港口list
function BoatData:setBlackShopIdList(list)
	self.shop_list = list 
end

function BoatData:getBlackShopIdList()
	return self.shop_list 
end

function BoatData:changeBlackShopIdList(old_port_id_list, new_port_id_list)
	self.shop_list = new_port_id_list
end

--拆解
function BoatData:askForDisassem(boat_key)
	GameUtil.callRpc("rpc_server_boat_disassembly", {boat_key}, "rpc_client_boat_disassembly")
end

--船舶改名
function BoatData:askForSetBoatName(boatKey, name)
	GameUtil.callRpc("rpc_server_boat_set_name", {boatKey, name}, "rpc_client_boat_set_name")
end

-- 势力商店列表
function BoatData:askPowerStoreList()
	GameUtil.callRpc("rpc_server_prestige_shop_list", {}, "rpc_client_prestige_shop_list")
end

-- 黑市商店分享给好友
function BoatData:askShareWithFriends(ids)
	GameUtil.callRpc("rpc_server_black_market_share", {ids}, "rpc_client_black_market_share")
end

--港口商店列表
function BoatData:askPortStoreList() 
	GameUtil.callRpc("rpc_server_black_market_shop",{}, "rpc_client_black_market_shop")
end

-- 港口商店购买物品
function BoatData:askBuyGood(shopId, amount)
	GameUtil.callRpc("rpc_server_port_shop_buy", {shopId, amount}, "rpc_client_port_shop_buy")
end

-- 黑市商店购买物品
function BoatData:askBuyBlackGood(portId, shopId, scale)
	GameUtil.callRpc("rpc_server_black_market_buy", { portId, shopId, scale})
end

--港口商店列表
function BoatData:askPortStoreList() 
	GameUtil.callRpc("rpc_server_port_shop_list",{}, "rpc_client_port_shop_list")
end

--请求港口/黑市
function BoatData:askOpenStore() 
	GameUtil.callRpc("rpc_server_port_shop_open",{})
end

 --请求增加船只上限
function BoatData:askAddBoatsMaxNum()       
	GameUtil.callRpc("rpc_server_boat_limit_add", {},"rpc_client_boat_limit_add")
end

--声望商店领取物品
function BoatData:askForAcceptPowerGood(shopId)
	GameUtil.callRpc("rpc_server_prestige_shop_reward", {shopId},"rpc_client_prestige_shop_reward")
end

--船舶宝物装备操作
function BoatData:boatUploadBaowu( boat_key, pos )
	GameUtil.callRpc("rpc_server_boat_upload_baowu", {boat_key, pos},"rpc_client_boat_upload_baowu")
end

--船舶宝物替换操作
function BoatData:boatChangeBaowu( boat_key, pos, baowu_id )
	GameUtil.callRpc("rpc_server_boat_change_baowu", {boat_key, pos, baowu_id},"rpc_client_boat_change_baowu")
end

function BoatData:askCreateBoat(boat_id, paper_num)
	GameUtil.callRpc("rpc_server_boat_create", {boat_id, paper_num})
end

---黑市商人通知商会成员和在线好友
function BoatData:askGuildMemberOrFriend(type_id) 
	GameUtil.callRpc("rpc_server_black_market_notify", {type_id})
end

--黑市分享跳转港口
function BoatData:gotoOtherPort(portId)
	GameUtil.callRpc("rpc_server_black_market_enter_port", {portId})
end

--当前阵营的 商品列表
function BoatData:getPowerCurList()

	local temp = {}
	for k, v in pairs(prestige_shop) do
		if v.camp == self.camp then
			-- temp[k] = v
			temp[#temp + 1] = k
		end
	end

	return temp
end

--true: 没有领取
--false: 已经领取
function BoatData:notReceived(shopId)

	for k, v in pairs(self.shopIds) do
		if v == shopId then
			return true
		end
	end

	return false
end

function BoatData:getCurPrestige()
	return self.cur_prestige
end

function BoatData:getCamp()
	return self.camp
end

function BoatData:getShopIds()
	return self.shopIds
end

---黑市商品购买
function BoatData:setBlackShopGoodsBuy(list)
	self.black_goods_buy = list 
end

function BoatData:getBlackShopGoodsBuy()
	return self.black_goods_buy  
end
--黑市金币商品折扣
function BoatData:setBlackCashGoodsScale(scale)
	self.black_cash_goods_scale = scale
end

function BoatData:getBlackCashGoodsScale()
	return self.black_cash_goods_scale/10
end
--黑市商人列表
function BoatData:setBlackShopList(datas, remain_time)

	self.black_goods = datas
	self.remain_time = remain_time

	local ui = getUIManager():get('ClsStoreList')
	if not tolua.isnull(ui) then
		ui:updateBlackStore()
	end
end

function BoatData:soldOut(shop_id, amount)
	self:askOpenStore()
end

function BoatData:getBlackShopList()
	return self.black_goods
end

--港口商品列表
function BoatData:setPortShopList(datas)
	self.port_goods = {}
	for k, v in pairs(datas) do
		self.port_goods[#self.port_goods + 1] = v
	end

	local ui = getUIManager():get('ClsStoreList')
	if not tolua.isnull(ui) then
		ui:updatePortStore()
	end
end

function BoatData:getPortGoods()
	return self.port_goods
end

function BoatData:getRemainTime()
	return self.remain_time
end

function BoatData:isBlackStore()
	return self.blackStore
end

function BoatData:setMaxNumLimit(max_num)
	self.max_num_limit = max_num
end

function BoatData:getMaxNumLimit()
	return self.max_num_limit
end
 -- 获取船舶的战斗力
function BoatData:getBoatFightValue(boat)
	local fightValue = EquipFormula:getPower(boat.fireClose, boat.fireFar, boat.ship_defense, boat.armor, boat.speed)
	return math.floor(fightValue + 0.5)
end

function BoatData:getBoatIdFromKey(key)
	return self.boat_list[key]
end

-- 接收旗舰key
function BoatData:receiveBoat(key)
	if not key then
		cclog("receive boat error, key is null")
		return
	end
	self.cur_boat_key = key
end

function BoatData:getKeyOfFlagShip()
	return self.cur_boat_key
end

function BoatData:receiveOwnBoats(list)
	for k, v in ipairs(list) do
		self:addToOwnBoats(v)
	end
	-- table.print(self.ownBoats)
	table.sort(self.ownBoats, function(a, b)
		return a.boat_type < b.boat_type
	end)
end

function BoatData:addToOwnBoats(boat)
	self.boat_list[boat.boat_key] = boat.boat_type
	if boat.rename == 0 then--未改过名字，所以用翻译名
		boat.name = boat_attr[boat.boat_type].name
	end
	self.ownBoats[boat.boat_key] = boat
end

--判断是否是新船
function BoatData:setNewBoat(boat)
	if not self.ownBoats[boat.boat_key] then
		self.new_boat[boat.boat_key] = boat
	end
end

--当玩家第一次打开列表后把新船从列表中删除
function BoatData:setBoatNotNew(boat_key)
	self.new_boat[boat_key] = nil
end

function BoatData:getNewBoatList()
	return self.new_boat
end

function BoatData:getOwnBoats()
	return self.ownBoats
end

function BoatData:getBoatDataByKey(key)
	if not self.ownBoats then return end
	return self.ownBoats[key]
end

function BoatData:judgeHasBoatByKey(key)
	return self.ownBoats[key]
end

function BoatData:isOldBoat(key)
	local boats_num = 0

	for k, v in pairs(self.ownBoats) do
		boats_num = boats_num + 1
	end

	if boats_num > 0 then
		return self.ownBoats[key]
	end
	return true
end

function BoatData:setBoatName(key, name)

	if self.ownBoats[key] then
		self.ownBoats[key].name = name
		return
	end
	cclog("set boat name fail:the boat is not exist!!!")
end

function BoatData:getBoatName(key)
	local key = key or self.cur_boat_key

	local boat = self.ownBoats[key]
	if boat then
		return boat.name or tool:getBoat(boat.boat_type).name
	end
	return ""
end

function BoatData:getPlayerBoatName(key)
	local key = key or self.cur_boat_key

	local boat = self.ownBoats[key]
	if boat then
		return boat.name or tool:getBoat(boat.boat_type).name
	end

	return ""
end

---------------------------------------------------------------------------------------

function BoatData:delBoat(boatKey)
	self.boat_list[boatKey] = nil

	self.ownBoats[boatKey] = nil
end

---------------------------------------------------------------------------------------

function BoatData:getBulletRes(id)
	if not id and id == 0 then return end
	local boat_info = require("game_config/boat/boat_info")
	local bullet_res_id
	if boat_info[id] then
		bullet_res_id = boat_info[id].fire_res
	end
	if not bullet_res_id or bullet_res_id == "" then
		bullet_res_id = 1
	end

	return bullet_res_id
end


--------------------除了服务端的基本船舶数据，还需要的船舶数据--------------------end

function BoatData:isBaoWuEquiped( baowu_id )
	for k,v in pairs(self.ownBoats) do
		if v.baowus then
			for i,key in ipairs(v.baowus) do
				if key == baowu_id then
					return v
				end
			end
		end
	end
	return nil
end

return BoatData
