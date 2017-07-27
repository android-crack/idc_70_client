
local ui_word = require("game_config/ui_word")
local plotDialogue = require("gameobj/mission/missionPlotDialogue")
local Alert = require("ui/tools/alert")
local treasuremap_info = require("game_config/collect/treasuremap_info")
local DataTool = require("module/dataHandle/dataTools")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsBaseView = require("ui/view/clsBaseView")

local TreasureMapLayer = class("TreasureMapLayer",ClsBaseView)

local PROP_ITEM_TREASURE = 80 --藏宝图id
local PROP_ITEM_TREASURE_VIP = 164 --高级藏宝图id

local widget_name = {
	"btn_close",
	"btn_explore",
	"tips_time_text",
	"tips_time_num",
	"tips_team",
	"tips_search",
}


function TreasureMapLayer:getViewConfig()
    return {
        is_swallow = true,
        effect = UI_EFFECT.FADE,
    }
end

function TreasureMapLayer:onEnter(  )

	self.resPlist = {["ui/treasure_map.plist"] = 1}
	self.armatureTab = {
        "effects/tx_0051.ExportJson",
	}
	LoadArmature(self.armatureTab)
	LoadPlist(self.resPlist)


	-- 打开藏宝图的同时关闭活动界面
	local target_ui = getUIManager():get("ClsActivityMain")
	if not tolua.isnull(target_ui) then
		target_ui:closeView()
	end

	self:initUi()
end

function TreasureMapLayer:initUi()

    self.m_explore_treasure_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_treasure.json")
    self:addWidget(self.m_explore_treasure_ui)

    local background_ui = getConvertChildByName(self.m_explore_treasure_ui, "background")

    for k,v in pairs(widget_name) do
    	self[v] = getConvertChildByName(background_ui, v)
    end

	local use_item_id = getGameData():getPropDataHandler():getUseItemId()
	self.tips_team:setVisible(use_item_id == PROP_ITEM_TREASURE_VIP)
	self.tips_search:setVisible(use_item_id == PROP_ITEM_TREASURE)

    self.tips_time_num:setVisible(false)
	self.tips_time_text:setVisible(true)

    self.m_map_spr = getConvertChildByName(self.m_explore_treasure_ui, "map")

    self.btn_close:addEventListener(function()
    	local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			port_layer:initTreasureInfo()
		end

    	local ClsBackpackMainUI = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(ClsBackpackMainUI) then
			ClsBackpackMainUI:effectClose()
		end

		self:close()
		self:removeTreasureScheduler()
        self:updateExploreUI()

    end, TOUCH_EVENT_ENDED)
	self:showTime()

	-- 宝藏图最终的大小
	local scaleToWidth = 1200

	-- 在大地图中的裁剪范围
	local width = 116 * 3
	local height = 51 * 3
	local coord = getGameData():getPropDataHandler():getTreasureCoordSmall() -- 方便策划，这是一个左上角坐标
	local map_id = coord[3]   -- 用哪张地图

	self.map_res = string.format("world_map/wm_arena_%d.jpg", map_id)

	local treasuremap_test = CCSprite:create(self.map_res)
	local map_size = treasuremap_test:getContentSize()
	local sx = coord[1] - width / 2
	if sx < 0 then
		sx = 0
	elseif sx > map_size.width - width then
		sx = map_size.width - width
	end

	local sy = coord[2] - height / 2
	if sy < 0 then
		sy = 0
	elseif sy > map_size.height - height then
		sy = map_size.height - height
	end
	treasuremap_test:setTextureRect(CCRect(sx, sy, width, height))
	treasuremap_test:setScale(scaleToWidth / width) -- 缩放裁剪图的比例以让其满足scaleToWidth的大小
	self.m_map_spr:addCCNode(treasuremap_test)

	local pos = treasuremap_test:convertToWorldSpace(ccp(coord[1] - sx, coord[2] - sy))
	local pos_offset = self.m_map_spr:convertToWorldSpace(ccp(0, 0))
	local treasuremapEffect = CCArmature:create("tx_0051")
	local armatureAnimation = treasuremapEffect:getAnimation()
	armatureAnimation:addMovementCallback(function() end)
	armatureAnimation:playByIndex(0)
	treasuremapEffect:setPosition(ccp(pos.x - pos_offset.x, pos.y - pos_offset.y))
	self.m_map_spr:addCCNode(treasuremapEffect)

	---探索界面创建藏宝对象
    if isExplore then
    	local ClsExploreTreasureMapEvent = require("gameobj/explore/exploreEvent/exploreTreasureMapEvent")
    	if tolua.isnull(ClsExploreTreasureMapEvent) then
			local explore_layer = getExploreLayer()
            local explore_event_layer = explore_layer:getExploreEventLayer()
			if not tolua.isnull(explore_event_layer) then
    			explore_event_layer:createCustomEventByName("treasure_map")
    		end
    	end
    end

    self.btn_explore:addEventListener(function()


    	local ClsBackpackMainUI = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(ClsBackpackMainUI) then
			ClsBackpackMainUI:effectClose()
		end

        self:updateExploreUI()
        self:close()
		local layer = getExploreLayer()
		if not tolua.isnull(layer) then
			layer:autoTreasureGo()
			return
		end

		local supplyData = getGameData():getSupplyData()
		supplyData:askSupplyInfo(true, function()
			local exploreData = getGameData():getExploreData()
			exploreData:setTreasureNavgation(true)
			local mapAttrs = getGameData():getWorldMapAttrsData()
			mapAttrs:goOutPort(nil, EXPLORE_NAV_TYPE_NONE)
		end)
    end, TOUCH_EVENT_ENDED)

	self:registerScriptHandler(function(event)
		if event == "exit" then self:onExit() end
	end)

	ClsGuideMgr:tryGuide("TreasureMapLayer")
