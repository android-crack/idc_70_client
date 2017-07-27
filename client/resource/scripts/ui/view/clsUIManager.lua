--2016/09/02
--create by wmh0497
--页面管理类

local ClsBaseView = require("ui/view/clsBaseView")
local ClsLinkList = require("base/clsLinkList")
local ClsUILogicHander = require("ui/view/clsUILogicHander")

UI_TYPE = {
    VIEW = 1,
    TIP = 2,
    DIALOG = 3,
    NOTICE = 4,
    TOP = 5,
}

UI_EFFECT = {
    DOWN = 1, --掉下来的效果
    FADE = 2, --渐变显示效果
    SCALE = 3, --页面从小到大的缩放效果
}

local MAX_PRIORITY = -10000
local UI_TOUCH_PRIORITY = {
    [UI_TYPE.VIEW] = -1,
    [UI_TYPE.TIP] = -4001,
    [UI_TYPE.DIALOG] = -6001,
    [UI_TYPE.NOTICE] = -8001,
    [UI_TYPE.TOP] = -10001,
}

local ClsUIManager = class("ClsUIManager", function() return display.newLayer() end)

function ClsUIManager:ctor()
	self.m_logic_hander = ClsUILogicHander.new()
	self.m_ui_datas = {}
	self.m_views_by_name = {}
	self.m_lock_touch_info = {
		reasons = {},
		count = 0,
		is_lock = false,
	}
	for _, order in pairs(UI_TYPE) do
		local ui_data = {}
		ui_data.view_list = ClsLinkList.new()
		ui_data.root_layer = display.newLayer()
		self:addChild(ui_data.root_layer, order)
		self.m_ui_datas[order] = ui_data
	end
	self.m_effect_layer = display.newLayer()
	self:addChild(self.m_effect_layer, 1000)
	
	self:registerScriptHandler(function(event)
		if event == "enterTransitionFinish" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)
end

function ClsUIManager:removeAllView()
	local view_name_tabs = {}
	for i = #self.m_ui_datas, 1, -1 do
		local ui_data = self.m_ui_datas[i]
		for j, view_obj in ui_data.view_list:rewalk() do
			table.insert(view_name_tabs, view_obj:getViewName())
		end
	end
	
	if #view_name_tabs > 0 then
		for _, name_str in ipairs(view_name_tabs) do
			self:close(name_str, {is_ignore_touch_update = true})
		end
		self:checkTouchState()
	end
end

--清除tips层的内容
function ClsUIManager:removeAllTipsView()
	local ui_data = self.m_ui_datas[UI_TYPE.TIP]
	local view_name_tabs = {}
	for i, view_obj in ui_data.view_list:walk() do
		table.insert(view_name_tabs, view_obj:getViewName())
	end
	
	if #view_name_tabs > 0 then
		for _, name_str in ipairs(view_name_tabs) do
			self:close(name_str, {is_ignore_touch_update = true})
		end
		self:checkTouchState()
	end
end

function ClsUIManager:removeViewOnFront(name_str)
	if not self:isLive(name_str) then
		return
	end
	local view_obj = self.m_views_by_name[name_str]
	if view_obj:getViewType() ~= UI_TYPE.VIEW then return end --暂时只允许移除VIEW层的东东
	
	local ui_data = self.m_ui_datas[view_obj:getViewType()]
	local is_found = false
	local view_name_tabs = {}
	for _, view_obj in ui_data.view_list:walk() do
		if not is_found then
			if view_obj:getViewName() == name_str then
				is_found = true
			end
		else
			table.insert(view_name_tabs, view_obj:getViewName())
		end
	end
	
	if #view_name_tabs > 0 then
		for _, view_name_str in ipairs(view_name_tabs) do
			self:close(view_name_str, {is_ignore_touch_update = true})
		end
		self:checkTouchState()
	end
end

function ClsUIManager:makeViewCfg(view_clazz, ...)
	local name_str = view_clazz.__cname
	params = view_clazz:getViewConfig(...) or {}
	params.type = params.type or UI_TYPE.VIEW
	params.name = params.name or name_str
	if nil == params.is_swallow then
		params.is_swallow = true
	end
	if nil == params.is_hander_swallow then
		params.is_hander_swallow = true
	end
	return params
end

