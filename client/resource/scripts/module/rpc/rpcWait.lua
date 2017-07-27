local reLinkUICls = require("ui/loginRelinkUI")
local wait = {}

local MAX_WAIT_TIME = 15
local PASS_TIME = 5

local is_show = false

local main = {}

local scheduler = nil

local max_wait = {}
-- is_show 是判断网络延迟弹框的是否正在显示的状态
--change_login_flag  正常情况下调用closeWaitting 会把网络延迟弹框关闭
-- 但是切换到重登ui下也会调用，原来会把is_show重新设置，这是错误的
-- 现在加上参数，切换重登情况下不改变is_show的状态
local function closeWaitting(change_login_flag)
	if not is_show then return end
	if not change_login_flag then
		is_show = false
	end
	local reLinkUI = reLinkUICls:maintainObj()
	reLinkUI:hide()
end

local function showWaitting()
	if is_show then return end
	
	is_show = true

	local reLinkUI = reLinkUICls:maintainObj()
	reLinkUI:mkLinkingDialog()
end

local function returnLogin()
	wait = {}
	main.stop()
	closeWaitting(true) -- 从风火轮切换到重登UI时候不改变is_show 的状态

	local reLinkUI = reLinkUICls:maintainObj()
	reLinkUI:mkReLoginDialog()
end

function main.wait(name, waitTime)
	if waitTime ~= nil then
		max_wait[name] = waitTime
	end
	wait[name] = os.time()

	if scheduler == nil then
		main.init()
	end
end

local function isNeedShow()
	local now = os.time()
	for rpc, waittime in pairs(wait) do
		local pass_time = now - waittime 
		if pass_time >= PASS_TIME then
			return true
		end
	end
	return false
end

function main.emit(name)
	wait[name] = nil

	if table.count(wait) < 1 then
		main.stop()
		closeWaitting()
	else 
		if isNeedShow() then
			showWaitting()
		else
			closeWaitting()
		end
	end
end

local function rpcWaitScheduler()
	local now = os.time()
	for rpc, waittime in pairs(wait) do
		local pass_time = now - waittime 
		if pass_time >= PASS_TIME and not is_show then
			showWaitting()

			cclog("********** rpc wait: **********")
			table.print(wait)
		end

		if pass_time >= (max_wait[rpc] or MAX_WAIT_TIME) then
			returnLogin()
			return
		end
	end
end

function main.init()
	if scheduler ~= nil then return end

	scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(rpcWaitScheduler, 0.5, false)
end

function main.stop()
	if scheduler == nil then return end

	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduler)
	scheduler = nil
end

function main.clear()
	main.stop()
	wait = {}
	max_wait = {}
end

return main
