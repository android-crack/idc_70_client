-- TODO 数据对象化， 公会数据比较乱，分布不同文件， 整理
local element_mgr = require("base/element_mgr")
-- 公会商店等级限制
local UNLOCKLIMIT = {[6] = 10, [7] = 20, [8] = 30, [9] = 40, [10] = 50, [11] = 60, [12] = 60}
local GuildShopData = class("GuildShopData")
local REASON_INDEX_LIMIT = 100 --100以上是个人礼包
function GuildShopData:ctor()
	self.shop_list = {}
	self.gift_list = {}
	self.contribute = 0

	--礼包的状态nil表示没有抢到改红包，2表示抢到过改红包，1表示抢到了该红包
	-- GIFT_GET = 1
	-- GIFT_GETTED = 2
	self.gift_status = {}
end

function GuildShopData:getGiftStatus(gift_id)
	if not gift_id then cclog("查询的礼包ID为空") return end
	return self.gift_status[gift_id]
end

function GuildShopData:setGiftStatus(gift_id, status)
	self.gift_status[gift_id] = status
end

function GuildShopData:setGiftList(list)
	if not list then return end

	local player_data = getGameData():getPlayerData()
	local player_id = player_data:getUid()

	for k, v in ipairs(list) do
		for i, j in pairs(v.rewardlist) do
			if j.uid == player_id then
				self.gift_status[v.giftId] = GIFT_GETTED
			end
		end
	end

	self.gift_list = list

	local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(guild_shop_ui) then
		local guild_shop_gift_ui = guild_shop_ui:getGuildGiftUI()
		if not tolua.isnull(guild_shop_gift_ui) then
			guild_shop_gift_ui:updateView()
		end
	end
end

function GuildShopData:cleanGiftData()
	self.gift_list = {}
end

function GuildShopData:deleteGiftByGiftId(id)
	for k, v in ipairs(self.gift_list) do
		if v.giftId == id then
			table.remove(self.gift_list, k)
			break
		end
	end
end

function GuildShopData:updateGift(info)
	for k, v in ipairs(self.gift_list) do
		if v.giftId == info.giftId then
			self.gift_list[k] = info
		end
	end

	local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(guild_shop_ui) then
		local guild_shop_gift_ui = guild_shop_ui:getGuildGiftUI()
		if not tolua.isnull(guild_shop_gift_ui) then
			guild_shop_gift_ui:updateListViewCell(info)
		end
	end
end

function GuildShopData:getAllGift()
	return self.gift_list or {}
end

function GuildShopData:getGiftById(gift_id)
	for k, v in ipairs(self.gift_list) do
		if v.giftId == gift_id then
			return v
		end
	end
end

function GuildShopData:getMyGift()
	local my_gift_list = {}
	local player_data = getGameData():getPlayerData()
	local player_id = player_data:getUid()
	for k, v in ipairs(self.gift_list) do
		if v.owner == player_id and v.reason > REASON_INDEX_LIMIT then
			table.insert(my_gift_list, v)
		end
	end
	return my_gift_list
end

--商品列表
function GuildShopData:receiveShopList(list)
	self.shop_list = list
	
	local UI = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(UI) then 
		UI:updateList(self.shop_list)
	end 
end 

function GuildShopData:getShopList()
	return self.shop_list
end 

function GuildShopData:getContribute()
	return self.contribute
end 

-- 更新贡献值
function GuildShopData:receiveContribute(value)
	self.contribute = value
	local UI = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(UI) then 
		UI:updateContribute(self.contribute)
	end 
end 

-- 获取格子的开锁的等级限制
function GuildShopData:getUnlockLimit(position)
	local grade = UNLOCKLIMIT[position]
	return grade
end

function GuildShopData:setShopGiftData( status, war_reward, gifts )
	self.war_reward = war_reward
	self.gifts = gifts
	local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(guild_shop_ui) then 
		guild_shop_ui:updateGiftInfo( gifts ) 
	end
end

function GuildShopData:removeGiftData( index )
	table.remove(self.gifts, index)
	local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
	if not tolua.isnull(guild_shop_ui) then 
		guild_shop_ui:updateGiftInfo(self.gifts) 
	end
end

function GuildShopData:buyShop(shop_id, amount)
	GameUtil.callRpc("rpc_server_guild_shop_buy", {shop_id, amount}, "rpc_client_guild_shop_buy") 
end 

--领取礼包奖励
function GuildShopData:askGetGift(uid)
	GameUtil.callRpc("rpc_server_group_get_gifts", {uid},"rpc_client_group_get_gifts")
end

function GuildShopData:askShopList()
	GameUtil.callRpc("rpc_server_guild_shop_list", {}, "rpc_client_guild_shop_list")
end 

--请求商会礼包信息
function GuildShopData:askGuildGifInfo()
	GameUtil.callRpc("rpc_server_group_gift_info", {})
end

--发放礼包
function GuildShopData:askGiveOutGuildGif(id)
	GameUtil.callRpc("rpc_server_open_group_gift", {id})
end

--抢礼包
function GuildShopData:askGrabGuildGif(id)
	GameUtil.callRpc("rpc_server_grab_group_gift", {tonumber(id)})
end

return GuildShopData