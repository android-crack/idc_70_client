local ui_word = require("game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsPrestigeRankCell = class("ClsPrestigeRankCell", ClsScrollViewItem)
local role_info = require("game_config/role/role_info")
local nobility_config = require("game_config/nobility_data")
local info_title = require("game_config/title/info_title")
local music_info = require("game_config/music_info")

local PRESTIGE_TYPE = 1
local FORE_FONT = 3
local TOTAL_RANK = 4
local cell_widget = {
	"rank_num",
	"head_icon",
	"prestige_text",
	"guild_name",
	"guild_name_title",
	"player_title_pic",
	"rank_bg_1",
	"level_num",
}

ClsPrestigeRankCell.updateUI = function(self, cell_data, panel)
	self.m_data = cell_data
	for i,v in ipairs(cell_widget) do
		self[v] = getConvertChildByName(panel, v)
	end
	self:mkUi()
end

local createRichLabel_byStr
createRichLabel_byStr = function(str)
	local node = createRichLabel(str,160,20,16,nil,true)
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(ccp(0.5, 0.5))
	return node
end

ClsPrestigeRankCell.mkUi = function(self)
	local nobilityMsg =	nobility_config[self.m_data.nobility] or {}
	local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
	file_name = convertResources(file_name)
	self.guild_name_title:changeTexture(file_name, UI_TEX_TYPE_PLIST)
	self.rank_num:setText(self.m_data.pos)
	self.player_title_pic:setVisible(false)
	if self.m_data.pos <= FORE_FONT then
		self.rank_bg_1:setVisible(true)
	end
	if self.m_data.title and self.m_data.title > 0 then
		local str_title = info_title[self.m_data.title].performance
		local pos = self.player_title_pic:getPosition()
		local node_title = createRichLabel_byStr(str_title)
		node_title:setPosition(ccp(pos.x, pos.y))
		self:addCCNode(node_title)
	end
	self.head_icon:changeTexture(role_info[self.m_data.role].res, UI_TEX_TYPE_LOCAL)
	self.guild_name:setText(self.m_data.name)
	self.prestige_text:setText(self.m_data.value)
	self.level_num:setText("Lv."..self.m_data.grade)
end

ClsPrestigeRankCell.onTap = function(self, x,y)
	if self.m_data.uid == getGameData():getPlayerData():getUid() then
		getUIManager():create("gameobj/playerRole/clsRoleInfoView")
		return
	end

	local main_ui = getUIManager():get("ClsRankMainUI"):getListView(PRESTIGE_TYPE)
	main_ui:openExpandPanel(self)
end

local ClsPrestigeRankUI = class("ClsPrestigeRankUI", function() 
	return UIWidget:create()
end)

ClsPrestigeRankUI.ctor = function(self, type, select_tab)
	self.m_list_width = 765
	self.m_list_height = 288
	self._type = type

	self.s_type = nil
	self.default_tab = select_tab or TOTAL_RANK
	self:initUi()
	self:defaultSelect()
end

local main_widget = {
	"my_rank_num",
	"my_prestige_num",
	"select_bg",
	"select_arrow",
	"select_text",
}

local tab_widget = {
	{res = "btn_adv", label = "btn_adv_text", rank_type = ADV_RANK_TYPE, pid = KIND_EXPORE},
	{res = "btn_navy", label = "btn_navy_text", rank_type = NAVY_RANK_TYPE, pid = KIND_SAILOR},
	{res = "btn_pirate", label = "btn_pirate_text", rank_type = PIRP_RANK_TYPE, pid = KIND_GUN},
	{res = "btn_all", label = "btn_all_text", rank_type = PRESTIGE_RANK_TYPE},
}

ClsPrestigeRankUI.initUi = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/rank_prestige.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	for _,name in ipairs(main_widget) do
		self[name] = getConvertChildByName(self.panel, name)
	end
	for k,v in ipairs(tab_widget) do
		self[v.res] = getConvertChildByName(self.panel, v.res)
		self[v.res].lab = getConvertChildByName(self.panel, v.label)
		self[v.res]:setTouchEnabled(true)
		self[v.res]:addEventListener(function()
			self:selectTab(k)
		end, TOUCH_EVENT_ENDED)
	end

	local call_back = function()
		self.select_arrow:setRotation(180)
	end
	self.select_bg:addEventListener(function()
		if getUIManager():isLive("ClsGradeRankPop") then
			getUIManager():close("ClsGradeRankPop")
			return
		end
		self.select_arrow:setRotation(180)
		local pop_ui = getUIManager():create("gameobj/rank/clsGradeRankPop", nil, call_back)
		pop_ui:setPosition(ccp(763,240))
	end, TOUCH_EVENT_ENDED)
end

ClsPrestigeRankUI.defaultSelect = function(self)
	self:selectTab(self.default_tab)
end

ClsPrestigeRankUI.selectTab = function(self, job_id)
	if self.s_type == job_id then return end
	self.s_type = job_id
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	for k,v in ipairs(tab_widget) do
		self[v.res]:setFocused(self.s_type == k)
		self[v.res]:setTouchEnabled(self.s_type ~= k)
		if self.s_type == k then
			setUILabelColor(self[v.res].lab, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		else
			setUILabelColor(self[v.res].lab, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end
	end

	self:updateView()
end

ClsPrestigeRankUI.updateView = function(self)
	if self.m_list_view and not tolua.isnull(self.m_list_view) then
		self.m_list_view:removeFromParent()
		self.m_list_view = nil
	end
	local grade_key, grade_tip = getGameData():getRankData():getGradeIntervalTip()
	self.select_text:setText(grade_tip)
	self.my_prestige_num:setText(getGameData():getPlayerData():getBattlePower())

	local rank_type = tab_widget[self.s_type].rank_type
	local rank_data_handle = getGameData():getRankData()
	local wealth_rank_info = rank_data_handle:getListByType(rank_type)
	if not wealth_rank_info then
		rank_data_handle:askRankList(rank_type, grade_key)
		return 
	end

	local my_profession = getGameData():getPlayerData():getProfession()
	if self.s_type == TOTAL_RANK or my_profession == tab_widget[self.s_type].pid then
		if wealth_rank_info.is_in_rank then
			self.my_rank_num:setText(string.format(ui_word.STR_USER_RANK_POS, wealth_rank_info.user_pos))
		else
			self.my_rank_num:setText(ui_word.STR_OUT_SIDE_RANK)
		end
	else
		self.my_rank_num:setText(string.format(ui_word.STR_OUT_SIDE_RANK_OTHER_JOB, JOB_TITLE[my_profession]))
	end

	local rank_list = wealth_rank_info.rank_list

	self.cells = {}
	self.m_list_view = ClsScrollView.new(self.m_list_width, self.m_list_height, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/rank_prestige_list.json")
		return cell_ui
	end)
	for i,v in ipairs(rank_list) do
		v.pos = i
		self.cells[i] = ClsPrestigeRankCell.new(CCSize(770, 76), v)
	end
	self.m_list_view:addCells(self.cells)
	self.m_list_view:setPosition(ccp(155, 88))
	self:addChild(self.m_list_view)

	-- if getUIManager():isLive("ClsRankMainUI") then
	-- 	getUIManager():get("ClsRankMainUI"):setTouch(true)
	-- end
end

ClsPrestigeRankUI.closeExpandPanel = function(self)
	getUIManager():close("ClsRankExpandPop")
end

ClsPrestigeRankUI.openExpandPanel = function(self, select_cell)
	if tolua.isnull(select_cell) then return end

	local ui = getUIManager():get("ClsRankExpandPop")
	if tolua.isnull(ui) then
		ui = getUIManager():create("gameobj/rank/clsRankExpandPop")
	else
		self:closeExpandPanel()
		return
	end
	ui:setBindCell(select_cell)
end

return ClsPrestigeRankUI