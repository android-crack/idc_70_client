local ui_word = require("game_config/ui_word")

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsMissionBattleFail = class("ClsMissionBattleFail", ClsQueneBase)
local Alert = require("ui/tools/alert")

function ClsMissionBattleFail:ctor(data)
	self.data = data
end

function ClsMissionBattleFail:getQueneType()
	return self:getDialogType().mission_battle_pop
end

function ClsMissionBattleFail:excTask()
	if self.data.is_reward then
		local function ok_func()
			if not self.data.rewards then return end

			local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")

			local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
			ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = self.data.rewards}))

			self:TaskEnd()
		end
		local view, _, _, panel = Alert:showAttention(ui_word.MISSION_HELP_SUCCESS, ok_func, ok_func, nil, {hide_cancel_btn = true})

	    local widgets = {}
	    local widget_info = {
	    	[1] = {name = "questionnaire_panel"},
	    	[2] = {name = "text_times"},
	    	[3] = {name = "text_num"},
		}

		for k, v in ipairs(widget_info) do
			local item = getConvertChildByName(panel, v.name)
			item:setVisible(true)
			widgets[v.name] = item
		end

	    local coin_num = getConvertChildByName(widgets.questionnaire_panel, "coin_num")
	    coin_num:setText(self.data.rewards and self.data.rewards.amount or 40)

	    local info = self.data.info or {}
	    widgets.text_num:setText(string.format("%d/%d", info.used_count or 0, info.total_count or 0))

	    view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(function()
	    	if tolua.isnull(view) then return end
	    	view:close()
	    	ok_func()
	    end)))
	else
		local ok_func = function()
			self:TaskEnd()
		end

		Alert:showAttention(ui_word.MISSION_FAIL_ASK_HELP, function()
	    	GameUtil.callRpcVarArgs("rpc_server_assist_group_ask", self.data.mission_id)
	    	self:TaskEnd()
	    end, ok_func, ok_func, {hide_cancel_btn = true, ok_text = ui_word.FRIEND_ASK_HELP})
	end
end

return ClsMissionBattleFail

