-- 新版每日目标
-- Author: Ltian
-- Date: 2016-06-29 16:54:29
--
local ClsDynSwitchView = require("ui/tools/DynSwitchView")
local daily_target = require("game_config/activity/daily_target")
local on_off_info=require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")
local alert = require("ui/tools/alert")
local music_info = require("scripts/game_config/music_info")

local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")


local TREASURE_ID = 80
local TREASURE_VIP_ID = 164 ---高级藏宝图id

local function isContinue(obj)
	local daily_target_panel_ui = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")

	local list_view = daily_target_panel_ui:getListView()
	local touch_pos = ccp(obj:getTouchStartPos().x, obj:getTouchStartPos().y)
	local pos = list_view:getParent():convertToNodeSpace(touch_pos)
	return (list_view.rect:containsPoint(pos))
end

local ClsDailyTargetItem = class("ClsDailyTargetItem", ClsScrollViewItem)

-- function ClsDailyTargetItem:ctor(size, data, k)
-- 	self.data = data
-- 	self.mission_info = daily_target[self.data.missionId]   ----任务本地表
-- 	self.step = self.data.cur_star
-- end

function ClsDailyTargetItem:initUI(cell_date)
	self.data = cell_date
	self.mission_info = daily_target[self.data.missionId]   ----任务本地表
	self.step = self.data.cur_star
	self:mkUi()
end

local widget_name = {
	"target_name",
	"target_times",
	"target_degree_num",
	"btn_go",
	"stamp_finished",
}
function ClsDailyTargetItem:mkUi()
	self.layer = UIWidget:create()
	-- self.layer:setTouchPriority(TOUCH_PRIORITY_GOD)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_target_item.json")
	convertUIType(self.panel)
	local activity_main_ui = nil
	if getUIManager():isLive("ClsActivityMain") then
		activity_main_ui = getUIManager():get("ClsActivityMain")
		-- if(activity_main_ui)then self.touch_priority = activity_main_ui:getTouchPriority() end
	end

	-- self.layer:setTouchPriority((self.touch_priority or 0) - 5)
	self.layer:addChild(self.panel)
	self:addChild(self.layer)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:updateView()
	self.btn_go:setPressedActionEnabled(true)
	self.btn_go:addEventListener(function()
		-- if not isContinue(self.btn_go) then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local explore_panel = getUIManager():get("ExploreUI")
		if explore_panel and not tolua.isnull(explore_panel) then
			if getGameData():getTeamData():isLock(true) then
				return
			end

			-- todo 前往小地图
			-- local layer_name = self.mission_info.skip_info[1]

			-- if layer_name == "small_map" then
			-- 	local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
			-- 	ExploreMap:showMax()
			-- 	activity_main_ui:destroy()
			-- 	return
			-- elseif layer_name == "treasure_map" then
			-- 	self:tryOpenTreasureMapUI()
			-- 	return
			-- end

			local is_explore_to_port = self.mission_info.explore_skip
			if is_explore_to_port == 1 then
				local port_info = require("game_config/port/port_info")
				local Alert = require("ui/tools/alert")
				local portData = getGameData():getPortData()
				local portName = port_info[portData:getPortId()].name
				local tips = require("game_config/tips")
				local str = string.format(tips[77].msg, portName)
				Alert:showAttention(str, function()
					---回港
					portData:setEnterPortCallBack(function()
						if not tolua.isnull(getUIManager():get("ClsActivityMain")) then return end
						getUIManager():create("gameobj/activity/clsActivityMain")
					end)
					portData:askBackEnterPort()
				end, nil, nil, {hide_cancel_btn = true})	
			else
				self:gotoMission()		
			end



		else
			if tonumber(self.data.missionId) == 15 then --商品热销特殊处理
				local item_id = 238 --倾斜的天平id
				local propDataHandle = getGameData():getPropDataHandler()
				local item_info = propDataHandle:hasPropItem(item_id)
				if not item_info then
					alert:warning({msg = ui_word.DAILY_TARGET_NO_ITEM_TIPS})
					return
				end

			end
			
			self:gotoMission()
		end
	end, TOUCH_EVENT_ENDED)

	if getGameData():getTeamData():isLock() then
		self.btn_go:disable()
	end
end

function ClsDailyTargetItem:updateView()
	local target_name = self.mission_info.name[1]
	self.target_name:setText(target_name)

	local all_liveness = self.mission_info.complete_times --需要的的条件总数
	local add_liveness = self.mission_info.liveness --增加活跃度
	local liveness = self.data.progress --已经完成的次数
	self.target_times:setText(liveness.."/"..all_liveness)
	self.target_degree_num:setText("+"..add_liveness)

	if liveness == all_liveness then
		self.btn_go:setVisible(false)
		-- self.btn_go:setTouchEnabled(false)
		self.stamp_finished:setVisible(true)
	end
