-- Import("logic/common/object_counter").dump_objects_counter(1)
-- Import("logic/common/object_counter").dump_reference_info_by_obj_string("")

-- 有些类重写了__tostring元方法，然后有些类还设自己为元表，用tostring的话会直接报错，这里做异常处理
local my_tostring = function(luaobj)
	if luaobj == nil then
		return "nil"
	end
	
	local success, ret = xpcall(function()
		return tostring(luaobj)
	end, function()
		local func_tostring = rawget(luaobj, "tostring")
		return func_tostring(luaobj)
	end)
		
	if ret == nil then
		return "nil"
	end

	return ret		
end

local obj_lists = {}
local obj_count_list = {}

object_counter = function(obj, type_id)
	local obj_list = obj_lists[type_id]

	if not obj_list then
		obj_list = {}
		setmetatable(obj_list, {__mode = "k"})
		
		obj_lists[type_id] = obj_list
	end
	
	obj_count_list[type_id] = obj_count_list[type_id] or 0
	obj_count_list[type_id] = obj_count_list[type_id] + 1

	obj_list[obj] = obj_count_list[type_id]
end

get_object_counter_log = function()
	local info = {}
	for type_id, obj_list in pairs(obj_lists) do
		local count = 0
		for obj, _ in pairs(obj_list) do
			count = count + 1
		end
		table.insert(info, string.format("%s:%d", type_id, count))
	end

	return info
end

dump_object_count = function(type_id, func_filter)
	local obj_list = obj_lists[type_id]
	if not obj_list then return end
	
	collectgarbage()
	collectgarbage()
	
	local obj_list_by_order = {}
	local order_list = {}
	
	for obj, order in pairs(obj_list) do
		table.insert(order_list, order)
		obj_list_by_order[order] = obj
	end
	
	table.sort(order_list)
	
	local count = 0
	
	for _, order in ipairs(order_list) do
		local obj = obj_list_by_order[order]
		
		if (not func_filter) or func_filter(obj) then
			count = count + 1
			
			local dump_config_by_type_id = dump_detail_info_config[type_id]
			if dump_config_by_type_id then
				local detail_info = ""
				for prop_name, func in pairs(dump_config_by_type_id) do
					local prop_value = obj[func] and obj[func](obj) or "nil"
					detail_info = detail_info..string.format(" %s=%s", prop_name, my_tostring(prop_value))
				end

--				log(type_id..count..":", detail_info, tostring(obj))
			end
		end
	end

--	log("------------------------>object count of", type_id, "is", count)
end

dump_detail_info_config = {
	view = {
		name = "getViewName",
	},
	CAIBase = {
		id = "GetId",
	},
	CAIAction = {
		id = "GetId",
	},
}

local flag_dump_detail = 1
-- dump_objects_counter(1)
dump_objects_counter = function(opt)
	opt = opt or 0
	collectgarbage()
	collectgarbage()
	
	local fp = io.open("objects_counter.txt", "w+")
	
	fp:write("information of objects counter:\n")

	for type_id, obj_list in pairs(obj_lists) do
		local dump_config_by_type_id = (opt == flag_dump_detail) and dump_detail_info_config[type_id]

		local count = 0

		for obj, _ in pairs(obj_list) do
			count = count + 1
			
			if type(dump_config_by_type_id) == "table" then
				local detail_info = my_tostring(obj)
				for prop_name, func in pairs(dump_config_by_type_id) do
					local prop_value = obj[func] and obj[func](obj) or "nil"
					detail_info = detail_info..string.format(" %s=%s", prop_name, my_tostring(prop_value))
				end
				
				local detail_str = type_id..count..":"..detail_info
				
				print(detail_str)
				
				fp:write(detail_str)
				fp:write("\n")
--				log(type_id..count..":", detail_info)
			end
		end
		
		local type_info_str = string.format("object type:%s\t\t\tcount:%d", type_id, count)
		
		print(type_info_str)
		
		fp:write(type_info_str)
		fp:write("\n")
--		log(string.format("object type:%s\t\t\tcount:%d", type_id, count))
	end
	
	fp:close()
end

local _traverse_lua_object = nil
local _traverse_table = nil
local _traverse_function = nil

local _traverse_stack = nil
local _traversed_list = nil

_reset_traverse_status = function()
	_traverse_stack = {}
	_traversed_list = {}
	setmetatable(_traversed_list, {__mode = "k"})
end

_add_obj_to_traverse_stack = function(obj, traverse_stack, debug_str)
	local info = {
		type = type(obj),
		name = my_tostring(obj),
		debug_str = debug_str,
	}
	
	local obj_type = type(obj)
	
	if obj_type == "function" then
		info.debug_info = debug.getinfo(obj) or ""
	end

	table.insert(traverse_stack, 1, info)
end

