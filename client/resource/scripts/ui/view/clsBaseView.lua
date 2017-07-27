--2016/09/02
--create by wmh0497
--页面基类

local ClsLinkList = require("base/clsLinkList")
local ClsViewButton = require("ui/view/clsViewButton")
local ClsViewTouchManager = require("ui/view/clsViewTouchManager")
local music_info = require("game_config/music_info")

local MAX_TOUCH_EVENT_ORDER = 999999

local ClsBaseView = class("clsBaseView", function() return UILayer:create() end)

--不能重载
function ClsBaseView:ctor(manager, name_str, view_cfg)
    self.m_manager = manager
    self.m_name_str = name_str
    self.m_auto_open_lock_reason_str = "auto_open_lock_"..self.m_name_str
    self.m_auto_close_lock_reason_str = "auto_close_lock_"..self.m_name_str
    self.m_view_cfg = view_cfg
    self.m_view_zorder = nil
    self.m_touch_priority = 0
    self.m_is_swallow_touch = nil
    self.m_is_hide_before_view = view_cfg.hide_before_view or false
	self.m_is_after_hide_before_view = false
    self.m_is_manager_touch = nil
    self.m_is_view_touch = true
    self.m_is_hander_swallow = true
    self.m_is_widget_touch_first = false
    self.m_components = {}
    self.m_touch_manager = nil
    
    self.m_view_enter_params = {}
    self.m_view_exit_params = {}
end

function ClsBaseView:setViewEnterParams(...)
    self.m_view_enter_params = {...}
end

function ClsBaseView:setViewExitParams(...)
    self.m_view_exit_params = {...}
end

function ClsBaseView:initViewBase()

	if false == self.m_view_cfg.is_hander_swallow then
		self.m_is_hander_swallow = false
	end

	self.m_view_root_spr = display.newSprite()
	self.m_view_effect_spr = display.newSprite()
	self.m_view_effect_spr:setPosition(display.cx, display.cy)
	self.m_view_adapt_spr = display.newSprite()
	self.m_view_adapt_spr:setPosition(-display.cx, -display.cy)
	
	self.m_view_root_spr:addChild(self.m_view_effect_spr)
	self.m_view_effect_spr:addChild(self.m_view_adapt_spr)
	
	self.m_touch_manager = ClsViewTouchManager.new(self.m_is_hander_swallow)
	self.m_view_adapt_spr:addChild(self.m_touch_manager)
	self.m_touch_manager:setView(self)

	local is_swallow_touch = self.m_view_cfg.is_swallow or false
	self:setSwallowTouch(is_swallow_touch, true)

	self:setTouchEnabled(true)
	self.m_touch_manager:setTouchEnabled(true)
	
	self.m_is_call_enter = false
	self:registerScriptHandler(function(event)
		if event == "enterTransitionFinish" then
			if not self.m_is_call_enter then
				self:onEnter(unpack(self.m_view_enter_params))
				self.m_is_call_enter = true
			end
		elseif event == "exit" then
			self:onExit(unpack(self.m_view_exit_params))
			self.m_manager:releaseLockTouchReason(self.m_auto_close_lock_reason_str, true)
			self.m_manager:releaseLockTouchReason(self.m_auto_open_lock_reason_str, true)
			self.m_touch_manager:clean()
		end
	end)

	if self.m_view_cfg.is_back_bg then
		local black_bg_spr = CCLayerColor:create(ccc4(0, 0, 0, 128))
		self.m_black_bg_spr = black_bg_spr
	end
	
	local black_bg_parent = self.m_view_root_spr
	if self.m_view_cfg.effect == UI_EFFECT.DOWN then
		self:playDownOpenEffect()
	elseif self.m_view_cfg.effect == UI_EFFECT.FADE then
		if self.m_is_hide_before_view then
			self.m_is_hide_before_view = false
			self.m_is_after_hide_before_view = true
		end
		self:playFadeOpenEffect()
		black_bg_parent = self.m_view_adapt_spr
	elseif self.m_view_cfg.effect == UI_EFFECT.SCALE then
		self:playScaleOpenEffect()
	end
	
	if not tolua.isnull(self.m_black_bg_spr) then
		black_bg_parent:addChild(self.m_black_bg_spr, -1000)
	end
