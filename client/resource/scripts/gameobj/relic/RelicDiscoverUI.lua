--是遗迹探索的主页面
--wmh create 2015-07-21 11:57
local ClsRelicPanelView = require("gameobj/relic/relicInfoPanel")
local ClsCompositeEffect = require("gameobj/composite_effect")
local ClsSkillCalc = require("module/battleAttrs/skill_calc")
local ClsAlert = require("ui/tools/alert")
local ClsUiCommon = require("ui/tools/UiCommon")
local ui_word = require("game_config/ui_word")
local voice_info = getLangVoiceInfo()
local music_info = require("game_config/music_info")
local relic_answers = require("game_config/collect/relic_answers")
local relic_star_info = require("game_config/collect/relic_star_info")
local error_info = require("game_config/error_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local MAX_STAR_COUNT = 7
local STATE_NORMAL = 1
local STATE_NEED_CLEAR_SOMETHING = 2
local STATE_NEED_GET_REWARD = 3
local STATE_FINISH = 4
local EXPLORE_STAR_NUM_LIMIT = 1

local EVENT_TYPE_ANSWER_QUESTION = 1     -- 回答问题
local EVENT_TYPE_SAILOR_BATTLE = 2       -- 水手单挑
local PER_DAY_EXPLORE_NUM = 1--每天能够探索的次数
local CONSUME_KIND_GOLD = 1
local CONSUME_KIND_POWER = 2
local CONSUME_KIND_DIAMOND = 3

local desc_tab = {[0] = {1,2}, [10] = {3,4}, [15] = {5,6}, [-5] = {7,8,9}}

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRelicDiscoverUI = class("ClsRelicDiscoverUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsRelicDiscoverUI:getViewConfig()
    return {
        name = "ClsRelicDiscoverUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        hide_before_view = true,
    }
end

--页面创建时调用
function ClsRelicDiscoverUI:onEnter(relic_info, close_callback, is_only_show_info_b)
    self.m_collect_handle = getGameData():getCollectData()  --记录其hander
	self.m_relic_info = relic_info -- 遗迹数据
	self.m_collect_handle:setCurrentVisitRelicInfo(relic_info)
	self.m_close_callback = close_callback  -- 结束回调
	self.m_is_only_show_info_b = is_only_show_info_b or false
	self.m_is_discover_before_b = self.m_collect_handle:isDigedRelic(relic_info.id) --是否发掘过遗迹
	self.m_is_discover_before_first_b = self.m_is_discover_before_b --记录刚进遗迹时是否还没发掘

	self.m_is_answer_question_b = false  --是否正在播放回答问题的界面
	self.m_is_show_up_star_eff_b = false  --是否正在播放升星的特效
	self.m_relic_total_star_num_n = 0  --该遗迹最大的星数
	self.m_answer_ui = nil --回答问题ui
	self.m_player_lv_n = 0  -- 记录其等级
	self.m_touch_priority = nil
	self.m_answers_info = {items = {}}
	self.m_menus = {}

	self.m_plist_tab = {
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/relic/relic.plist"] = 1,
	}
	self.m_armature_tab = {}
	LoadPlist(self.m_plist_tab)
	LoadArmature(self.m_armature_tab)

	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6))) --设置随机数种子（之后会用的）
	self:initUI()
	self:initEvent()
	
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():setStopFoodReason("ClsRelicDiscoverUI_show")
	end
end

function ClsRelicDiscoverUI:updateInfo(id)
	self.m_player_lv_n = getGameData():getPlayerData():getLevel()
	if id ~= self.m_relic_info.id then return end
	self.m_relic_info = self.m_collect_handle:getRelicInfoById(self.m_relic_info.id)
end

