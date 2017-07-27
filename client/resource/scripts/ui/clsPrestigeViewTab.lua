
---fmy0570
---声望提升cell
local ClsUiTools = require("gameobj/uiTools")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local prestige_info = require("game_config/prestige_info")
local alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")


local ClsPrestigeViewItem = class("ClsPrestigeViewItem", ClsScrollViewItem)

local list_view = nil 
local NO_CLICK = 0
local widget_name = {
	"item_pic",
	"event_text",
	"evaluation_text",
	"btn_go",
	"bar_info",
	"list_pamel_2",
	"lisdt_panel_1",
	"event_tips",
	"star_1",
	"star_2",
	"star_3",
	"star_4",
	"star_5",
}


local prestige_text = {
	[1] = ui_word.PRESTIGE_TAB_1,
	[2] = ui_word.PRESTIGE_TAB_2,
	[3] = ui_word.PRESTIGE_TAB_3,
	[4] = ui_word.PRESTIGE_TAB_4,
}


function ClsPrestigeViewItem:initUI(data)
	self.data = data
	local nobility_data = getGameData():getNobilityData()
	local prestige_data = nobility_data:getPrestigeInfo()

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_prestige_list.json")
	self:addChild(self.panel)

	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end	

	self.btn_go:setPressedActionEnabled(true)
	self.btn_go:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:gotoMission()
	end, TOUCH_EVENT_ENDED)

	self.event_text:setText(self.data.name)

	self.lisdt_panel_1:setVisible(self.data.is_bar == 0)	
	self.list_pamel_2:setVisible(self.data.is_bar == 1)	
	if self.data.is_bar == 0 then
		local data = prestige_data[self.data.data_info]
		local percent = data.current/data.max*100

		if percent > 100 then
			percent = 100
		end
		self.bar_info:setPercent(percent)
		local prestige_level = self:getPrestigeGrade(percent)
		self.evaluation_text:setText(prestige_text[prestige_level])

	else
		self.event_tips:setText(self.data.des)
		for i=1,5 do
			self["star_"..i]:setVisible(i <= self.data.star_num)
		end
	end

	self.item_pic:changeTexture(self.data.prestige_icon, UI_TEX_TYPE_PLIST)
	self.item_pic:setScale(0.6)
end


function ClsPrestigeViewItem:getPrestigeGrade(percent)
	local prestige_grade = 1
	if percent <= 40 then
		prestige_grade = 1
	elseif percent > 40 and percent <= 60 then
		prestige_grade = 2
	elseif percent > 60 and percent <= 80 then
		prestige_grade = 3
	elseif percent > 80 then
		prestige_grade = 4
	end
	return prestige_grade
end

function ClsPrestigeViewItem:gotoMission()

	if isExplore then
		if self.data.explore_skip == 1 then --探索界面不能点击
			alert:warning({msg = ui_word.PRESTIGE_BTN_TIPS, size = 26})
			return			
		end
	end

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if explore_map and tolua.isnull(explore_map) then
		alert:warning({msg = ui_word.PRESTIGE_BTN_TIPS, size = 26})
		return
	end

	---队员不能点击
	local team_data = getGameData():getTeamData()
	if self.data.click == NO_CLICK and team_data:isInTeam() and not team_data:isTeamLeader() then
		alert:showAttention(ui_word.LEAVE_TEAM_TIP, function()
			team_data:askLeaveTeam()
		end)
		return 
	end

	local onOffData = getGameData():getOnOffData()
	if self.data.switch ~= "" and  not onOffData:isOpen(on_off_info[self.data.switch].value) then
		return 
	end


	---弹出不足弹框
	local NOT_ENOUGH_TYPE = self.data.kind
	if NOT_ENOUGH_TYPE ~= "" then
		alert:showJumpWindow(NOT_ENOUGH_TYPE,nil,nil,"ClsPrestigeMainUI")
		return 
	end


	local layer_name = self.data.skip_info[1]
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")

	if layer_name == "relic" then
		local collect_data = getGameData():getCollectData()
		local relic_id = collect_data:findNavigateRelicID(isExplore)
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local supply_data = getGameData():getSupplyData()

		if not isExplore then
			if not relic_id then
				local portData = getGameData():getPortData()
				local port_id = portData:getPortId() -- 当前港口id
				mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE)
				return
			end

			supply_data:askSupplyInfo(true, function()
				mapAttrs:goOutPort(relic_id, EXPLORE_NAV_TYPE_RELIC)
			end)
		else

			if relic_id then
				local goal_info = {id = relic_id,navType = EXPLORE_NAV_TYPE_RELIC}
    			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, goal_info)
			end
		end

	else

		getUIManager():get("ClsPrestigeMainUI"):close()
		missionSkipLayer:skipLayerByName(layer_name)
	end
	
end


local ClsPrestigeViewTab = class("ClsPrestigeViewTab", function() return UIWidget:create() end)

function ClsPrestigeViewTab:ctor(tab_tag)
	self.tab_tag = tab_tag 
	self:mkUI()	
end

function ClsPrestigeViewTab:getViewList()
	local view_data_list = {}
	for i,v in ipairs(prestige_info) do
		if v.group == self.tab_tag then
			view_data_list[#view_data_list + 1] = v 
		end
	end
	return view_data_list
end

function ClsPrestigeViewTab:mkUI( )
	self.cells = {}
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local _rect = CCRect(290 ,40, 556, 357)
	local cell_size	= CCSize(556, 98)

	self.list_view = ClsScrollView.new(556, 357, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(290, 40)) 
	list_view = self.list_view

	local view_list = self:getViewList()

	for k,v in pairs(view_list) do
		local onOffData = getGameData():getOnOffData()
		if v.switch == "" or onOffData:isOpen(on_off_info[v.switch].value) then
			self.cells[k] = ClsPrestigeViewItem.new(cell_size, v, _rect)
			self.list_view:addCell(self.cells[k])
		end
	end
	self:addChild(self.list_view)	
end


return ClsPrestigeViewTab
