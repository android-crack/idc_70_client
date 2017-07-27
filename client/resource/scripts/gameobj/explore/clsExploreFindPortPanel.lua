local ClsBaseView = require("ui/view/clsBaseView")
local port_info = require("game_config/port/port_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local composite_effect = require("gameobj/composite_effect")
local UiCommon = require("ui/tools/UiCommon")
local music_info=require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local ClsExploreFindPortPanel = class("ClsExploreFindPortPanel",ClsBaseView)


local widget_name = {
	-- "port_pic", --港口图片
	"port_name", --港口名称
	"shade_panel", --裁剪的图片
	"shade_left",--左边黑影
	"shade_right",--右边黑影
	"port_pic", -- 中间的jpg图
	"port_pic",
	"btn_share",
}


local cd_widget = {
    "cd_num",
    "cd_text",
}

-- local new_port_data = {["portId"] = portId,["old_prestige"] = old_prestige,["new_prestige"] = new_prestige}


function ClsExploreFindPortPanel:resetTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
	end
	self.timer = nil
end
local touch_rect = CCRect(380, 100, 200, 300)
function ClsExploreFindPortPanel:onEnter(port_data)
	local module_game_sdk = require("module/sdk/gameSdk")
	self.login_platform = module_game_sdk.getPlatform() --登录类型
	self.plist_res = {
		["ui/explore_sea.plist"] = 1,
	}
	LoadPlist(self.plist_res)
	audioExt.playEffect(music_info.UI_NEW_PORT.res)
	self.port_data = port_data
	self.is_can_close = false

	local arr_action = CCArray:create()
	arr_action:addObject(CCDelayTime:create(0.3))
	arr_action:addObject(CCCallFunc:create(function()
		self:showPort()
	end))

	local function touch_callback(event,x, y)
		local touch_point = ccp(x, y)
		local is_in = touch_rect:containsPoint(touch_point)
		if self.is_can_close and not is_in then
			self:closeView()
		end
	end
	self:regTouchEvent(self, touch_callback)

	-- arr_action:addObject(CCDelayTime:create(1))
	-- arr_action:addObject(CCCallFunc:create(function()
	-- 	self:regTouchEvent(self, function(...) return self:closeView() end, TOUCH_BG_ORDER)
	-- end))
	-- arr_action:addObject(CCDelayTime:create(2))
	-- arr_action:addObject(CCCallFunc:create(function()
	-- 	self:closeView()
	-- end))
	-- 中断导航
	self:isAutoNavi(false)
	self:runAction(CCSequence:create(arr_action))
	local explore_layer = getExploreLayer()
    if not tolua.isnull(explore_layer) then
  		explore_layer:getShipsLayer():setStopShipReason("ClsExploreFindPortPanel")
  		explore_layer:getShipsLayer():setStopFoodReason("ClsExploreFindPortPanel")
   	end

-- "ui/explore_port/"
end

function ClsExploreFindPortPanel:showPort()
	local black_bg_spr = CCLayerColor:create(ccc4(0, 0, 0, 0))
	self:addChild(black_bg_spr, -1000)
	self.m_black_bg_spr = black_bg_spr

	self.main_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_new_port.json")
	convertUIType(self.main_ui)
	self.main_ui:setPosition(ccp(0,40))
	self:addWidget(self.main_ui)

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.main_ui, v)
	end

	for i,v in ipairs(cd_widget) do
		self[v] = getConvertChildByName(self.main_ui, v)
		self[v]:setVisible(false)
	end

	self:initShareBtn()
	-- self.port_data.portId = 20 -- test

	local str = require("game_config/port/portSet")[require("game_config/port/port_info")[self.port_data.portId].portType].res
	str = string.gsub(str,"port_bg_","explore_port_")
	str = "ui/explore_port/"..str
	-- print("----------------- str ",str)
	self.port_pic:changeTexture(str)

	self.shade_panel:setClippingEnable(true)

	self:onShow(self.port_data.portId)
	-- self:playEffect()
	self:playTitleEffect()

	-- self:playPrestigeEffect()
end