end

function ClsDailyTargetItem:gotoMission()
	local TREASURE_ID = 80 ---藏宝图id
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local layer_name = self.mission_info.skip_info[1]

	local main_tab = getUIManager():get("ClsActivityMain")
	-- main_tab:setTouch(false)
	if layer_name == "ports" then
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local portData = getGameData():getPortData()
		local port_id = portData:getPortId() -- 当前港口id
		mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE, function()
		end, function()
			if tolua.isnull()(self) then return end
			-- main_tab:setTouch(true)
		end)

	elseif layer_name == "seven" then
		local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if tolua.isnull(explore_map_obj) then
			if getGameData():getExplorePirateEventData():isOpen() then
				EventTrigger(EVENT_DEL_PORT_ITEM)
				missionSkipLayer:skipPortLayer()
				local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
				explore_map_obj:turnToWorldExt()
			else
				-- main_tab:setTouch(true)
			end
		end
	elseif layer_name =="reward" then
		EventTrigger(EVENT_MAIN_SELECT_LAYER, TYPE_LAYER_PORT)
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsLoginAwardUIQuene = require("gameobj/quene/clsLoginAwardUIQuene")
		DialogQuene:insertTaskToQuene(clsLoginAwardUIQuene.new({func = function() EventTrigger(EVENT_DEL_PORT_ITEM) end}))
	elseif layer_name == "arena" then
		getUIManager():create("gameobj/arena/clsArenaMainUI")
	elseif layer_name == "town" then
		-- 关闭主界面
		getUIManager():get("ClsActivityMain"):close()
		-- 等后续Ui框架优化,现在先这么处理
		-- 尝试获取
		local target_ui = getUIManager():get('clsPortTownUI')
		-- 如果不为空
		if not tolua.isnull(target_ui) then
			-- 先移除
			getUIManager():get("clsPortTownUI"):close()
		end
		-- 再添加
		getUIManager():create('gameobj/port/clsPortTownUI',nil,1)
	elseif layer_name == "treasure_map" then

		if not tolua.isnull(main_tab) then
			self:tryOpenTreasureMapUI(main_tab)
		end
	elseif layer_name == "relic" then
		local collect_data = getGameData():getCollectData()
		local relic_id = collect_data:findNavigateRelicID(isExplore)
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local supply_data = getGameData():getSupplyData()
		local explore_data = getGameData():getExploreData()
		if not isExplore then
			if not relic_id then
				collect_data:askAdviseRelic()
				-- main_tab:setTouch(true)
				return
			end
			supply_data:askSupplyInfo(true, function()

				mapAttrs:goOutPort(relic_id, EXPLORE_NAV_TYPE_RELIC)
				-- main_tab:setTouch(true)
			end,function( )
				-- main_tab:setTouch(true)
			end)
		else
			if relic_id then
				local goal_info = {id = relic_id,navType = EXPLORE_NAV_TYPE_RELIC}
				EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, goal_info)
			else
				collect_data:askAdviseRelic()
				-- main_tab:setTouch(true)
			end
			if not tolua.isnull(main_tab) then
				main_tab:close()
			end

		end
	else
		local layer = missionSkipLayer:skipLayerByName(layer_name)
	end
end