_remove_obj_from_traverse_stack = function(obj, traverse_stack)
	assert(traverse_stack[1].name == my_tostring(obj))
	table.remove(traverse_stack, 1)
end

_traverse_table = function(tbl, callback, traverse_stack, debug_str)
	if type(tbl) ~= "table" then return end

	local mt = debug.getmetatable(tbl)
	
	local mode = mt and rawget(mt, "__mode")
	
	local is_key_weak_tbl = mode and string.find(mode, "k")
	local is_value_weak_tbl = mode and string.find(mode, "v")

	-- traverse the table members
	for k, _ in pairs(tbl) do
		v = rawget(tbl, k)
		
		if not is_key_weak_tbl then
			_traverse_lua_object(k, callback, traverse_stack, "key with value:"..my_tostring(v))
		end

		if not is_value_weak_tbl then
			_traverse_lua_object(v, callback, traverse_stack, "value with key:"..my_tostring(k))
		end
	end
end

_traverse_function = function(func, callback, traverse_stack, debug_str)
	if type(func) ~= "function" then return end

	-- traverse the up values
	local index = 1
	while true do
		local k, v = debug.getupvalue(func, index)
		if not k then break end

		_traverse_lua_object(k, callback, traverse_stack, "upvalue & key with value:"..my_tostring(v))
		_traverse_lua_object(v, callback, traverse_stack, "upvalue & value with key:"..my_tostring(k))

		index = index + 1
	end
end

_traverse_lua_object = function(obj, callback, traverse_stack, debug_str)
	if not obj then return end

	for _, ref_obj_info in ipairs(traverse_stack) do
		-- avoid nested references
		if ref_obj_info.name == my_tostring(obj) then
			return 
		end
	end

	_add_obj_to_traverse_stack(obj, traverse_stack, debug_str)
	callback(obj, traverse_stack)
	_remove_obj_from_traverse_stack(obj, traverse_stack)

	if _traversed_list[obj] then return end
	_traversed_list[obj] = 1

	_add_obj_to_traverse_stack(obj, traverse_stack, debug_str)

	-- traverse the fenv
	local fenv = debug.getfenv(obj)
	_traverse_lua_object(fenv, callback, traverse_stack, "fenv")
	
	-- traverse the metatable
	local mt = debug.getmetatable(obj)
	_traverse_lua_object(mt, callback, traverse_stack, "metatable")
	
	local obj_type = type(obj)

	if obj_type == "table" then
		_traverse_table(obj, callback, traverse_stack, debug_str)
	elseif obj_type == "function" then
		_traverse_function(obj, callback, traverse_stack, debug_str)
	else
		
	end

	_remove_obj_from_traverse_stack(obj, traverse_stack)

	if obj == _G then
		local reg = debug.getregistry()
		if reg then
			_traverse_lua_object(reg, callback, traverse_stack, "registry")
		end
	end
end

search_reference_info_by_obj_string = function(str)
	local ref_list = {}

--	local st = get_current_time_ex()
	local traverse_count = 0
	local traverse_stack = {}
	
	_reset_traverse_status()
	_traverse_lua_object(_G, function(obj, ref_stack)
		if my_tostring(obj) == str then
			local copy_stack = table.clone(ref_stack)
			table.insert(ref_list, copy_stack)
		end

		traverse_count = traverse_count + 1
	end, traverse_stack, "_G")
	
--	local et = get_current_time_ex()
	
--	log(string.format("find end, found count:%d total time:%ds, traverse count:%d", #ref_list, math.floor((et-st)/10000), traverse_count))
	
	return ref_list
end

dump_reference_info_by_obj_string = function(str)
	local ref_list = search_reference_info_by_obj_string(str)
	
	local file_name = "ref_stack.txt"
	local fp = io.open(file_name, "w+")
	
	fp:write(string.format("find ref info of obj:%s\ncount:%d", str, #ref_list))

	for i, ref_stack in ipairs(ref_list) do
--		log(string.format("\n<--------------------------stack%03d:-------------------------------->", i))
		fp:write(string.format("\n<--------------------------stack%03d:-------------------------------->\n", i))

		for j, ref_obj_info in ipairs(ref_stack) do
--			logv("\t"..j..":", ref_obj_info.name, ref_obj_info.debug_str or "nodebugstring", ref_obj_info.debug_info)
			fp:write("\n\t"..j..":")
			fp:write(ref_obj_info.name.."\t"..(ref_obj_info.debug_str or "nodebugstring"))
			
			fp:write("\n\t".."info:")
			if type(ref_obj_info.debug_info) == "table" then
				for k, v in pairs(ref_obj_info.debug_info) do
					fp:write(string.format("\n\t\t %s = %s", my_tostring(k), my_tostring(v)))
				end
			end
		end
	end
	
	fp:close()
end