function ClsExploreFindPortPanel:initShareBtn( ... )
	self:updateCDshare()
	self.btn_share:setPressedActionEnabled(true)
	self.btn_share:addEventListener(function()

		if self.show_lock_time and tonumber(self.show_lock_time) > 0 then
            local Alert = require("ui/tools/alert")
            local tips = string.format(ui_word.PHOTO_NOT_SHARE_TIPS, tostring(self.show_lock_time))
            Alert:warning({msg = tips, size = 26})
            return 
        end

		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.canOperate(function ( )
			require("gameobj/tips/clsPostCardTips")
			createPostCard(self.port_data.portId)
		end)
		

	end, TOUCH_EVENT_ENDED)

	if self.login_platform <= 1 then
		self.btn_share:disable()
		self.btn_share:setTouchEnabled(false)
	end

	self.btn_share:setVisible(not GTab.IS_VERIFY)
end


local interval_time = 60 * 60 --30分钟

function ClsExploreFindPortPanel:updateCDshare()
    CCUserDefault:sharedUserDefault()
    local user_data = CCUserDefault:sharedUserDefault()
    local cur_share_time = user_data:getStringForKey("CurshareTime", "")
    local old_share_time = tonumber(cur_share_time)
    local remind_time = os.time() - old_share_time
    if remind_time < interval_time and remind_time > 0 then --小鱼30分钟
        for i,v in ipairs(cd_widget) do
            self[v]:setVisible(true)
        end
        local show_remian = math.ceil((interval_time - remind_time)/60)
        self.cd_num:setText(show_remian.."m")
        self.show_lock_time = show_remian
    else
        

    end

end

function ClsExploreFindPortPanel:playPrestigeEffect()
	self.is_can_close = true
	if self.port_data.new_prestige and self.port_data.old_prestige then
		local prestige = self.port_data.new_prestige - self.port_data.old_prestige
		local function prestige_callback()
			local function timer_callback()
				self:resetTimer()
				self:closeView()
			end
			-- self:resetTimer()
			-- print(" ----------------- new timer ---------------")
			self.timer = scheduler:scheduleScriptFunc(timer_callback, 4, false)
		end
		local power_effect = self:createPrestigeEffectUI(prestige,nil,1.3,prestige_callback)
		local pos = ccp(40, display.cy-480)
		power_effect:setPosition(pos)
		-- power_effect:setScale(0.8)

		self:addWidget(power_effect)
	end
end

function ClsExploreFindPortPanel:preClose()
	self:stopAllActions()
	self:removeEffect()
	self:removeTileAction()

end

function ClsExploreFindPortPanel:closeView()
	self:resetTimer()
	getGameData():getExploreData():showNewPort() --播放下个剧情
	-- 继续开船
	self:isAutoNavi(true)
	self:close()

end

function ClsExploreFindPortPanel:isAutoNavi(state)
	-- if true then
	-- 	return
	-- end
	-- print(" ----------------- 发现港口 中断导航 ------- ")
	-- print(state)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		-- print("有探索界面---------------- ")
		if state then
			explore_layer:getShipsLayer():releaseStopShipReason("ClsExploreFindPortPanel_StopShip")

			-- explore_layer:continueAutoNavigation(true)
		else
			explore_layer:getShipsLayer():setStopShipReason("ClsExploreFindPortPanel_StopShip")
		end
	end
end