function ClsDailyTargetItem:tryOpenTreasureMapUI(main_tab)

	-- print('------------- tryOpenTreasureMapUI -------------- ')
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local propDataHandle = getGameData():getPropDataHandler()
	local treasure_info = propDataHandle:getTreasureInfo()

	if treasure_info and treasure_info.treasure_id ~= 0 then
		missionSkipLayer:skipLayerByName("treasure_map")
	else
		local have_num = 0
		local item_id = TREASURE_ID

		local item = propDataHandle:hasPropItem(TREASURE_ID)
		if item then
			have_num = item.count
		end
		if have_num == 0 then
			item = propDataHandle:hasPropItem(TREASURE_VIP_ID)
			if item then
				have_num = item.count
				item_id = TREASURE_VIP_ID
			end
		end

		if have_num > 0 then
			local function ok_call_back_func()
				propDataHandle:askTreasureUse(item_id)
			end
			local function close_call_back_func()
			end
			alert:showAttention(ui_word.TREASUREMAP_ITEM_TIPS, ok_call_back_func, close_call_back_func)
		else
			if isExplore then
				alert:warning({msg = ui_word.TREASURE_MAP_TIPS_LBL})
			else
				alert:showJumpWindow(CANGBAOTU_NOT_ENOUGH)
			end
		end
	end

	-- local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	-- local ClsDailyTargetTab = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")
	-- local PropDataHandler = getGameData():getPropDataHandler()
	-- local treasure_info = PropDataHandler:getTreasureInfo()

	-- if treasure_info and treasure_info.treasure_id ~= 0 then

	-- 	if treasure_info.treasure_id == TREASURE_VIP_ID then
	-- 		alert:warning({msg = ui_word.TREASUREMAP_NO_FANISHI, size = 26})
	-- 		-- main_tab:setTouch(true)
	-- 		return
	-- 	end
	-- 	-- todo 以后需要优化的辣鸡代码
	-- 	missionSkipLayer:skipLayerByName("treasure_map")

	-- else
	-- 	local use_item_id = PropDataHandler:getUseItemId()
	-- 	local  function ok_call_back_func()
	-- 		if PropDataHandler:getTreasureItemCount(use_item_id) > 0 then
	-- 			PropDataHandler:askTreasureUse(use_item_id)
	-- 		else
	-- 			alert:warning({msg = ui_word.TREASUREMAP_ITEM_NO, size = 26})
	-- 			-- main_tab:setTouch(true)
	-- 		end
	-- 	end

	-- 	local function close_call_back_func()
	-- 		-- main_tab:setTouch(true)
	-- 	end
	-- 	alert:showAttention(ui_word.TREASUREMAP_ITEM_TIPS, ok_call_back_func, close_call_back_func)
	-- end
end

local ClsDailyTargetTab = class("ClsDailyTargetTab", function() return UIWidget:create() end)

function ClsDailyTargetTab:ctor(bid)
	self.is_enable = true
	self:mkUI()
	self:regEvent()

	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)

	getUIManager():get("ClsActivityMain"):regChild("ClsDailyTargetTab",self)
end

local widget_box_name = {
	{box = "btn_box_1", award_icon = "award_icon_1", award_num = "award_amoun_1", award_light = "award_light_1", get_pic = "get_pic_1",available = "available_1",
	 on_off_key = on_off_info.ACTIVE_1.value, task_keys = {on_off_info.ACTIVE_1.value,} },
	{box = "btn_box_2", award_icon = "award_icon_2", award_num = "award_amoun_2", award_light = "award_light_2", get_pic = "get_pic_2",available = "available_2",
	 on_off_key = on_off_info.ACTIVE_2.value, task_keys = {on_off_info.ACTIVE_2.value,} },
	{box = "btn_box_3", award_icon = "award_icon_3", award_num = "award_amoun_3", award_light = "award_light_3", get_pic = "get_pic_3",available = "available_3",
	 on_off_key = on_off_info.ACTIVE_3.value, task_keys = {on_off_info.ACTIVE_3.value,} },
	{box = "btn_box_4", award_icon = "award_icon_4", award_num = "award_amoun_4", award_light = "award_light_4", get_pic = "get_pic_4",available = "available_4",
	 on_off_key = on_off_info.ACTIVE_4.value, task_keys = {on_off_info.ACTIVE_4.value,} },
	{box = "btn_box_5", award_icon = "award_icon_5", award_num = "award_amoun_5", award_light = "award_light_5", get_pic = "get_pic_5",available = "available_5",
	 on_off_key = on_off_info.ACTIVE_5.value, task_keys = {on_off_info.ACTIVE_5.value,} },
}

-- local BOX_DOING = 0
local BOX_CAN_GET = 1
local BOX_HAVE_GET = 2

function ClsDailyTargetTab:mkUI()
	self.ui_layer = UIWidget:create()
	self:addChild(self.ui_layer)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_target.json")
	self.reward_panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_target_award.json")
	convertUIType(self.panel)
	convertUIType(self.reward_panel)

	self.ui_layer:addChild(self.panel)
	self.ui_layer:addChild(self.reward_panel)
	self.reward_panel:setVisible(false)

	self.degree_bar = getConvertChildByName(self.panel, "degree_bar")
	self.liveness_label = getConvertChildByName(self.panel, "liveness_num")

	local task_data = getGameData():getTaskData()
	for i,v in ipairs(widget_box_name) do
		self[v.box] = getConvertChildByName(self.panel, v.box)
		self[v.award_icon] = getConvertChildByName(self.panel, v.award_icon)
		self[v.award_num] = getConvertChildByName(self.panel, v.award_num)
		self[v.award_light] = getConvertChildByName(self.panel , v.award_light)
		self[v.get_pic] = getConvertChildByName(self.panel , v.get_pic)
		self[v.available] = getConvertChildByName(self.panel,v.available)

		if v.task_keys and v.on_off_key then
			task_data:regTask(self[v.box], v.task_keys, KIND_CIRCLE, v.on_off_key, nil, nil, true)
		end
	end

	self.box_btn_tbl = {
		self.btn_box_1,
		self.btn_box_2,
		self.btn_box_3,
		self.btn_box_4,
		self.btn_box_5,
	}

	self.list_view = ClsScrollView.new(460,340,true,nil,{is_fit_bottom = true})
	self.list_view:setPosition(ccp(490, 21))
	self:addChild(self.list_view)
	self:updateView()
