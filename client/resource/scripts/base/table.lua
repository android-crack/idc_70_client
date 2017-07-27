
table.print = function( tb ) 
	if type(tb) ~= "table" then		
		return
	end
	
	local tb_deep =  20
	local cur_deep = 0
	local tb_cache = {}
	local function print_table(tb_data)
		-- 存储当前层table
		if type(tb_data) ~= "table"  then
			log("Error", "存储类型必须为table:", tb )
			return
		end
		if tb_cache[tb] then
			log("Error", "无法继续存储，table中包含循环引用，", tb )
			return
		end
		local k, v
		cur_deep = cur_deep + 1
		if cur_deep > tb_deep then
			cur_deep = cur_deep -  1
			return	"..."
		end
		local tab = string.rep(" ", (cur_deep-1)*4)
		local str = "{\n"
		
		-- 调整table存储顺序，按照key排序
		local keys_num = {}
		local keys_str = {}
		for k, v in pairs(tb_data) do
			if type(k) == "number" then
				table.insert(keys_num, k)
			elseif type(k) == "string" then
				table.insert(keys_str, k)
			end
		end
		table.sort(keys_str)
		table.sort(keys_num)
		
		local keys = {}
		for i, k in ipairs(keys_num) do
			table.insert(keys, k)
		end
		for i, k in ipairs(keys_str) do
			table.insert(keys, k)
		end
		for k, v in pairs(tb_data) do
			if type(k) ~= "number" and type(k) ~= "string" then
				table.insert(keys, k)
			end
		end
		
		-- 保存调整后的table
		local i
		for i, k in ipairs(keys) do
			v = tb_data[k]
			local arg, value
			if type(k) == "number" then
				arg = string.format("[%d]", k)   --认为key一定是整数
			elseif type(k) == "string" then
				arg = string.format("[\"%s\"]", string.gsub(k,"\\","\\\\"))
			else
				arg = string.format("[\"%s\"]", string.gsub(tostring(k),"\\","\\\\"))
			end

			if type(v) == "number" then
				value = string.format("%f", v)
			elseif type(v) == "string" then
				value = string.format("\"%s\"", string.gsub(v,"\\","\\\\"))		
			elseif type(v) == "table" then
				value = print_table(v)
			else 
				value = tostring(v)
			end
			
			
			if arg and value then
				str = str..string.format("%s%s = %s,\n", tab, arg, value)
			end
		end
		tb_cache[tb_data] = true
		cur_deep = cur_deep -  1
		return str..tab.."}"
	end
	
	local tb_str = print_table(tb)
	print( tb_str )
		
	return true
end


 table.save_fd = function(file, tb, tb_deep, func_save_item)
	 if type(tb) ~= "table" or not file then		
		 return
	 end

	 tb_deep =  tb_deep or 20
	 local cur_deep = 0
	 local tb_cache = {}
	 local function save_table(tb_data)
		 -- 存储当前层table
		 if type(tb_data) ~= "table"  then
			 log("Error", "存储类型必须为table:", tb, path, tb_deep)
			 return
		 end
		 if tb_cache[tb] then
			 log("Error", "无法继续存储，table中包含循环引用，", tb, path, tb_deep)
			 return
		 end
		 local k, v
		 cur_deep = cur_deep + 1
		 if cur_deep > tb_deep then
			 log("Error", "待存储table超过可允许的table深度", tb, path, tb_deep)
			 cur_deep = cur_deep -  1
			 return
		 end
		 local tab = string.rep(" ", (cur_deep-1)*4)
		 local str = "{\n"

		 -- 调整table存储顺序，按照key排序
		 local keys_num = {}
		 local keys_str = {}
		 for k, v in pairs(tb_data) do
			 if type(k) == "number" then
				 table.insert(keys_num, k)
			 elseif type(k) == "string" then
				 table.insert(keys_str, k)
			 end
		 end
		 table.sort(keys_str)
		 table.sort(keys_num)

		 local keys = {}
		 for i, k in ipairs(keys_num) do
			 table.insert(keys, k)
		 end
		 for i, k in ipairs(keys_str) do
			 table.insert(keys, k)
		 end
		 for k, v in pairs(tb_data) do
			 if type(k) ~= "number" and type(k) ~= "string" then
				 table.insert(keys, k)
			 end
		 end

		 -- 保存调整后的table
		 local i
		 for i, k in ipairs(keys) do
			 v = tb_data[k]
			 local arg, value
			 if type(k) == "number" then
				 arg = string.format("[%d]", k)   --认为key一定是整数
			 end
			 if type(k) == "string" then
				 arg = string.format("[\"%s\"]", string.gsub(k,"\\","\\\\"))
			 end
			 if type(k) == "boolean" then
				 value = tostring(k)
			 end
			 if type(v) == "number" then
				 value = string.format("%f", v)
			 end
			 if type(v) == "string" then
				 value = string.format("\"%s\"", string.gsub(v,"\\","\\\\"))
			 end			
			 if type(v) == "table" then
				 value = save_table(v)
			 end
			 if type(v) == "boolean" then
				 value = tostring(v)
			 end
			 if arg and value then
			 	 item_str = func_save_item and func_save_item(tab, arg, value) or string.format("%s%s = %s,\n", tab, arg, value)
				 str = str..item_str
			 end
		 end
		 tb_cache[tb_data] = true
		 cur_deep = cur_deep -  1
		 return str..tab.."}"
	 end

	 local tb_str = "return \n"..save_table(tb)
	 file:write(tb_str)

	 return true
 end

 table.save = function(tb, path, tb_deep, is_compile, is_compress, func_save_item)
	 local mode = is_compile and "wb" or "w"
	 mode = is_compress and "wb" or "w"
	 if type(path)=="table" then
		 path=path[1].."/"..path[2]
	 end

	 local file = io.open(path, mode)
	 if not file then
		 error("table.save打开文件错误:"..path)
	 end

	 -- table.save_fd参数依次为：file, tb, tb_deep, func_save_item
	 local rtn = table.save_fd(file, tb, tb_deep, func_save_item)
	 file:close()
	 return rtn
 end
 
 table.load = function(path)
	local file = io.open(path, "rb")
	local str = file:read("*a")
	file:close()
	local f = loadstring(str)
	if f then
		return f()
	end