--[[
	创建声望升级特效 由公共接口变更而来
	Alert:showZhanDouLiEffect
]]
function ClsExploreFindPortPanel:createPrestigeEffectUI(value,start_num, show_time, call_back)

	local layer = UIWidget:create()
	local effect_layer = UIWidget:create()
	local start_number = start_num or 0
	local label_zhandouli = createBMFont({text = start_number, size = 20, color = ccc3(dexToColor3B(COLOR_YELLOW_STROKE)), fontFile = FONT_NUM_COMBAT})
	local label_pic

	-- 只显示增加的声望.不显示总声望
	if start_num then
		label_pic = getChangeFormatSprite("ui/txt/txt_prestige_total_1.png")
	else
		label_pic = getChangeFormatSprite("ui/txt/txt_get_force.png")
	end
	audioExt.playEffect(music_info.PRESTIGE_RAISE.res)
	-- print(" -------------------")
	-- label_pic:setPositionX(-400)
	label_pic:setScale(0.6)
	layer:addChild(effect_layer)

	local effect_node = composite_effect.new("tx_0184_stop", display.cx, display.cy, effect_layer, nil, nil, nil, nil, true)
	local pos_x,pos_y = display.cx ,display.cy

	local array_action = CCArray:create()
	array_action:addObject(CCDelayTime:create(0.6))
	array_action:addObject(CCCallFunc:create(function (  )
		label_zhandouli:setPosition(ccp(pos_x+480, pos_y-25))
	end) )

	layer:addCCNode(label_zhandouli)

	local label_wgt = UIWidget:create()
	label_wgt:addCCNode(label_pic)
	label_wgt:setPosition(ccp(-7,0))
	layer:addChild(label_wgt)

	array_action:addObject(CCMoveTo:create(0.3, ccp(500,pos_y-25)))
	array_action:addObject(CCDelayTime:create(0.2))
	array_action:addObject(CCCallFunc:create(function ()
		UiCommon:numberEffect(label_zhandouli, start_number or 0, value, 30)
	end) )
	-- array_action:addObject(CCDelayTime:create(1.3))
	-- array_action:addObject(CCMoveTo:create(0.2, ccp(-20,pos_y-25)))
	-- array_action:addObject(CCFadeOut:create(0.2))
	-- array_action:addObject(CCFadeIn:create(0.01)) -- mid
	label_zhandouli:runAction(CCSequence:create(array_action))


	local array_action_pic = CCArray:create()
	array_action_pic:addObject(CCDelayTime:create(0.6))
	array_action_pic:addObject(CCCallFunc:create(function ()
		label_pic:setPosition(ccp(pos_x-370, 288))
	end))

	array_action_pic:addObject(CCMoveTo:create(0.3, ccp(402, 288)))

	-- array_action_pic:addObject(CCDelayTime:create(1.4))
	-- array_action_pic:addObject(CCMoveTo:create(0.25, ccp(1000,288)))
	-- array_action_pic:addObject(CCFadeOut:create(0.25))
	-- array_action_pic:addObject(CCFadeIn:create(0.01))
	label_pic:runAction(CCSequence:create(array_action_pic))


	local scheduler = CCDirector:sharedDirector():getScheduler()
	local function callBack()
		if type(call_back) == "function" then
			call_back()
			if layer.scheduleHandler then
				scheduler:unscheduleScriptEntry(layer.scheduleHandler)
			end
			layer.scheduleHandler = nil
		end
	end

	layer.scheduleHandler = scheduler:scheduleScriptFunc(callBack, show_time or 3, false)

	-- layer.touchCallBack = function()
	-- 	callBack()
	-- end

	-- layer.close = call_back

	-- layer.onExit = function(self)
	-- 	if layer.scheduleHandler then
	-- 		scheduler:unscheduleScriptEntry(layer.scheduleHandler)
	-- 	end
	-- 	layer.scheduleHandler = nil
	-- end
	return layer
end

function ClsExploreFindPortPanel:playTitleEffect()

	-- print(" -------------- playTitleEffect --------- ")
	local function title_action_callback()
		-- print(" --------------- title_action_callback--------------- ")
	end

	self:playEffect()
	local timer

	local function show_tilte_effect_callback()
		if tolua.isnull(self.title_effect) then
			self.effect = composite_effect.new("tx_txt_new_port", display.cx, display.height + 180, self, nil, title_action_callback, nil, nil,nil)
			if timer then
				scheduler:unscheduleScriptEntry(timer)
			end
			timer = nil
		end
	end

	timer = scheduler:scheduleScriptFunc(show_tilte_effect_callback,0.37,false)

	-- local img = UIImageView:create()
	-- img:changeTexture("ui/txt/txt_new_port.png")
	-- img:setPosition(ccp(display.width*0.5 ,display.height*0.88 + 90 ))
	-- self:addWidget(img)
	-- local arr = CCArray:create()
	-- local a1 = CCMoveTo:create(0.6, ccp(img:getPosition().x,img:getPosition().y - 90))
	-- local a2 = CCMoveTo:create(0.3,ccp(img:getPosition().x, img:getPosition().y -90 - 9 ))
	-- -- local a3 = CCCallFunc:create(callback)

	-- arr:addObject(a1)
	-- arr:addObject(a2)
	-- -- arr:addObject(a3)
	-- img:stopAllActions()
	-- img:runAction(CCSequence:create(arr))
