--2016/09/02
--create by wmh0497
--页面基类

local ClsLinkList = require("base/clsLinkList")

local ClsTouchDispatcher = class("ClsTouchDispatcher", function() return display.newSprite() end)

--不能重载
function ClsTouchDispatcher:ctor()
	self.m_touch_obj_list  = ClsLinkList.new()
	self.m_touch_select_info = nil
end

function ClsTouchDispatcher:insertTouchEvent(node, touch_func, order_n)
	order_n = order_n or 0
	local item = {obj = node, touch_func = touch_func, order = order_n}
	for i, touch_obj in self.m_touch_obj_list:walk() do
		if touch_obj.order <= order_n then
			self.m_touch_obj_list:insert(i, item)
			return
		end
	end
	self.m_touch_obj_list:pushBack(item)
end

function ClsTouchDispatcher:onTouch(event, x, y)
	if event == "began" then
		self.m_touch_select_info = nil
		local remove_touch_obj = {}
		local remove_touch_count = 0
		for i, touch_obj in self.m_touch_obj_list:walk() do
			if touch_obj.obj and ("function" == type(touch_obj.touch_func)) then
				if tolua.isnull(touch_obj.obj) then
					remove_touch_count = remove_touch_count + 1
					remove_touch_obj[remove_touch_count] = touch_obj
				elseif touch_obj.obj:isVisible() then
					local result_b = touch_obj.touch_func(event, x, y)
					if result_b then
						--自动删除多余节点
						self:removeUselessTouchObj(self.m_touch_obj_list, remove_touch_obj, remove_touch_count)
						self.m_touch_select_info = touch_obj
						return result_b
					end
				end
			end
		end
		--自动删除多余节点
		self:removeUselessTouchObj(self.m_touch_obj_list, remove_touch_obj, remove_touch_count)
		return false
	else
		local select_info = self.m_touch_select_info
		if select_info and (not tolua.isnull(select_info.obj)) and ("function" == type(select_info.touch_func)) then
			local touch_func = select_info.touch_func
			if event ~= "moved" then
				self.m_touch_select_info = nil
			end
			touch_func(event, x, y)
		else
			self.m_touch_select_info = nil
		end
	end
end

--删除多余节点
function ClsTouchDispatcher:removeUselessTouchObj(list, remove_objs, count)
	if count > 0 then
		for i = 1, count do
			list:removeByValue(remove_objs[i])
		end
	end
end

return ClsTouchDispatcher