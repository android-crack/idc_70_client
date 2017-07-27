
module("gc", package.seeall)

print("！！！！！！！！gc.lua ！！！！！！！！！！！！ ")

local default_gc_step = 0.5
local gc_stepmulti = 1.2

local gc_manager_enable = false
local gc_step = default_gc_step

local past_time = 0
local gc_interval = 1

local last_lua_memory = 0

-- lua默认的gc时机和规则，会导致gc过程过慢，并且一些lua小泄漏会导致每次回收的间隔越来越大，这样会导致内存最大值也会越来越大
-- 自己去管理gc时机，先"stop"，然后在app update的时候，定时调用一次"step"
enable_gc_manager = function()
	gc_manager_enable = true
	
	collectgarbage("stop")
end

update_gc = function(delta_time)
	if gc_manager_enable then
		past_time = past_time + delta_time
	
		if past_time > gc_interval then
			local cur_lua_memory = collectgarbage("count")

			last_lua_memory = last_lua_memory or cur_lua_memory
			
			if cur_lua_memory - last_lua_memory > 0 then
				-- 每次lua内存增加，都加大步进
				gc_step = gc_step * gc_stepmulti
			else
				-- lua内存减少时，重设步进
				gc_step = default_gc_step
			end
			
			last_lua_memory = cur_lua_memory

			-- 在调用collectgarbage("collect")后，stop状态会失效，所以每次都要设一次stop
			-- 现在不清楚这样每次都设一次会不会引起效率问题，至少测试是没发现的
			collectgarbage("stop")
			collectgarbage("step", gc_step)
			
			past_time = past_time - gc_interval
		end
	end
end