end

function ClsExploreFindPortPanel:removeTileAction()
	if not tolua.isnull(self.title_effect) then
		self.title_effect:removeFromParentAndCleanup(true)
		self.title_effect = nil
	end
end

function ClsExploreFindPortPanel:playEffect()

	-- print(" --------------- playEffect --------------- ")
	local function discover_callback()
		-- print(" --------------- discover_callback--------------- ")
		self:playPrestigeEffect()
	end

	-- if tolua.isnull(self.effect) then
		local eff_pos = self.shade_panel:getPosition()
		local eff_size = self.shade_panel:getContentSize()
		self.effect = composite_effect.new("tx_new_port", eff_pos.x + eff_size.width / 2, eff_pos.y + eff_size.height / 2 - 8 , self, 1.2,discover_callback, nil, nil, nil)
	-- end
end

function ClsExploreFindPortPanel:removeEffect()
	if not tolua.isnull(self.effect) then
		self.effect:removeFromParentAndCleanup(true)
		self.effect = nil
	end
end

function ClsExploreFindPortPanel:setTargetScale(target,width,height)
	local content_size = target:getContentSize()
	local scale_x = width / content_size.width
	local scale_y = height / content_size.height
	target:setScaleX(scale_x)
	target:setScaleY(scale_y)
end

--添加黑影图片
function ClsExploreFindPortPanel:addBackSprite(container)
	local back_sprite = display.newSprite("#explore_new_port_shade.png")
	local content_size = container:getContentSize()
	-- back_sprite:setContentSize(CCSize(content_size.width,content_size.height))
	self:setTargetScale(back_sprite,content_size.width,content_size.height)
	back_sprite:setAnchorPoint(ccp(0,0))
	container:addCCNode(back_sprite)
	return back_sprite
end

function ClsExploreFindPortPanel:onExit()
	UnLoadPlist(self.plist_res)
	local explore_layer = getExploreLayer()
    if not tolua.isnull(explore_layer) then
  		explore_layer:getShipsLayer():releaseStopShipReason("ClsExploreFindPortPanel")
  		explore_layer:getShipsLayer():releaseStopFoodReason("ClsExploreFindPortPanel")
   	end
end

function ClsExploreFindPortPanel:createBgNode()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	local spt = display.newSprite("ui/port/bg/port_bg_2.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
	self:addChild(spt)
end

function ClsExploreFindPortPanel:onShow(portId)
	local port_data = port_info[portId]
	local portCfg = ClsDataTools:getPortSet(port_data.portType)


	self.port_name:setText(port_data.name)

	if not tolua.isnull(self.spriteBg) then
		self.spriteBg:removeFromParentAndCleanup(true)
	end
	local container_pos = self.shade_panel:getPosition()

	self.spriteBg = display.newSprite()
	self.spriteBg:setContentSize(CCSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT))
	self.spriteBg:setPosition(display.cx, display.cy - container_pos.y)
	self.shade_panel:addCCNode(self.spriteBg)
	-- use rgb565
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	self.spriteBgPhoto = display.newSprite(portCfg.res, display.cx, display.cy)
	CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
	self.spriteBg:addChild(self.spriteBgPhoto)

	-- local portData = getGameData():getPortData()
	if port_data.flipX == 1 then
		self.spriteBg:setFlipX(true)
		self.spriteBgPhoto:setFlipX(true)
	end
	--得到缩放的比例
	self.bgScale = CONFIG_SCREEN_WIDTH/self.spriteBgPhoto:getContentSize().width
	self.spriteBgPhoto:setScale(self.bgScale)
end

return ClsExploreFindPortPanel
