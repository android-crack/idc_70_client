local Alert = require("ui/tools/alert")

--问卷信息下发
function rpc_client_question_info(current_id)
	local question_data = getGameData():getQuestionPaperData()
	question_data:setQuestionInfo(current_id)

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:jugeShowQuestionBtn()
	end
end

--领取奖励
function rpc_client_question_take_reward(rewards)
	if not rewards then return end
    Alert:showCommonReward(rewards, nil)
end