end

table.save_as_json = function(tb,path,is_compress)
	local mode = is_compress and "wb" or "w"
	local file = io.open(path, mode)
	if not file then
		error("table.save打开文件错误:"..path)
	end
	local str = json.encode(tb)
	file:write(str)
	file:close()
	return str
end

table.load_from_json = function(path)
	local file = io.open(path, "rb")
	local str = file:read("*a")
	file:close()
	return json.decode(str) or {}
end

table.is_empty = function(tbl)
 	for _, _ in pairs(tbl) do
 		return false
 	end
 	
 	return true
 end
 
 table.merge = function(dest, src)
	 if type(dest) ~= "table" or type(src) ~= "table" then
		 return
	 end
	 for k, v in pairs(src) do
		 dest[k] = v
	 end
	 return dest
 end
 
 table.clone = function(src)
	 if type(src) ~= "table" then
		 return src
	 end

	 local table_already_clone = {}	-- 已经复制好的table，防止嵌套复制引起的死循环

	 local copy_table
	 local level = 0
	 local function clone_table(t)
		 level = level + 1
		 if level > 20 then
			--TODO
			if DEBUG > 0 then 
				error("table clone failed, source table is too deep!")
			else
				print("Warning:source table is too deep!!! More than 20!")
			end
		 end
		 local k, v
		 local rel = {}

		 table_already_clone[tostring(t)] = rel

		 for k, v in pairs(t) do
			 if type(v) == "table" then
				 rel[k] = table_already_clone[tostring(v)] or clone_table(v)
--				 rel[k] = clone_table(v)
			 else
				 rel[k] = v
			 end
		 end
		 level = level - 1
		 return rel
	 end
	 return clone_table(src)
 end

--此排序可以解决table对于相等元素的列表排序的问题
--外部必须重载sotf方法
--应用在比如战绩报告界面等
--算法:冒泡排序
table.fsort = function(list,sortf)
	 if sortf==nil then
		 table.sort(list)
	 end
	 local length = #list
	 for i=1,length do
		 for j=i+1,length do
			 if sortf(list[i],list[j]) then
				 local tmpObj = list[j]
				 list[j] = list[i]
				 list[i] =tmpObj
			 end
		 end
	 end
end

--把srct列表按顺序追加到desct列表的未尾
 --要求srct和desct两个表都是顺序表
table.fcat = function(srct,desct)
	for k, v in ipairs( srct ) do
		table.insert( desct, v )
	end
end

table.remove_element = function(t,e)
	for k,v in pairs(t) do
		if v==e then
			t[k] = nil
		end
	end
end

table.value_key = function(t,v)
	for k,value in pairs(t) do
		if v==value then
			return k
		end
	end
end

table.count = function(t)
	local c = 0
	for k,v in pairs(t) do
		c = c+1
	end
	return c
end

table.count_not_nil = function(t)
	local c = 0
	for k,v in pairs(t) do
		if v~=nil then c = c+1 end
	end
	return c
end

function table.new_weak_table(mod)
	mod = mod or "kv"

	local t = {}
	setmetatable(t, {__mode = mod})
	return t
end

table.keys = function(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

table.random_key = function(t)
	local keys = table.keys(t)
	return keys[math.random(#keys)]
end