--从表中取出一个一项
local function randomsSelectValue(array, is_remove_b)
	local index = math.random(#array)
    local value = array[index]
	if is_remove_b then
		table.remove(array, index)
	end
	return value
end

function ClsRelicDiscoverUI:initEvent()
	RegTrigger(CASH_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateCashCall()
	end)

	RegTrigger(POWER_UPDATE_EVENT, function() 
		if tolua.isnull(self) then return end
		self:updatePowerCall()
	end)
end

--发掘结束回调
function ClsRelicDiscoverUI:updateDigCallback(result_n, progress_n)
	if not self.m_is_discover_before_b then--如果没有发掘过是不需要弹提示
		return
	end
	if not tolua.isnull(self.dig_panel) and not tolua.isnull(self.dig_panel.btn) then
		self.dig_panel.btn:setTouchEnabled(true)
	end
	if result_n > 0 then
		local tip_index_n = randomsSelectValue(desc_tab[progress_n])
		local show_txt = string.format("RELIC_DESCOVER_RESULT%d", tip_index_n)
		ClsAlert:tipsWithCover({msg = ui_word[show_txt], add_move_y = 40, time = 1, fate_out_delay = 2.0})
		if 1 == tip_index_n then
			local supplyData = getGameData():getSupplyData()
			local num_n = math.floor(supplyData:getCurFood())
			if num_n > 0 then
				num_n = math.floor(num_n * 0.2)
				supplyData:subFood(num_n)
			end
		end
	end
	self:updateBtns()
end

--从未发掘之后的第一次发掘打开遗迹的回调
function ClsRelicDiscoverUI:updateFirstOpenRelicCallback(new_relic_info)
	if new_relic_info.id ~= self.m_relic_info.id then return end
	self.m_is_discover_before_b = self.m_collect_handle:isDigedRelic(new_relic_info.id)
	self.m_relic_info = new_relic_info
	self:startFirstOpenRelic()
	if STATE_NEED_CLEAR_SOMETHING == new_relic_info.status then
		self:judgeEventType()
	end
end

--遗迹数据更新回调
function ClsRelicDiscoverUI:updateRelicInfoCallback(new_relic_info)  
	if new_relic_info.id ~= self.m_relic_info.id then return end
	self.m_is_discover_before_b = self.m_collect_handle:isDigedRelic(new_relic_info.id)
	self.m_relic_info = new_relic_info
	self:updateRelicIcon()
	self:updateBtns()
	self:updateRelicStarsShow()
	self:updateHadDiscoverUI()

	if STATE_NEED_CLEAR_SOMETHING == new_relic_info.status then
		self:judgeEventType()
	elseif STATE_NEED_GET_REWARD == new_relic_info.status then
		self.m_warning_lab:setVisible(false)
		self:starStarRewardEff(true)
	elseif new_relic_info.status > STATE_NEED_GET_REWARD then
		EventTrigger(EVENT_PORT_PVE_CPDATA_RELIC_UPDATE, new_relic_info.id) -- 刷下地图
	end
end

--遗迹升星问题回答的回调
function ClsRelicDiscoverUI:updateRelicAnswerResultCallback(result_n)
	self:hideQuestionUi()
	self.m_close_btn:setVisible(true)
	self.m_is_answer_question_b = false
	local event_type = self.m_relic_info.relicInfo.event_type
	if 0 == result_n and event_type[self.m_relic_info.star + 1] == EVENT_TYPE_ANSWER_QUESTION then
		ClsAlert:tipsWithCover({msg = ui_word.RELIC_ANSWER_WRONG_TIPS, add_move_y = 100, time = 1, fate_out_delay = 0.5})
	end
	self.m_relic_desc_ui:setVisible(true)
	self:updateBtns()
end

--遗迹奖励获取回调
function ClsRelicDiscoverUI:updateRelicGetRewardCallback(rewards)
	self.m_relic_card_ui:stopAllActions()
	if self.m_relic_card_ui.eff_spr then
		self.m_relic_card_ui.eff_spr:removeFromParentAndCleanup(true)
		self.m_relic_card_ui.eff_spr = nil
	end
	self.m_relic_desc_ui:setVisible(true)
	self.m_relic_card_ui:setPosition(ccp(self.m_relic_card_ui.org_pos.x, self.m_relic_card_ui.org_pos.y))
	
	--播放领取物品特效
	local show_star_reward_n = (self.m_relic_info.star or 0)
	if show_star_reward_n > self.m_relic_info.relicInfo.max_star then
		show_star_reward_n = self.m_relic_info.relicInfo.max_star
	end

	local rewards_items = self.m_relic_info.relicInfo.reward[show_star_reward_n]

	local path = string.format("game_config/relic/relic_%s_info", self.m_relic_info.id)
	local relic_reward = require(path)

	ClsAlert:showCommonReward(rewards, function() 
		self:updateBtns()
	end)
end

function ClsRelicDiscoverUI:preClose()
	--如果有遗迹的冒泡，则把它去掉
	if self.m_is_discover_before_b and (not self.m_is_discover_before_first_b) then
		local relic_guide_layer = ClsRelicPanelView:getActionLayer()
		if relic_guide_layer and (not tolua.isnull(relic_guide_layer)) then
			relic_guide_layer:removeFromParentAndCleanup(true)
			relic_guide_layer = nil
		end
	end
end

function ClsRelicDiscoverUI:onExit()
	UnLoadPlist(self.m_plist_tab)
	UnLoadArmature(self.m_armature_tab)
	ReleaseTexture(self)
	
	UnRegTrigger(CASH_UPDATE_EVENT)
	UnRegTrigger(POWER_UPDATE_EVENT)
	
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():releaseStopFoodReason("ClsRelicDiscoverUI_show")
	end
end

function ClsRelicDiscoverUI:initUI()	
	--更新等级
	self.m_player_lv_n = getGameData():getPlayerData():getLevel()
	
	--添加基本层
	self.m_panel = GUIReader:shareReader():widgetFromJsonFile("json/relic.json")
	self:addWidget(self.m_panel)
	
	self.m_main_layer = display.newLayer()
	self:addChild(self.m_main_layer)

	local color_layer = CCLayerColor:create(ccc4(0, 0, 0, 255*0.65))
	self.m_panel:addCCNode(color_layer)

	self.m_bg_spr = getConvertChildByName(self.m_panel, "bg")
	self.m_question_panel = getConvertChildByName(self.m_panel, "question_panel")
	self.m_relic_desc_ui = getConvertChildByName(self.m_panel, "relic_panel")
	self.m_unknow_panel = getConvertChildByName(self.m_panel, "find_panel")
	self.unlock_panel = getConvertChildByName(self.m_panel, "unlock_panel")
	-------------------------发掘和探索panel初始化开始-------------------------
	--方便接下来界面的各种变化
	--发掘按钮初始化
	self.dig_panel = getConvertChildByName(self.m_panel, "dig_panel")
	local comsume_manager = {}
	self.dig_panel.comsume_manager = comsume_manager

	function self.dig_panel:setValueByKind(kind, value, color)
		self.comsume_manager.objs[kind]:setText(value, color)
	end

	comsume_manager.title = getConvertChildByName(self.dig_panel, "consume_text")
	comsume_manager.objs = {}

	function comsume_manager:setVisible(enable)
		self.title:setVisible(enable)
		for k, v in ipairs(self.objs) do
			v:setVisible(enable)
		end
	end

	local comsume_obj = {}
	function comsume_obj:setVisible(enable)
		self.icon:setVisible(enable)
		self.num:setVisible(enable)
	end

	function comsume_obj:setText(value, color)
		self.num:setText(value)
		if color then
			self.num:setUILabelColor(color)
		end
	end

	comsume_obj.icon = getConvertChildByName(self.dig_panel, "consume_gold_icon")
	comsume_obj.num = getConvertChildByName(self.dig_panel, "consume_num")
	comsume_obj.kind = CONSUME_KIND_GOLD
	comsume_manager.objs[CONSUME_KIND_GOLD] = comsume_obj

	local btn_dig = getConvertChildByName(self.dig_panel, "btn_dig")
	btn_dig:setPressedActionEnabled(true)
	self.dig_panel.btn = btn_dig
	self.btn_dig = btn_dig
	
	self.dig_panel.btn.last_time = 0
	self.dig_panel.btn:addEventListener(function()--发掘
		if CCTime:getmillistimeofCocos2d() - self.dig_panel.btn.last_time < 500 then return end
		self.dig_panel.btn.last_time = CCTime:getmillistimeofCocos2d()
		if self.m_is_show_up_star_eff_b then return end

		local star = (self.m_relic_info.star or 0) + 1
		if star > self.m_relic_info.relicInfo.max_star then
			star = self.m_relic_info.relicInfo.max_star
		end

		--等级限制判断
		local need_lv = relic_star_info[star].grade
		if self.m_player_lv_n < need_lv then
			ClsAlert:warning({msg = ui_word.DIG_LEVEL_NOT_ENOUGH})
			return
		end

		local cash_n = self:getNeedCash()
		local now_cash = getGameData():getPlayerData():getCash()
		if (now_cash < cash_n) and (self.m_is_discover_before_b) then
			ClsAlert:showJumpWindow(CASH_NOT_ENOUGH, self, {need_cash = cash_n, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE, come_name = "relic_discover", ignore_sea = true})
			return
		end
		self.m_collect_handle:relicActive(self.m_relic_info.id)
		self.dig_panel.btn:setTouchEnabled(false)
	end, TOUCH_EVENT_ENDED)

	local btn_dig_func = btn_dig.setVisible
	function btn_dig:setVisible(enable)
		btn_dig_func(self, enable)
		self:setTouchEnabled(enable)
	end
	
	local dig_panel_visible = self.dig_panel.setVisible
	function self.dig_panel:setVisible(enable)
		dig_panel_visible(self, enable)
		self.btn:setVisible(enable)
		self.comsume_manager:setVisible(enable)
	end

	--探索按钮
	self.explore_panel = getConvertChildByName(self.m_panel, "btn_bg_2")
	comsume_manager = {}
	self.explore_panel.comsume_manager = comsume_manager

	function self.explore_panel:setValueByKind(kind, value, color)
		self.comsume_manager.objs[kind]:setText(value, color)
	end

	comsume_manager.title = getConvertChildByName(self.explore_panel, "btn_explore_text_2")
	comsume_manager.times = getConvertChildByName(self.explore_panel, "explore_time_num_2")
	comsume_manager.objs = {}

	function comsume_manager:setVisible(enable)
		self.title:setVisible(enable)
		self.times:setVisible(enable)
		for k, v in ipairs(self.objs) do
			v:setVisible(enable)
		end
	end

	local explore_panel_consume_info = {
		[1] = {icon = "cost_power_icon_2", num = "cost_power_num_2", kind = CONSUME_KIND_POWER},
		[2] = {icon = "cost_gold_icon_2", num = "cost_gold_num_2", kind = CONSUME_KIND_GOLD},
	}

	for k, v in ipairs(explore_panel_consume_info) do
		local comsume_obj = {}
		function comsume_obj:setVisible(enable)
			self.icon:setVisible(enable)
			self.num:setVisible(enable)
		end

		function comsume_obj:setText(value, color)
			self.num:setText(value)
			if color then
				self.num:setUILabelColor(color)
			end
		end
		comsume_obj.kind = v.kind
		comsume_obj.icon = getConvertChildByName(self.explore_panel, v.icon)
		comsume_obj.num = getConvertChildByName(self.explore_panel, v.num)
		comsume_manager.objs[v.kind] = comsume_obj
	end

	local btn_explore = getConvertChildByName(self.explore_panel, "btn_explore_icon_2")
	btn_explore:setPressedActionEnabled(true)
	self.explore_panel.btn = btn_explore
	self.btn_explore = btn_explore

	self.explore_panel.btn.last_time = 0
	self.explore_panel.btn:addEventListener(function()--探索
		if CCTime:getmillistimeofCocos2d() - self.explore_panel.btn.last_time < 500 then return end
		self.explore_panel.btn.last_time = CCTime:getmillistimeofCocos2d()

		if self.m_relic_info.canGetDailyReward == 0 then
			ClsAlert:warning({msg = error_info[673].message})
			return
		end

		local player_data = getGameData():getPlayerData()
		local current_power = player_data:getPower()
		local current_cash = player_data:getCash()
		local star = (self.m_relic_info.star or 0) + 1
		local star_info = relic_star_info[star]
		local power = star_info.explore_consume_power
		local cash = star_info.explore_consume_cash

		if current_power < power then
			ClsAlert:showJumpWindow(POWER_NOT_ENOUGH, self, {need_power = power, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE, come_name = "relic_discover", ignore_sea = true})
			return
		end

		if current_cash < cash then
			ClsAlert:showJumpWindow(CASH_NOT_ENOUGH, self, {need_cash = cash, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE, come_name = "relic_discover", ignore_sea = true})
			return
		end

		self.m_collect_handle:relicExplore(self.m_relic_info.id)
	end, TOUCH_EVENT_ENDED)

	local btn_explore_func = btn_explore.setVisible
	function btn_explore:setVisible(enable)
		btn_explore_func(self, enable)
		self:setTouchEnabled(enable)
	end

	--扫荡按钮
	self.sweep_panel = getConvertChildByName(self.m_panel, "btn_bg_1")
	self.sweep_panel.icon = getConvertChildByName(self.sweep_panel, "btn_explore_diamond")
	comsume_manager = {}
	self.sweep_panel.comsume_manager = comsume_manager

	function self.sweep_panel:setValueByKind(kind, value, color)
		self.comsume_manager.objs[kind]:setText(value, color)
	end

	comsume_manager.title = getConvertChildByName(self.sweep_panel, "btn_explore_text_1")
	comsume_manager.times = getConvertChildByName(self.sweep_panel, "explore_time_num_1")
	comsume_manager.objs = {}

	function comsume_manager:setVisible(enable)
		self.title:setVisible(enable)
		self.times:setVisible(enable)
		self.icon:setVisible(enable)

		for k, v in ipairs(self.objs) do
			v:setVisible(enable)
		end
	end

	local sweep_panel_consume_info = {
		[1] = {icon = "cost_gold_icon_1", num = "cost_gold_num_1", kind = CONSUME_KIND_DIAMOND},
	}

	for k, v in ipairs(sweep_panel_consume_info) do
		local comsume_obj = {}
		function comsume_obj:setVisible(enable)
			self.icon:setVisible(enable)
			self.num:setVisible(enable)
		end

		function comsume_obj:setText(value, color)
			self.num:setText(value)
			if color then
				self.num:setUILabelColor(color)
			end
		end

		comsume_obj.kind = v.kind
		comsume_obj.icon = getConvertChildByName(self.sweep_panel, v.icon)
		comsume_obj.num = getConvertChildByName(self.sweep_panel, v.num)
		comsume_manager.objs[v.kind] = comsume_obj
	end

	local btn_sweep = getConvertChildByName(self.sweep_panel, "btn_explore_icon_1")
	btn_sweep:setPressedActionEnabled(true)
	self.sweep_panel.btn = btn_sweep

	self.sweep_panel.btn.last_time = 0
	self.sweep_panel.btn:addEventListener(function()
		if CCTime:getmillistimeofCocos2d() - self.sweep_panel.btn.last_time < 500 then return end
		self.sweep_panel.btn.last_time = CCTime:getmillistimeofCocos2d()

		if self.m_relic_info.advanceExplore ~= 1 then
			ClsAlert:warning({msg = error_info[673].message})
			return
		end
		
		local player_data = getGameData():getPlayerData()
		local current_diamond = player_data:getGold()
		local star = (self.m_relic_info.star or 0) + 1
		local star_info = relic_star_info[star]
		local need_diamond = star_info.explore_consume_diamond

		if current_diamond < need_diamond then
			ClsAlert:warning({msg = ui_word.TIP_NONENOUGH_DIAMOD_STR})
			return
		end

		local show_txt = string.format(ui_word.RELIC_SWEEP_TIP, need_diamond)
		ClsAlert:showAttention(show_txt, function()
	        self.m_collect_handle:relicExplore10(self.m_relic_info.id)
	    end)

	end, TOUCH_EVENT_ENDED)

	local btn_sweep_func = btn_sweep.setVisible
	function btn_sweep:setVisible(enable)
		btn_sweep_func(self, enable)
		self:setTouchEnabled(enable)
	end
	-------------------------发掘和探索panel初始化结束-------------------------

	self.m_relic_card_ui = getConvertChildByName(self.m_panel, "relic_card_frame")
	self.m_warning_lab = getConvertChildByName(self.m_panel, "red_level_tips")
	self.m_finish_lab = getConvertChildByName(self.m_panel, "all_finish_lab")
	self.m_close_btn = getConvertChildByName(self.m_panel, "btn_close")
	
	self.m_relic_card_ui.relic_spr = getConvertChildByName(self.m_relic_card_ui, "relic_card")
	self.m_relic_card_ui.stars_panel = getConvertChildByName(self.m_relic_card_ui, "stars_panel")
	self.m_relic_card_ui.name_lab = getConvertChildByName(self.m_relic_card_ui, "card_title")

	self.m_relic_card_ui.stars_ui = {}
	for i = 1, MAX_STAR_COUNT do
		local star_info = {}
		star_info.star_bg_spr = getConvertChildByName(self.m_relic_card_ui.stars_panel, "star_bg_"..i)
		star_info.star_spr = getConvertChildByName(self.m_relic_card_ui.stars_panel, "star_"..i)
		self.m_relic_card_ui.stars_ui[i] = star_info
	end
	local stars_panel_pos = self.m_relic_card_ui.stars_panel:getPosition()
	self.m_relic_card_ui.stars_panel.org_pos = {x = stars_panel_pos.x, y = stars_panel_pos.y}
	self.m_relic_card_ui.is_first_update = true
	local relic_card_ui_pos = self.m_relic_card_ui:getPosition()
	self.m_relic_card_ui.org_pos = {x = relic_card_ui_pos.x, y = relic_card_ui_pos.y}
	
	self.m_relic_desc_ui.name_lab = getConvertChildByName(self.m_relic_desc_ui, "title")
	self.m_relic_desc_ui.desc_lab = getConvertChildByName(self.m_relic_desc_ui, "describe_info")
	self.m_relic_desc_ui.per_lab = getConvertChildByName(self.m_relic_desc_ui, "explore_info_1")
	self.m_relic_desc_ui.num_lab = getConvertChildByName(self.m_relic_desc_ui, "bar_num")
	self.m_relic_desc_ui.progress_bar = getConvertChildByName(self.m_relic_desc_ui, "bar")
	self.m_relic_desc_ui.per_tip_lab = getConvertChildByName(self.m_relic_desc_ui, "explore_text_2")
	self.m_relic_desc_ui.rewards_panel = getConvertChildByName(self.m_relic_desc_ui, "rewards_panel")
	
	self.m_relic_desc_ui.per_tip_lab.org_text_str = self.m_relic_desc_ui.per_tip_lab:getStringValue()
	self.m_relic_desc_ui.rewards_ui = {}
	for i = 1, 2 do
		local reward_ui = {}
		reward_ui.icon_spr = getConvertChildByName(self.m_relic_desc_ui.rewards_panel, "reward_pic_"..i)
		reward_ui.name_lab = getConvertChildByName(self.m_relic_desc_ui.rewards_panel, "reward_lab_"..i)
		self.m_relic_desc_ui.rewards_ui[i] = reward_ui
	end
	
	self.m_question_panel.confirm_btn = getConvertChildByName(self.m_question_panel, "btn_confirm")
	self.m_question_panel.question_lab = getConvertChildByName(self.m_question_panel, "question_text")
	self.m_question_panel.choices_ui = {}
	for i = 1, 4 do
		local choice_ui = {}
		choice_ui.btn = getConvertChildByName(self.m_question_panel, "btn_"..i)
		choice_ui.answer_lab = getConvertChildByName(self.m_question_panel, "answer_"..i)
		self.m_question_panel.choices_ui[i] = choice_ui
	end
	
	self.m_bg_spr:setVisible(not self.m_is_only_show_info_b)
	
	--关闭按钮
	self.m_close_btn:setPressedActionEnabled(true)
	self.m_close_btn:addEventListener(function()
		if self.m_is_answer_question_b then
			return
		end
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		if self.m_close_callback then
			self.m_close_callback()
		end
	end, TOUCH_EVENT_ENDED)
	
	local relic_data = self.m_relic_info.relicInfo
	
	--创建遗迹图片
	self:updateRelicIcon()
	
	--创建遗迹星级显示
	self.m_relic_total_star_num_n = relic_data.max_star
	self:updateRelicStarsShow()

	if self.m_is_only_show_info_b then
		self:setHideBeforeView(false)
		if self.m_is_discover_before_b then
			self.m_relic_desc_ui:setVisible(true)
			self:onlyShowInfo()
			self:updateHadDiscoverUI()
		else
			self.m_relic_desc_ui:setVisible(false)
			self:onlyShowInfo()
			--显示解锁条件
			if self:showUnlockCond() then
				self.unlock_panel:setVisible(false)
			end
		end
		return
	else
		local collect_data_handle = getGameData():getCollectData()
		local is_discovery = collect_data_handle:isDiscoveryRelic(self.m_relic_info.id)
		if self.m_is_discover_before_b then
			self:updateHadDiscoverUI()
		elseif not is_discovery then
			self:updateNotDiscoveryUI()
			return
		else
			self:updateNotDigUI()
			return
		end
	end

	self:updateBtns()
	if self.m_relic_info.status then
		if STATE_NEED_CLEAR_SOMETHING == self.m_relic_info.status then
			--如果是显示答题
			self:judgeEventType()
		elseif STATE_NEED_GET_REWARD == self.m_relic_info.status then
			--如果是显示领取
			self:starStarRewardEff()
		end
	end

    ClsGuideMgr:tryGuide("ClsRelicDiscoverUI")
end

function ClsRelicDiscoverUI:onlyShowInfo()
	self.dig_panel:setVisible(false)
	self.explore_panel:setVisible(false)
	self.sweep_panel:setVisible(false)
	self.m_warning_lab:setVisible(false)
end

function ClsRelicDiscoverUI:updateNotDiscoveryUI()
	self.m_relic_desc_ui:setVisible(false)
	self.explore_panel:setVisible(false)
	self.dig_panel:setVisible(false)
	self.sweep_panel:setVisible(false)
end

function ClsRelicDiscoverUI:updateNotDigUI()
	self.m_relic_desc_ui:setVisible(false)
	self.explore_panel:setVisible(false)
	self.dig_panel:setVisible(false)
	self.sweep_panel:setVisible(false)
	if self:showUnlockCond() then
		self.unlock_panel:setVisible(false)
		self.dig_panel:setVisible(true)
		self.dig_panel.comsume_manager:setVisible(false)
	end
end

function ClsRelicDiscoverUI:showUnlockCond()
	local active_conditions = self.m_relic_info.relicInfo.active_conds
	local is_ok = true
	if active_conditions and #active_conditions > 0 then
		self.unlock_panel:setVisible(true)
		self.show_labels = {}
		for k = 1, 6 do
			local name = string.format("nulock_text_%s", k)
			local show_label = getConvertChildByName(self.unlock_panel, name)
			show_label:setVisible(false)
			self.show_labels[#self.show_labels + 1] = show_label
		end
		for k, v in ipairs(active_conditions) do
			local show_label = self.show_labels[k]
			show_label:setVisible(true)
			local text = self.m_collect_handle:getShowText(v)
			local color = COLOR_GREEN
			local relic_data = getGameData():getRelicData()
			if not relic_data:isUnlockOk(self.m_relic_info.id, v) then
				is_ok = false
				color = COLOR_RED
			end 
			show_label:setText(text)
			show_label:setUILabelColor(color)
		end
	end
	return is_ok
end

--成功第一次打开遗迹
function ClsRelicDiscoverUI:startFirstOpenRelic()
	--更新遗迹ui
	self:updateRelicIcon()
	self:updateRelicStarsShow()
	self:updateHadDiscoverUI()
	self:updateBtns()
	
	--播放特效
	local open_eff = nil
	open_eff = ClsCompositeEffect.new("tx_0040", 273, 282, self.m_main_layer, nil, function()
		open_eff:removeFromParentAndCleanup(true)
		open_eff:removeTexture()
	end)
	open_eff:setZOrder(5)
	audioExt.playEffect(music_info.UNLOCK_RELIC.res)
end

--更新遗迹图片显示（有可能从未知的变成已知的某个）
function ClsRelicDiscoverUI:updateRelicIcon()
	--创建对应图片
	local is_discover_b = self.m_is_discover_before_b
	local relic_data = self.m_relic_info.relicInfo
	if not self.m_is_discover_before_b then
		self.m_unknow_panel:setVisible(true)
		self.m_relic_card_ui:setVisible(false)
	elseif self.m_relic_card_ui.is_discover_b ~= is_discover_b then
		self.m_relic_card_ui.relic_spr:changeTexture("ui/yiji/" .. relic_data.res, UI_TEX_TYPE_LOCAL)
		self.m_unknow_panel:setVisible(false)
		self.m_relic_card_ui:setVisible(true)
		self.m_relic_card_ui.name_lab:setText(relic_data.name)
	end
	self.m_relic_card_ui.is_discover_b = is_discover_b
end

--更新对应的星星ui
function ClsRelicDiscoverUI:updateRelicStarsShow()
	if not self.m_is_discover_before_b then
		return
	end
	local total_star_num = self.m_relic_total_star_num_n
	local relic_data = self.m_relic_info.relicInfo
	local cur_star_num = self.m_relic_info.star or 0
	local stars_ui = self.m_relic_card_ui.stars_ui
	local stars_panel = self.m_relic_card_ui.stars_panel
	local stars_panel_width = stars_panel:getSize().width
	local single_star_offset = (stars_panel_width * 0.5) / MAX_STAR_COUNT
	stars_panel:setPosition(ccp(stars_panel.org_pos.x + (MAX_STAR_COUNT - total_star_num) * single_star_offset, stars_panel.org_pos.y))
	for i = 1, MAX_STAR_COUNT do
		local star_ui = stars_ui[i]
		if i <= total_star_num then
			star_ui.star_bg_spr:setVisible(true)
			if i <= cur_star_num then
				if not star_ui.star_spr.is_lock then
					star_ui.star_spr:setVisible(true)
				end
			else
				star_ui.star_spr:setVisible(false)
			end
		else
			star_ui.star_bg_spr:setVisible(false)
		end
	end
end

--更新探索后的ui
function ClsRelicDiscoverUI:updateHadDiscoverUI()
	local relic_data = self.m_relic_info.relicInfo
	local max_star_n = relic_data.max_star or 1
	local relic_star_item = relic_star_info[max_star_n]
	local max_explore_point_n = relic_star_item.explorePoint
	local now_explore_point_n = self.m_relic_info.explorePoint
	local per_n = math.floor(now_explore_point_n/max_explore_point_n*100 + 0.5)
	local now_star_n = self.m_relic_info.star or 0
	local show_star_reward_n = self.m_collect_handle:getRelicRewardStar(self.m_relic_info.id)
	local need_per_n = 100
	if show_star_reward_n > max_star_n then
		show_star_reward_n = max_star_n
	end
	if relic_star_info[now_star_n + 1] and (now_star_n < max_star_n) then
		need_per_n = math.floor(relic_star_info[show_star_reward_n].explorePoint/max_explore_point_n*100 + 0.5)
	end
	if per_n > 100 then
		per_n = 100
	end
	if need_per_n > 100 then
		need_per_n = 100
	end
	
	self.m_relic_desc_ui.per_lab:setText(per_n.."%")
	self.m_relic_desc_ui.per_tip_lab:setText(string.format(self.m_relic_desc_ui.per_tip_lab.org_text_str, need_per_n.."%"))
	
	--描述页面的特效
	local desc_lab = self.m_relic_desc_ui.desc_lab
	if not desc_lab.is_played_act and not desc_lab.is_playing_act then
		desc_lab.is_playing_act = true
		self.m_relic_desc_ui.name_lab:setText(relic_data.name)
		local dec_str = relic_data.desc or "nil"
		local dec_lab_cut_tab = ClsRelicPanelView:spliteString(dec_str, 1)
		local dec_lab_cut_count_n = 1
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.15))
		array:addObject(CCCallFunc:create(function()
			if type(dec_lab_cut_tab) == "table" then
				if dec_lab_cut_count_n > #dec_lab_cut_tab then
					desc_lab:stopAllActions()
					desc_lab.is_played_act = true
					desc_lab.is_playing_act = false
					return
				end
			end
			if not tolua.isnull(desc_lab) then
				local str = ""
				for i = 1, dec_lab_cut_count_n do
					str = str .. dec_lab_cut_tab[i]
				end
				desc_lab:setText(str)
			else
				desc_lab:stopAllActions()
				return
			end
			dec_lab_cut_count_n = dec_lab_cut_count_n + 1
		end))
		desc_lab:runAction(CCRepeatForever:create(CCSequence:create(array)))
	end
	--更新进度条特效和显示
	self:updateProgressShow(self.m_relic_card_ui.is_first_update)
	self.m_relic_card_ui.is_first_update = false
	self.m_relic_desc_ui:setVisible(true)
	self.m_close_btn:setVisible(true)
	
	--优化，如果一样，则不更新
	if self.m_relic_desc_ui.rewards_panel.show_star_n and (self.m_relic_desc_ui.rewards_panel.show_star_n == show_star_reward_n) then
		return
	end

	local path = string.format("game_config/relic/relic_%s_info", self.m_relic_info.id)
	local relic_reward = require(path)

	local show_reward = {}
	for k, v in ipairs(relic_reward) do
		if v.star == show_star_reward_n then
			show_reward[#show_reward + 1] = v
		end
	end

	local offset_x = 40
	local rewards_ui = self.m_relic_desc_ui.rewards_ui
	for i, reward_ui in ipairs(rewards_ui) do
		local reward_item = show_reward[i]
		if reward_item then
			reward_ui.icon_spr:setVisible(true)
			reward_ui.name_lab:setVisible(true)
			
			local reward_info = getCommonRewardData(reward_item)
			local icon_str, amount_n, scale_n, name_str = getCommonRewardIcon(reward_info)
			reward_ui.icon_spr:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
			local icon_pos_y = reward_ui.icon_spr:getPosition().y
			reward_ui.icon_spr:setPosition(ccp(offset_x, icon_pos_y))
			autoScaleWithLength(reward_ui.icon_spr, 38)
			
			offset_x = offset_x + 20
			reward_ui.name_lab:setText(tostring(name_str) .. "x" .. amount_n)
			local lab_pos_y = reward_ui.name_lab:getPosition().y
			reward_ui.name_lab:setPosition(ccp(offset_x, lab_pos_y))
			
			offset_x = offset_x + reward_ui.name_lab:getContentSize().width + 50
		else
			reward_ui.icon_spr:setVisible(false)
			reward_ui.name_lab:setVisible(false)
		end
	end
	self.m_relic_desc_ui.rewards_panel.show_star_n = show_star_reward_n
end

function ClsRelicDiscoverUI:updateCashCall()
	if tolua.isnull(self) then return end
	--发掘需要花费
	local cash_n = self:getNeedCash()
	local now_cash = getGameData():getPlayerData():getCash()
	local color = COLOR_GREEN_STROKE
	if now_cash < cash_n then
		color = COLOR_RED
	end

	self.dig_panel:setValueByKind(CONSUME_KIND_GOLD, tostring(cash_n), color)

	--探索需要花费	
	local next_star = (self.m_relic_info.star or 0) + 1
	local star_info = relic_star_info[next_star]
	if not star_info then return end
	local cash = star_info.explore_consume_cash
	color = COLOR_GREEN_STROKE
	if now_cash < cash then
		color = COLOR_RED
	end

	self.explore_panel:setValueByKind(CONSUME_KIND_GOLD, tostring(cash), color)
end

function ClsRelicDiscoverUI:updateDiamondCall()
	if tolua.isnull(self) then return end
	--扫荡花费的钻石
	local next_star = (self.m_relic_info.star or 0) + 1
	local star_info = relic_star_info[next_star]
	if not star_info then return end
	local diamond = star_info.explore_consume_diamond
	local now_diamond = getGameData():getPlayerData():getGold()
	color = COLOR_GREEN_STROKE
	if now_diamond < diamond then
		color = COLOR_RED
	end
	self.sweep_panel:setValueByKind(CONSUME_KIND_DIAMOND, tostring(diamond), color)
end

function ClsRelicDiscoverUI:updatePowerCall()
	--一次
	local now_power = getGameData():getPlayerData():getPower()
	local next_star = (self.m_relic_info.star or 0) + 1
	local star_info = relic_star_info[next_star]
	local power = star_info.explore_consume_power
	local color = COLOR_GREEN_STROKE
	if now_power < power then
		color = COLOR_RED
	end

	self.explore_panel:setValueByKind(CONSUME_KIND_POWER, tostring(power), color)
end

--更新发掘和探索按钮
function ClsRelicDiscoverUI:updateBtns()
	if tolua.isnull(self) then return end

	if self.m_is_answer_question_b or self.m_is_show_up_star_eff_b then
		self.dig_panel:setVisible(false)
		self.m_warning_lab:setVisible(false)
		self.explore_panel:setVisible(false)
		self.sweep_panel:setVisible(false)
		return
	end

	--判断是否能发掘
	local relic_data_handler = getGameData():getRelicData()
	local is_can_dig = true
	local next_need_lv = nil
	if self.m_relic_info.dig == 0 then--表示该遗迹只是发现了没有发掘过
		local is_unlock_relic = relic_data_handler:isUnlockTotalOk(self.m_relic_info.id)
		if is_unlock_relic then--表示条件解锁了(没有条件也算条件解锁)
			local next_star = (self.m_relic_info.star or 0) + 1
			next_need_lv = relic_star_info[next_star].grade
			if self.m_player_lv_n < next_need_lv then
				is_can_dig = false
				local show_txt = string.format("%s%s%s", ui_word.RELIC_NEED_SAILOR_SKILL, tostring(next_need_lv), ui_word.RELIC_NEED_SAILOR_SKILL_2)
				self.m_warning_lab:setText(show_txt)
				self.m_warning_lab:setVisible(true)
			else
				self.m_warning_lab:setVisible(false)
			end
		else
			is_can_dig = false
			self:showUnlockCond()
		end
	elseif self.m_relic_info.dig >= 1 then--表示遗迹发掘过
		self.m_warning_lab:setVisible(false)
		if self.m_relic_info.star == self.m_relic_info.relicInfo.max_star then
			is_can_dig = false
			self.m_finish_lab:setVisible(true)
		else
			local next_star = (self.m_relic_info.star or 0) + 1
			next_need_lv = relic_star_info[next_star].grade
			if self.m_player_lv_n < next_need_lv then
				is_can_dig = false
			else
				local status = self.m_relic_info.status
				if status and (STATE_NORMAL ~= status) then
					is_can_dig = false
				end
			end
		end
	end

	self.dig_panel:setVisible(is_can_dig)
	if not self.m_is_discover_before_b then--是否发掘过遗迹
		self.dig_panel.comsume_manager:setVisible(false)
	end

	--判断是否能进行一次探索
	local show_explore_one = true
	local is_show_tip = (not is_can_dig and self.m_relic_info.status ~= STATE_FINISH)
	if self.m_relic_info.dig == 0 then--没有发掘过
		show_explore_one = false
	else
		if is_can_dig then
			show_explore_one = false
		else
			local status = self.m_relic_info.status
			if not (STATE_NORMAL == status or STATE_FINISH == status) then
				show_explore_one = false
				is_show_tip = false
			end
		end 
	end

	if show_explore_one then
		local remain_time = 1
		local color = COLOR_WHITE_STROKE
		if self.m_relic_info.canGetDailyReward == 0 then
			color = COLOR_RED
			remain_time = 0
		end
		if remain_time == 1 then
			is_show_tip = false
		end

		self.explore_panel.comsume_manager.times:setText(string.format(ui_word.ACTIVITY_TIME_STR, remain_time, 1))
		self.explore_panel.comsume_manager.times:setUILabelColor(color)
	end
	self.explore_panel:setVisible(show_explore_one)

	if is_show_tip then
		local show_txt = string.format("%s%s%s", ui_word.RELIC_NEED_SAILOR_SKILL, tostring(next_need_lv), ui_word.RELIC_NEED_SAILOR_SKILL_2)
		self.m_warning_lab:setText(show_txt)
		self.m_warning_lab:setVisible(true)
	end
	
	local show_explore_ten = true
	if self.m_relic_info.dig == 0 then
		show_explore_ten = false
	else
		if is_can_dig then
			show_explore_ten = false
		else
			if self.m_relic_info.advanceExplore == 0 then
				show_explore_ten = false
			else
				local status = self.m_relic_info.status
				if not (STATE_NORMAL == status or STATE_FINISH == status) then
					show_explore_ten = false
				end
			end
		end
	end

	if show_explore_ten then
		local remain_time = 1
		local color = COLOR_WHITE_STROKE
		if self.m_relic_info.advanceExplore == 2 then
			remain_time = 0
			color = COLOR_RED
		end
		self.sweep_panel.comsume_manager.times:setText(string.format(ui_word.ACTIVITY_TIME_STR, remain_time, 1))
		self.sweep_panel.comsume_manager.times:setUILabelColor(color)
	end
	self.sweep_panel:setVisible(show_explore_ten)

	self:updateCashCall()
	self:updatePowerCall()
	self:updateDiamondCall()
	ClsGuideMgr:tryGuide("ClsRelicDiscoverUI")
end

--更新进度条的显示
function ClsRelicDiscoverUI:updateProgressShow(is_not_show_effect_n)
	local progress_bar = self.m_relic_desc_ui.progress_bar
	local relic_data = self.m_relic_info.relicInfo
	local max_star_n = relic_data.max_star or 1
	local relic_star_item = relic_star_info[max_star_n]
	local max_explore_point_n = relic_star_item.explorePoint
	local now_explore_point_n = self.m_relic_info.explorePoint
	local per_n = math.floor(now_explore_point_n / max_explore_point_n * 100 + 0.5)
	if per_n > 100 then
		per_n = 100
	end
	
	--设置进度
	progress_bar.new_per_n = per_n
	--设置数字提升特效
	local progress_num_lab = self.m_relic_desc_ui.num_lab
	if is_not_show_effect_n then
		progress_num_lab:setText(tostring(now_explore_point_n))
		progress_num_lab.show_num_n = now_explore_point_n
		progress_bar:setPercent(per_n)
	else
		local before_num_n = progress_num_lab.show_num_n or 0
		if before_num_n ~= now_explore_point_n then
			ClsUiCommon:numberEffect(progress_num_lab, before_num_n, now_explore_point_n, nil, nil, nil, nil, function(now_num, end_num)
				if not tolua.isnull(progress_num_lab) then
					progress_num_lab.show_num_n = now_num
					local per_n = math.floor(100*now_num/max_explore_point_n)
					progress_bar:setPercent(per_n)
					progress_bar.new_per_n = per_n
				end
			end)
		end
	end
end

--开始播放获取星级奖励的特效
function ClsRelicDiscoverUI:starStarRewardEff(is_show_effect_b)
	self.dig_panel:setVisible(false)
	self.explore_panel:setVisible(false)
	self.sweep_panel:setVisible(false)
	self.m_close_btn:setVisible(false)

	local scale_time_n = 0.12
	local box_eff = nil
	local back_spr = getChangeFormatSprite("ui/yiji/" .. self.m_relic_info.relicInfo.res, 0, 0)
	back_spr:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self.m_relic_card_ui:addCCNode(back_spr)
	back_spr:setVisible(false)
	local star_ui = self.m_relic_card_ui.stars_ui[self.m_relic_info.star]
	local star_bg_spr = star_ui.star_bg_spr
	if is_show_effect_b then
		star_ui.star_spr.is_lock = true
		star_ui.star_spr:setVisible(false)
	end
	
	local array = CCArray:create()
	if is_show_effect_b then
		self.m_is_show_up_star_eff_b = true
		--先播进度条特效
		local progress_bar = self.m_relic_desc_ui.progress_bar
		local scale_n = progress_bar.new_per_n/100
		local progress_eff_spr = display.newSprite()
		local progress_bar_pos = progress_bar:getWorldPosition()
		local progress_bar_width = progress_bar:getContentSize().width
		local x = progress_bar_pos.x - (progress_bar_width * progress_bar:getAnchorPoint().x)
		local y = progress_bar_pos.y
		progress_eff_spr:setPosition(x + progress_bar_width*scale_n*0.5, y)
		progress_eff_spr:setScaleX(scale_n)
		self.m_main_layer:addChild(progress_eff_spr, 5)
		local progress_eff = nil
		progress_eff = ClsCompositeEffect.new("tx_0081", 3, 0.5, progress_eff_spr, nil, function()
			progress_eff:removeFromParentAndCleanup(true)
			progress_eff_spr:removeFromParentAndCleanup(true)
		end)
		
		local move_time_n = 0.2
		local move_particle = CCParticleSystemQuad:create("effects/tx_0080tuowei01.plist")
		move_particle:setPosition(ccp(x, y - 2))
		self.m_main_layer:addChild(move_particle, 100)
		local eff_particle = CCParticleSystemQuad:create("effects/tx_0080tuowei02.plist")
		eff_particle:setPosition(ccp(0, 0))
		move_particle:addChild(eff_particle)
		move_particle:runAction(CCMoveTo:create(move_time_n, ccp(x + progress_bar_width * scale_n, y)))
		
		array:addObject(CCDelayTime:create(move_time_n + 0.2))
		array:addObject(CCCallFunc:create(function()
			local part_arr = CCArray:create()
			part_arr:addObject(CCDelayTime:create(0.2))
			part_arr:addObject(CCCallFunc:create(function()
				local star_pos = star_bg_spr:getWorldPosition()
				local org_pos = self.m_relic_card_ui:getWorldPosition()
				move_particle:runAction(CCMoveTo:create(0.3, ccp(star_pos.x + display.cx - org_pos.x, star_pos.y + display.cy - org_pos.y)))
			end))
			move_particle:stopAllActions()
			move_particle:runAction(CCSequence:create(part_arr))
			self.m_relic_desc_ui:setVisible(false)
		end))
		array:addObject(CCMoveTo:create(0.5, ccp(display.cx, display.cy)))
		array:addObject(CCCallFunc:create(function() 
			move_particle:stopAllActions()
			move_particle:removeFromParentAndCleanup(true)
			local star_eff_spr = display.newSprite()
			star_eff_spr:setScale(2)
			star_bg_spr:addCCNode(star_eff_spr)
			star_eff_spr:setZOrder(10)
			star_bg_spr.star_eff_spr = star_eff_spr
			ClsCompositeEffect.new("tx_0080hit", -1, -2, star_eff_spr, nil, function() end)
		end))
		array:addObject(CCDelayTime:create(0.7))
		array:addObject(CCCallFunc:create(function() --清除特效
			if not tolua.isnull(star_bg_spr.star_eff_spr) then
				star_bg_spr.star_eff_spr:removeFromParentAndCleanup()
				star_bg_spr.star_eff_spr = nil
				star_ui.star_spr.is_lock = nil
				self:updateRelicStarsShow()
			end
		end))
	else
		self.m_relic_card_ui:setPosition(ccp(display.cx, display.cy))
		self.m_relic_desc_ui:setVisible(false)
	end

	for i = 1, 2 do
		if is_show_effect_b then
			array:addObject(CCScaleTo:create(scale_time_n,0,1))
			array:addObject(CCCallFunc:create(function()
				back_spr:setVisible(true)
			end))
			array:addObject(CCScaleTo:create(scale_time_n,-1,1))
			array:addObject(CCScaleTo:create(scale_time_n,0,1))
		end
		
		local i_n = i
		array:addObject(CCCallFunc:create(function()
			back_spr:setVisible(false)
			if i_n < 2 then return end
			
			local eff_spr = display.newSprite()
			self.m_relic_card_ui:addCCNode(eff_spr)
			eff_spr:setZOrder(20)
			self.m_relic_card_ui.eff_spr = eff_spr
			--领取按钮
			local pic_str = "#common_btn_close1.png"
			local reward_btn = MyMenuItem.new({image = pic_str, imageDisabled = pic_str, sound = "", x = 0 , y = -5})
			reward_btn:regCallBack(function()--领奖啦，少年
				reward_btn:setEnabled(false)
				local captainInfoData = getGameData():getCaptainInfoData()
				local cur_prosper, max_prosper = captainInfoData:getCurStepProsper()
				captainInfoData:setOldProsperInfo({level = captainInfoData:getCurInvestLevel(), cur_prosper = cur_prosper,  max_prosper = max_prosper})
				self.m_collect_handle:getRelicReward(self.m_relic_info.id)
			end)
			reward_btn:setScale(2.3)
			reward_btn:setOpacity(0)
			local reward_btn_menu = self:getMenuNode({reward_btn})
			self.m_menus["reward_btn"] = reward_btn_menu
			eff_spr:addChild(reward_btn_menu, 7)
			local tips_lab = createBMFont({text = ui_word.RELIC_REWARD_TIPS, fontFile = FONT_CFG_1, size = 20, x = 0, y = 100, color = ccc3(dexToColor3B(COLOR_GREEN_STROKE))})
			eff_spr:addChild(tips_lab, 8)
			
			self.m_armature_tab["box"] = "effects/box.ExportJson"
			LoadArmature({self.m_armature_tab["box"]})
			box_eff = CCArmature:create("box")
			box_eff:setPosition(7, 5)
			eff_spr:addChild(box_eff, 6)
		end))
		
		if is_show_effect_b then
			array:addObject(CCScaleTo:create(scale_time_n,1,1))
		end
	end
	array:addObject(CCCallFunc:create(function() --结束旋转回调
		back_spr:removeFromParentAndCleanup(true)
		self.m_is_show_up_star_eff_b = false
		if box_eff and (not tolua.isnull(box_eff)) then
			box_eff:getAnimation():playByIndex(0, -1, -1, 0)
			local seq_act = CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function() 
					if not tolua.isnull(self.m_relic_card_ui.eff_spr) then
						local box_bg_eff = ClsCompositeEffect.new("tx_0011", 3, -10, self.m_relic_card_ui.eff_spr, nil, function() end)
						box_bg_eff:setScale(0.5)
						box_bg_eff:setZOrder(5)
					end
				end))
			self.m_relic_card_ui.eff_spr:runAction(seq_act)
		end
	end))
	self.m_relic_card_ui:runAction(CCSequence:create(array))