end

function ClsDailyTargetTab:regEvent()
	local course_data = getGameData():getDailyCourseData()
	local course_reward = course_data:getReward()
	if not course_reward then return end
	for bid,btn in ipairs(self.box_btn_tbl) do

		btn:addEventListener(function()
			-- self.reward_panel:setVisible(false)
			if course_reward[bid].status == BOX_CAN_GET then
				course_data:askReward(bid)
			end
		end, TOUCH_EVENT_ENDED)

		local status = course_reward[bid].status

		local award_light = self["award_light_"..bid]
		local available = self["available_"..bid]
		award_light:stopAllActions()
		if status == BOX_CAN_GET then
			award_light:setVisible(true)
			available:setVisible(true)
			local fadeIn = CCFadeTo:create(0.25, 255 * 0.5)
			local fadeOut = CCFadeTo:create(0.25, 255)
			local actions = CCArray:create()
			actions:addObject(fadeIn)
			actions:addObject(fadeOut)
			local action = CCSequence:create(actions)
			-- award_light:setCascadeOpacityEnabled(true)
			award_light:runAction(CCRepeatForever:create(action))
		else
			award_light:setVisible(false)
			available:setVisible(false)
		end
		self["get_pic_"..bid]:setVisible(status == BOX_HAVE_GET)
	end
end

function ClsDailyTargetTab:updateAwardView(box_id)
	local course_data = getGameData():getDailyCourseData()
	local course_reward = course_data:getReward()
	local reward = course_reward[box_id].rewards
	for reward_id, reward_info in ipairs(reward) do
		local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(reward_info)
		self["award_icon_"..box_id]:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
		self["award_amoun_"..box_id]:setText(amount)
	end
end

function ClsDailyTargetTab:updateView()
	self:regEvent()
	self:updateList()
	self:updateLivenessBarandReward()
end

--更新活动列表
function ClsDailyTargetTab:updateList()
	self.cells = {}
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
	end
	local course_data  = getGameData():getDailyCourseData()
	local mission_list = course_data:getActivityCourseList()

	local size = 0
	for k,v in pairs(mission_list) do
		size = size + 1
	end
	-- print(size)
	if mission_list == nil or size < 1 then
		-- print(' ----------- 活动数据为0 ---------------------------------- ')
		return
	end

	local _rect = CCRect(490, 21, 460, 340)
	local cell_size	= CCSize(460, 82)
	local activity_main_ui = getUIManager():get("ClsActivityMain")
	local onOffData = getGameData():getOnOffData()
	for i,v in pairs(mission_list) do
		local cell_index = tonumber(i)
		local status = false
		if daily_target[v.missionId].switch == "" then
			status = true
		else
			status = onOffData:isOpen(on_off_info[daily_target[v.missionId].switch].value)
		end
		
		if status then
			self.cells[cell_index] = ClsDailyTargetItem.new(cell_size, v)
			self.list_view:setTag(1)
			self.list_view:addCell(self.cells[cell_index])
		end
	end

end

function ClsDailyTargetTab:getListView()
	return self.list_view
end

-- 更新活跃度和相关领奖
function ClsDailyTargetTab:updateLivenessBarandReward()
	local course_data  = getGameData():getDailyCourseData()
	local course_liveness = course_data:getLiveness()
	local course_reward = course_data:getReward()
	if course_reward == nil or #course_reward < 1 then
		return
	end
	if course_liveness > 100 then
		course_liveness = 100
	end
	self.liveness_label:setText(course_liveness)
	self.degree_bar:setPercent(course_liveness)

	for i,v in ipairs(course_reward) do
		self:updateAwardView(i)
	end
end

function ClsDailyTargetTab:preClose()
	-- body
end

function ClsDailyTargetTab:onExit()
	getUIManager():get("ClsActivityMain"):unRegChild("ClsDailyTargetTab")
end

function ClsDailyTargetTab:setTouch(enable)

end
return ClsDailyTargetTab
