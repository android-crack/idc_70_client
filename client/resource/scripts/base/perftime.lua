
module("perftime", package.seeall)

local is_publish = true

local perf_begin_time = {}

local perf_time = {}
local perf_count = {}
local perf_item_nest_level = {}	-- 嵌套层次

gperf_begin = function(msg)
	if is_publish then return end

	perf_item_nest_level[msg] = perf_item_nest_level[msg] or 0
	perf_item_nest_level[msg] = perf_item_nest_level[msg] + 1

	if perf_item_nest_level[msg] == 1 then
		perf_begin_time[msg] = CCTime:getmillistimeofCocos2d()
	end
end

gperf_end = function(msg)
	if is_publish then return end

	if perf_begin_time[msg] then
		perf_count[msg] = perf_count[msg] or 0
		perf_count[msg] = perf_count[msg] + 1
		
		perf_item_nest_level[msg] = perf_item_nest_level[msg] - 1

		if perf_item_nest_level[msg] == 0 then
			perf_time[msg] = perf_time[msg] or 0 
			perf_time[msg] = perf_time[msg] + CCTime:getmillistimeofCocos2d() - perf_begin_time[msg]
			perf_begin_time[msg] = nil			
		end
	end
end

get_gperf_msg = function(count)
	if is_publish then return "publish version!" end

--	if table.count(perf_time) == 0 then return end
	
	count = count or 5
	
	local key_times = {}
	for k, v in pairs(perf_time) do
		table.insert(key_times, k)
	end
	
	if #key_times == 0 then
		return "no perftime items"
	end
	
	table.fsort(key_times, function(v1, v2)
		return perf_time[v1] <= perf_time[v2]
	end)
	
	local str_msg = ""
	for i, perf_key in ipairs(key_times) do
		if i <= count then
			str_msg = str_msg .. "[SCRIPT_PERF]" .. string.format("rank:%d,%s,t:%.2fms,cnt:%d\n", i, perf_key, perf_time[perf_key], perf_count[perf_key])
		end
	end

	perf_time = {}
	perf_count = {}

	return str_msg
end

local past_time = 0
local dump_interval = 1

update = function(delta_time)
	if is_publish then return end
	
	past_time = past_time + delta_time
	
	if past_time > dump_interval then
		print(get_gperf_msg(10))
		
		past_time = past_time - dump_interval
	end
end