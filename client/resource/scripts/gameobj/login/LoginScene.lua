require("module/login/loginBase")
require("ui/tools/MyMenu")
require("ui/tools/MyMenuItem")
require("gameobj/composite_effect")
require("module/dataManager")

local login_layer = nil

local main = {}

function main.startLoginScene()
	local game_rpc = require("module/gameRpc")
	game_rpc.closeSocket()

	-- 清理异步线程
	QResourceManager:purgeResourceManager()
	
	local function login_scene() 
		local runScene = GameUtil.getRunningScene()
	end

	GameUtil.runScene(login_scene, SCENE_TYPE_LOGIN)
	
	-- 清理数据
	cleanGameData()
	
	print("=======================main.startLoginScene()")
	local ui = getUIManager():create("gameobj/login/clsLoginAuthLayer")
end

--创建选服务器界面
function main.startServerListScene() 
	local server_ui = getUIManager():get("ClsLoginServerUI")
	if not tolua.isnull(server_ui) then
		server_ui:close()
	end
	local runScene = GameUtil.getRunningScene()
	if tolua.isnull(runScene) then
		GameUtil.runScene(nil, SCENE_TYPE_LOGIN)
	end
	getUIManager():create("gameobj/login/clsLoginServerUI")
end

function main.loginFinish()  -- 登录完毕
end 


return main
