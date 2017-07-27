-- 副本结算ui
local ClsExploreSea = require("gameobj/explore/exploreSea")
local ClsCompositeEffect = require("gameobj/composite_effect")
local UiCommon= require("ui/tools/UiCommon")
local ClsDataTools = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ClsBaseView = require("ui/view/clsBaseView")


local sportsResultUI = class("sportsResultUI", ClsBaseView)
--[[
class scene_result_info {
	int star;
	user_info *rank;
	int score;
	int max_score;
}
--]]

function sportsResultUI:onEnter(result_info, close_callback)
	local sea_layer = createExploreSea()
	self:addChild(sea_layer, -1)
	self.m_close_callback = close_callback
	-- 测试用代码
	-- result_info.star = 5
	-- result_info.score = 50
	-- result_info.max_score = 100
	-- result_info.rewards = {[1] = {id = ITEM_INDEX_GOLD, value = 1000, type = ITEM_INDEX_GOLD}}

	self.m_result_info = result_info
	self.m_plist_tab = {
		["ui/instance_ui.plist"] = 1,
		["ui/box.plist"] = 1,
	}
	LoadPlist(self.m_plist_tab)
	self:initEvent()
	self:initUI()
	self:showUI()
end

function sportsResultUI:initEvent()
	if self.timer == nil then
		local function callback()
			self:closeView()
		end
		self.timer = scheduler:scheduleScriptFunc(callback,3,false)
	end
end

function sportsResultUI:initUI()
	--拼的ui
	self.m_explore_complete_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_copy_complete.json")
	self:addWidget(self.m_explore_complete_ui)

	local background_ui = getConvertChildByName(self.m_explore_complete_ui, "copy_speed")
	local copy_treasure = getConvertChildByName(self.m_explore_complete_ui, "copy_treasure")
	copy_treasure:setEnabled(false)
	background_ui:setVisible(true)
	background_ui:setEnabled(true)
	--获取玩家的label
	self.m_player_name_labs = {}
	for i = 1, 3 do
		self.m_player_name_labs[i] = getConvertChildByName(background_ui, "player_name_info_"..i)
	end
	self.m_player_get_baozang = getConvertChildByName(background_ui, "player_get_baozang_1")
	self.m_player_get_baozang:setVisible(false)

	local bg_balck_ui = getConvertChildByName(background_ui, "bg_black")

	--界面获取的星级
	self.m_star_sprs = {}
	local star_panel = getConvertChildByName(bg_balck_ui, "star_panel")
	for i = 1, 3 do
		local star_spr = getConvertChildByName(star_panel, "star_"..i)
		self.m_star_sprs[i] = star_spr
	end
	self.m_star_panel = star_panel

	self.m_reward_tabs = {}
	for i = 1, 4 do
		local reward_item = {}
		reward_item.panel = getConvertChildByName(bg_balck_ui, "baowu_panel_"..i)
		reward_item.icon_spr = getConvertChildByName(reward_item.panel, "award_item_"..i)
		reward_item.name_lab = getConvertChildByName(reward_item.panel, "baowu_text_"..i)
		reward_item.num_lab = getConvertChildByName(reward_item.panel, "baowu_num_"..i)
		reward_item.panel:setVisible(false)
		self.m_reward_tabs[i] = reward_item
	end
	self.m_bg_balck_ui = bg_balck_ui
	--退出按钮
	local exit_btn = getConvertChildByName(background_ui, "btn_exit")

	self.m_exit_btn = exit_btn
	self.m_exit_btn:setEnabled(false)
	exit_btn:setPressedActionEnabled(true)
	exit_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

function sportsResultUI:showUI()
	local rank_tab = self.m_result_info.users or {}

	for k, player_name_lab in ipairs(self.m_player_name_labs) do
		if rank_tab[k] then
			player_name_lab:setText(tostring(rank_tab[k].name))
			if rank_tab[k].uid == self.m_result_info.winner then
				local pos = ccp(self.m_player_get_baozang:getPosition().x,
									player_name_lab:getPosition().y)
				self.m_player_get_baozang:setPosition(pos)
			end
		else
			player_name_lab:setVisible(false)
		end
	end

	local werck_cnt = self.m_result_info.winner
	if werck_cnt > 0 then
		self.m_player_get_baozang:setVisible(true)
	end

	local ac1 = CCDelayTime:create(0.4)
	local ac2 = CCCallFunc:create(function()
		self:startStarsEff()
	end)
	self:runAction(CCSequence:createWithTwoActions(ac1, ac2))
end

function sportsResultUI:startStarsEff()
	local array = CCArray:create()
	for k, star_spr in ipairs(self.m_star_sprs) do
		if k <= self.m_result_info.star or ( (k <= 1) and (self.m_result_info.star < 1)) then
			array:addObject(CCCallFunc:create(function()
					local true_star_spr = star_spr
					if 1 > self.m_result_info.star then
						true_star_spr = CCGraySprite:createWithSpriteFrameName("common_star1.png")
						local pos = star_spr:getPosition()
						true_star_spr:setPosition(ccp(pos.x, pos.y))
						self.m_star_panel:addCCNode(true_star_spr)
					else
						true_star_spr:setVisible(true)
					end
					true_star_spr:setScale(0)
					true_star_spr:setVisible(true)
					true_star_spr:runAction(CCEaseBackOut:create(CCScaleTo:create(0.6, 1, 1)))
				end))
			array:addObject(CCDelayTime:create(0.4))
		end
	end
	array:addObject(CCCallFunc:create(function()
			self:startRewardEff()
		end))
	self.m_explore_complete_ui:runAction(CCSequence:create(array))
end

function sportsResultUI:startRewardEff()
	if #self.m_result_info.rewards > 0 then
		for k, reward_item in ipairs(self.m_reward_tabs) do
			if self.m_result_info.rewards[k] then
				local icon_str, amount_n, scale_n, name_str = getCommonRewardIcon(self.m_result_info.rewards[k])
				reward_item.panel:setVisible(true)
				reward_item.icon_spr:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
				local size_tab = {[ITEM_INDEX_GOLD] = 40}
				local size_n = size_tab[self.m_result_info.rewards[k].key] or 50
				autoScaleWithLength(reward_item.icon_spr, size_n)
				local name_lab = reward_item.name_lab
				name_lab:setText(tostring(name_str))
				reward_item.num_lab:setText(tostring(amount_n))
				local pos_y = reward_item.num_lab:getPosition().y
				local pos_x = name_lab:getPosition().x + name_lab:getContentSize().width + 5
				reward_item.num_lab:setPosition(ccp(pos_x, pos_y))
			end
		end
	end
	self.m_exit_btn:setEnabled(true)
end

function sportsResultUI:closeView()
	--以防多次退出
	if self._exit then
		return
	end
	self._exit = true
	self:removeFromParentAndCleanup(true)
	if self.m_close_callback then
		self.m_close_callback()
	end
end

function sportsResultUI:onExit()
	UnLoadPlist(self.m_plist_tab)
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end


return sportsResultUI