end

-- 判定事件类型：水手单挑或回答问题
function ClsRelicDiscoverUI:judgeEventType()
	if not self.m_relic_info or not self.m_relic_info.relicInfo then return end
	local cur_step = self.m_relic_info.star + 1
	if cur_step > self.m_relic_info.relicInfo.max_star then return end
	if self.m_relic_info.relicInfo.event_type then
		local event_type = self.m_relic_info.relicInfo.event_type
		if event_type[cur_step] == EVENT_TYPE_ANSWER_QUESTION then
			self:showQuestion()
		elseif event_type[cur_step] == EVENT_TYPE_SAILOR_BATTLE then
			self:enterSailorBattle(self.m_relic_info.id, cur_step)
		end
	end
end

function ClsRelicDiscoverUI:getCurrentRelicInfo()
	return self.m_relic_info
end

--进入水手单挑
function ClsRelicDiscoverUI:enterSailorBattle(relic_id, step)
	ClsAlert:tipsWithCover({msg = ui_word.RELIC_DISCOVER_SAILOR_BATTLE})
	local collect_data_handle = getGameData():getCollectData()
	collect_data_handle:askEnterSailorBattle(relic_id, step)
end

function ClsRelicDiscoverUI:hideQuestionUi()
	for k, v in pairs(self.m_question_panel.choices_ui) do
		v.btn:setTouchEnabled(false)
		v.answer_lab:setTouchEnabled(false)
	end
	self.m_question_panel:setVisible(false)
