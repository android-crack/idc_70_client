-- Game rpc base module
local rpc = require("module/rpc/rpc")
require("module/rpcs/rpc_error")
require("module/rpcs/rpc_login")
require("module/rpcs/rpc_port")
require("module/rpcs/rpc_player")
require("module/rpcs/rpc_guild")
require("module/rpcs/rpc_worldMap")
require("module/rpcs/rpc_mission")
require("module/rpcs/rpc_explore")
require("module/rpcs/rpc_system")
require("module/rpcs/rpc_collect")
require("module/rpcs/rpc_shop")
require("module/rpcs/rpc_fight")
require("module/rpcs/rpc_reward")
require("module/rpcs/rpc_sailor")
require("module/rpcs/rpc_boat")
require("module/rpcs/rpc_question")
require("module/rpcs/rpc_market")
require("module/rpcs/rpc_friend")
require("module/rpcs/rpc_arena")
require("module/rpcs/rpc_achieve")
require("module/rpcs/rpc_tip")
require("module/rpcs/rpc_loginVipAward")
require("module/rpcs/rpc_loot")
require("module/rpcs/rpc_portPve")
require("module/rpcs/rpc_propItem")
require("module/rpcs/rpc_baowu")
require("module/rpcs/rpc_captainInfo")
require("module/rpcs/rpc_activity")
require("module/rpcs/rpc_chat")
require("module/rpcs/rpc_daily_activity")
require("module/gameBases")
require("module/eventHandlers")
require("module/rpcs/rpc_daily_course")
require("module/rpcs/rpc_title")
require("module/rpcs/rpc_mail")
require("module/rpcs/rpc_copy_scene")
require("module/rpcs/rpc_sea_star")
require("module/rpcs/rpc_buff_state")
require("module/rpcs/rpc_explore_ships")
require("module/rpcs/rpc_team")
require("module/rpcs/rpc_trade_complete")
require("module/rpcs/rpc_nobility")
require("module/rpcs/rpc_partner")
require("module/rpcs/rpc_ship")
require("module/rpcs/rpc_explore_npc")
require("module/rpcs/rpc_time_pirate")
require("module/rpcs/rpc_mineral_point")
require("module/rpcs/rpc_worldMission")
require("module/rpcs/rpc_growth_fund")
require("module/rpcs/rpc_municipal_work")
require("module/rpcs/rpc_gain_back")
require("module/rpcs/rpc_area")
require("module/rpcs/rpc_port_battle")
require("module/rpcs/rpc_rank")
require("module/rpcs/rpc_mission3d_scene")
require("module/rpcs/rpc_festival_activity")

rpc:loadConfig("rpcJson.cfg")
local module_game_sdk = require("module/sdk/gameSdk")
local ModuleLoginBase = require("module/login/loginBase")
local ModuleDataHandle = require("module/dataManager")
local Alert =  require("ui/tools/alert")
local error_info = require("game_config/error_info")

local scheduler = CCDirector:sharedDirector():getScheduler()

local gameRpc = {}

local sock = nil

--是否停止协议解析
local net_pause = false

local user_heartbeat
local heardBeatSessions = {}
local heardId = 0
local latestTimeInterval = 0

local libevent_dispatch
libevent_dispatch = function()
	if sock then
		sock:dispatch() 
	end
	if rpc:get_lua_socket() then
		rpc:dispatch()
	end
end

local libevent_dispatch_tm = nil

-- 开始解析心跳
local start_dispatch
start_dispatch = function()
	if libevent_dispatch_tm == nil then 
		libevent_dispatch_tm = scheduler:scheduleScriptFunc(libevent_dispatch, 0.1, false)
	end 
end 

-- 停止解析
local stop_dispatch
stop_dispatch = function()
	if libevent_dispatch_tm then
		scheduler:unscheduleScriptEntry(libevent_dispatch_tm)
		libevent_dispatch_tm = nil
	end
end

-- 玩家心跳
local userHeartbeat
userHeartbeat = function()
	heardId = heardId + 1
	heardBeatSessions[heardId] = CCTime:getmillistimeofCocos2d()
	GameUtil.callRpc('rpc_server_user_heartbeat', {heardId})
end


GameUtil.regRpc("rpc_client_user_heartbeat", function (id)
	for k,v in ipairs(heardBeatSessions) do
		if k == id then
			--最近返回的
			latestTimeInterval = math.floor(CCTime:getmillistimeofCocos2d() - v)
		end
	end
	if device.platform == "windows" then
		-- prc_ping_bg:setVisible(true)
		if not tolua.isnull(rpc_ping_value) then
			rpc_ping_value:setString(tostring(latestTimeInterval))
		end
	end
end)

