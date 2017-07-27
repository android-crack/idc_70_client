
---成长福利数据

local error_info = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("scripts/game_config/ui_word")

local growthFundData = class("growthFundData")

function growthFundData:ctor()
	self.fund_info = {}	---福利信息
	self.recharge_reward_preview = {} ---充值预览奖励表
	self.recharge_reward = {} ---充值奖励表
	-- self.frist_btn_effect_status = 0 ---首冲Btn特效状态
	-- self.frist_tab_effect_status = 0 ---首冲tab特效状态
	-- self.fund_effect_status = 0 ---成长基金特效状态
	-- self.vip_effect_status = 0 ---vip特效状态

	---首充主界面按钮 1 首充页签 2 成长基金页签 3 vip特权页签 4
	self.effect_status = {  ----特效状态列表
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	}

end

function growthFundData:setVipEffectStatus(list)
	if #list > 0 then
		for k,v in pairs(list) do
			self.effect_status[v.key] = v.val 
		end
	end 
	--self.effect_status = list 
end

---vip特效
function growthFundData:getVipEffectStatus(key)
	return self.effect_status[key]
end

function growthFundData:setEffectStatus(key,status)
	 self.effect_status[key] = status
end



---充值奖励表
function growthFundData:setRechargeRewardInfo(info_list)
	self.recharge_reward = info_list
end

function growthFundData:getRechargeRewardInfo()
	return self.recharge_reward
end


---首冲预览奖励表
function growthFundData:setRechargeRewardPreviewInfo(info_list)
	self.recharge_reward_preview = info_list
end

function growthFundData:getRechargeRewardPreviewInfo()
	return self.recharge_reward_preview
end

---福利信息
function growthFundData:setFundInfo(info)
	self.fund_info = info
end

function growthFundData:getFundInfo()
	return self.fund_info
end


---判断充值是否满
function growthFundData:isRechargeFull()
	if self.recharge_reward and self.recharge_reward.taken_list and 
		#self.recharge_reward.taken_list >= RECHARGE_ALL_TIMES then
		return true
	end
	return false
end

--判断是否首充

function growthFundData:isFristRecharge()
	if self.recharge_reward and self.recharge_reward.amount and 
		self.recharge_reward.amount > 0 then
		return true
	end
	return false	
end

--------------------------------请求协议---------------------

function growthFundData:askFundReward(id)
	GameUtil.callRpc("rpc_server_fund_take_reward", {id})
end

function growthFundData:askFundInfo()
	GameUtil.callRpc("rpc_server_fund_info", {})
end


--------------------首冲的协议--------------------
---请求奖励预览
function growthFundData:askRechargeRewardPreview()
	GameUtil.callRpc("rpc_server_recharge_reward_preview", {},"rpc_client_recharge_reward_preview")
end

---领取奖励
function growthFundData:getRechargeTakeReward(id)
	GameUtil.callRpc("rpc_server_recharge_take_reward", {id})
end

--- 获得充值活动奖励
-- function growthFundData:askRechargeReward()
-- 	GameUtil.callRpc("rpc_server_recharge_info", {},"rpc_client_recharge_info")
-- end

----Vip,成长基金，首冲，按钮上的特效状态
function growthFundData:askEffectStatusById(key, status)
	GameUtil.callRpc("rpc_server_set_effect", {key, status})
end

return growthFundData