end

function ClsBaseView:addToManager(parent, order_n)
	order_n = order_n or 0
	parent:addChild(self.m_view_root_spr, order_n)
	self.m_view_adapt_spr:addChild(self)
end

function ClsBaseView:getViewRoot()
	return self.m_view_root_spr
end

function ClsBaseView:getViewName()
	return self.m_name_str
end
---------------------------------------------
----------------可重载方法-------------------

--[[
必须重写的方法
参数:
    name :              (选填）默认使用类名，用于查询ui的key值，注意别跟别人一样
    type :              (选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
    is_swallow :        (选填) 默认true, 是否吞掉下层页面的触摸事件
    effect:             (选填) 默认nil, 无特效，如果有，使用 UI_EFFECT.FATE,DOWN,SCALE
    is_back_bg:         (选填) 默认false, 是否在界面上加一个半透明的黑化层
    is_hander_swallow   (选填) 默认是true, 绝大多数情况不填就可以了。在cocos2d-x中是否接受事件，并且传递到下一层
    hide_before_view    (选填) 默认是false, 全屏界面不显示下层界面
--]]
function ClsBaseView:getViewConfig(...)
    return {}
end
--在对象new，未addchild前调用, 参数由uimanage传入的
function ClsBaseView:onCtor(...)
end

--cocos2d-x的enter事件触发(推荐使用)
function ClsBaseView:onEnter(...)
end

--在对象new，addchild后调用
function ClsBaseView:onStart(...)
end

--cocos2d-x的exit事件触发(推荐使用) 删除资源和数据
function ClsBaseView:onExit()
end

--对象被完全释放
function ClsBaseView:onFinish( ... )
    -- body
end

--在页面调用remove前调用,主用删除ui对象
function ClsBaseView:preClose(...)
    
end

--在页面的触摸改变时会调用（不要重载这个接口，特殊情况才可用）
function ClsBaseView:onTouchChange(is_touch)
end

--------------特效相关回调--------------------
--在fade特效快结束要显示出来的时候（注意，只有使用了fade特效之后才可能调用）
function ClsBaseView:onFadeFinish()
end
----------------------------------------------

-------------可重载方法结束------------------
---------------------------------------------

---------------组件方法---------------
function ClsBaseView:addComponent(name_str, clazz, ...)
    if self.m_components[name_str] then
        print("has same Component", name_str)
        return
    end
    self.m_components[name_str] = clazz.new(self)
    self.m_components[name_str]:onStart(...)
end

function ClsBaseView:callComponent(name_str, func_name, ...)
    local component = self.m_components[name_str]
    if component then
        if component[func_name] then
            return component[func_name](component, ...)
        end
    end
end

function ClsBaseView:removeComponent(name_str, ...)
    local component = self.m_components[name_str]
    if component then
        component:onClose(...)
    end
    self.m_components[name_str] = nil
end
---------------------------------------

--关闭自己的页面
function ClsBaseView:close()
    self.m_manager:close(self.m_name_str)
end

--关闭自己的页面(带特效的假关，在特效播完之后才会真的关)
function ClsBaseView:effectClose()
	if self.m_view_cfg.effect == UI_EFFECT.DOWN then
		self:playDownCloseEffect()
	elseif self.m_view_cfg.effect == UI_EFFECT.FADE then
		self:playFadeCloseEffect()
	elseif self.m_view_cfg.effect == UI_EFFECT.SCALE then
		self:playScaleCloseEffect()
	else
		self:close()
	end
end

--管理器调的，别用
function ClsBaseView:setViewOrder(zorder)
    if self.m_view_zorder ~= zorder then
        self.m_view_zorder = zorder
        self.m_view_root_spr:setZOrder(self.m_view_zorder)
    end
end

function ClsBaseView:getViewOrder()
    return self.m_view_zorder or 0
end

function ClsBaseView:isSwallowTouch()
    return self.m_is_swallow_touch
end

function ClsBaseView:setSwallowTouch(is_swallow, ignore_manager_touch_update)
    if self.m_is_swallow_touch ~= is_swallow then
        self.m_is_swallow_touch = is_swallow
        if not ignore_manager_touch_update then
            self.m_manager:checkTouchState()
        end
    end
end

function ClsBaseView:isHideBeforeView()
    return self.m_is_hide_before_view
end

function ClsBaseView:setHideBeforeView(is_hide, ignore_manager_touch_update)
    if self.m_is_hide_before_view == is_hide then return end
    
    self.m_is_hide_before_view = is_hide
    if not ignore_manager_touch_update then
        self.m_manager:checkTouchState()
    end
end

--管理器调的，别用
function ClsBaseView:setManagerTouchEnabled(is_touch)
    if self.m_is_manager_touch ~= is_touch then
        self.m_is_manager_touch = is_touch
        self:updateTouchState()
    end
end

function ClsBaseView:getManagerTouchEnabled()
    return self.m_is_manager_touch
end

function ClsBaseView:getUIManager()
    return self.m_manager
end

--可调用
function ClsBaseView:setViewTouchEnabled(is_touch)
    self.m_is_view_touch = is_touch
    self:updateTouchState()
end

function ClsBaseView:getViewTouchEnabled()
    if not self:getManagerTouchEnabled() then
        return false
    end
    return self.m_is_view_touch
end

function ClsBaseView:setViewVisible(is_visible)
    self:setVisible(is_visible)
    self:setViewTouchEnabled(is_visible)
end

--不可以调用
function ClsBaseView:updateTouchState()
    local is_touch = self:getViewTouchEnabled()
    
    if is_touch ~= self:isTouchEnabled() then
        self:setTouchEnabled(is_touch)
        if not tolua.isnull(self.m_touch_manager) then
            self.m_touch_manager:setTouchEnabled(is_touch)
        end
        self:onTouchChange(is_touch)
    end
end

--不可以调用
function ClsBaseView:setViewTouchPriority(priority_n)
    if self.m_touch_priority ~= priority_n then
        self.m_touch_priority = priority_n
        self:updateViewTouchHander()
    end
end

--不可以调用
function ClsBaseView:updateViewTouchHander()
    local ui_layer_pri = self.m_touch_priority
    local user_layer_pri = self.m_touch_priority - 1
    if self.m_is_widget_touch_first then
        ui_layer_pri, user_layer_pri = user_layer_pri, ui_layer_pri
    end
    self:setTouchPriority(ui_layer_pri)
    if not tolua.isnull(self.m_touch_manager) then
        self.m_touch_manager:setUserTouchPriority(user_layer_pri)
        self.m_touch_manager:setGuildTouchPriority(self.m_touch_priority - 2)
        self.m_touch_manager:setGuildPassTouchPriority(self.m_touch_priority - 3)
    end
end

--设置是否cocosStuido的内容优先于自定义触摸的响应
function ClsBaseView:setIsWidgetTouchFirst(is_first)
    if self.m_is_widget_touch_first ~= is_first then
        self.m_is_widget_touch_first = is_first
        self:updateViewTouchHander()
    end
end

function ClsBaseView:setMoveCamera(camera)
    self.m_touch_manager:setMoveCamera(camera)
end

function ClsBaseView:getOriginScreenXY(x, y)
    return self.m_touch_manager:getOriginXY(x, y)
end

--order_n 整型，值越大，越先响应。值一样的，后加的先响应
function ClsBaseView:regTouchEvent(node, touch_func, order_n)
    order_n = order_n or 0
    if tolua.isnull(node) or ("function" ~= type(touch_func)) then
        return
    end
    self.m_touch_manager:insertUserTouchEvent(node, touch_func, order_n)
end

--这个是注册新手引导的回调，请不要调用啊
function ClsBaseView:regGuildTouchEvent(node, touch_func, order_n)
    order_n = order_n or 0
    if tolua.isnull(node) or ("function" ~= type(touch_func)) then
        return
    end
    self.m_touch_manager:insertGuildTouchEvent(node, touch_func, order_n)
end
--这个是注册新手引导的回调，请不要调用啊
function ClsBaseView:regGuildPassTouchEvent(node, touch_func, order_n)
    order_n = order_n or 0
    if tolua.isnull(node) or ("function" ~= type(touch_func)) then
        return
    end
    self.m_touch_manager:insertGuildPassTouchEvent(node, touch_func, order_n)
end

--[[
参数
x,y
sound
image
imageSelected
imageDisabled == "" 用 image 的灰白图， imageDisabled == "#xxx.png" 则用它自己 

--下面的是在按钮上加字时的参数（全部都是可以不填）
fsize 字体大小
fx, fy 文本框坐标
fcolor 文本颜色
text 文本文字
fpading 自动缩放的左右空隙像素
ftag 文本控件的显示层级
fanchor 文本的描点
fopacity 文本透明度
fscale 文本的缩放
ignoreAuto 是否关闭自动缩放
--]]
function ClsBaseView:createButton(btn_param, order_n)
    order_n = order_n or 0
    local btn = ClsViewButton.new(btn_param)
    local touch_func = function(...)
        return btn:onTouch(...)
    end
    self:regTouchEvent(btn, touch_func, order_n)
    return btn
end

function ClsBaseView:createLockButton(btn_param)
    local btn = ClsViewButton.new(btn_param)
    local touch_func = function(...)
        return btn:onTouch(...)
    end
    self:regGuildTouchEvent(btn, touch_func, -100)
    return btn
end

function ClsBaseView:getViewType()
    return self.m_view_cfg.type
end

----------------页面打开特效播放相关-----------------------
function ClsBaseView:playScaleOpenEffect()
	local target = self.m_view_effect_spr
	local t_scale_x = 1
	local t_scale_y = 1
	target:setScaleX(0)
	target:setScaleY(0)
	target:stopAllActions()
	
	local scale_arr = CCArray:create()
	scale_arr:addObject(CCScaleTo:create(0.05, t_scale_x * 0.8, t_scale_y * 0.8))
	scale_arr:addObject(CCScaleTo:create(0.05, t_scale_x * 0.93, t_scale_y * 1.05))
	scale_arr:addObject(CCScaleTo:create(0.09, t_scale_x * 1.01, t_scale_y * 0.99))
	scale_arr:addObject(CCScaleTo:create(0.05, t_scale_x, t_scale_y))
	target:runAction(CCSequence:create(scale_arr))
	audioExt.playEffect(music_info.TOWN_CARD.res)
end

function ClsBaseView:playScaleCloseEffect()
	self.m_manager:setLockTouchReason(self.m_auto_close_lock_reason_str)
	local target = self.m_view_effect_spr
	local t_scale_x = target:getScaleX()
	local t_scale_y = target:getScaleY()
	target:stopAllActions()
	
	local scale_arr = CCArray:create()
	scale_arr:addObject(CCScaleTo:create(0.09, t_scale_x * 1.01, t_scale_y * 0.99))
	scale_arr:addObject(CCScaleTo:create(0.05, t_scale_x * 0.93, t_scale_y * 1.05))
	scale_arr:addObject(CCScaleTo:create(0.05, t_scale_x * 0.8, t_scale_y * 0.8))
	scale_arr:addObject(CCScaleTo:create(0.05, 0, 0))
	scale_arr:addObject(CCCallFunc:create(function()
			self:close()
		end))
	target:runAction(CCSequence:create(scale_arr))
	audioExt.playEffect(music_info.TOWN_CARD.res)
end

function ClsBaseView:playFadeOpenEffect()
	local target = self.m_view_effect_spr
	target:stopAllActions()
	
	self.m_view_effect_spr:setPosition(10000, 0)
	self.m_manager:setLockTouchReason(self.m_auto_open_lock_reason_str, true)
	
	local tran_color_spr = CCLayerColor:create(ccc4(0,0,0,255))
	local t = 0.25
	local fade_arr = CCArray:create()
	fade_arr:addObject(CCFadeIn:create(t))
	fade_arr:addObject(CCCallFunc:create(function()
			if tolua.isnull(self) or (not self.m_manager:isLive(self.m_name_str)) then
				if not tolua.isnull(tran_color_spr) then
					tran_color_spr:removeFromParentAndCleanup(true)
					tran_color_spr = nil
				end
				return
			end
			self.m_view_effect_spr:setPosition(display.cx, display.cy)
			if self.m_is_after_hide_before_view then
				self:setHideBeforeView(true)
			end
			self:onFadeFinish()
		end))
	fade_arr:addObject(CCFadeOut:create(t))
	fade_arr:addObject(CCCallFunc:create(function()
			if not tolua.isnull(tran_color_spr) then
				tran_color_spr:removeFromParentAndCleanup(true)
				tran_color_spr = nil
			end
			
			if not self.m_manager:isLive(self.m_name_str) then return end
			self.m_manager:releaseLockTouchReason(self.m_auto_open_lock_reason_str)
		end))
	tran_color_spr:runAction(CCSequence:create(fade_arr))
	self.m_manager:addToEffectLayer(tran_color_spr)
end

function ClsBaseView:playFadeCloseEffect()
	self.m_manager:setLockTouchReason(self.m_auto_close_lock_reason_str)
	
	local tran_color_spr = CCLayerColor:create(ccc4(0,0,0,255))
	local t = 0.25
	local fade_arr = CCArray:create()
	fade_arr:addObject(CCFadeIn:create(t))
	fade_arr:addObject(CCCallFunc:create(function()
			self:close()
		end))
	fade_arr:addObject(CCFadeOut:create(t))
	fade_arr:addObject(CCCallFunc:create(function()
			if not tolua.isnull(tran_color_spr) then
				tran_color_spr:removeFromParentAndCleanup(true)
				tran_color_spr = nil
			end
		end))
	tran_color_spr:runAction(CCSequence:create(fade_arr))
	self.m_manager:addToEffectLayer(tran_color_spr)
end

function ClsBaseView:playDownOpenEffect()
	local target = self.m_view_effect_spr
	target:stopAllActions()
	
	target:setPosition(display.cx, display.cy*4)

	local array_down = CCArray:create()
	array_down:addObject(CCCallFunc:create(function (  )
		self:onCreateFinish()
		end))	
	array_down:addObject(CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(display.cx, display.cy))))

	target:runAction(CCSequence:create(array_down))
	audioExt.playEffect(music_info.PAPER_STRETCH.res)
