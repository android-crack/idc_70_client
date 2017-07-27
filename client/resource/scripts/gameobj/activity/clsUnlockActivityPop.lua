local ClsBaseView = require("ui/view/clsBaseView")
local ClsUnlockActivityPop = class("ClsUnlockActivityPop", ClsBaseView)
local activity_open_conf = require("game_config/activity/activity_open_info")
local activity_next_info = require("game_config/activity/activity_next_txt")
local CompositeEffect = require("gameobj/composite_effect")

local HEIGHT_RATE = 0.5
local WIDTH_RATE = {
	[1] = {0.5},
	[2] = {0.34, 0.66},
	[3] = {0.18, 0.5, 0.82},
}

local paper_widget_name = {
	"name_txt",
	"activity_icon",
	"time_info",
	"activity_tips_info",
	"award_1",
	"award_2",
	"award_3",
	"activity_pic",
	"paper_panel",
	"Panel_effect_bg",
	"Panel_effect_before",
	"paper_pic",
}

local nex_widget_name = {
	"activity_name_1",
	"activity_demand_1",
	"activity_name_2",
	"activity_demand_2",
	"activity_name_3",
	"activity_demand_3",
	"txt_new_activity",
}

function ClsUnlockActivityPop:getViewConfig()
    return {
        name = "ClsUnlockActivityPop",
        is_swallow = true,
        is_back_bg = true,
    }
end

function ClsUnlockActivityPop:initPaperPanel(panel, index)
	local activity_info = activity_open_conf[self.activity_list[index]]

	local effect = CompositeEffect.new("tx_new_activity02", 0, -105, panel.Panel_effect_before, nil, nil, nil, nil, true)
	panel.paper_pic:setVisible(false)
	panel.paper_panel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.6), CCCallFunc:create(function ()
		panel.paper_pic:setVisible(true)
		effect:removeFromParentAndCleanup(true)
		CompositeEffect.new("tx_new_activity03", 0, 0, panel.Panel_effect_before, nil, nil, nil, nil, true)
	end)))
	panel.name_txt:setText(activity_info.activity_name)
	panel.time_info:setText(activity_info.activity_time_txt)
	panel.activity_tips_info:setText(activity_info.activity_info_txt)
	panel.activity_icon:changeTexture(activity_info.activity_big_icon, UI_TEX_TYPE_PLIST)
	panel.activity_pic:changeTexture(activity_info.activity_bg, UI_TEX_TYPE_PLIST)

	for k,v in ipairs(activity_info.activity_reward) do
		panel["award_"..k]:setVisible(true)
		panel["award_"..k]:changeTexture(v, UI_TEX_TYPE_PLIST)
	end
	panel.paper_pic:addEventListener(function ( )
		print("---------------------1----------------")
		self:gotoMission(activity_info.skip_info[1])
	end, TOUCH_EVENT_ENDED)
	panel.paper_pic:setTouchEnabled(true)
end


function ClsUnlockActivityPop:gotoMission(layer_name)
	local TREASURE_ID = 80 ---藏宝图id
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
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
		end
	else
		local layer = missionSkipLayer:skipLayerByName(layer_name)
	end
end

function ClsUnlockActivityPop:getNexUnLockActivitys()
	local temp = {}
	local next_ids = {}
	for index = 1,#self.activity_list do
		local activity_info = activity_open_conf[self.activity_list[index]]
		for _,id in ipairs(activity_info.activity_next_id) do
			temp[id] = true
		end
	end
	for id,_ in pairs(temp) do
		table.insert(next_ids, id)
	end
	return next_ids
end

function ClsUnlockActivityPop:mkUI()
	local json_ui = GUIReader:shareReader():widgetFromJsonFile("json/activity_unlock.json")
	self:addWidget(json_ui)
	for k,name in ipairs(nex_widget_name) do
        self[name] = getConvertChildByName(json_ui, name)
    end
    local effect = CompositeEffect.new("tx_new_activity01", 0, 0, self.txt_new_activity, nil, nil, nil, nil, true)

    local next_activity_tbl = self:getNexUnLockActivitys()
    for i = 1,3 do
    	if next_activity_tbl[i] then
    		local next_infos = activity_next_info[next_activity_tbl[i]]
    		self["activity_name_"..i]:setText(next_infos.activity_next_txt)
    		local width = self["activity_name_"..i]:getContentSize().width
    		self["activity_demand_"..i]:setText(next_infos.activity_next_lv_txt)
    		local pos = self["activity_demand_"..i]:getPosition()
    		self["activity_demand_"..i]:setPosition(ccp(width - 66.5 , pos.y))

    	else
    		self["activity_name_"..i]:setVisible(false)
    		self["activity_demand_"..i]:setVisible(false)
    	end
    end

 	for k,v in ipairs(self.activity_list) do
 		local PANEL_NAME = "Panel_"..k
 		self[PANEL_NAME] = GUIReader:shareReader():widgetFromJsonFile("json/activity_unlock_paper.json")
 		for _, name in ipairs(paper_widget_name) do
 			self[PANEL_NAME][name] = getConvertChildByName(self[PANEL_NAME], name)
 		end
 		json_ui:addChild(self[PANEL_NAME])
 		self:initPaperPanel(self[PANEL_NAME], k)
 		
 		local sX, sY = display.width * WIDTH_RATE[#self.activity_list][k], display.height * HEIGHT_RATE
 		self[PANEL_NAME]:setPosition(ccp(sX, sY))
 	end

 	self:regTouchEvent(self, function(eventType, x, y)
		if eventType =="began" then 
			self:close() 
			return true 
		end
	end)
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(6), CCCallFunc:create(function()
		self:close()
		end
		)))

end

function ClsUnlockActivityPop:onEnter(params)
	self.plist = {
		["ui/activity_ui.plist"] = 1,
	}
	LoadPlist(self.plist)
	self:setIsWidgetTouchFirst(true)
	self.activity_list = params.data
	self.call_back = params.call_back
	local port_layer =  getUIManager():get("ClsPortLayer")
	local is_explore = getGameData():getSceneDataHandler():isInExplore()
	if tolua.isnull(port_layer) and (not is_explore) then
		self:close()
	end
	self:mkUI()
end

function ClsUnlockActivityPop:onExit()
	UnLoadPlist(self.plist)
	if type(self.call_back) == "function" then
		self.call_back()
	end
end

return ClsUnlockActivityPop