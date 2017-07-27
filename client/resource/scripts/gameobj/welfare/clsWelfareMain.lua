--
-- Author: Ltian
-- Date: 2016-07-01 16:37:59
--
local on_off_info=require("game_config/on_off_info")
local music_info=require("game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ui_word = require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local STAR_STATUS_OPEN = 1
local STAR_STATUS_CLOSE = 0

local REWARD_CAN_RECEIVE = 1
local COMPLATE_FUND_REWARD_DAYS = 6

local pos_nine = 9
local pos_three = 3
local pos_five = 5
local pos_seven = 7 
local pos_two = 2
local pos_eight = 8
local pos_four = 4

local ClsWefareTab = class("ClsWefareTab",ClsScrollViewItem)

ClsWefareTab.initUI = function(self, cell_data)
	self.data = cell_data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_tab.json")
	self:addChild(self.panel)

	self.tab_bg = getConvertChildByName(self.panel, "tab_bg")

	self.tab_txt = getConvertChildByName(self.panel, "tab_txt")

	self.tab_txt:setText(cell_data.btn_lbl)

	if cell_data.other_btn_lbl and not getUIManager():get("ClsWefareMain"):isFirstRecharge() then
		self.tab_txt:setText(cell_data.other_btn_lbl)
	end

	self:updateSelectStatus()

	self.tab_bg:setTouchEnabled(true)
	local task_data = getGameData():getTaskData()
	if self.data.task_keys and self.data.on_off_key then
		task_data:regTask(self.tab_bg, self.data.task_keys, KIND_RECTANGLE, self.data.on_off_key, 60, 30, true)
		self.tab_bg:setTouchEnabled(false)
	end

	local fund_data = getGameData():getGrowthFundData()
	if cell_data.effect and fund_data:getVipEffectStatus(cell_data.effect_id) == 0  then
		self.effect = CompositeEffect.new(cell_data.effect, 0, 0, self.tab_bg,nil,nil,nil,nil,true)
	end
end

ClsWefareTab.updateSelectStatus = function(self)
	if self.panel then
		if self.data.default_tab then
			self.tab_bg:changeTexture(convertResources("common_btn_tab4.png"), UI_TEX_TYPE_PLIST)
			setUILabelColor(self.tab_txt, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			setUILabelColor(self.tab_txt, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
			self.tab_bg:changeTexture(convertResources("common_btn_tab3.png"), UI_TEX_TYPE_PLIST)
		end
	end
end

ClsWefareTab.onTap = function(self)
	if self.tapFunc then
		self:tapFunc()
	end
end

ClsWefareTab.setTapCallFunc = function(self, func)
	self.tapFunc = func
end

local ClsWefareMain = class("ClsWefareMain",require("ui/view/clsBaseView"))

ClsWefareMain.getViewConfig = function(self)
	return { 
		hide_before_view = true, 
		effect = UI_EFFECT.FADE, 
	}
end

ClsWefareMain.onEnter = function(self, tab_id, call_back, dismiss_true)
	getGameData():getSeaStarData():askSeaStarList()
	self.call_back = call_back
	self:askData()
	self.plist = {
		["ui/box.plist"] = 1,
		["ui/award_ui.plist"] = 1,
	}

	LoadPlist(self.plist)
	self.is_finish_effect = false

	local voice_info = getLangVoiceInfo()
	audioExt.playEffect(voice_info.VOICE_SWITCH_1004.res)
	self.default_tab = tab_id or 0
	self:mkUI()
	if type(self.call_back) == "function" then
		self.call_back()
	end
end

ClsWefareMain.onFadeFinish = function(self)
	self.is_finish_effect = true
	if not tolua.isnull(self.show_view) then
		self.show_view:setViewVisible(true)
	end
end

ClsWefareMain.askData = function(self)
	local login_award_data = getGameData():getLoginVipAwardData()
	login_award_data:askIdleAwardInfo()
end

---首冲转累充
ClsWefareMain.isFirstRecharge = function(self)
	local growth_fund_data = getGameData():getGrowthFundData()
	self.reward_info = growth_fund_data:getRechargeRewardInfo()
	if self.reward_info.taken_list and #self.reward_info.taken_list > 0 then
		return false
	end
	return true
end

-----是否有充值
ClsWefareMain.isRechargeVisible = function(self)
	if getGameData():getGrowthFundData():isRechargeFull() then
		return false
	end
	return true
end

---判断离线的显示
ClsWefareMain.isIdleAwardVisible = function(self)
	local login_award_data = getGameData():getLoginVipAwardData()
	local data = login_award_data:getIdleAwardInfo()

	if data and  data.cash and data.cash ~= 0 then
		return true
	end

	return false
end

---成长基金
ClsWefareMain.isGrowthFundVisible = function(self)
	local growth_fund_data = getGameData():getGrowthFundData()
	self.fund_data_info = growth_fund_data:getFundInfo()
	if self.fund_data_info and self.fund_data_info.taken_list and #self.fund_data_info.taken_list >= COMPLATE_FUND_REWARD_DAYS then
		return false
	end
	return true
end

---爵位分红
ClsWefareMain.isInvestRewardVisible = function(self)
	local daily_activity_data = getGameData():getDailyActivityData()
	local reward_status = daily_activity_data:getInvestRewardStatus()
	if reward_status == REWARD_CAN_RECEIVE then
		return true
	else
		return false
	end
end

---海上新星的状态
ClsWefareMain.getSeaStarStatus = function(self)
	return getGameData():getSeaStarData():getSeaStarStatus()
end

--每日礼包的状态
ClsWefareMain.getDailyGiftStatus = function(self)
	local shop_data = getGameData():getShopData()
	local is_buy_all = shop_data:isBuyAllGift() 
	return not is_buy_all
end

local tab_list = {
	{btn_lbl = ui_word.TAB_VIP, on_off_key = on_off_info.VIP_PAGE.value, task_keys = {
		on_off_info.VIP_DIAMONDGET.value, --【vip】VIP特权界面-领取按钮
	}, tab_pos = 1,effect = "tx_1042_5", effect_id = 4 },

	{btn_lbl = ui_word.TAB_FIRST, on_off_key = on_off_info.RECHARGE_PAGE.value, task_keys = {
		on_off_info.RECHARGE_REWARD.value
	}, tab_pos = 2, other_btn_lbl = ui_word.TAB_RECHARGE,effect = "tx_1042_5", effect_id = 2}, --首冲

	{btn_lbl = ui_word.TAB_FUND, on_off_key = on_off_info.GROWTH_FUND.value, task_keys = {
		on_off_info.GROWTH_FUND.value
	}, tab_pos = 3, effect = "tx_1042_5", effect_id = 3}, ---成长基金

	{btn_lbl = ui_word.DAILY_GIFT, on_off_key = on_off_info.WELFARE_DAILY.value, task_keys = {
		on_off_info.WELFARE_DAILY.value
	}, tab_pos = 4}, ---每日礼包

	{btn_lbl = ui_word.TAB_STAR, on_off_key = on_off_info.SEA_STAR.value, task_keys = {
		on_off_info.SEA_STAR_FIRST.value, --第一天
		on_off_info.SEA_STAR_SECOND.value, --第二天
		on_off_info.SEA_STAR_THIRD.value, --第三天
		on_off_info.SEA_STAR_FORTH.value, --第四天
		on_off_info.SEA_STAR_FIFTH.value, --第五天
		on_off_info.SEA_STAR.value,
	}, tab_pos = 5},

	{btn_lbl = ui_word.TAB_WEEK, on_off_key = on_off_info.DAILY_COMPETITION.value, task_keys = {
		on_off_info.DAILY_COMPETITION.value, --每周竞赛
	}, tab_pos = 6},

	{btn_lbl = ui_word.TAB_LIXIAN , on_off_key = on_off_info.WELFARE_LIXIAN.value , task_keys = {
		on_off_info.WELFARE_LIXIAN.value ---离线
	}, tab_pos = 7},

	{btn_lbl = ui_word.TAB_SIGNIN , on_off_key = on_off_info.SIGNIN_REWARD.value , task_keys = {
		on_off_info.SIGNIN_REWARD.value,--签到奖励
	}, tab_pos = 8},

	{btn_lbl = ui_word.TAB_NOBILITY , on_off_key = on_off_info.PEERAGES_FENHONG.value , task_keys = {
		on_off_info.PEERAGES_FENHONG.value ---爵位分红
	}, tab_pos = 9},
	{btn_lbl = ui_word.TAB_GAINBACK , on_off_key = on_off_info.INCOME_BACK.value , task_keys = {
		on_off_info.INCOME_BACK.value --增益找回
	}, tab_pos = 10},
}

----去掉不显示的tab
ClsWefareMain.getTabListOrder = function(self, tab_list)
	local new_tab_list = {}
	for k,v in pairs(tab_list) do
		if v.tab_pos == pos_three then
			if self:isGrowthFundVisible() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_nine then
			if self:isInvestRewardVisible() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_four then
			if self:getDailyGiftStatus() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_five then
			if self:getSeaStarStatus() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_seven then
			if self:isIdleAwardVisible() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_two then
			if self:isRechargeVisible() then
				new_tab_list[#new_tab_list + 1] = v
			end
		elseif v.tab_pos == pos_eight then
			if self:isOpenTask(v.task_keys) then
				new_tab_list[#new_tab_list + 1] = v
			end
		else
			new_tab_list[#new_tab_list + 1] = v
		end
	end
	return new_tab_list
end

ClsWefareMain.isOnOffOpen = function(self)
	local onOffData = getGameData():getOnOffData()
	local new_tab_list = {}
	for k,v in pairs(tab_list) do
		if onOffData:isOpen(v.on_off_key) then
			new_tab_list[#new_tab_list + 1] = v
		end
	end
	return new_tab_list
end

ClsWefareMain.isOpenTask = function(self, task_keys)
	local task_data = getGameData():getTaskData()
	for k,v in pairs(task_keys) do
		if task_data:judgeOpenTask(v) then
			return true
		end
	end
	return false
end

ClsWefareMain.isRedPoint = function(self, list)
	local have_red_point = {}
	local no_red_point = {}
	local onOffData = getGameData():getOnOffData()
	local task_data = getGameData():getTaskData()
	for k,v in pairs(list) do
		if self:isOpenTask(v.task_keys) then
			have_red_point[#have_red_point + 1] = v
		else
			no_red_point[#no_red_point + 1] = v
		end
	end

	table.sort(have_red_point,function (a,b)
		return a.tab_pos < b.tab_pos
	end)

	table.sort(no_red_point,function (a,b)
		return a.tab_pos < b.tab_pos
	end)

	for k,v in pairs(no_red_point) do
		have_red_point[#have_red_point + 1]= v
	end
	return have_red_point
end

----当登陆奖励没领取时获取tab 位置
ClsWefareMain.getLoginRewardPos = function(self, tab_list,pos_tag)
	local task_data = getGameData():getTaskData()
	for k,v in pairs(tab_list) do
		if v.tab_pos == pos_tag  then--and task_data:judgeOpenTask(v.on_off_key)
			return k
		end
	end
	return 1
end

ClsWefareMain.mkUI = function(self)
	--self.default_tab = 1
	self.s_type  = nil
	if not tolua.isnull(self.panel) then
		self.panel:removeFromParent()
		self.panel = nil
	end

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.cells = {}

	self.line_cut = getConvertChildByName(self.panel, "line_cut")
	self.bg = getConvertChildByName(self.panel, "bg")

	self.close_btn = getConvertChildByName(self.panel, "close_btn")
	self.close_btn:setPressedActionEnabled(true)
	self.close_btn:addEventListener(function()
		self:closeView()
	end
	, TOUCH_EVENT_ENDED)

	self.btn_star_help = getConvertChildByName(self.panel, "btn_help")
	self.btn_star_help:setPressedActionEnabled(true)
	self.btn_star_help:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local sea_star_ui = getUIManager():get("ClsSeaStarUI")
		if not tolua.isnull(sea_star_ui) then
			getUIManager():create("gameobj/welfare/clsSeaStarDesTip")
		end
	end, TOUCH_EVENT_ENDED)

	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
		self.list_view = nil
	end

	self.list_view = ClsScrollView.new(190, 488, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(0,10))

	local cell_size	= CCSize(169, 73)
	local tab_list = self:isOnOffOpen()
	local tab_list_1 = self:isRedPoint(tab_list)
	local new_tab_list  = self:getTabListOrder(tab_list_1)
	local login_view_tab  = self:getLoginRewardPos(new_tab_list, self.default_tab)
	if login_view_tab ~= 0 then
		self.default_tab = login_view_tab
	end

	self.new_tab_list = new_tab_list
	for k,v in pairs(new_tab_list) do
		if k == self.default_tab then
			v.default_tab = self.default_tab
		else
			v.default_tab = false
		end
		local cell_tab = ClsWefareTab.new(cell_size, v, _rect)
		self.list_view:addCell(cell_tab)
		self.cells[#self.cells + 1] = cell_tab
		cell_tab:setTapCallFunc(function()
			self:onCellTap(v,k)
		end)
	end
	self:addWidget(self.list_view)

	for k,v in pairs(self.cells) do
		if k == self.default_tab then
			v:onTap()
		end
	end

	self.getWelfareGuideObj = function(condition)
		return self:getGuideInfo(condition)
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(function (  )
		ClsGuideMgr:tryGuide("ClsWefareMain")
	end))

	self:runAction(CCSequence:create(array))
end

ClsWefareMain.getGuideInfo = function(self, condition)
	if tolua.isnull(self.list_view) then return end
	local parent_ui = self.list_view:getInnerLayer()
	local tab_pos = condition.tab_pos

	for k, v in ipairs(self.new_tab_list) do

		if v.tab_pos == tab_pos then
			local world_pos = self.cells[k]:convertToWorldSpace(ccp(100, 30))
			local parent_pos = parent_ui:convertToWorldSpace(ccp(0,0))
			local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
			return parent_ui, guide_node_pos, {['w'] = 170, ['h'] = 60}
		end
	end
end

ClsWefareMain.onCellTap = function(self, v,k)
	self:selectTab(k)
end

ClsWefareMain.selectTab = function(self, tab)
	if self.s_type == tab then
		return
	end

	self.s_type = tab
	if self.show_view and not tolua.isnull(self.show_view) then
		self.show_view:close()
		self.show_view = nil
	end

	local tab = self.new_tab_list[tab].tab_pos
	self.line_cut:setVisible(false)
	self.bg:setVisible(true)
	if tab == 1 then
		self.line_cut:setVisible(true)
		self.bg:changeTexture("ui/bg/bg_award_vip.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsDailyMonthCard")
	elseif tab == 2 then
		self.bg:changeTexture("ui/bg/bg_award_recharge.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsFirstRechargeTab")
	elseif tab == 3 then
		self.bg:changeTexture("ui/bg/bg_award_fund.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsGrowthFundTab")
	elseif tab == 4 then
		self.bg:setVisible(true)
		self.bg:changeTexture("ui/bg/bg_award_gift.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsDailyGift")
	elseif tab == 5 then
		self.bg:setVisible(false)
		self.show_view = getUIManager():create("gameobj/welfare/clsSeaStarUI")
	elseif tab == 6 then
		self.bg:setVisible(false)
		self.show_view = getUIManager():create("gameobj/welfare/clsWeeklyRace")
	elseif tab == 7 then
		self.bg:changeTexture("ui/bg/bg_award_idle.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsIdleAwardTab")
	elseif tab == 8 then
		self.line_cut:setVisible(true)
		self.bg:changeTexture("ui/bg/bg_award_vip.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsLoginAwardUI")
	elseif tab == 9 then
		self.bg:changeTexture("ui/bg/bg_award_bonus.jpg", UI_TEX_TYPE_LOCAL)
		self.show_view = getUIManager():create("gameobj/welfare/clsInvestRewardView")
	elseif tab == 10 then
		self.bg:setVisible(false)
		self.show_view = getUIManager():create("gameobj/welfare/clsGainBackTab")
	end

	if not self.is_finish_effect and not tolua.isnull(self.show_view)  then
		self.show_view:setViewVisible(false)
	end

	local fund_data = getGameData():getGrowthFundData()

	for k,v in pairs(self.cells) do
		if v.tab_bg then
			if self.s_type == k then
				v.tab_bg:changeTexture(convertResources("common_btn_tab4.png"), UI_TEX_TYPE_PLIST)
				setUILabelColor(v.tab_txt, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
				if v.effect then
					if v.effect and not tolua.isnull(v.effect) then
						v.effect:removeFromParentAndCleanup(true)
						v.effect = nil
					end
					fund_data:askEffectStatusById(tab_list[tab].effect_id, 1)
					fund_data:setEffectStatus(tab_list[tab].effect_id, 1)
				end
			else
				v.tab_bg:changeTexture(convertResources("common_btn_tab3.png"), UI_TEX_TYPE_PLIST)
				setUILabelColor(v.tab_txt, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
			end
		end
	end
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
end

ClsWefareMain.updateSeaStar = function(self)
	local task_keys = {
		on_off_info.SEA_STAR_FIRST.value, --第一天
		on_off_info.SEA_STAR_SECOND.value, --第二天
		on_off_info.SEA_STAR_THIRD.value, --第三天
		on_off_info.SEA_STAR_FORTH.value, --第四天
		on_off_info.SEA_STAR_FIFTH.value, --第五天
	}

	local task_data = getGameData():getTaskData()

	local seaStarData = getGameData():getSeaStarData()
	local seaStarInfo = seaStarData:getInfoData()
	local arr_action = CCArray:create()
	local seaStarData = getGameData():getSeaStarData()
	local star_open_time = seaStarInfo.remainTime

	arr_action:addObject(CCCallFunc:create(function()
		local seaStarInfo = seaStarData:getInfoData()
		if seaStarInfo.isOpen == STAR_STATUS_OPEN and star_open_time > 0 then
			star_open_time = star_open_time - 1
			seaStarData:setSeaStarStatus(true)
			--self.tab_new_star:setVisible(true)

			--没解锁不显示红点
			local today = seaStarInfo.today
			local new_today = seaStarData:getUnlockDay()
			if today > 5 then
				today = 5
			end

			if new_today <= today then
				new_today = today
			end

			if new_today > 5 then
				new_today = 5
			end
			for k, task_key in ipairs(task_keys) do
				if k > new_today then
					task_data:setTask(task_key, false)
				end
			end

			if not seaStarData:getIsNotReward() then
				task_data:setTask(on_off_info.SEA_STAR.value, true)
			else
				task_data:setTask(on_off_info.SEA_STAR.value, false)
				for k, task_key in ipairs(task_keys) do
					if not task_data.tasks[task_key] then
						task_data:setTask(task_key, false)
					end
				end
			end
		else
			if not seaStarData:getIsNotReward() then
				seaStarData:setSeaStarStatus(true)
				task_data:setTask(on_off_info.SEA_STAR.value, true)
			else
				task_data:setTask(on_off_info.SEA_STAR.value, false)
				seaStarData:setSeaStarStatus(false)
			end
		end
	end))
	arr_action:addObject(CCDelayTime:create(1))
	self:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

ClsWefareMain.closeView = function(self)
	audioExt.playEffect(music_info.COMMON_CLOSE.res)
	local MainAwardUI = getUIManager():get("MainAwardUI")
	if not tolua.isnull(MainAwardUI) then
		MainAwardUI:updateCallBack()
	end

	self:effectClose()
	local target_ui = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(target_ui) then
		target_ui = target_ui:getMainUI()
		if not tolua.isnull(target_ui) then
			-- print('------------ re open')
			getGameData():getActivityData():requestActivityInfo()
			target_ui:recentOpenActivity()
		end
	end
end

ClsWefareMain.showHelpBTN = function(self, is_show)
	self.btn_star_help:setVisible(is_show)
	self.btn_star_help:setTouchEnabled(is_show)
end

ClsWefareMain.onExit = function(self)
	UnLoadPlist(self.plist)
end

ClsWefareMain.updateMkUI = function(self)
	if(self.show_view and not tolua.isnull(self.show_view))then self.show_view:close()end
	self.default_tab = 0
	self:mkUI()
end

ClsWefareMain.onFinish = function(self)
	if(self.show_view and not tolua.isnull(self.show_view))then self.show_view:close()end
	getUIManager():close("ClsWefareMain")
end

return ClsWefareMain