--[[
path_str: view的文件路径
params: 保留字段，扩展用
	before_view = "test1" :在某个界面上插入页面。注意：两个页面的UI_TYPE应该相同，如果不是，默认在新页面的顶层上加
...: 传入view的参数
--]]
function ClsUIManager:create(path_str, params, ...)
	params = params or {}
	local view_clazz = require(path_str)
	local view_cfg_item = self:makeViewCfg(view_clazz, ...)
	if params.layer_pos then
		view_cfg_item.type = params.layer_pos
	end

	local name_str = view_cfg_item.name
	if not name_str then
		print("error!!!!!!!!!!!!!, miss view key ", path_str)
		return
	end
	local type_n = view_cfg_item.type
	local ui_data = self.m_ui_datas[type_n]
	if not ui_data then
		print("error!!!!!!!!!!!!!, miss view type: id = ", type_n)
		return
	end
	if self.m_views_by_name[name_str] then
		print("error!!!!!!!!!!!!!, view has show ", name_str)
		return
	end
	
	if false == self.m_logic_hander:isCreate(view_cfg_item) then
		return
	end
	
	local view_obj = view_clazz.new(self, name_str, view_cfg_item)
	local order_n = ui_data.view_list:getCount() + 1

	self.m_views_by_name[name_str] = view_obj

	--插入到特定页面之前
	local is_add = false
	if params.before_view and self:isLive(params.before_view) then
		local before_view_obj = self:get(params.before_view)
		for i, find_view_obj in ui_data.view_list:walk() do
			if before_view_obj == find_view_obj then
				order_n = i + 1
				ui_data.view_list:insert(i + 1, view_obj)
				is_add = true
				break
			end
		end
	end
	if not is_add then
		ui_data.view_list:pushBack(view_obj)
	end

	view_obj:initViewBase()
	self.m_logic_hander:doViewOnCreate(name_str)
	
	view_obj:setViewEnterParams(...)
	view_obj:onCtor(...)

	if not self:isLive(name_str) then  --可能在onAwake方法关闭页面
		return
	end
	view_obj:addToManager(ui_data.root_layer, order_n)

	if not self:isLive(name_str) then  --可能在onEnter方法关闭页面
		return
	end

	self:checkTouchState()

	view_obj:onStart(...)

	return view_obj
end

function ClsUIManager:close(name_str, params, ...)
	params = params or {}
	if not self:isLive(name_str) then
		return
	end
	local view_obj = self.m_views_by_name[name_str]

	local ui_data = self.m_ui_datas[view_obj:getViewType()]
	if not ui_data then
		print("error!!!!!!!!!!!!!, miss view type: id = ", view_obj:getViewType())
		return
	end
	
	self.m_logic_hander:doViewOnClose(name_str)
	view_obj:setViewExitParams(...)
	view_obj:preClose(...)
	if self:isLive(name_str) then
		self.m_views_by_name[name_str] = nil
		ui_data.view_list:removeByValue(view_obj)
		view_obj:getViewRoot():removeFromParentAndCleanup(true)
	else 
		self.m_views_by_name[name_str] = nil
		ui_data.view_list:removeByValue(view_obj)
	end

	if true ~= params.is_ignore_touch_update then
		self:checkTouchState()
	end
	view_obj:onFinish(...)
end

function ClsUIManager:isLive(name_str)
	if self.m_views_by_name[name_str] then
		return true
	end
	return false
end

function ClsUIManager:get(name_str)
	return self.m_views_by_name[name_str]
end

function ClsUIManager:checkTouchState()
	local can_touch_b = not self.m_lock_touch_info.is_lock

	local can_hide_b = true

	for i = #self.m_ui_datas, 1, -1 do
		local ui_data = self.m_ui_datas[i]
		for j, view_obj in ui_data.view_list:rewalk() do
			view_obj:setViewOrder(j)
			local priority_n = UI_TOUCH_PRIORITY[i]
			view_obj:setViewTouchPriority(priority_n - 4*(j-1))
			view_obj:setManagerTouchEnabled(can_touch_b)
			if can_touch_b and view_obj:isSwallowTouch() then
				can_touch_b = false
			end

			if can_hide_b then
				view_obj:getViewRoot():setVisible(true)
				if view_obj:isHideBeforeView() then
					can_hide_b = false
				end
			else
				view_obj:getViewRoot():setVisible(false)
			end
		end
	end
end

function ClsUIManager:setLockTouchReason(reason_str, is_ignore_update_touch)
	if not self.m_lock_touch_info.reasons[reason_str] then
		self.m_lock_touch_info.reasons[reason_str] = true
		self.m_lock_touch_info.count = self.m_lock_touch_info.count + 1
	end
	if self.m_lock_touch_info.count > 0 then
		if not self.m_lock_touch_info.is_lock then
			self.m_lock_touch_info.is_lock = true
			if true ~= is_ignore_update_touch then
				self:checkTouchState()
			end
		end
	end
end

function ClsUIManager:releaseLockTouchReason(reason_str, is_ignore_update_touch)
	if self.m_lock_touch_info.reasons[reason_str] then
		self.m_lock_touch_info.reasons[reason_str] = nil
		self.m_lock_touch_info.count = self.m_lock_touch_info.count - 1
	end
	if self.m_lock_touch_info.count <= 0 then
		if self.m_lock_touch_info.is_lock then
			self.m_lock_touch_info.is_lock = false
			if true ~= is_ignore_update_touch then
				self:checkTouchState()
			end
		end
	end
end

function ClsUIManager:addToEffectLayer(new_effect_spr)
	self.m_effect_layer:addChild(new_effect_spr)
end

function ClsUIManager:onEnter()
	self.m_logic_hander:doOnEnter()
end

function ClsUIManager:onExit()
	self.m_logic_hander:doOnExit()
end

return ClsUIManager