end

function ClsBaseView:onCreateFinish()
		
end

function ClsBaseView:playDownCloseEffect()
	self.m_manager:setLockTouchReason(self.m_auto_close_lock_reason_str)
	local target = self.m_view_effect_spr
	target:stopAllActions()
	
	local move_arr = CCArray:create()
	move_arr:addObject(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(display.cx, display.cy*4))))
	move_arr:addObject(CCCallFunc:create(function()
			self:close()
		end))
	target:runAction(CCSequence:create(move_arr))
	audioExt.playEffect(music_info.PAPER_STRETCH.res)
end

return ClsBaseView


--[[
local ClsBaseView = require("ui/view/clsBaseView")
local testView = class("testView", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function testView:getViewConfig(...)
    return {
        name = "testView",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end
--页面创建时调用
function testView:onEnter()
    self.m_plist_tab = {}
    LoadPlist(self.m_plist_tab)
    
    local btn = self:createButton({image = "#common_btn_blue1.png", text = "66666", x = 200, y = 200})
    btn:regCallBack(function()
            getUIManager():close("testView") --页面关闭
        end)
    self:addChild(btn)
    
    --cocosStudio的json内容
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/test_btn.json")
    --self.m_bg_spr = getConvertChildByName(panel,"xxx") -- 关闭按钮
    self:addWidget(panel)
end

function testView:updateView()
    return true
end
function testView:printInfo(...)
    print("printInfo---------", ...)
    return true
end

function testView:preClose(...)
    print("删除ui节点相关--------------")
end
function testView:onExit(...)
    print("---------onExit")
    UnLoadPlist(self.m_plist_tab)
end
return testView

--ui使用代码：
-- getUIManager():create("ui/view/testView")--创建
-- getUIManager():isLive("testView")--判断页面是否存在
-- local view_obj = getUIManager():get("testView") --获取对应的对象
-- getUIManager():isLive("testView") --判断是否存活 --]]