end

--显示问题
function ClsRelicDiscoverUI:showQuestion()
	self.m_relic_desc_ui:setVisible(false)
	self.m_close_btn:setVisible(false)
	self.m_is_answer_question_b = true
	self.m_question_panel:setVisible(true)
	self.dig_panel:setVisible(false)
	self.sweep_panel:setVisible(false)
	self.explore_panel:setVisible(false)

	--随机获得一个问题
	local answer_item = {}
	local star_n = self.m_collect_handle:getRelicRewardStar(self.m_relic_info.id)
	local event_type_tab = self.m_relic_info.relicInfo.event_type
	local question_order_id = 0
	--先确定问题是哪一个
	for k, v in ipairs(event_type_tab) do
		if v == EVENT_TYPE_ANSWER_QUESTION then
			question_order_id = question_order_id + 1
		end
		if k >= star_n then
			break
		end
	end
	local count_n = 1
	for k, v in ipairs(relic_answers) do
		if self.m_relic_info.id == v.relic_id then
			if count_n >= question_order_id then
				answer_item = v
				answer_item.id = k
				break
			end
			count_n = count_n + 1
		end
	end

	local question_item = {}
	question_item.title = answer_item.question or "nil"
	local question = {}
	question[#question + 1] = answer_item.answer_1 or "nil1"
	question[#question + 1] = answer_item.answer_2 or "nil2"
	question[#question + 1] = answer_item.answer_3 or "nil3"
	question[#question + 1] = answer_item.answer_4 or "nil4"
	question_item.question = question
	question_item.true_answer_id = 1
	
	self.m_question_panel.question_lab:setText(question_item.title)
	self.m_question_panel.confirm_btn.select_index_n = 0
	local numbers_tab = {1, 2, 3, 4}
	for i = 1, 4 do
		local choice_ui_id = i
		local choice_ui = self.m_question_panel.choices_ui[i]
		local index_n = randomsSelectValue(numbers_tab, true)
		choice_ui.index_n = index_n
		choice_ui.answer_lab:setText(question[index_n])
		local touch_callback = function()
				for k, v in ipairs(self.m_question_panel.choices_ui) do
					if choice_ui_id == k then
						v.btn:setFocused(true)
						self.m_question_panel.confirm_btn.select_index_n = v.index_n
						self.m_question_panel.confirm_btn:setVisible(true)
						self.m_question_panel.confirm_btn:setTouchEnabled(true)
					else
						v.btn:setFocused(false)
					end
				end
			end
		choice_ui.answer_lab:setTouchEnabled(true)
		choice_ui.answer_lab:addEventListener(touch_callback, TOUCH_EVENT_ENDED)
		choice_ui.btn:setFocused(false)
		choice_ui.btn:setTouchEnabled(true)
		choice_ui.btn:addEventListener(touch_callback, TOUCH_EVENT_ENDED)
	end
	self.m_question_panel.confirm_btn:setTouchEnabled(false)
	self.m_question_panel.confirm_btn:setVisible(false)
	self.m_question_panel.confirm_btn:addEventListener(function()
		self.m_collect_handle:relicEventIsSucc(self.m_relic_info.id, answer_item.id, self.m_question_panel.confirm_btn.select_index_n)
		self.m_question_panel.confirm_btn:setTouchEnabled(false)
	end, TOUCH_EVENT_ENDED)
	
	--更新进度条（防止隐藏后出现特效异常）
	self:updateProgressShow(true)
end

--获取发掘所需的钱
function ClsRelicDiscoverUI:getNeedCash()
	local star_n = (self.m_relic_info.star or 0) + 1
	if star_n > self.m_relic_info.relicInfo.max_star then
		star_n = self.m_relic_info.relicInfo.max_star
	end
	local cash_n = relic_star_info[star_n].cash
	if not self.m_is_discover_before_b then
		cash_n = 0
	end
	return cash_n
end

function ClsRelicDiscoverUI:showRewardUI(rewards)
	getUIManager():create("gameobj/relic/clsRewardUI", nil, rewards)
end

function ClsRelicDiscoverUI:getMenuNode(items)
	items = items or {}
	if self.m_touch_priority then
		return MyMenu.new(items, self.m_touch_priority)
	end
	return MyMenu.new(items, nil, true)
end

return ClsRelicDiscoverUI