end

function TreasureMapLayer:updateExploreUI()
	local explore_panel = getUIManager():get("ExploreUI")
	if explore_panel and not tolua.isnull(explore_panel) then
		explore_panel:updateTreasureBtn()
	end
end

function TreasureMapLayer:showTime()
	local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
    if treasure_info and treasure_info.treasure_id ~= 0 then
        self.tips_time_num:setVisible(true)
        local scheduler = CCDirector:sharedDirector():getScheduler()
        self.treasure_info_time= scheduler:scheduleScriptFunc(function()
            self:updateTreasureTime()
        end, 1, false)
    else
        self.tips_time_num:setVisible(false)
    end
end
function TreasureMapLayer:updateTreasureTime()
	local treasure_info  = getGameData():getPropDataHandler():getTreasureInfo()
	local end_time = treasure_info.end_time
	local new_time = os.time()
	local time = end_time - new_time

	if time > 0 then
		local time = DataTool:getZnTimeStr(end_time - new_time)
		self.tips_time_num:setText(time)
		self.tips_time_num:setVisible(true)
    else
        self.tips_time_num:setVisible(false)
        local list = {treasure_id = 0, mapId = 0, positionId = 0, time = 0}
        getGameData():getPropDataHandler():setTreasureInfo(list)

        self.btn_close:executeEvent(TOUCH_EVENT_ENDED)
    end
end

function TreasureMapLayer:removeTreasureScheduler()
    if self.treasure_info_time then
        local scheduler = CCDirector:sharedDirector():getScheduler()
        scheduler:unscheduleScriptEntry(self.treasure_info_time)
        self.treasure_info_time = nil
    end
end

function TreasureMapLayer:onExit()
	self:removeTreasureScheduler()
	local plotConfig = plotDialogue:getPlotConfig()
	plotDialogue:completeMission(plotConfig.treasureMap)
	UnLoadPlist(self.resPlist)
	UnLoadArmature(self.armatureTab)

end

return TreasureMapLayer
