local Alert = require("ui/tools/alert")
local error_info=require("game_config/error_info")
local ui_word = require("game_config/ui_word")

function rpc_client_shop_quick_complete(result,err, index, key, kind)
	local shopData = getGameData():getShopData()
	shopData:receiveQuickCompleteResult(result, err, index, key, kind)
end

function rpc_client_shop_buy(error)
    local shopData = getGameData():getShopData()
    if error == 0 then
        local exploreLayer = getUIManager():get("ExploreLayer")
        if not tolua.isnull(exploreLayer) then --探索pve，购买体力成功提示
            Alert:alertBuyResult() --这个提示是固定了 ，60点体力
            shopData:callBuyItemCb(result)
            return 
        end
    else
  	    Alert:warning({msg =error_info[error].message, size = 26})
    end
    shopData:callBuyItemCb(result)
end

function rpc_client_shop_list(datas)
	local shopData = getGameData():getShopData()
	shopData:receiveShopList(datas)
end 

function rpc_client_shop_item(data)
    local shopData = getGameData():getShopData()
    shopData:receiveShopInfo(data)
end 

function rpc_client_shop_discount_list(good_list)
    local shop_data = getGameData():getShopData()
    shop_data:updateLimitsInfo(good_list)
end

function rpc_client_shop_discount_info(good_item)
    local shop_data = getGameData():getShopData()
    shop_data:updateLimitInfo(good_item)
    local mall_main = getUIManager():get("ClsMallMain")
    if not tolua.isnull(mall_main) then
        mall_main:updateView()
    end
end


----商城购买物品成功
function rpc_client_shop_buy_reward(rewards)
    if rewards then
        local Alert = require("ui/tools/alert")
        Alert:showCommonReward(rewards)
    end    
end

--请求创建订单返回
function rpc_client_payment_create(code, info)
    -- if code == 0 then--订单成功，开始拉起支付
    local module_game_sdk = require("module/sdk/gameSdk")
    module_game_sdk.pay(code, info)
end

function rpc_client_shop_daily_info(info)
   
    local shop_data = getGameData():getShopData()
    shop_data:setGiftData(info)
    local daily_gift = getUIManager():get("ClsDailyGift")
    if not tolua.isnull(daily_gift) then
        daily_gift:updateView()
    end
end

-- function rpc_client_shop_daily_get(item_id)
--     local rewards = {
--        {key = ITEM_INDEX_PROP,
--        id = item_id,
--        amount = 1,}
--     }
--     Alert:showCommonReward(rewards)
-- end