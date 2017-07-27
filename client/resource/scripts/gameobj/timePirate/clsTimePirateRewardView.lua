--2016/11/23
--create by wmh0497
--时段海盗结束后发给我们的奖励弹框

local mission_guide = require("gameobj/mission/missionGuide")
local ClsBaseView = require("ui/view/clsBaseView")
local port_info = require("game_config/port/port_info")
local port_type_info = require("game_config/port/port_type_info")
local goods_type_info = require('game_config/port/goods_type_info')
local music_info = require("scripts/game_config/music_info")
local news = require("game_config/news")
local ClsAlert = require("ui/tools/alert")
local ClsScrollView = require("ui/view/clsScrollView")
local ui_word = require("game_config/ui_word")

local ClsRankListCell = class("ClsRankListCell", require("ui/view/clsScrollViewItem"))
function ClsRankListCell:updateUI(cell_date, cell_ui)
	local rank_lab = getConvertChildByName(cell_ui, "rank_num")
	local name_lab = getConvertChildByName(cell_ui, "player_name")
	local prestige_lab = getConvertChildByName(cell_ui, "prestige_num")
	local hurt_lab = getConvertChildByName(cell_ui, "damage_num")
	
	rank_lab:setText(tostring(cell_date.rank))
	name_lab:setText(cell_date.name)
	hurt_lab:setText(cell_date.hurt)
	prestige_lab:setText(cell_date.prestige)
end


local ClsTimePirateRewardView = class("ClsTimePirateRewardView", require("ui/view/clsBaseView"))

function ClsTimePirateRewardView:getViewConfig()
	return {
		type = UI_TYPE.VIEW,
		is_swallow = true,
		effect = UI_EFFECT.SCALE,
		is_back_bg = true,
	}
end

function ClsTimePirateRewardView:onEnter(reward_data, close_callback)
	self.m_plist = {
		["ui/equip_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
	}
	LoadPlist(self.m_plist)
	self.m_my_uid = getGameData():getPlayerData():getUid() or 0
	self.m_reward_data = reward_data
	self.m_start_time = os.clock()
	self.m_close_callback = close_callback

	--添加探索开始图标
	local reward_ui = GUIReader:shareReader():widgetFromJsonFile("json/activity_monster.json")
	self:addWidget(reward_ui)
	
	local bg_ui = getConvertChildByName(reward_ui, "info_bg")
	local gold_num_lab = getConvertChildByName(reward_ui, "gold_num")
	local exp_num_lab = getConvertChildByName(reward_ui, "exp_num")
	local close_btn = getConvertChildByName(reward_ui, "btn_close")
	local team_level_lab = getConvertChildByName(reward_ui, "team_level")
	
	self.my_info = {}
	self.my_info.name_lab = getConvertChildByName(bg_ui, "my_name")
	self.my_info.rank_lab = getConvertChildByName(bg_ui, "my_rank")
	self.my_info.prestige_lab = getConvertChildByName(bg_ui, "my_prestige")
	self.my_info.hurt_lab = getConvertChildByName(bg_ui, "my_damage")
	
	-- 设置等级段
	local region = self.m_reward_data.region or getGameData():getPlayerData():getGradeInterval()
	local title = team_level_lab:getStringValue()
	title = title..string.format(ui_word.STR_LV_RANGE, region * 10 -9, region * 10)
	team_level_lab:setText(title)

	local reward_items = {}
	for i = 1, 4 do
		local item = {}
		item.name_lab = getConvertChildByName(reward_ui, "treasure_name_"..i)
		item.icon_spr = getConvertChildByName(reward_ui, "treasure_icon_"..i)
		reward_items[i] = item
	end
	
	local org_scale = reward_items[1].icon_spr:getScale()
	
	local list_view = ClsScrollView.new(400, 160, true, function()
			return GUIReader:shareReader():widgetFromJsonFile("json/activity_monster_rank.json")
		end, {is_fit_bottom = true})
	list_view:setPosition(ccp(-198, -83))
	bg_ui:addChild(list_view)
	
	local my_info, rank_infos, reward_info = self:getParseInfo()
	local rank_items = {}
	for k, data in ipairs(rank_infos) do
		local item = ClsRankListCell.new(CCSize(400, 30), data)
		rank_items[#rank_items + 1] = item
	end
	list_view:addCells(rank_items)
	
	if my_info then
		self.my_info.name_lab:setText(my_info.name)
		if my_info.rank <= 0 then
			self.my_info.rank_lab:setText("10+")
		else
			self.my_info.rank_lab:setText(my_info.rank)
		end
		self.my_info.prestige_lab:setText(my_info.prestige)
		self.my_info.hurt_lab:setText(my_info.hurt)
	end
	
	gold_num_lab:setText(reward_info.cash)
	exp_num_lab:setText(reward_info.exp)
	
	for k, ui_item in ipairs(reward_items) do
		local equip_info = reward_info.equips[k]
		if equip_info then
			ui_item.name_lab:setText(equip_info.name)
			ui_item.icon_spr:changeTexture(convertResources(equip_info.res), UI_TEX_TYPE_PLIST)
			ui_item.icon_spr:setScale(equip_info.scale)
		else
			ui_item.name_lab:setVisible(false)
			ui_item.icon_spr:setVisible(false)
		end
	end
	
	close_btn:setPressedActionEnabled(true)
	close_btn:addEventListener(function()
			self:close()
		end, TOUCH_EVENT_ENDED)

end

function ClsTimePirateRewardView:getParseInfo()
	local my_info = self.m_reward_data.my_rank
	local rank_items = self.m_reward_data.ranks
	
	local reward_info = {cash = 0, exp = 0, equips = {}}
	for _, value in ipairs(self.m_reward_data.rewards) do
		local res, amount, scale, name = getCommonRewardIcon(value) 
		if value.type == ITEM_INDEX_CASH then
			reward_info.cash = amount
		elseif value.type == ITEM_INDEX_EXP then
			reward_info.exp = amount
		else
			reward_info.equips[#reward_info.equips + 1] = {res = res, amount = amount, scale = scale, name = name}
		end
	end
	
	return my_info, rank_items, reward_info
end

function ClsTimePirateRewardView:onExit()
	UnLoadPlist(self.m_plist)
	if self.m_close_callback then
		self.m_close_callback()
	end
end

return ClsTimePirateRewardView
