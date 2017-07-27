--登陆&VIP奖励协议响应
local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")

local scheduler=CCDirector:sharedDirector():getScheduler()

function rpc_client_login_get_award(result)
	
end

function rpc_client_vip_get_award(result)
	
end

function rpc_client_business_auto_info(info)
	local login_award_data = getGameData():getLoginVipAwardData()
	login_award_data:setIdleAwardInfo(info)
	local idle_award = getUIManager():get("ClsIdleAwardTab")
	if not tolua.isnull(idle_award) then
		idle_award:updateView()
	end

end

function rpc_client_business_auto_get(result, error)
	if result == 1 then
		local login_award_data = getGameData():getLoginVipAwardData()
		local data = login_award_data:getIdleAwardInfo()
		local cash = data.cash or 0
		local item_reward = {}
		item_reward.key = ITEM_INDEX_CASH
		item_reward.value = cash
		local reward = {}
		table.insert(reward, item_reward)
		Alert:showCommonReward(reward, function()
			login_award_data:clearIdleAwardInfo()
			local idle_award = getUIManager():get("ClsIdleAwardTab")
			if not tolua.isnull(idle_award) then
				idle_award:updateView()

				local ClsWefareMain = getUIManager():get("ClsWefareMain")
				if not tolua.isnull(ClsWefareMain) then
					ClsWefareMain:updateMkUI()
				end
			end
		end)
	end
end
