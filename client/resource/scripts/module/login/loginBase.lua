
-- Login process module
local login = {}
login.relink_count = 0


function login.isConnected()
	return is_connected
end

function login.showReLink(tips, hide_again)
	local reLinkUI = require("ui/loginRelinkUI"):maintainObj()
	reLinkUI:mkReLoginDialog(nil, tips, hide_again)
end 

function login.reLinkSocket()
	local playerData = getGameData():getPlayerData()
	local uid = playerData:getUid()

	local ModuleDataHandle = require("module/dataManager")
	local start_and_login_data = getGameData():getStartAndLoginData()
	local kick_out_uid = start_and_login_data:getKickOutUid( )

	if kick_out_uid and uid and kick_out_uid == uid then
		return
	end

	local kick_out_login_use = start_and_login_data:getKickOutLoginUse( )
	local login_use = start_and_login_data:getLoginUse()
	if kick_out_login_use and login_use and kick_out_login_use == login_use then
		local loginLayer = getUIManager():get("LoginLayer")
		if not tolua.isnull(loginLayer) then
			loginLayer:setViewTouchEnabled(true)
		end
		return
	end

	--if tolua.isnull(require("ui/loginRelinkUI").getCurUIObj()) then 
	local module_game_rpc = require("module/gameRpc")
	module_game_rpc.linkSocket()
	
	login.relink_count = login.relink_count + 1
end 

function login.getRelinkCount()
	return login.relink_count
end

function login.clearRelinkCount()
	login.relink_count = 0
end

function login.logOutEnterBackground()
	local module_game_rpc = require("module/gameRpc")
	module_game_rpc.forceCloseSocket()

	if login.delayRelinkScheduler then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(login.delayRelinkScheduler)
		login.delayRelinkScheduler = nil
	end
end

function login.relinkEnterForeground()
	--首次起来引挚会调过来，但是getGameData()还没有初始化
	if not getGameData then
		return
	end
	local start_and_login_data = getGameData():getStartAndLoginData()
	if start_and_login_data:getLoginFinishOnce() then
		--local reLinkUICls = require("ui/loginRelinkUI")
		--local reLinkUI = reLinkUICls:maintainObj()
		--reLinkUI:mkLinkingDialog()
		--login.delayRelinkScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
    		-- print("relink......11111111")
    		--require("gameobj/loadingUI"):hide()
			login.reLinkSocket()
		--	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(login.delayRelinkScheduler)
		---	login.delayRelinkScheduler = nil
		--end, 2, false)
	end
end


return login