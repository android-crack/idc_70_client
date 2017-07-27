local Alert = require("ui/tools/alert")
local error_info=require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local voice_info = getLangVoiceInfo()
local music_info=require("game_config/music_info")

---------------------------------新船只下发协议-------------------------------------------------
local MERERIAL_NOT_ENOUGH = 101
local CASH_NOT_ENOUGH = 13

----精英战役获得船只
function rpc_client_elite_got_boat(boat)
	local boatData = getGameData():getBoatData()
	boatData:setEliteRewardBoat(boat)
end

function rpc_client_all_boat_info(list)
	local boatData = getGameData():getBoatData()
	boatData:receiveOwnBoats(list)
end

function rpc_client_boat_limit_amount(max_num)
	local boatData = getGameData():getBoatData()
	boatData:setMaxNumLimit(max_num)
end

function rpc_client_boat_limit_add(errno)
	if errno == 0 then
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

--触发黑市商人
function rpc_client_black_market_trigger()
end

--黑市
function rpc_client_black_market_shop(shop_list,time)
	local boatData = getGameData():getBoatData()
	boatData:setBlackShopList(shop_list,time)	
end

---黑市商品购买信息
function rpc_client_black_market_port_buy_log(list,scale)
	--print("=================黑市商品购买信息==")
	--table.print(list)

	local boatData = getGameData():getBoatData()
	boatData:setBlackShopGoodsBuy(list)
	boatData:setBlackCashGoodsScale(scale)

	local ui = getUIManager():get('ClsStoreList')
	if not tolua.isnull(ui) then
		ui:updateBlackStore()
	end
end

--港口
function rpc_client_port_shop_list(datas)
	local boatData = getGameData():getBoatData()
	boatData:setPortShopList(datas)
end

---黑市商店开启
function rpc_client_black_market_open(portIds,time)
	local boatData = getGameData():getBoatData()
	boatData:setBlackShopIdList(portIds)
	local open_status = 1
	--boatData:setBlackShopStatus(open_status)		
	boatData:setAllBlackShopStatus(open_status)	
end

---黑市商店变化
function rpc_client_black_market_change(portIds,to_portIds)
	local portData = getGameData():getPortData()
	local port_id = portData:getPortId()
	local boatData = getGameData():getBoatData()
	boatData:changeBlackShopIdList(portIds,to_portIds)
end

---黑市商店结束
function  rpc_client_black_market_end()
	local boatData = getGameData():getBoatData()
	local close_status = 0
	--boatData:setBlackShopStatus(close_status)
	boatData:setAllBlackShopStatus(close_status)
	boatData:tryDispacthDarkRedPoint()
end

--result, errno, shop_id, amount
function rpc_client_black_market_buy(result,error, portId, id, entry)
	local ui = getUIManager():get('ClsStoreList')
	local boatData = getGameData():getBoatData()
	boatData:soldOut()
	if result ~= 1 then
		Alert:warning({msg = error_info[error].message, size = 26})
		return
	end
	--播放特效
	if not tolua.isnull(ui) then
		local buy_amount =  1
		ui:buySuccess(id, buy_amount, true)
	end
end

--单个港口商品
function rpc_client_port_shop_buy(result, errno, shop_id, amount)
	local ui = getUIManager():get('ClsStoreList')
	if result ~= 1 then
		Alert:warning({msg = error_info[errno].message, size = 26})

		if not tolua.isnull(ui) then
			--ui:setTouch(true)
		end

		return
	end

	--播放特效
	if not tolua.isnull(ui) then
		ui:buySuccess(shop_id, amount)
	end

	local boatData = getGameData():getBoatData()
	boatData:askOpenStore()

end

--黑市商店分享给好友
function rpc_client_black_market_share(errno)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

--势力商店领奖
function rpc_client_prestige_shop_reward(errno, shopId)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})

		local ui = getUIManager():get('ClsStoreList')
		if not tolua.isnull(ui) then
			ui:setTouch(true)
		end
		return
	end

	local ui = getUIManager():get('ClsStoreList')
	if not tolua.isnull(ui) then
		ui:showAward(shopId)
	end
end

--船舶改名
function rpc_client_boat_set_name(erro, boatKey, name)  
	if erro ~= 0 then
		Alert:warning({msg = error_info[erro].message, size = 16})
		return 
	end

	if name == "" then
		Alert:warning({msg = MSG_BOAT_NAME_SET_FAIL, size = 26})
	else
		local boatData = getGameData():getBoatData()
		boatData:setBoatName(boatKey, name)
	end
end

--拆解船只
function rpc_client_boat_disassembly(erro, boat_key)  
	if erro ~= 0 then
		Alert:warning({msg = error_info[erro].message, size = 26})
		return
	end

	local ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(ui) then 
		ui:disassembleBoat(boat_key)
	end
end

function rpc_client_boat_disassembly_reward(erro, rewards)
	if erro ~= 0 then
		Alert:warning({msg = error_info[erro].message, size = 26})
		
		local ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(ui) then 
			ui:setTouch(true)
		end
		return
	end

	local ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(ui) then 
		ui:createBoatDisassemLayer(rewards)
	end
end



function rpc_client_black_market_notify(error)
	if error == 0 then
		Alert:warning({msg = ui_word.BLACKMARKET_ASK_GUILD_FRIEND_SUCC , size = 26})
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end
	
end
---------------------------------新船只下发协议-------------------------------------------------