local onRead
onRead = function(luaSock, data)
	rpc:dispatch()
end

local createUserHeartbeat
createUserHeartbeat = function()
	user_heartbeat = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(userHeartbeat, 120, false)
	local start_and_login_data = getGameData():getStartAndLoginData()
	start_and_login_data:setStartGameState(true)
end

rpc_client_user_kick_out = function()
	local playerData = getGameData():getPlayerData()
	local start_and_login_data = getGameData():getStartAndLoginData()
	local uid = playerData:getUid()
	if uid then
		start_and_login_data:setKickOutUid( uid )
	end
	--被踢的话都不重连
	start_and_login_data:setLoginAgain(true)

	local login_use = start_and_login_data:getLoginUse()
	if login_use then
		start_and_login_data:setKickOutLoginUse(login_use)
	end
end

rpc_client_uid_relink_return = function(errno)
	if errno == 0 then--令牌环重连成功，加上心跳，不走auth协议流程了
		createUserHeartbeat()
	end
	module_game_sdk.relinkCallBack( errno )
end

rpc_client_auth_return = function(result, msg, error_n)
	if result ~= 0 then
		updateVersonInfo(LOG_1043)
		--to do  失败重新拉起sdk
		--GameUtil.callRpc("rpc_server_user_main_info")
		local start_and_login_data = getGameData():getStartAndLoginData()
		start_and_login_data:setWaitingLoginTimes()
		
		local ui_word = require("game_config/ui_word")
		if -2 == result then --账号被封掉
			local open_time = error_n
			local tips_str = ui_word.IS_LOCK_ACCOUNT_FOREVER
			if open_time ~= -1 then
				local time_info = os.date("*t", open_time)
				tips_str = string.format(ui_word.IS_LOCK_ACCOUNT, time_info.year, time_info.month, time_info.day, time_info.hour, time_info.min)
			end
			Alert:showAttention(tips_str,
				function() CCDirector:sharedDirector():endToLua() end, nil, nil, 
				{ok_text = ui_word.OUT_GAME_TIPS, hide_close_btn = true, hide_cancel_btn = true, is_notification = true, is_add_touch_close_bg = false})
		elseif result == -3 then--成长守护禁登
			Alert:showAttention(msg, function() 
					CCDirector:sharedDirector():endToLua() 
				end, function()
					CCDirector:sharedDirector():endToLua() 
				end, nil, 
				{ok_text = ui_word.OUT_GAME_TIPS, hide_close_btn = true, hide_cancel_btn = true, is_notification = true, is_add_touch_close_bg = false})
		else  --登陆失败
			local msg = error_info[error_n] and error_info[error_n].message
			if not msg then
				print("not error msg,error code:",error_n)
				return
			end
			Alert:warning({msg = msg, zorder = TOPEST_ZORDER})

			local login_layer = getUIManager():get("LoginLayer")
			if login_layer and not tolua.isnull(login_layer) then
				gameRpc.closeSocket()
				login_layer:setViewTouchEnabled(true)
			end
		end
		return
	end
	updateVersonInfo(LOG_1042)
	createUserHeartbeat()
end

local onConnectedGame
onConnectedGame = function(luaSock)
	updateVersonInfo(LOG_1006)
	local login_layer = getUIManager():get("LoginLayer")
	if tolua.isnull(login_layer) then--如果有登录界面，登录界面已经做了清理了
		--这里的清理是为了重连时候，保证在成功重连之后清掉之前全部的ui
		QResourceManager:purgeResourceManager()
		getUIManager():removeAllView() 
		local reLinkUI = require("ui/loginRelinkUI"):maintainObj()
		reLinkUI:mkParseWaitDialog()
	end
	cleanGameData()

	rpc:set_lua_socket(luaSock)
	package.loaded["filelist"] = nil
	local cFileInfos = require( "filelist" )
	local module_start_game = require("module/login/startGame")
	GameUtil.callRpc("rpc_server_version", {GTab.APP_VERSION, GTab.VERSION_UPDATE, cFileInfos["res/rpcJson.cfg"].md5,  module_start_game.getChannelId()}, "rpc_client_version_return")

	setNetPause(false)
	--ModuleLoginBase.clearRelinkCount()
end

