--------------------------- 战斗结算 ---------------------------
local news = require("game_config/news")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local composite_effect = require("gameobj/composite_effect")
local dataTools = require("module/dataHandle/dataTools")
local UiCommon = require("ui/tools/UiCommon")
local battleScene = require("gameobj/battle/battleScene")
local battle_scene_cfg = require("game_config/battle/battle_scene_cfg")
local ClsBaseView = require("ui/view/clsBaseView")

local DELAY_TIME = 0.5 --time for playing animation

local FIRST_BTN = 1
local SECOND_BTN = 2
local THIRD_BTN = 3

local MAX_AWARDS_LINE = 6 --4行奖励固定为星级奖励
--哪些是通用奖励,那么其他都是特殊奖励
local COMMON_REWARD = {
	[ITEM_INDEX_EXP] = true,
	[ITEM_INDEX_CASH] = true,
	[ITEM_INDEX_HONOUR] = true,
	[ITEM_INDEX_REPUTATION] = true,
}

local ClsBattleAccounts = class("ClsBattleAccounts", ClsBaseView)

function ClsBattleAccounts:onEnter(rewards, battle_result, call_back, relic_tag, is_get, star_rewards)
	setNetPause(true)
	
	local battle_data = getGameData():getBattleDataMt()	
	self.is_hide_btn = battle_data:GetData("is_hide_prestige_btn")

	self.item = battle_result or {}
	self.rewards = rewards
	self.star_rewards = star_rewards
	self.call_back = call_back
	self.relic_tag = relic_tag  -- 是否遗迹单挑结束
	self.is_get = is_get
	
	self.is_main_mission_battle = (battle_data:GetData("to_panel") == "main_mission_battle")
	self.is_relic =  (battle_data:GetData("to_panel") == "relic")
	print("=================结算界面数据==========")

	self.resPlist = {
		["ui/account_ui.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/shipyard_ui.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
	}
	LoadPlist(self.resPlist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/account_new.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	--背景图片
	self.bg = getConvertChildByName(self.panel, "bg")

	self.btn_next = getConvertChildByName(self.panel, "btn_go")
	self.btn_next:setVisible(false)

	self.btn_refresh = getConvertChildByName(self.panel, "btn_back")
	self.btn_refresh:setVisible(false)

	self:updateView()
	self:initEvent()

	self:showBtnsAndtouch()
    
    if self.item.battle_type ~= battle_config.fight_type_pve_elite_battle then
	    local act = UiCommon:getDelayAction(5, function()
	            self:touchEndCallBack()
	        end)
	    self:runAction(act)
	end
end

function ClsBattleAccounts:showBtnsAndtouch()
	local time = DELAY_TIME * 4
	if self.item.is_win then
		time = DELAY_TIME * 5
	end
	local arr = CCArray:create()
	if self.item.is_win then

		arr:addObject(CCDelayTime:create(time - DELAY_TIME * 2))
		arr:addObject(CCCallFunc:create(function()
			if self.item.is_win then
				self:initBtns()
			end
		end))
		arr:addObject(CCDelayTime:create(DELAY_TIME * 2))
	else
		arr:addObject(CCDelayTime:create(time))
	end

	arr:addObject(CCCallFunc:create(function()
	end))
	self:runAction(CCSequence:create(arr))
end
function ClsBattleAccounts:initEffects()
	local dy = 25
	if self.item.is_win then
		local pos_1 = ccp(-274, 80)
	    self.gaf_light_2 = composite_effect.new("tx_0011", pos_1.x, pos_1.y, self.bg, nil, nil, nil, nil, true)
	    self.gaf_light_2:setZOrder(1)

		local pos_2 = ccp(-274, 75)
	    local gaf_win_floor = composite_effect.new("tx_0018", pos_2.x, pos_2.y, self.bg, nil, nil, nil, nil, true)
	    gaf_win_floor:setZOrder(2)
	    
	    --碎花星
	    local pos_5 = ccp(-287, 120)
        local gaf_shanshan_star = composite_effect.new("tx_0017", pos_5.x, pos_5.y, self.bg, nil, nil, nil, nil, true)
        gaf_shanshan_star:setZOrder(5)
        
	    local funcs = function()
	        self.gaf_win_tanqi:removeFromParentAndCleanup(true)
	        
	        local pos_4 = ccp(-272, 75)
	        local gaf_win_shuaguang = composite_effect.new("tx_0020", pos_4.x, pos_4.y, self.bg, nil, nil, nil, nil, true)
	        gaf_win_shuaguang:setZOrder(4)
	    end

	    --Win字样
	    local pos_3 = ccp(-270, 25)
	    self.gaf_win_tanqi = composite_effect.new("tx_0021", pos_3.x, pos_3.y, self.bg, nil, funcs, nil, nil, true)
	    self.gaf_win_tanqi:setZOrder(3)

	    audioExt.playEffect(music_info.BATTLE_RESULT_WIN.res)
	else
		local pos = ccp(-272, 580)
	    self.gaf_fail = composite_effect.new("tx_0008", pos.x, pos.y, self.bg, nil, nil, nil, nil, true)
	    self.gaf_fail:setZOrder(1)

	    audioExt.playEffect(music_info.BATTLE_RESULT_LOSE.res)
	end

	self:showName()
end

function ClsBattleAccounts:getBattleInfo()
	local battle_data = getGameData():getBattleDataMt()
	local battle_id = toint(battle_data:GetData("battle_field_data").battle_id)
	if not battle_id then return end
	local battle_info = require("game_config/battle/battle_info")[battle_id]
	local battle_info_config_data = getGameData():getBattleInfoConfigData()
	if not battle_info_config_data:isGeneralConfig() then
        battle_info = require("game_config/battle/battle_jy_info")[battle_id]
    end
	return battle_info
end

--[[
--显示战役的名字
]]
function ClsBattleAccounts:showName()
	local name = ""
	if self.item.battle_type == battle_config.fight_type_arena then
		local battle_data = getGameData():getBattleDataMt()
		local layer_id = battle_data:GetData("battle_field_data").layerId
		
		name = battle_scene_cfg[layer_id].sea_name
	elseif self.item.battle_type == battle_config.fight_type_plunder then
		local portData = getGameData():getPortData()
		name = portData:getPortAreaName()
	end

	--战役名字显示
	if self.item.is_win then
		self.win_name:setVisible(true)
		self.win_name:setText(name)
	else
		self.fail_name:setVisible(true)
		self.fail_name:setText(name)
	end
end

--失败时的跳转按钮显示及事件
function ClsBattleAccounts:showAdviceBtns()
	if self.is_hide_btn then return end

	

	self.btn_prestige:setPressedActionEnabled(true)
	self.btn_prestige:addEventListener(function()
		if self.relic_tag then
			if type(self.call_back) == "function" then
				self.call_back(true)
			end
			local explore_data = getGameData():getExploreData()
			explore_data:exploreOver()
			
		else
	 		self:close()
	 		self:touchEndCallBack()

	 		if not is_main_mission_battle and getGameData():getOnOffData():isOpen(on_off_info.PEERAGES.value) then
	 			getGameData():getPortData():saveBattleEndLayer("prestige")
	 		end
	 	end
	end, TOUCH_EVENT_ENDED)

end

--关闭界面
function ClsBattleAccounts:close()
	local battle_data = getGameData():getBattleDataMt()
	local clearDataCallBack = battle_data:GetData("battle_clear_data_callback") --针对一些特定的系统去清除数据
	if clearDataCallBack then
		clearDataCallBack()
	end
end


--view更新显示
function ClsBattleAccounts:updateView()
	--界面名字
	local panel_name = getConvertChildByName(self.panel, "titl_text_2")
	panel_name:setVisible(true)

	--战役名字
	self.win_name = getConvertChildByName(self.panel, "win_info") 
	self.fail_name = getConvertChildByName(self.panel, "fail_info")
	self.win_name:setVisible(false)
	self.fail_name:setVisible(false)

	--三个跳转按钮
	self.btn_boat = getConvertChildByName(self.panel, "btn_boat")
	self.btn_boat:setVisible(false)
	self.btn_equip = getConvertChildByName(self.panel, "btn_equip")
	self.btn_equip:setVisible(false)
	self.btn_sailor = getConvertChildByName(self.panel, "btn_sailor")
	self.btn_sailor:setVisible(false)
	self.btn_prestige = getConvertChildByName(self.panel, "btn_prestige")
	local onOffData = getGameData():getOnOffData()
	if onOffData:isOpen(on_off_info.PEERAGES.value) and not self.is_relic then
		self.btn_prestige:setVisible(true)
	else
		self.btn_prestige:setVisible(false)
	end
	

	--获得奖励
	self.get_award_text = getConvertChildByName(self.panel, "get_award_text")
	self.material_text = getConvertChildByName(self.panel, "material_text")

	local award_panel_1 = getConvertChildByName(self.panel, "award_panel_1")
	local award_panel_2 = getConvertChildByName(self.panel, "award_panel_2")
	local award_panel_5 = getConvertChildByName(self.panel, "award_panel_5")

	self.start_x, self.start_y = award_panel_1:getPosition().x, award_panel_1:getPosition().y
	--奖励的间隔
	self.award_dx = award_panel_5:getPosition().x - award_panel_1:getPosition().x
	self.award_dy = award_panel_1:getPosition().y - award_panel_2:getPosition().y

	--奖励背景
	self.award_bg = getConvertChildByName(self.panel, "award_bg")

	--背景
	if not self.item.is_win then
		self.bg:setGray(true)
	else
		self.bg:setGray(false)
	end

	

	--胜利或失败特效
	self:initEffects()
	--失败的提示按钮
	if not self.item.is_win then
		self:showAdviceBtns()
		self:initBtns()
		if self.is_hide_btn then
			self.btn_prestige:setVisible(false)
		end
	end

	if self.item.battle_type == battle_config.fight_type_sea_boss_explore then  -- 探索海域boss战
		self:showExplorePlunderDataInfo()
		return
	end
	
	self:showRewardsInfo()

end

function ClsBattleAccounts:showExplorePlunderDataInfo()
	local show_text = ui_word.BATTLE_RECEIVE_REWARD
	if self.is_get == 0 then
		show_text = ui_word.BATTLE_LOSE_REWORD
	end
	self.get_award_text:setText(show_text)

	-- local silverNum = self.item.player.cash or 0
	-- local honourNum = self.item.player.honour or 0

	self.common_awards = {} --普通
	self.material_awards = {} --材料奖励
	self.action_rewars = {}

	-- local reward_silver = {}
	-- reward_silver.type = ITEM_INDEX_CASH
	-- reward_silver.amount = silverNum
	-- self:createRewardItemLayer(reward_silver)

	-- local reward_honour = {}
	-- honourNum.type = ITEM_INDEX_HONOUR
	-- honourNum.amount = honourNum
	-- self:createRewardItemLayer(reward_honour)

	--普通/材料奖励
	for k, v in pairs(self.rewards) do
		self:createRewardItemLayer(v)
	end

	local cur_line = 0 --当前奖励第几行

	--普通奖励layer和位置
	local total_line = self:commonAwardsItem()

	--材料奖励
	local cur_line = self:materialAwardsItem(total_line)

	--奖励的滑动出现动画
	self:actionForAwards()

	--星星
	self:createStarsEffect()
end

function ClsBattleAccounts:starAwardsItem(total_line)
	local cur_line = 0
	if self.star_rewards then
		--材料奖励文本
		local reward_explain = {
			[1] = ui_word.LOOT_REWARD_EXPLAIN_1,
			[2] = ui_word.LOOT_REWARD_EXPLAIN_2,
			[3] = ui_word.LOOT_REWARD_EXPLAIN_3,
		}
		self.material_text:setVisible(#self.star_rewards > 0)
		self.material_text:setText(reward_explain[self.item.star])

		for k, v in pairs(self.star_awards) do
			local award_item, cur_x, cur_y, line  = self:calCurAwardPos(k, v)
			cur_line = total_line + line

			award_item.line_num = cur_line
			self.action_rewars[#self.action_rewars + 1] = award_item
		end
	end
	return cur_line
end

--材料奖励layer和位置
function ClsBattleAccounts:materialAwardsItem(total_line)
	local cur_line = 0
	--材料奖励
	if self.material_awards then
		for k, v in pairs(self.material_awards) do
			
			local award_item, cur_x, cur_y, line = self:calCurAwardPos(k, v)
			cur_line = total_line + line

			if k == #self.material_awards then
				self.start_y = cur_y - (MAX_AWARDS_LINE - cur_line) * self.award_dy
			end
			
			award_item.line_num = cur_line
			self.action_rewars[#self.action_rewars + 1] = award_item
		end
	end
	return cur_line
end

--普通奖励layer和位置
function ClsBattleAccounts:commonAwardsItem()
	local cur_line = 0
	if self.common_awards then
		for k, v in pairs(self.common_awards) do
			local award_item, cur_x, cur_y, line = self:calCurAwardPos(k, v)
			cur_line = line
			if k == #self.common_awards then
				if self.material_awards and #self.material_awards > 0 then
					self.start_y = cur_y - self.award_dy
				else
					self.start_y = cur_y - (MAX_AWARDS_LINE - cur_line ) * self.award_dy
				end
			end
			award_item.line_num = cur_line
			self.action_rewars[#self.action_rewars + 1] = award_item
		end
	end
	return cur_line
end

--奖励的滑动出现动画
function ClsBattleAccounts:actionForAwards()
	local delay_time = DELAY_TIME
	for k, v in pairs(self.action_rewars) do

		print("===========v.line_num:" .. v.line_num)
		--时间根据第几行控制，比如第一行就是0.5，然后第二行就1s
		delay_time = DELAY_TIME + (v.line_num - 1) * DELAY_TIME
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay_time))
		arr:addObject(CCMoveTo:create(DELAY_TIME, v.end_pos))
		arr:addObject(CCCallFunc:create(function()
			audioExt.playEffect(music_info.COMMON_NUMBER.res)
			UiCommon:numberEffect(v.widgets.num, 0, tonumber(v.info.amount))
		end))

		-- --动画播放完毕后，设置界面可点击
		-- if k == #self.action_rewars  then
		-- 	self:initBtns()
		-- end

		v:runAction(CCSequence:create(arr))
	end
end

--奖励item
function ClsBattleAccounts:createRewardItem(info)

	local ui_layer = UILayer:create()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_account_common_reward.json")
    ui_layer:addWidget(panel)

    local widget_info = {
		[1] = { name = "icon" },
		[2] = { name = "num" },
	}

    local widgets = {}
    for k, v in ipairs(widget_info) do
    	widgets[v.name] = getConvertChildByName(panel, v.name)
    end

    --icon
    if info.icon then
    	widgets.icon:changeTexture(convertResources(info.icon), UI_TEX_TYPE_PLIST)
    	--widgets.icon:setScale(info.scale or 1)
    	if info.name == ui_word.EXPLORE_GOTO_LOOT_PRIVATE then
    		widgets.icon:setScale(info.scale or 1)
    	end
    end

    --num
    widgets.num:setText(0)

    if info.amount < 0 then
    	widgets.num:setColor(ccc3(dexToColor3B(COLOR_RED)))
    end

    ui_layer.widgets = widgets
    ui_layer.info = info
    return ui_layer
end

--创建对应奖励的layer: 木材 100
function ClsBattleAccounts:createRewardItemLayer(item, is_star_award)
	local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(item)

	local temp = {}
	temp.icon = icon
	temp.amount = tonumber(amount)
	temp.scale = scale
	temp.name = name

	local reward_layer = self:createRewardItem(temp)

	if is_star_award then
		self.star_awards[#self.star_awards + 1] = reward_layer
	else
		if COMMON_REWARD[item.key] then
			self.common_awards[#self.common_awards + 1] = reward_layer
		else
			self.material_awards[#self.material_awards + 1] = reward_layer
		end
	end
end

--计算当前奖励的位置x,y
--self.start_x:当前奖励的x坐标
function ClsBattleAccounts:calCurAwardPos(index, award_item)

    local cur_x, cur_y = 0, 0
    local temp =  math.floor(index / 2)

    if temp < index / 2 then --当为单数时，就是y减去对应倍数的dy
        cur_x = self.start_x
    else --当为双数时，就是x 加上对应倍数的dx
       cur_x = self.start_x + self.award_dx
    end
    cur_y = self.start_y - math.ceil(index / 2 - 1) * self.award_dy

	award_item:setPosition(ccp(cur_x + 500, cur_y))
	self.award_bg:addCCNode(award_item)

	award_item.end_pos = ccp(cur_x, cur_y)
	return award_item, cur_x, cur_y, math.ceil(index / 2)
end

--获得奖励区域显示
function ClsBattleAccounts:showRewardsInfo()
	if not self.rewards or #self.rewards < 1 then return end

	local show_text = ui_word.BATTLE_RECEIVE_REWARD
	if self.is_get == 0 then
		show_text = ui_word.BATTLE_LOSE_REWORD
	end

	self.get_award_text:setText(show_text)

	--奖励
	table.sort(self.rewards, function(a, b)
		return (REWARD_SHOW_PRIORITY[a.type] or 10000) < (REWARD_SHOW_PRIORITY[b.type]  or 10000)
	end)

	self.common_awards = {} --普通
	self.material_awards = {} --材料奖励
	self.star_awards = {}  --星级奖励

	self.action_rewars = {}

	if self.rewards then
		print("==============普通及材料奖励=========")
		table.print(self.rewards)

		--普通/材料奖励
		for k, v in pairs(self.rewards) do
			self:createRewardItemLayer(v)
		end
	end

	--星级奖励
	if self.star_rewards then
		--星级奖励排序
		table.sort(self.star_rewards, function(a, b)
			return (REWARD_SHOW_PRIORITY[a.type] or 10000) < (REWARD_SHOW_PRIORITY[b.type]  or 10000)
		end)

		print("==============星级奖励=========")
		table.print(self.star_rewards)

		for k, v in pairs(self.star_rewards) do
			self:createRewardItemLayer(v, true)
		end
	end

	--普通奖励layer和位置
	local total_line = self:commonAwardsItem()

	--材料奖励layer和位置
	total_line = self:materialAwardsItem(total_line)

	--星级奖励layer和位置
	total_line = self:starAwardsItem(total_line)

	--奖励的滑动出现动画
	self:actionForAwards()

	--星星
	self:createStarsEffect()

end

--星星特效
function ClsBattleAccounts:createStarsEffect()
	if type(self.item.star) ~= "number" then return end

	local pos = {
		[1] = {-353, -14},
		[2] = {-274, 8},
		[3] = {-198, -15}
	}

	local delay_time = DELAY_TIME
	for k = 1, self.item.star do
		delay_time = delay_time + DELAY_TIME
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay_time))
		arr:addObject(CCCallFunc:create(function()
			self.star_gaf = composite_effect.new("tx_0024", pos[k][1], pos[k][2], self.bg, nil, nil, nil, nil, true)
			self.star_gaf:setZOrder(6)
		end))
		arr:addObject(CCDelayTime:create(0.3))
		arr:addObject(CCCallFunc:create(function()
			audioExt.playEffect(music_info.BATTLE_START.res)
		end))

		-- if k == self.item.star then
		-- 	self:initBtns()
		-- end

		self:runAction(CCSequence:create(arr))
	end
end

function ClsBattleAccounts:initBtns()
	self.btn_next:setVisible(true)
	
	local pos = self.btn_next:getPosition()

	self.btn_next:setPosition(ccp(pos.x + 200, pos.y))

	self.btn_next:setPressedActionEnabled(true)
	self.btn_next:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:touchEndCallBack()
	end, TOUCH_EVENT_ENDED)

	self.btn_next:runAction(CCMoveBy:create(DELAY_TIME, ccp(-200, 0)))

	if not self.item.is_win and (self.item.battle_type == battle_config.fight_type_pve_elite_battle
		or self.item.battle_type == battle_config.fight_type_portPve) then

		print("==============self.item.battle_type: "..self.item.battle_type, self.item.is_win)
		self.btn_refresh:setVisible(true)

		local refresh_pos = self.btn_refresh:getPosition()
		self.btn_refresh:setPosition(ccp(refresh_pos.x + 200, refresh_pos.y))
		self.btn_refresh:setPressedActionEnabled(true)
		self.btn_refresh:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			
			local battleData = getGameData():getBattleDataMt()
			battleData:ClearBattleData()

		end, TOUCH_EVENT_ENDED)
		self.btn_refresh:runAction(CCMoveBy:create(DELAY_TIME, ccp(-200, 0)))
	end
end

--Initialize exit event and touch event
function ClsBattleAccounts:initEvent()

	self.bg:addEventListener(function()
		self:touchEndCallBack()
	end, TOUCH_EVENT_ENDED)
end


function ClsBattleAccounts:touchEndCallBack()
	if self.is_end then return end
	self.is_end = true

	if self.relic_tag and type(self.call_back) == "function" then
		self.call_back()
		setNetPause(false)
	else

		local battle_data = getGameData():getBattleDataMt()
		local result_para = {}
		if self.item.battle_type == battle_config.fight_type_plunder then
			local battle_field_data = battle_data:GetData("battle_field_data")
			result_para.reward = self.rewards
			result_para.battle_tag = battle_field_data.battle_tag
		end
		
		require("gameobj/battle/battleLayer").EndCallback(nil, self.item.is_win, result_para)
	end
	if self.is_main_mission_battle and getGameData():getOnOffData():isOpen(on_off_info.PEERAGES.value) then
		getGameData():getPortData():saveBattleEndLayer("prestige")
	end
end

sailors = {2, 3, 0}

function ClsBattleAccounts:onExit( ... )
	
	UnLoadPlist(self.resPlist)
	ReleaseTexture(self)
end

return ClsBattleAccounts