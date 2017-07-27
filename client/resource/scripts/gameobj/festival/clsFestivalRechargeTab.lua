--
-- 充值活动
--
local missionSkipLayer 			= require("gameobj/mission/missionSkipLayer")
local recharge_reward_config	= require("game_config/duanwu_activity_diamond.lua")
local music_info 				= require("game_config/music_info")
local ui_word 					= require("game_config/ui_word")
local ClsAlert   				= require("ui/tools/alert")


local ClsFestivalRechargeTab 	= class("ClsFestivalRechargeTab", function() return UIWidget:create() end)

-- JSON地址
local TAB_JSON_URL 				= "json/activity_dw_charge.json"			-- 界面JSON

local LABEL_COLOR				= 
{
	DAILY_GIFT_LOCK 	= ccc3(dexToColor3B(COLOR_CHAT)),
	DAILY_GIFT_UNLOCK 	= ccc3(dexToColor3B(COLOR_GREEN)),
}

function ClsFestivalRechargeTab:ctor()
	self["panel"]				= nil 		-- 界面panel
	self["btn_daily"]			= nil 		-- 每日礼包的按钮
	self["btn_daily_txt"]		= nil 		-- 上边那个按钮的文本
	self["btn_recharge"]		= nil 		-- 累计充值领取经历的按钮
	self["btn_recharge_txt"]	= nil 		-- 上边那个按钮的文本

	self["panel_1"]				= nil 		-- 上方的关于每日礼包的panel
	self["daily_award_tips"]	= {} 		-- 每日礼包的三个文本

	self["panel_2"] 			= nil 		-- 下方的关于累计充值的panel
	self["recharge_award"]		= {} 		-- 关于累计充值的一些控件
	--[[
	{
		[1]:{
			"award_tips":	-- 可领取/已领取
			"award_num":	-- 海洋之心的数量
			"rmb_tips":		-- 该条件需要的人民币
			"rmb_num": 		-- 人民币数值 
		}, ...
	}
	--]]
	self["rmb_ammount"]			= nil  		--累计充值总数

	self:mkUI()

	getGameData():getFestivalActivityData():askRechargeInfo()
end

function ClsFestivalRechargeTab:mkUI()
	self.panel 			  = GUIReader:shareReader():widgetFromJsonFile(TAB_JSON_URL)
	self.panel_1 		  = getConvertChildByName(self.panel, "panel_1")
	self.panel_2		  = getConvertChildByName(self.panel, "panel_2")
	self.btn_daily 		  = getConvertChildByName(self.panel, "btn_go_1")
	self.btn_daily_txt	  = getConvertChildByName(self.panel, "btn_go_text_1")
	self.rmb_ammount	  = getConvertChildByName(self.panel, "recharge_rmb_num")
	self.btn_recharge	  = getConvertChildByName(self.panel, "btn_go_2")
	self.btn_recharge_txt = getConvertChildByName(self.panel, "btn_go_text_2")
	self:addChild(self.panel)
	-- daily_award_tips
	for k = 1, 3 do 
		table.insert(self.daily_award_tips, getConvertChildByName(self.panel_1, "award_tips"..k))
	end
	-- 充值相关
	for k, config in ipairs(recharge_reward_config) do
		table.insert(self.recharge_award, {
			["award_tips"] 	= getConvertChildByName(self.panel_2, "award_tips_"..k),
			["award_num"]	= getConvertChildByName(self.panel_2, "award_icon_num_"..k),
			["rmb_tips"]	= getConvertChildByName(self.panel_2, "rmb_tips_panel_"..k),
			["rmb_num"]		= getConvertChildByName(self.panel_2, "award_rmb_num_"..k)
		})
		-- 默认把所有的阶段条件设置一下
		self.recharge_award[k]["award_num"]:setText("x"..config["sea_heart_num"])
		self.recharge_award[k]["rmb_num"]:setText(config["top_ups_num"])
	end 

	self:updateRechargeStatus()
end

-- update接口
function ClsFestivalRechargeTab:updateRechargeStatus()
	self:updateDailyPanel()
	self:updateRechargePanel()
end

function ClsFestivalRechargeTab:updateDailyPanel()
	-- 设置每日礼包的状态
	local had_reward, daily_gift_status = getGameData():getFestivalActivityData():getDailyGiftStatus()
	local is_all_unlocked = true
	-- 解锁和非解锁的文本颜色设置
	for k, status in ipairs(daily_gift_status) do
		if status then
			self.daily_award_tips[k]:setColor(LABEL_COLOR.DAILY_GIFT_UNLOCK)
		else
			self.daily_award_tips[k]:setColor(LABEL_COLOR.DAILY_GIFT_LOCK)
			is_all_unlocked = false
		end
	end
	-- 根绝解锁、领取状态获取按钮文本和按钮方法
	self:updateBtnDaily(is_all_unlocked, had_reward)