rpc_client_version_return = function(state, encoding)
	updateVersonInfo(LOG_1007)
	local reLinkUI = require("ui/loginRelinkUI"):getCurUIObj()
	if not tolua.isnull(reLinkUI) then
		reLinkUI:removeFromParentAndCleanup(true)
	end
	if module_game_sdk.tryExecuteAuthChn() then
		return
	end
	if module_game_sdk.tryRelink() then
		return
	end
	
	local login_layer = getUIManager():get("LoginLayer")
	if login_layer and not tolua.isnull(login_layer) then
		gameRpc.closeSocket()
		login_layer:setViewTouchEnabled(true)
	else
		require("gameobj/login/LoginScene").startLoginScene()
	end
end

--relink_socket是否是登录中重连，这时候其他流程不继续走(主要用于登录使用)
gameRpc.connectGame = function(call_back)
	updateVersonInfo(LOG_1005)
	local start_and_login_data = getGameData():getStartAndLoginData()
	local tips_left_time = start_and_login_data:getConnectDelayTime()
	local reLinkUI = require("ui/loginRelinkUI"):maintainObj()
	if tips_left_time and tips_left_time > 0 then
		reLinkUI:mkWaitingLoginDialog(tips_left_time)
		return
	end

	reLinkUI:mkLinkingDialog(true)
	
	start_dispatch()
	sock = LuaSocket:create()

	sock:setScriptReadCB(onRead)
	sock:setScriptErrorCB(function(socke, event, event_string)
		print("socket script error", event, event_string)
		setNetPause(false)
		rpc:dispatch()
		
		--sock出错 引擎会自动关闭sock
		sock = nil
		
		gameRpc.closeSocket()

		--登陆帐号和密码成功过，才需要重连。
		--local start_and_login_data = getGameData():getStartAndLoginData()
		--if start_and_login_data:getLoginFinish() then
		--	ModuleLoginBase.reLink()
		--end

		--如果是被顶号不需主动重连，或者是登录界面以及被踢的时候
		local start_and_login_data = getGameData():getStartAndLoginData()
		if start_and_login_data:getLoginAgain() then
			return
		end

		--只重连三次
		if ModuleLoginBase.getRelinkCount() > 3 then
			ModuleLoginBase.showReLink()
			ModuleLoginBase.clearRelinkCount()
			local msg = error_info[401].message
			Alert:warning({msg = msg, zorder = TOPEST_ZORDER})
			return
		end

		module_game_sdk.beginRelink()
		ModuleLoginBase.reLinkSocket()
	end)

	sock:setScriptConnectedCB(function(luaSock)
			if call_back and type(call_back) == "function" then
				call_back()
			end
			onConnectedGame(luaSock)
		end)

	sock:set_client_privatekey([[
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDe1vb10zie6d0PnKZQL61JX8lHMsrfzRQMp/k1S/yWlH0dRrab
+4jTyGJ1boT35b/QpKzJFYlHQY0vd9bnydSn7Q5gQ1EBdxKz2cUoW02mBTGtYawi
k2yQGNJxFUYf1ewQMsf+TqSwYIO9BVHQwV6NV8UgJSiSqFwxfJkmTGj4SQIDAQAB
AoGAJIPPFfsVlRy3R56gthUJ7TMP9WXCTqf5OBWyRWR9MGOGmOyEcczm3+U/FQUW
LtTr+JFzasPnqdB5BSU7BuJQwSFUfHFfsFl7icSw1Zs87EWdDK8rwz0VUgRbsalj
tAQKiHlWJDMrRg06Cs2dyDXqiaID3v7vV8Xa82WM0yd1YAECQQDxNvoPNCkd/U6o
qy2KVnL+Y1VaooZdOTV3lMtxmO00KGBJNsrro3oOzkRllqTgczg334etXJq7NV11
S07lbPRJAkEA7H+n25LsS+1vrNsWTNdEgtpmInDkWaii5DvDaVXeRioVnCAlgWMo
n8DdffxlsZssxuVzyQ24uefjlUGSXBPkAQJAAyd9458B/qNmWOxMHyf8Pvlbj2Da
svNhkJvAgU7Ho0v33l06EBTGLtVhrZZnt4uqK4jfxFOWrmYHP9ZpRLTFCQJBAMPj
HJrvgA+H1CcdtMPizhmAYnaGgW2OE5XttnbqK9h8BTgzHD2mb0CbVBqFU4ofmKAJ
77SJTAeX/dZj4KGpzAECQAzdd2XeGzKeeOG5MXJtI8VI9bvdt+4XEwo+BlxevvaC
eRZgLBjJ/4MyChdVMKQ3TEw+nEg/SAPIEH8jclhk7Nw=
-----END RSA PRIVATE KEY-----
]])
	sock:set_server_publickey([[
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCj7eOXX+zGINX2JIzi7KB67igd
06qPOLHACdY41orY3PvscfFYT46ZDBdG3o9lILfmcv6fRzeieXYm5ef+bnLFcIwc
WXoYcYb08iGxuSqD3w3A0G/CjeVnwYS+eQ1W2VA1vP/ZxNffImDTSY7ozqMj6et1
ff9EkaiErVyMvPV0MwIDAQAB
-----END PUBLIC KEY-----
]])


	local start_and_login_data = getGameData():getStartAndLoginData()
	local server_cfg = start_and_login_data:getLoginIpPort()
	local ip, port = server_cfg.ip, server_cfg.port
	local domain = server_cfg.domain
	
	if domain and domain ~= "" then 
		print("socket connect:", domain, port)
		sock:connectWithDomain(domain, port)
	else 
		print("socket connect:", ip, port)
		sock:connect(ip, port)
	end 
