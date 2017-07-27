local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local tool = require("module/dataHandle/dataTools")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

function rpc_client_huodong_login_reward_info(loginDay,hasGetedDay,isSpeAward,chongzhi,chongzhiId)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	loginVipDataHandle:receiveLoginVipAwardInfo(loginDay,hasGetedDay,isSpeAward,chongzhi,chongzhiId)
end

----------不用的协议
function rpc_client_huodong_login_reward_get_login(result,err,rewardDays)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local login_reward_ui = getUIManager():get("MainAwardUI")
	if not tolua.isnull(login_reward_ui) then
		login_reward_ui:setViewTouch()
	end
	if result==1 then
		loginVipDataHandle:receiveGetLoginAward(result,rewardDays)
	else
		Alert:warning({msg =error_info[err].message, size = 26})
	end
end

-- 单独领取每天登陆奖励
function rpc_client_huodong_login_reward_get_all(rewardDays)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local login_reward_ui = getUIManager():get("MainAwardUI")
	if not tolua.isnull(login_reward_ui) then
		login_reward_ui:setViewTouch()
	end
	
		loginVipDataHandle:receiveGetLoginAward(1,rewardDays)
	-- else
	-- 	Alert:warning({msg =error_info[err].message, size = 26})
	-- end
end

function rpc_client_get_login_and_vip_reward(rewardDays, vip_reward)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local login_reward_ui = getUIManager():get("MainAwardUI")
	if not tolua.isnull(login_reward_ui) then
		login_reward_ui:setViewTouch()
	end
	
	--table.print(vip_reward)
		loginVipDataHandle:receiveGetLoginAward(1, rewardDays, vip_reward)
	-- else
	-- 	Alert:warning({msg =error_info[err].message, size = 26})
	-- end
end

function rpc_client_huodong_login_reward_get_chongzhi(result,err,chongzhiId)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local login_reward_ui = getUIManager():get("MainAwardUI")
	if not tolua.isnull(login_reward_ui) then
		login_reward_ui:setViewTouch()
	end
	if result==1 then
		loginVipDataHandle:receiveGetVipAward(result,chongzhiId)
	else
		Alert:warning({msg =error_info[err].message, size = 26})
	end
end

function rpc_client_vip_month_time(remain,today_reward)
   	local remainDay = tool:getZnTimeStrForVip(remain)
    local playerData = getGameData():getPlayerData()
    playerData:setVipRemainDay(remainDay) ----VIP特权剩余时间
    if today_reward == 1 then
        playerData:setIsGetAward(true)
    else
        playerData:setIsGetAward(false)
    end
    local element = getUIManager():get("ClsDailyMonthCard")
   	if element then
   		element:updateView()
  	end
end

function rpc_client_vip_get_day_reward(reward, result, error)
	if reward then
		local rewards_tab = {}
		rewards_tab[1] = reward
		ClsAlert:showCommonReward(rewards_tab)
	end
	if result == 1 then
		local playerData = getGameData():getPlayerData()
		playerData:setIsGetAward(true)
		local element = getUIManager():get("ClsDailyMonthCard")
   		if element then
   			element:updateView()
   		end
	else
		Alert:warning({msg =error_info[error].message, size = 26})
	end
end

function  rpc_client_vip_buy_month_card(result,error)
	if result == 1 then -- 表示购买VIP特权成功
	   Alert:warning({msg = ui_word.SHOP_VIP_CARD_LAB, size = 26})
	   local port_layer = getUIManager():get("ClsPortLayer")
	   if not tolua.isnull(port_layer) then
	   		if not tolua.isnull(port_layer.mainLayer) then
	   			port_layer.mainLayer:clearWelfareEffect()
	   		end
	   end
	else
	   Alert:warning({msg =error_info[error].message, size = 26})
	end
	
end

--后面扩展，reward_pop代表是否主动弹出登录奖励
function rpc_client_huodong_login_reward_pop_win(reward_pop, auto_trade_cash, boat_key, boat_type)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
  	loginVipDataHandle:setLoginPopData(reward_pop, auto_trade_cash, boat_key, boat_type)

  	-- if reward_pop == 1 then
		-- local DialogQuene = require("gameobj/quene/clsDialogQuene")
		-- local clsAutoPopWelfare = require("gameobj/quene/clsAutoPopWelfare")
  --       DialogQuene:insertTaskToQuene(clsAutoPopWelfare.new({}))
  -- 	end
end

--通用的提示，目前只自动经商用到
function rpc_client_reward_tips(reward)
    local function _callback()
        local clsMineralDefendView = getUIManager():get("clsMineralDefendView")
        if not tolua.isnull(clsMineralDefendView) then
            clsMineralDefendView:updateGetStatus()
        end
    end

    if reward then
        local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
        local ClsAutoTradeRewardPopViewQuene = require("gameobj/quene/clsAutoTradeRewardPopViewQuene")
   		ClsDialogSequence:insertTaskToQuene(ClsAutoTradeRewardPopViewQuene.new({reward = reward, callBackFunc = _callback}))
    end

end