--[[3 class item_t {
  4         int id;
  5         int amount;
  6 }
  7 
  8 void rpc_server_items(object oUser);
  9 void rpc_client_items(int uid, item_t* list);
 13 
 14 void rpc_client_item_add(int uid, int itemId, int amount);
 15 void rpc_client_item_del(int uid, int itemId, int amount);]]
--道具的协议
local ClsAlert = require("ui/tools/alert")
local error_info=require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local item_info = require("game_config/propItem/item_info")

function rpc_client_items(itemList)
	local propDataHandle = getGameData():getPropDataHandler()
	propDataHandle:set_propItem_list(itemList)
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_COMSUME)
end

function rpc_client_item_add(itemId, amount)
	local propDataHandle = getGameData():getPropDataHandler()
	propDataHandle:add_propItem(itemId, amount)
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_COMSUME)
	EventTrigger(ITEM_UPDATE_EVENT)
end

function rpc_client_item_del(itemId, amount)
	local propDataHandle = getGameData():getPropDataHandler()
	propDataHandle:del_propItem_by_id(itemId, amount)
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_COMSUME)

	-- local view = element_mgr:get_element("SailorUpgradeView")
	-- if view then
	-- 	view:updatePropItemNums()
	-- end

	local backpack_item_tips = getUIManager():get("ClsBackpackItemTips")
	if not tolua.isnull(backpack_item_tips) then
		backpack_item_tips:updateTipsItemNums(itemId, amount)
	end
end

local function alertSellGetReward(sell_get, item_id, amount)
	local reward = {}
	for k,v in pairs(sell_get) do
		local rewardItem = {}
		rewardItem.key = ITEM_TYPE_MAP[k]
		-- rewardItem.id = reward.id
	    rewardItem.value = v * amount
	    reward[#reward + 1] = rewardItem
	end
	ClsAlert:showCommonReward(reward)
end

function rpc_client_item_sell(item_id, amount, result, error)
	if result == 1 then
		local sell_get = item_info[item_id].sell_get
		alertSellGetReward(sell_get, item_id, amount)

		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo(BAG_PROP_TYPE_COMSUME)
		end
	else
		ClsAlert:warning({msg = error_info[error].message, size = 26})
	end
end

-- function rpc_client_boat_sell_material(item_id, amount, err)
-- 	if err == 0 then
-- 		local sell_get = equip_material_info[item_id].sell_get
-- 		alertSellGetReward(sell_get, item_id, amount)

-- 		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
-- 		if not tolua.isnull(backpack_ui) then
-- 			backpack_ui:refreshBackpackInfo(BAG_PROP_TYPE_ASSEMB)
-- 		end
-- 	else
-- 		ClsAlert:warning({msg = error_info[err].message, size = 26})
-- 	end
-- end

function rpc_client_cangbaotu_cnt( itemId, count )
	local propDataHandle = getGameData():getPropDataHandler()
	propDataHandle:setTreasureItem(itemId, count)
end

--接近藏宝图后的回调
function rpc_client_treasure_arrive_destination(error_n,rewards)
	if error_n == 0 then

		local TreasureMapLayer = getUIManager():get("TreasureMapLayer")
		if not tolua.isnull(TreasureMapLayer) then
			TreasureMapLayer:close()
		end

		local  treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
		local treasure_map_id = 80 
		if treasure_info.treasure_id == treasure_map_id then
			ClsAlert:showCommonReward(rewards)			
		end

	    local list = {treasure_id = 0, mapId = 0, positionId = 0, time = 0}
	    getGameData():getPropDataHandler():setTreasureInfo(list)
	    getGameData():getExploreData():setAutoPos(nil)
		local ExploreUI = getUIManager():get("ExploreUI")
		if not tolua.isnull(ExploreUI) then
			ExploreUI:updateTreasureBtn()
		end
	    
	else
		ClsAlert:warning({msg = error_info[error_n].message, size = 26})
	end
end