end

function ClsFestivalRechargeTab:updateRechargePanel()
	local received_step = getGameData():getFestivalActivityData():getRechargeReceivedStep()
	local current_step  = getGameData():getFestivalActivityData():getRechargeCurrentStep()

	for k, widgets in ipairs(self.recharge_award) do
		if k <= current_step then
			-- 这个步骤已经达到，去除人民币条件，显示提示文本
			widgets.rmb_tips:setVisible(false)
			widgets.award_tips:setVisible(true)
			-- 这个步骤不仅达到，而且已经领取了奖励
			if k <= received_step then
				widgets.award_tips:setText(ui_word.HAD_GET_REWARD_TIP_51)
				widgets.award_tips:setColor(LABEL_COLOR.DAILY_GIFT_LOCK)
			-- 这个步骤仅仅是达到，但是还没有领取奖励
			else
				widgets.award_tips:setText(ui_word.CAN_GET_REWARD_TIP_51)
				widgets.award_tips:setColor(LABEL_COLOR.DAILY_GIFT_UNLOCK)
			end
		else
			-- 没达到的步骤显示条件，去除文本，显示人民币条件
			widgets.rmb_tips:setVisible(true)
			widgets.award_tips:setVisible(false)
		end		
	end

	self:updateBtnRecharge(received_step, current_step)
	-- 已累计充值数目
	self.rmb_ammount:setText(getGameData():getFestivalActivityData():getTotalRecharge())
end

function ClsFestivalRechargeTab:updateBtnDaily(is_all_unlocked, is_had_exchange)
	local btn_info 		= 
	{
		["GO_TO_BUY"] 	= {
			["text"] 	= ui_word.GO_TO_BUY_51,
			["call_func"] 	= function()
				getUIManager():close("ClsFestivalActivityMain")
				getUIManager():create("gameobj/welfare/clsWelfareMain", nil, 4) 
			end
		},
		["GET_REWARD"] 	= {
			["text"]	= ui_word.BTN_CAN_GET_REWARD_51,
			["call_func"]	= function()
				getGameData():getFestivalActivityData():askDailypacksReward() 
			end
		},
		["OVER_REWARD"]	= {
			["text"]	= ui_word.BTN_HAD_GET_REWARD_51,
			["call_func"]	= function()
				ClsAlert:warning({msg = ui_word.HAD_GET_REWARD_ALERT_TIP_51})
			end
		} 
	}

	local cur_btn_info 	= btn_info.GO_TO_BUY 	-- 默认没有完成，前往购买
	if is_all_unlocked then  					-- 如果全部解锁了
		if is_had_exchange == 0 then 			-- 并且还没有领奖，就去领奖
			cur_btn_info = btn_info.GET_REWARD
		else 									-- 不然就领完了
			cur_btn_info = btn_info.OVER_REWARD
		end
	end

	self.btn_daily_txt:setText(cur_btn_info.text)
	self.btn_daily:setTouchEnabled(true)

	self.btn_daily:setPressedActionEnabled(true)
	self.btn_daily:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		cur_btn_info.call_func()
	end, TOUCH_EVENT_ENDED)
end

function ClsFestivalRechargeTab:updateBtnRecharge(received_step, current_step)
	self.btn_recharge:setTouchEnabled(true)

	local btn_info = {
		["CAN_GET_REWARD"] 	= {
			["btn_text"]	= ui_word.BTN_CAN_GET_REWARD_51,
			["call_func"]	= function()
				getGameData():getFestivalActivityData():askAccumulatedRechargeReward()
			end
		},
		["NOT_ARRIVE"]		= {
			["btn_text"]	= ui_word.BTN_NOT_ARRIVE,
			["call_func"]	= function()
				ClsAlert:warning({msg = ui_word.NOT_ARRIVE_ALERT_TIP_51})
			end
		},
		["HAD_GET_REWARD"]	= {
			["btn_text"]	= ui_word.BTN_HAD_GET_REWARD_51,
			["call_func"]	= function()
				ClsAlert:warning({msg = ui_word.HAD_GET_REWARD_ALERT_TIP_51})
			end
		},
	}

	local cur_btn_info = btn_info.CAN_GET_REWARD
	if received_step >= current_step then 	-- 已领取的等于可领取的
		if current_step == #recharge_reward_config then		-- 如果达到的已经到最后了，就没有能领取的了，显示已经领取
			cur_btn_info = btn_info.HAD_GET_REWARD
		else			-- 显示未达到
			cur_btn_info = btn_info.NOT_ARRIVE
		end
	end

	self.btn_recharge_txt:setText(cur_btn_info.btn_text)
	self.btn_recharge:setPressedActionEnabled(true)
	self.btn_recharge:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		cur_btn_info.call_func()
	end, TOUCH_EVENT_ENDED)
end

return ClsFestivalRechargeTab