end

gameRpc.closeSocket = function()
	updateVersonInfo(LOG_0001)
	print("===================gameRpc.closeSocket()")
	
	stop_dispatch()
	if sock then
		rpc:dispatch()	
		sock:close()
		sock = nil
	end
	
	if user_heartbeat then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(user_heartbeat)
		user_heartbeat = nil
	end 
	
	local start_and_login_data = getGameData():getStartAndLoginData()
	start_and_login_data:setStartGameState(false)
	
	rpc:set_lua_socket(nil)
	rpc:clear()
	require("module/rpc/rpcWait").clear()
end



gameRpc.checkSocketConnectByAuth = function(auth_chn)
	updateVersonInfo(LOG_1038)
	if sock then--防止点击多次授权返回
		gameRpc.closeSocket()
	end
	local start_and_login_data = getGameData():getStartAndLoginData()
	print("=========================auth_chn", auth_chn)
	module_game_sdk.delayExecuteAuthChn()

	local user_default = CCUserDefault:sharedUserDefault()
	user_default:setStringForKey(LAST_SELECT_AUTH_CHN, auth_chn)

	local module_start_game = require("module/login/startGame")
	local server_list = module_start_game.getLoginServer()
	local server_cfg
	for i,v in pairs(server_list) do
		if v.name == auth_chn then
			server_cfg = v
		end
	end
	if not server_cfg then
		server_cfg = server_list[1]
	end
	updateVersonInfo(LOG_1039)
	start_and_login_data:setLoginIpPort(server_cfg)
	gameRpc.connectGame()
end

gameRpc.reStartGame = function(call_back)
	gameRpc.restart_call_back = call_back
	module_game_sdk.logout()
	module_game_sdk.clearAutoLoginInfo()
	print("==========================gameRpc.reStartGame")
	local reLinkUI = require("ui/loginRelinkUI"):getCurUIObj()
	if not tolua.isnull(reLinkUI) then
		reLinkUI:removeFromParentAndCleanup(true)
	end

	gameRpc.closeSocket()
	local module_start_game = require("module/login/startGame")
	module_start_game.startGame()
end

gameRpc.linkSocket = function(time)
	local start_and_login_data = getGameData():getStartAndLoginData()
	local need_tips_time, delay_time = start_and_login_data:setConnectDelayCount()
	local reLinkUI = require("ui/loginRelinkUI"):maintainObj()
	if need_tips_time > 0 then
		reLinkUI:mkWaitingLoginDialog(need_tips_time)
		return
	end

	time = time or delay_time
	module_game_sdk.beginRelink()

	reLinkUI:mkLinkingDialog()
	
	gameRpc.closeSocket()
	
	local actions = {}
	actions[1] = CCDelayTime:create(time)
	actions[2] = CCCallFunc:create( function()
		gameRpc.connectGame()
		reLinkUI:hide()
	end)
	local action = transition.sequence(actions)
	reLinkUI:runAction(action)
end

--登陆时候来调用，看是否有需要自动登陆
gameRpc.callLoginFun = function()
	if gameRpc.restart_call_back and type(gameRpc.restart_call_back) == "function" then
		gameRpc.restart_call_back()
	end
end

return gameRpc
