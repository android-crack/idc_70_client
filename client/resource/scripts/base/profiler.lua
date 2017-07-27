--[[
--用法: 首先require profiler 模块，然后在你想分析的地方之前后分别添加profiler.start(), profiler.finish()函数
--eg:
--local profiler = require("gameobj.profiler")
--profiler.start()
--test1()
--test2()
--profiler.finish()
--]]

local profiler = {}
local file_name = "lprofiler.log"
local funcs = {}

local function strformat(func)
	local f = func.name
	if f.what == "C" then
		return string.format("[%-20s]\t, %d,\t %d,\t %d", f.name, func.count, func.time, func.time / func.count)
	end

	local loc = string.format("[%s]: %s", f.short_src, f.linedefined)
	if f.namewhat ~= "" then
		return string.format("[%-20s]\t, %d,\t %d,\t %d\n+%s", f.name, func.count, func.time, func.time / func.count, loc)
	else
		return string.format("%s", loc)
	end
end

local function hook(event)
	local f = debug.getinfo(2, "f").func
	if event == "call" then
		if funcs[f] == nil then
			funcs[f] = {}
			funcs[f].count = 1
			funcs[f].time 	= 0
			funcs[f].name 	= debug.getinfo(2, "Sn")
		else
			funcs[f].count = funcs[f].count + 1
		end
		funcs[f].stamp = QTZUtil.getCurrentTime()	
	elseif event == "return" then
		if funcs[f] == nil then return end
		local delta = QTZUtil.getCurrentTime() - funcs[f].stamp
		funcs[f].time = funcs[f].time + delta
		funcs[f].stamp = 0
	end
end

local function pprint()
	for _, f in pairs(funcs) do
		if f.time ~= 0 then
			print(strformat(f))
		end
	end
end

local function pfile()
	local info = io.open( file_name, "wb")
	for _, f in pairs(funcs) do
		if f.time ~= 0 then
			info:write(strformat(f))
			info:write("\n")
		end
	end
	info:close()
end

function profiler.start(_filename)
	debug.sethook(hook, "cr")

	if _filename then
		file_name = _filename
	end
end

function profiler.finish(mode)
	debug.sethook()
	if mode == nil or mode == "print" then
		pprint()
	elseif mode == "file" then
		pfile()
	end
	funcs = {}
end

return profiler
