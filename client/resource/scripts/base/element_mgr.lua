local element_mgr = {}
local ui_word = require("game_config/ui_word")
local event_config = require("game_config/event/event_config")

--变量保存
element_mgr.element_list = {}
--事件保存
element_mgr.event_list = {}

element_mgr.add_element = function( self,  name, element )
	self.element_list[name] = element
end

element_mgr.del_element = function( self, name )
	self.element_list[name] = nil
end

element_mgr.get_element = function( self, name )
	return self.element_list[name]
end

-- 刷新界面接口
function element_mgr:refresh(param)
	if type(param) == "string" then
		local view = element_mgr:get_element(param)
		if not tolua.isnull(view) then
			view:updateView()
		end
	elseif type(param) == "table" then
		for __ , view_name in pairs(param) do
			local view = element_mgr:get_element(view_name)
			if not tolua.isnull(view) then
				view:updateView()
			end
		end
	end		
end

-- 关闭界面接口
function element_mgr:close(param)
	if type(param) == "string" then
		local view = element_mgr:get_element(param)
		if not tolua.isnull(view) then
			view:destroy()
		end
	elseif type(param) == "table" then
		for __ , view_name in pairs(param) do
			local view = element_mgr:get_element(view_name)
			if not tolua.isnull(view) then
				view:destroy()
			end
		end
	end
end

--以后可以尝试着用这个改进这个使用
--为name表示的对象注册事件event_id，等事件触发时执行func
element_mgr.registerEvent = function(self, name, event_id, func)
	if not self.event_list[event_id] then
		self.event_list[event_id] = {}
	end
	self.event_list[event_id][name] = func
end

element_mgr.dispatchEvent = function(self, event_id, parameter)
	if not self.event_list[event_id] then return end
	for name, func in pairs(self.event_list[event_id]) do
		local obj = self.element_list[name]
		if not tolua.isnull(obj) then
			print(ui_word.EVENT_TRIGGLE_OBJECT_TIP_START)
			print(string.format(ui_word.EVENT_TRIGGLE_OBJECT_TIP_ID, event_config[event_id].id_str))
			print(string.format(ui_word.EVENT_TRIGGLE_OBJECT_TIP_DEC, event_config[event_id].dec))
			print(ui_word.EVENT_TRIGGLE_OBJECT_TIP_END)
			func(obj, parameter)
		end
	end
end

element_mgr.del_event = function(self, event_id)
	self.event_list[event_id] = nil
end

return element_mgr