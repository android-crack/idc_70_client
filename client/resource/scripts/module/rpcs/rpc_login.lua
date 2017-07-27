
local Alert = require("ui/tools/alert")
local error_info = require("game_config/error_info")
local ui_word = require("game_config/ui_word")

function rpc_client_close_reason(reason, errno)
	local message_parse = require("module/message_parse.lua")
	local tips = message_parse.parse(errno)
	--1为被顶号，2为在登录停留太久被踢下线，这两种不需要重连处理，其他的话服务器下行没有主动踢人就提示并有返回登录的按钮
 	if reason == 1 or reason == 2 then 
 		local start_and_login_data = getGameData():getStartAndLoginData()
		start_and_login_data:setLoginAgain(true) 
	elseif reason == 3 then
		local start_and_login_data = getGameData():getStartAndLoginData()
		start_and_login_data:setLoginAgain(true) 
		--检查本地与服务端的版本号是否匹配，服务端弹出提示
		Alert:showVersionTips(tips)
		return
 	end
	local login = require("module/login/loginBase")
	login.showReLink(tips, true)
end

function rpc_client_platform_login(result, error)
	if result ~= 1 then
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end
end

--[[
-- 2.no charact
function rpc_client_uid_list(list_table)
	GameUtil.callRpc("rpc_server_new_uid", {1, 1, "test_fq_1"})
end

-- 3 after 2.no charact
function rpc_client_new_uid_return(ret)
end
--]]
-- 2.has charact
-- function rpc_client_login_return(errno)
-- 	local errorRes = error_info[errno]
-- 	if errorRes then
-- 		Alert:warning({msg = errorRes.message, size = 26})
-- 	else
-- 		print("client login return erro", errno)
-- 	end
-- end

function rpc_client_fcm_report( code )
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
    local ClsMarketHotSellQuene = require("gameobj/quene/clsAddictPopQueue")
    ClsDialogSequence:insertTaskToQuene(ClsMarketHotSellQuene.new(code))
end


local function loginFinish(token)
	hideVersionInfo()
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.setRelinkToken(token)
	-- GameUtil.callRpc("rpc_server_user_main_info")
	local ModuleDataHandle = require("module/dataManager")
	local start_and_login_data = getGameData():getStartAndLoginData()
	start_and_login_data:setLoginFinish(true)
end

GameUtil.regRpc("rpc_client_user_login_finish", loginFinish)

