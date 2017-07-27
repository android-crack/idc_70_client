

local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")

---成长福利数据
function rpc_client_fund_info(fund_info)
	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:setFundInfo(fund_info)

	local ClsGrowthFundTab = getUIManager():get("ClsGrowthFundTab")
	if not tolua.isnull(ClsGrowthFundTab) then
		ClsGrowthFundTab:initUI()
	end
end

---福利等级奖励
function rpc_client_fund_take_reward(rewards)
	local rewards_list = {}
	rewards_list[#rewards+ 1] = rewards
	Alert:showCommonReward(rewards_list)
end


------------------------------------------------首冲
---获得充值活动奖励
function rpc_client_recharge_info(recharge_info)

	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:setRechargeRewardInfo(recharge_info)

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:updateFristRecharge()
	end

	if growth_fund_data:isRechargeFull() then
		local ClsWefareMain = getUIManager():get("ClsWefareMain")
		if not tolua.isnull(ClsWefareMain) then
			ClsWefareMain:updateMkUI()
		end
	end

end


---领取奖励
function rpc_client_recharge_take_reward(rewards)
	local rewards_list = {}	
	for k,v in pairs(rewards) do
		if v.type ~= ITEM_INDEX_BOAT then
			rewards_list[#rewards_list + 1] = v
		end
	end

	Alert:showCommonReward(rewards_list)		

end

-----首冲奖励的船
function rpc_client_recharge_got_boat(boat)
	local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
	local ClsShipRewardPop = require("gameobj/quene/clsShipRewardPop")
    ClsDialogSequene:insertTaskToQuene(ClsShipRewardPop.new({boatInfo = boat, callBackFunc = function ( )
               
	end}))
end

---请求奖励预览
function rpc_client_recharge_reward_preview(list)
	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:setRechargeRewardPreviewInfo(list)

	local ClsFirstRechargeTab = getUIManager():get("ClsFirstRechargeTab")
	if not tolua.isnull(ClsFirstRechargeTab) then
		ClsFirstRechargeTab:mkUI()
	end
end


-----按钮特效状态 首充主界面按钮 1 首充页签 2 成长基金页签 3 vip特权页签 4
function  rpc_client_all_effect(effect_status_list)
	--print("========================按钮特效状态=")
	--table.print(effect_status_list)

	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:setVipEffectStatus(effect_status_list)
	
end

function rpc_clinet_set_effect(error)
	
end