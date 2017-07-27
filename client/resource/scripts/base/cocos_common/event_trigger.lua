
local eventToFunctionTbl = {}

EVENT_TAG_NONE = "none"

EVENT_GET_TOUCH_POINT = 1
EVENT_SCREEN_ENLARGE = 2

--注册事件，支持1个事件对应多个回调函数，回调函数用event_tag作为区分
function RegTrigger(event_id, func, event_tag)
	if type(func) ~= "function" then
		cclog("Event trigger set not a function, id : %i", event_id)
		return
	end
	event_tag = event_tag or EVENT_TAG_NONE
	if not eventToFunctionTbl[event_id] then
		eventToFunctionTbl[event_id] = {}
	end
	eventToFunctionTbl[event_id][event_tag] = func
end

function UnRegTrigger(event_id, event_tag)
	local event_to_function_tmp = eventToFunctionTbl[event_id]
	if event_to_function_tmp then
		event_tag = event_tag or EVENT_TAG_NONE
		event_to_function_tmp[event_tag] = nil
	end
end

function HasRegTrigger(event_id, event_tag)
	local event_to_function_tmp = eventToFunctionTbl[event_id]
	if not event_to_function_tmp then return false end
	if event_tag then
		local func = event_to_function_tmp[event_tag]
		if func ~= nil then
			return true
		end
	else
		local func = nil
		for k, v in pairs(event_to_function_tmp) do
			func = v
			if func ~= nil then
				return true
			end
		end
	end
	return false
end

function EventTrigger(event_id, ...)
	local event_to_function_tmp = eventToFunctionTbl[event_id]
	if not event_to_function_tmp then return end
	local func = nil
	local has_func = false
	local func_return_value = nil --兼容之前的
	for k, v in pairs(event_to_function_tmp) do
		func = v
		if func ~= nil then
			has_func = true
			func_return_value = func(...)
		end
	end
	if not has_func then
		cclog("Event trigger no such function id : %i", event_id)
		return
	end
	return func_return_value
end