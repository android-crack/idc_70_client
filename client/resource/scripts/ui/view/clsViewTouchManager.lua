--2016/09/02
--create by wmh0497
--页面基类

local ClsLinkList = require("base/clsLinkList")

local ClsViewTouchManager = class("ClsViewTouchManager", function() return display.newSprite() end)

--不能重载
function ClsViewTouchManager:ctor(is_hander_swallow)

	self.m_is_hander_swallow = is_hander_swallow

	self.m_pass_guild_touch_layer = display.newLayer()
	self:addChild(self.m_pass_guild_touch_layer)

	self.m_guild_touch_layer = display.newLayer()
	self:addChild(self.m_guild_touch_layer)

	self.m_user_touch_layer = display.newLayer()
	self:addChild(self.m_user_touch_layer)

	self.m_user_touch_obj_list  = ClsLinkList.new()
	self.m_guild_touch_obj_list = ClsLinkList.new()
	self.m_guild_pass_touch_obj_list = ClsLinkList.new()

	self.m_move_camera = nil
	self.m_view = nil

	self.m_touch_select_info = {}
end

function ClsViewTouchManager:clean()
	self.m_user_touch_obj_list = ClsLinkList.new()
	self.m_guild_touch_obj_list = ClsLinkList.new()
	self.m_guild_pass_touch_obj_list = ClsLinkList.new()
end

function ClsViewTouchManager:setView(view)
	self.m_view = view
end

function ClsViewTouchManager:setMoveCamera(camera)
	self.m_move_camera = camera
end

function ClsViewTouchManager:setUserTouchPriority(priority_n)
	if not tolua.isnull(self.m_user_touch_layer) then
		self.m_user_touch_layer:registerScriptTouchHandler(function(event, x, y)
			return self:onTouch("user", self.m_user_touch_obj_list, event, x, y)
		end, false, priority_n, self.m_is_hander_swallow)
		self.m_user_touch_layer:setTouchPriority(priority_n)
	end
end

function ClsViewTouchManager:setGuildTouchPriority(priority_n)
	if not tolua.isnull(self.m_guild_touch_layer) then
		self.m_guild_touch_layer:registerScriptTouchHandler(function(event, x, y)
			return self:onTouch("guild", self.m_guild_touch_obj_list, event, x, y)
		end, false, priority_n, true)
		self.m_guild_touch_layer:setTouchPriority(priority_n)
	end
end

function ClsViewTouchManager:setGuildPassTouchPriority(priority_n)
	if not tolua.isnull(self.m_pass_guild_touch_layer) then
		self.m_pass_guild_touch_layer:registerScriptTouchHandler(function(event, x, y)
			return self:onTouch("pass_guild", self.m_guild_pass_touch_obj_list, event, x, y)
		end, false, priority_n, false)
		self.m_pass_guild_touch_layer:setTouchPriority(priority_n)
	end
end

function ClsViewTouchManager:setTouchEnabled(is_touch)
	self.m_user_touch_layer:setTouchEnabled(is_touch)
	self.m_guild_touch_layer:setTouchEnabled(is_touch)
	self.m_pass_guild_touch_layer:setTouchEnabled(is_touch)
	if not is_touch then
		self:clearTouchObj()
	end
end

function ClsViewTouchManager:insertUserTouchEvent(node, touch_func, order_n)
	self:insertTouchEvent(self.m_user_touch_obj_list, node, touch_func, order_n)
end

function ClsViewTouchManager:insertGuildTouchEvent(node, touch_func, order_n)
	self:insertTouchEvent(self.m_guild_touch_obj_list, node, touch_func, order_n)
end

function ClsViewTouchManager:insertGuildPassTouchEvent(node, touch_func, order_n)
	self:insertTouchEvent(self.m_guild_pass_touch_obj_list, node, touch_func, order_n)
end

function ClsViewTouchManager:insertTouchEvent(touch_obj_list, node, touch_func, order_n)
	local item = {obj = node, touch_func = touch_func, order = order_n}
	for i, touch_obj in touch_obj_list:walk() do
		if touch_obj.order <= order_n then
			touch_obj_list:insert(i, item)
			return
		end
	end
	touch_obj_list:pushBack(item)
end

function ClsViewTouchManager:onTouch(type_str, touch_obj_list, event, x, y)
	--防止两个不同的触摸层同时点中
	if self:checkIsTouchTwo(type_str) then
		return false
	end
	if self.m_move_camera ~= nil then
		local cx, cy, cz = self.m_move_camera:getEyeXYZ(0,0,0)
		x = x + cx
		y = y + cy
	end

	if event == "began" then
		self.m_touch_select_info[type_str] = nil
		local remove_touch_obj = {}
		local remove_touch_count = 0
		for i, touch_obj in touch_obj_list:walk() do
			if touch_obj.obj and ("function" == type(touch_obj.touch_func)) then
				if tolua.isnull(touch_obj.obj) then
					remove_touch_count = remove_touch_count + 1
					remove_touch_obj[remove_touch_count] = touch_obj
				elseif touch_obj.obj:isVisible() then
					local result_b = touch_obj.touch_func(event, x, y)
					if result_b then
						--自动删除多余节点
						self:removeUselessTouchObj(touch_obj_list, remove_touch_obj, remove_touch_count)
						self.m_touch_select_info[type_str] = {["type"] = type_str, ["touch_obj"] = touch_obj}
						return result_b
					end
				end
			end
		end
		--自动删除多余节点
		self:removeUselessTouchObj(touch_obj_list, remove_touch_obj, remove_touch_count)
		return false
	else
		local select_info = self.m_touch_select_info[type_str]
		if select_info and (not tolua.isnull(select_info.touch_obj.obj)) 
			and ("function" == type(select_info.touch_obj.touch_func)) then
			
			local touch_func = select_info.touch_obj.touch_func
			if event ~= "moved" then
				self.m_touch_select_info[type_str] = nil
			end
			touch_func(event, x, y)
		else
			self.m_touch_select_info[type_str] = nil
		end
	end
end

function ClsViewTouchManager:getOriginXY(x, y)
	if self.m_move_camera ~= nil then
		local cx, cy, cz = self.m_move_camera:getEyeXYZ(0,0,0)
		x = x - cx
		y = y - cy
	end
	return x, y
end

--防止两个不同的触摸层同时点中
local lock_types = {["guild"] = 1, ["user"] = 1}
function ClsViewTouchManager:checkIsTouchTwo(check_type_str)
	if lock_types[check_type_str] then
		for type_str, _ in pairs(lock_types) do
			if type_str ~= check_type_str then
				local select_info = self.m_touch_select_info[type_str]
				if select_info and select_info.type then
					return true
				end
			end
		end
	end
	return false
end

--删除多余节点
function ClsViewTouchManager:removeUselessTouchObj(list, remove_objs, count)
	if count > 0 then
		for i = 1, count do
			list:removeByValue(remove_objs[i])
		end
	end
end

function ClsViewTouchManager:clearTouchObj()
	for k, select_info in pairs(self.m_touch_select_info) do
		if select_info then
			if (not tolua.isnull(select_info.touch_obj.obj)) and ("function" == type(select_info.touch_obj.touch_func)) then
				local touch_func = select_info.touch_obj.touch_func
				self.m_touch_select_info[k] = nil
				touch_func("cancelled", 0, 0)
			end
		end
	end
	self.m_touch_select_info = {}
end

return ClsViewTouchManager