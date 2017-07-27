-- 等待中的需求：

local error_info = require("game_config/error_info")
local ClsAlert   = require("ui/tools/alert")
local parseMsg   = require("module/message_parse.lua")
local dataTools  = require("module/dataHandle/dataTools")
local ClsDialogSequene 			= require("gameobj/quene/clsDialogQuene")
local ClsSailorWineRecuitQuene 	= require("gameobj/quene/clsSailorWineRecuitQuene")


-- 活动状态下发: 0 ：没开、提示 , 1 ：已经开了 , 2 : 开完了
function rpc_client_goddess_box_status(status)
	getGameData():getFestivalActivityData():updateActivityStatus(status)
end

-- 开启女神宝箱的结果
--[[
{
	id:
	amount:
	type:
	memoJson:
}	
--]]
function rpc_client_open_ocean_heart(error_n, reward, isRare)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		if reward["type"] == ITEM_INDEX_SAILOR then
			ClsDialogSequene:insertTaskToQuene(ClsSailorWineRecuitQuene.new({sailor_id = reward.id}))
		else
			ClsAlert:showCommonReward({reward})
		end
		getGameData():getFestivalActivityData():updateHeartNum()
	end
end

-- 返回稀有奖励玩家列表
--[[
list:	
[
	{
		name:   -- 玩家姓名
		reward: -- 奖励
	} * n
]
--]]
function rpc_client_goddess_box_list(error_n, list)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		getGameData():getFestivalActivityData():updateRareRewardList(list)
	end
end

-- 返回每日礼包的信息, 返回充值送礼的信息
--[[
{
	dailypacks = {1, 3, 6},  已购买的每日礼包
	had_reward = 1/0,        是否还有奖励
	total_recharge = number, 已累计充值总数
	received_step = number,  已经领取到哪个阶段了
}	
]]--
function rpc_client_goddess_recharge_info(error_n, info)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		getGameData():getFestivalActivityData():updateRechargeInfo(info)
	end
end

-- 返回日常活动的信息
--[[
daily_activity_info:
{
	"type": 1, "step": 1, "schedule": 0, "target": 10
}
--]]
function rpc_client_goddess_daily_activities_info(error_n, grade, daily_activity_info)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		getGameData():getFestivalActivityData():updateDailyActivityInfo(grade, daily_activity_info)
	end
end

-- 领取每日礼包的海洋之心的结果
function rpc_client_goddess_dailypacks_reward(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		local festival_data_handler = getGameData():getFestivalActivityData()
		festival_data_handler:updateDailyGiftHadReward(1)
		festival_data_handler:receiveHeart()
	end
end

-- 领取累计充值的海洋之心的结果
function rpc_client_goddess_accumulated_recharge_reward(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		local festival_data_handler = getGameData():getFestivalActivityData()
		festival_data_handler:updateReceivedStep()
		festival_data_handler:receiveHeart()
	end
end

-- 每日活动积分兑换结果
-- amount 换取了多少个, current 剩余了多少积分
function rpc_client_goddess_box_exchange(error_n, amount, current)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		local festival_data_handler = getGameData():getFestivalActivityData()
		festival_data_handler:updateDailyActivityGrade(current)
		festival_data_handler:receiveHeart()
	end
end