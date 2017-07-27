--这个是点击遗迹后出来的页面，用于补给或者进入遗迹的主页面

local ClsAlert = require("ui/tools/alert")
local ClsDialogLayer = require("ui/dialogLayer")
local news = require("game_config/news")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local relic_info = require("game_config/collect/relic_info")
local relic_star_info = require("game_config/collect/relic_star_info")
local exploreMapUtil = require("module/explore/exploreMapUtil")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRelicEnterAndSuplyView = class("ClsRelicEnterAndSuplyView", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsRelicEnterAndSuplyView:getViewConfig()
    return {
        name = "ClsRelicEnterAndSuplyView",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsRelicEnterAndSuplyView:onEnter(relic_info, close_callback, enter_call)
	self:setIsWidgetTouchFirst(true)
	self.m_collect_handle = getGameData():getCollectData()  --记录其hander
	self.m_relic_info = relic_info --记录其信息（包含后端数据）
	self.m_plist_tab = {}
	self.m_image_tab = {}

	self.m_ui_layer = nil
    self.m_panel = nil --json ui
	self.m_close_callback = close_callback  -- 结束回调
	self.enter_call = enter_call --进入回调
	self.m_is_suply_b = false
	self.m_is_need_resume_explore = true
	self.m_is_unknow_relic_b = true --是否是为探索的遗迹

	--中断导航
	if IS_AUTO then
		getExploreLayer().land:breakAuto(true)
	end

	LoadPlist(self.m_plist_tab)
	self:initUI()

	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():setStopFoodReason("ClsRelicEnterAndSuplyView_show")
	end
	if type(self.enter_call) == "function" then
		self.enter_call()
	end
end

--基础ui初始化
function ClsRelicEnterAndSuplyView:initUI()
	if self.m_relic_info.explorePoint then
		self.m_is_unknow_relic_b = false
	end
	--添加基本层
    self.m_panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_sea_relic.json")
    self:addWidget(self.m_panel)

	self.m_bg_spr = getConvertChildByName(self.m_panel,"bg") -- 关闭按钮
	local bg_size = self.m_bg_spr:getSize()
	self.touch_rect = CCRect(display.cx - bg_size.width / 2, display.cy - bg_size.height / 2, bg_size.width, bg_size.height)

	self.m_close_btn = getConvertChildByName(self.m_panel,"btn_close") -- 关闭按钮
	self.m_suply_btn = getConvertChildByName(self.m_panel,"btn_add") -- 补给按钮
	self.m_enter_btn = getConvertChildByName(self.m_panel,"btn_enter") -- 进入遗迹按钮

	self.m_relic_bg_spr = getConvertChildByName(self.m_panel,"relic_pic_bg") -- 遗迹图片显示内容
	self.m_detail_panel = getConvertChildByName(self.m_panel,"detail_panel") -- 遗迹图片显示内容

    --设置公告层可视区域
	self.m_clip_node = CCClippingNode:create()
	local draw_node = CCDrawNode:create()
	local color = ccc4f(0, 1, 0, 1)
	local points = CCPointArray:create(120)
    local len_n = 88
    for i = 1, 120 do
        local angle_n = math.rad((i - 1)*3)
        points:add(ccp(math.cos(angle_n)*len_n, math.sin(angle_n)*len_n))
    end
	draw_node:drawPolygon(points, color, 0, color)
	draw_node:setPosition(0, 0)
	self.m_clip_node:setStencil(draw_node)
	self.m_clip_node:setInverted(false)
	self.m_clip_node:setPosition(ccp(-1, 5))
    self.m_relic_bg_spr:addCCNode(self.m_clip_node)

	self:initBtnsAndEvent()
	self:initRelicName()
	if self.m_is_unknow_relic_b then
		self:initUnknowRelicUI()
	else
		self:initKnowRelicUI()
	end
end

--添加事件回调和触发事件
function ClsRelicEnterAndSuplyView:initBtnsAndEvent()
	--关闭按钮
	self.m_close_btn:setPressedActionEnabled(true)
    self.m_close_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
    end, TOUCH_EVENT_ENDED)

	--补给按钮
	self.m_suply_btn:setPressedActionEnabled(true)
	self.m_suply_btn:addEventListener(function()
		-- 请求补给
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getGameData():getSupplyData():askSupplyFull()
		self.m_suply_btn:setTouchEnabled(false)
    end, TOUCH_EVENT_ENDED)
	self.m_suply_btn:setTouchEnabled(true)
	--进入按钮
	self.m_enter_btn:setPressedActionEnabled(true)
	self.m_enter_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
		self:onEnterRelic()
    end, TOUCH_EVENT_ENDED)

	RegTrigger(EVENT_RELIC_SUPLY_DONE, function(is_error)
		if tolua.isnull(self) then return end
		if (nil == view_obj) then return end
		self.m_suply_btn:setTouchEnabled(true)
		if not is_error then
			self:showAfterSuplyView()
		end
		return true
	end)

	self:regTouchEvent(self, function(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "ended" then
            if not self.touch_rect:containsPoint(ccp(x, y)) then
            	self:close()
            end
        end
    end)
end

--补给结束后的弹框回调
function ClsRelicEnterAndSuplyView:showAfterSuplyView()
	local supplyData = getGameData():getSupplyData()
	supplyData:saveConsumeCash()
	local text = string.format(news.EXPLORER_SUPPLY_CASH.msg, supplyData:getComsumeCash())
	ClsAlert:explorerSupplyAttention(text, self.m_close_callback)
end

--初始化遗迹名
function ClsRelicEnterAndSuplyView:initRelicName()
	local name_lab = getConvertChildByName(self.m_bg_spr,"relic_name")
	local desc_str = self.m_relic_info.relicInfo.name
	if self.m_is_unknow_relic_b then
		desc_str = ui_word.RELIC_UNKNOW_DESC
	end
	name_lab:setText(desc_str)
end

--初始化未知遗迹的ui
function ClsRelicEnterAndSuplyView:initUnknowRelicUI()
	--添加未知遗迹图片
	local unknow_relic_pic_str = "ui/relic/relic_unknown.jpg"
	local unknow_relic_spr = CCGraySprite:create(unknow_relic_pic_str)
	self.m_clip_node:addChild(unknow_relic_spr)
    unknow_relic_spr:setScale(0.7)
	self.m_image_tab[unknow_relic_pic_str] = 1

    self.m_detail_panel:setVisible(false)
    --通过功能开关控制
    local on_off_info = require("game_config/on_off_info")
    local is_relic_open = getGameData():getOnOffData():isOpen(on_off_info.YIJI_EXPLORE.value)
    if not is_relic_open then
    	self.m_enter_btn:disable()
		self.m_suply_btn:disable()
		local tips_str = ui_word.RELIC_NOT_OPEN_TIP
		local need_tip_lab = createBMFont({text = tips_str, fontFile = FONT_COMMON, size = 24, x = 0, y = -85,
			color = ccc3(dexToColor3B(COLOR_RED))})
		self.m_bg_spr:addCCNode(need_tip_lab)
    end

	--通过等级控制
	-- local lv_n = getGameData():getPlayerData():getLevel()
	-- local need_lv_n = relic_star_info[1].grade
	-- if need_lv_n > lv_n then
	-- 	self.m_enter_btn:disable()
	-- 	self.m_suply_btn:disable()
	-- 	local tips_str = ui_word.RELIC_NEED_SAILOR_SKILL .. tostring(need_lv_n) ..ui_word.MAIN_LEVEL
	-- 	local need_tip_lab = createBMFont({text = tips_str, fontFile = FONT_COMMON, size = 24, x = 0, y = -85,
	-- 		color = ccc3(dexToColor3B(COLOR_RED))})
	-- 	self.m_bg_spr:addCCNode(need_tip_lab)
	-- end
end

--初始化已开放的遗迹的ui
function ClsRelicEnterAndSuplyView:initKnowRelicUI()
	self.m_detail_panel:setVisible(true)

	--遗迹图片
	local relic_pic_str = "ui/yiji/"..self.m_relic_info.relicInfo.res
	self.m_image_tab[relic_pic_str] = 1
	local relic_pic_spr = display.newSprite(relic_pic_str, 0, 0)
    relic_pic_spr:setScale(0.7)
    self.m_clip_node:addChild(relic_pic_spr)

	--探索度
	local relic_discover_num_lab = getConvertChildByName(self.m_detail_panel,"explore_num")
	local relic_data = self.m_relic_info.relicInfo
	local max_star_n = relic_data.max_star or 1
	local relic_star_item = relic_star_info[max_star_n]
	local max_explore_point_n = relic_star_item.explorePoint
	local now_explore_point_n = self.m_relic_info.explorePoint
	local per_n = math.floor(now_explore_point_n/max_explore_point_n*100 + 0.5)
	if per_n > 100 then
		per_n = 100
	end
	relic_discover_num_lab:setText(per_n .. ui_word.RELIC_DISCOVER_PER)

	local cur_star_n = self.m_relic_info.star or 0
	local max_star_n = self.m_relic_info.relicInfo.max_star or 0
	local ui_star_n = 5
	local star_panel = getConvertChildByName(self.m_detail_panel, "star_panel")
	for i = 1, 7 do
		local star_ui = getConvertChildByName(star_panel,"star_bg_"..i)
		if i <= max_star_n then
			if i <= cur_star_n then
				local bright_star_spr = getConvertChildByName(star_ui,"star_"..i)
				bright_star_spr:setVisible(true)
			end
		else
			star_ui:setVisible(false)
		end
	end
end

function ClsRelicEnterAndSuplyView:onEnterRelic()
	self.m_is_need_resume_explore = false
	if self.m_close_callback then
		self.m_close_callback()
	end
	ClsDialogLayer:hideAllDialog()
	local collect_data = getGameData():getCollectData()
	local relic_id = self.m_relic_info.id
	local is_discovery = collect_data:isDiscoveryRelic(relic_id)
	if not is_discovery then
		collect_data:askDiscoveryRelic(relic_id)
	end
	self:showDiscoverUi(self.m_relic_info)
end

function ClsRelicEnterAndSuplyView:showDiscoverUi(relic_info)
	getUIManager():close("ClsRelicDiscoverUI")
	getUIManager():create("gameobj/relic/RelicDiscoverUI", nil, relic_info, function()
		getUIManager():close("ClsRelicDiscoverUI")
	end)
end

function ClsRelicEnterAndSuplyView:onExit()
	UnLoadPlist(self.m_plist_tab)
	UnLoadImages(self.m_image_tab)
	UnRegTrigger(EVENT_RELIC_SUPLY_DONE)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():releaseStopFoodReason("ClsRelicEnterAndSuplyView_show")
	end
end

return ClsRelicEnterAndSuplyView
