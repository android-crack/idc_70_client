
local function process(parent_desc, x, recrusion_count)
		if x == _G.dump_by_type then return end
		if x == _G.dum_all then return end

		--跳过已处理的对象
		if _G.dum_all[x] then
			return
		end

		

		local t = type(x)
		local obj_element =  {
			parent = parent_desc,
			type = t,
			value = x,
		}
		--记录每一个_G上的对象
		_G.dum_all[x] = obj_element

		--遂类型统计
		if _G.dump_by_type[t] then
			_G.dump_by_type[t][x] = obj_element
		else
			--未知类型统计
			_G.dump_by_type.error_type[t] = true
		end



		----递归...
		--层数
		recrusion_count = recrusion_count -1
		if recrusion_count <= 0 then return end

		--lua对象不递归
		if (t == "userdata" and getmetatable(x)) or t == "table" then
			if  x.class and type(x.class) == "table" and x.class.__cname then
				_G.dump_by_type["lua_class_obj"][x] = {
					parent = parent_desc,
					type = string.format("lua_class_obj:%s",x.class.__cname),
					value = x,	
				}
				--return
			end
		end

		--递归function 与table.其它的:coroutine, number,string等直接记录即可
		if t == "function" then
			dumpFunction(x, recrusion_count)
		elseif t == "table" then
			dumpTable( x, recrusion_count)
		end
end




function dumpTable(t, recrusion_count )
	local parent_table = nil
	local parent_desc = nil

	for k, v in pairs(t) do
		parent_table = string.format( "parent_table:%s",  tostring(t) )

		parent_desc = string.format( "a key_value of %s,", parent_table )
		process( parent_desc, k, recrusion_count )
			

		parent_desc = string.format( "a value of %s, handle by key:%s, key_type:%s", parent_table, tostring(k), type(k) )
		process( parent_desc, v, recrusion_count )
	end


	
	local m = getmetatable(t)
	if m then
		local parent_desc = string.format("table %s metatable", tostring(t))
		_G.dump_by_type["metatable"][m] = {
			parent = parent_desc,
			type = "metatable",
			value = m,
		}
		dumpTable(m, recrusion_count )
	end
	
end



function dumpFunction( f, recrusion_count)
	local env = getfenv(f)
	if env then
		local desc = string.format("function:%s env", tostring(f))
		_G.dump_by_type["func_evn"][env] = {
			parent = desc,
			type = "func_evn",
			value = env,
		}
		dumpTable( env, recrusion_count )
	end

	local i = 1
	while i <= 255 do
		local n, v = debug.getupvalue(f, i)
		if v then
			local desc = string.format("function:%s upvalue", tostring(f))
			_G.dump_by_type["func_upvalue"][v] = {
				parent = desc,
				type = "func_upvalue",
				value = v,
			}
			process(desc, v, recrusion_count)
		else
			return
		end
		i = i + 1
	end
end

--返回dump _G的全部内容
function dumpG(recrusion_count)
	
	local dump_by_type = {
		["userdata"] = {},
		["func_upvalue"] = {},
		["func_evn"] = {},
		["number"] = {},
		["string"] = {},
		["table"] = {},
		["boolean"] = {},
		["function"] = {},
		["metatable"] = {},
		["lua_class_obj"] = {},

		--未知类型
		["error_type"] = {},
	}

	local dum_all = {}

	_G.dump_by_type = dump_by_type
	_G.dum_all = dum_all


	collectgarbage("collect")
	
	recrusion_count = recrusion_count or 10
	dumpTable(_G, recrusion_count)
	return dum_all, dump_by_type
end


function printG( recrusion_count )
	local g_snap_shot, g_by_type = dumpG( recrusion_count )
	local obj_desc = nil

	--local count = 0
	--for k, v in pairs(g_snap_shot) do
	--	obj_desc = string.format( "obj:%s,			obj_type:%s,			obj_parent:%s", tostring(v.value), v.type, v.parent )
	--	print(obj_desc)
	--	count = count + 1
	--end
	--print("snap obj all count", count)

	local count_sum = 0
	local count_by_type = {}
	for type, t_by_type in pairs( g_by_type ) do
		local per_count_by_type = 0
		for k, v in pairs( t_by_type ) do
			obj_desc = string.format( "obj:%s,			obj_type:%s,			obj_parent:%s", tostring(v.value), v.type, v.parent )
			print(obj_desc)
			per_count_by_type = per_count_by_type + 1
		end
		count_by_type[tostring(type)] = per_count_by_type
		count_sum = count_sum + per_count_by_type
	end

	for type, count in pairs( count_by_type ) do
		print(string.format("type %s count:%s ", type, count))
	end
	print("obj by type all count:", count_sum)
end