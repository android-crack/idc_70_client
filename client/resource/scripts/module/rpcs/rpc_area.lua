--2017/01/17
--create by wmh0497
--海域专用rpc

--[[
class area_reward_info {
    int areaId;

    int investSum;  // 当前投资等级和
    int investStar; // 投资奖励星级

    int relicSum; // 当前遗迹星级和
    int relicStar; // 遗迹奖励星级
}
]]
--void rpc_client_area_reward_info(int uid, area_reward_info info);
function rpc_client_area_reward_info(area_reward_info)
	getGameData():getAreaRewardData():setAreaRewardStatus(area_reward_info.areaId, area_reward_info)
end

--void rpc_client_area_get_reward(int uid, random_reward_t* rewards);
function rpc_client_area_get_reward(random_rewards)
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
	ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = random_rewards, callBackFunc = function() end}))
end
