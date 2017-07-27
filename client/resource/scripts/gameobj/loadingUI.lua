-- loading 界面
local UiCommon = require("ui/tools/UiCommon")
local UI_WORD = require("game_config/ui_word")
local loading_tips_info = require("game_config/loading_tips_info")

local ModuleLoading = {}

local TICK_VALUE = - 0.1

function ModuleLoading:show(callback, bg_params)
	if not tolua.isnull(self.layer) then return end

	bg_params = bg_params or {}
	self.res_tab = {
		bg = bg_params.load_bg_path or "ui/bg/bg_loading.jpg",
		rudder = "ui/loading/loading_helm.png",
		compass = "ui/loading/loading_helm_bg.png",
		progress_bg = "ui/loading/loading_bar_bg.png",
		progress = "ui/loading/loading_bar.png",
		bottom_bg = "ui/loading/loading_black.png",
		bottom_text_bg = "ui/loading/loading_tips_bg.png",
	}

	self.layer = display.newLayer()
	self.layer:setTouchPriority(TOUCH_PRIORITY_GOD)
	self.layer:setTouchEnabled(true)

	local backgroundSprite = UiCommon:getBgSprite(self.res_tab.bg, display.cx, display.cy, nil, kCCTexture2DPixelFormat_RGB565)
	self.layer:addChild(backgroundSprite)
	if bg_params.is_flip_x then
		backgroundSprite:setFlipX(true)
	end

	local bottom_bg = display.newSprite(self.res_tab.bottom_bg)
	bottom_bg:setPosition(ccp(display.cx, 113))
	self.layer:addChild(bottom_bg)

	local bottom_text_bg = display.newSprite(self.res_tab.bottom_text_bg)
	bottom_text_bg:setPosition(ccp(display.cx, 43))
	self.layer:addChild(bottom_text_bg)

	local rudderAction = CCRotateBy:create(6, 720)
	local rudder = display.newSprite(self.res_tab.rudder)
	rudder:runAction(CCRepeatForever:create(rudderAction))
	rudder:setPosition(345, 144)
	self.layer:addChild(rudder)

	local compassAction = CCRotateBy:create(20, -720)
	local compass = display.newSprite(self.res_tab.compass)
	compass:setPosition(345, 144)
	compass:runAction(CCRepeatForever:create(compassAction))
	self.layer:addChild(compass)

	local progress_bg = display.newSprite(self.res_tab.progress_bg)
	progress_bg:setPosition(display.cx, 144)
	self.layer:addChild(progress_bg)

	local precent = 0.0
	local progress_sprite = display.newSprite(self.res_tab.progress)
	self.proWidth = progress_sprite:getContentSize().width
	self.progress = CCProgressTimer:create(progress_sprite)
	self.progress:setType(kCCProgressTimerTypeBar)
	self.progress:setMidpoint(ccp(0, 1))
	self.progress:setBarChangeRate(ccp(1, 0))
	self.progress:setPercentage(precent * 100)
	self.progress:setPosition(display.cx, 144)
	self.layer:addChild(self.progress)

	self.num = createBMFont({text = "0%", size = 16, fontFile = FONT_COMMON,color = ccc3(dexToColor3B(COLOR_WHITE))})
	self.num:setPosition(display.cx, 144)
	self.layer:addChild(self.num)

	local label = createBMFont({text = UI_WORD.LOADING, size = 16, fontFile = FONT_COMMON,color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	label:setPosition(display.cx + 20, 168)
	self.layer:addChild(label)

	local lbl_game_tips = createBMFont({text = loading_tips_info[math.random(1, #loading_tips_info)].tips_txt, size = 18, fontFile = FONT_COMMON,color = ccc3(dexToColor3B(COLOR_WHITE))})
	lbl_game_tips:setPosition(display.cx, 43)
	self.layer:addChild(lbl_game_tips)

	-- 增加UI 活动与开放
	self.plist_table = {
		-- ["ui/activity_ui.plist"] = 1,
	}
	LoadPlist(self.plist_table)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_loading.json")
	convertUIType(panel)

	local wgts = {
		["panel_act"] = "today_activity", -- 活动面板
		["panel_rest"] = "today_rest", -- 休息面板
		["img_award_1"] = "award_icon_1",-- 奖励图标1
		["img_award_2"] = "award_icon_2", -- 奖励图标2
		["text_time"] = "time_num", -- 活动时间文本
		["img_icon"] = "activity_icon", -- 活动图标
		["text_name"] = "activity_name", --活动名
	}
	for k,v in pairs(wgts) do
		panel[k] = getConvertChildByName(panel,v)
	end
	local item = require("game_config/activity/loading_info")[tonumber(os.date("%w",os.time()))]

	-- print('----------- item',os.date("%w",os.time()))
	-- table.print(item)
	-- table.print(require("game_config/activity/loading_info")[5])

	if item ~= nil then
		panel.panel_act:setVisible(true)
		panel.panel_rest:setVisible(false)
		panel.text_name:setText(item.name)
		panel.text_time:setText(item.time)
		panel.img_icon:changeTexture(item.icon,UI_TEX_TYPE_PLIST)
		panel.img_award_1:changeTexture(item.reward[1],UI_TEX_TYPE_PLIST)
		panel.img_award_2:changeTexture(item.reward[2],UI_TEX_TYPE_PLIST)

	else
		panel.panel_act:setVisible(false)
		panel.panel_rest:setVisible(true)
	end
	panel:setScale(1)
	panel:setVisible(true)
	local uilayer = UILayer:create()
	uilayer:addWidget(panel)
	self.layer:addChild(uilayer)

	local running_scene = GameUtil.getNotification()
	running_scene:addChild(self.layer, ZORDER_PORT_LOADING)

	-- 渲染这个界面之后才回调
	if callback then
		require("framework.scheduler").performWithDelayGlobal(callback, 0)
	end

	self:musicFade()
end

function ModuleLoading:musicFade(is_fadeIn)
	self:removeHandler()

	if not audioExt.isMusicEnabled() then return end

	local tick_value = TICK_VALUE

	if is_fadeIn then
		audioExt.setMusicVolume(0)

		tick_value = - tick_value
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.handler = scheduler:scheduleScriptFunc(function()
		local music = false

		local music_volume = audioExt.getMusicVolume() + tick_value

		if is_fadeIn then
			if music_volume >= 1 then
				audioExt.setMusicVolume(1)
				music = true
			else
				audioExt.setMusicVolume(music_volume)
			end
		else
			if music_volume <= 0 then
				audioExt.setMusicVolume(0)
				music = true
			else
				audioExt.setMusicVolume(music_volume)
			end
		end

		if not music then return end

		self:removeHandler()
	end, 0.2, false)
end

function ModuleLoading:removeHandler()
	if self.handler then
		local scheduler = CCDirector:sharedDirector():getScheduler()

		scheduler:unscheduleScriptEntry(self.handler)
		self.handler = nil
	end
end

function ModuleLoading:remove(isRelink)
	if tolua.isnull(self.layer) then
		self:removeHandler()
		return
	end

	self:musicFade(true)

	self.layer:removeFromParentAndCleanup(true)
	for k, v in pairs(self.res_tab) do
		RemoveTextureForKey(v)
	end

	UnLoadPlist(self.plist_table)

	if not isRelink and type(self.call_back) == "function" then
		self.call_back()
	end

	if not IS_SYNC_SERVER_TIME then
		GameUtil.callRpc("rpc_server_sync_server_time", {})
	end
end

function ModuleLoading:start(load_res, callback)
	self.call_back = callback

	self:show()

	local function loadfunc(current, count)
		if tolua.isnull(self.progress) then
			return
		end
		local precent = current/count
		self.progress:setPercentage(precent * 100)
		self.num:setString(tostring(toint(precent * 100)).."%")

		if current == count then
			require("framework.scheduler").performWithDelayGlobal(function() 
				self:remove() 
			end, 0)
		end
	end

	require("module/preload/preload_mgr").asyncLoadRes(load_res, loadfunc)
end

function ModuleLoading:hide()
	if not tolua.isnull(self.layer) then
		self.layer:removeFromParentAndCleanup(true)
	end
end

function ModuleLoading:forceClear()
	if tolua.isnull(self.layer) then
		return
	end
	QResourceManager:purgeResourceManager()
	require("gameobj/loadingUI"):remove(true)
end

return ModuleLoading
