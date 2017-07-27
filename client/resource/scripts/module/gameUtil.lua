local rpc = require("module/rpc/rpc")
local util = {}

local root_node = nil
local cur_scene_type = 0
local has_create_exit = nil --创建退出游戏

local function mkScene(createScene)
	if createScene then
		createScene()
	end
	local scene = CCScene:create()
	local SceneTouchLayer = require("gameobj/sceneTouchLayer")
	scene:addChild(SceneTouchLayer.new())

	local DebugEnter = require("gameobj/debugEnter")
	scene:addChild(DebugEnter.new())

	return scene
end

local function mkRootNode()
	local node = CCNode:create()
	node.hasReleaseForRetain = false
	node:retain()
	node:ignoreAnchorPointForPosition(true)
	node:setContentSize(CCSizeMake(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT))
	return node
end

-- 过渡场景，避免场景切换引起内存高峰
local function ReplaceScene(createScene)
	local tranScene = CCScene:create()
	tranScene:registerScriptHandler(function(event)
		if event == "enterTransitionFinish" then
			TextureGC()
			local scene = mkScene(createScene)
			if not tolua.isnull(root_node) then
				scene:addChild(root_node)
				root_node:release()
				root_node.hasReleaseForRetain = true
			end

			CCDirector:sharedDirector():replaceScene(scene)
        end
    end)
	CCDirector:sharedDirector():replaceScene(tranScene)
end

function util.removeUIManager()
    local ui_manager = getUIManager()
    if not tolua.isnull(ui_manager) then
        ui_manager:removeAllView()
        ui_manager:removeFromParentAndCleanup(true)
    end
    setUIManager(nil)
end

function util.addUIManager()
    local ui_manager = getUIManager()
    if tolua.isnull(ui_manager) then
        local ClsUIManager = require("ui/view/clsUIManager")
        ui_manager = ClsUIManager.new()
        setUIManager(ui_manager)
        util.getRunningScene():addChild(ui_manager)
    end
end

function util.runScene(createScene, sceneType)
	if not tolua.isnull(root_node) and not root_node.hasReleaseForRetain then
		root_node:release()
	end
	root_node = nil
    util.removeUIManager()
	cur_scene_type = sceneType

	root_node = mkRootNode()
	local running_scene = CCDirector:sharedDirector():getRunningScene()

	if running_scene then
		ReplaceScene(createScene)
	else
		local scene = mkScene(createScene)
		if not tolua.isnull(root_node) then
			scene:addChild(root_node)
			root_node:release()
			root_node.hasReleaseForRetain = true
		end
		CCDirector:sharedDirector():runWithScene(scene)
	end
    util.addUIManager()
	--TODO 添加真机返回键退出游戏
	if not has_create_exit then
		has_create_exit = true

		local parent = util.getNotification()
		local ClsExitGame = require("scripts/gameobj/clsExitGame")
		ClsExitGame.new(parent)
	end

end

-- 通告栏，和场景无关
function util.getNotification()
	local notification_node = CCDirector:sharedDirector():getNotificationNode()
	if tolua.isnull( notification_node ) then
		notification_node = CCNode:create()
		CCDirector:sharedDirector():setNotificationNode(notification_node)
	end
	return notification_node
end

-- 通告栏上界面管理，和场景无关
function util.getNotificationUIMgr()
	local notification_node = util.getNotification()
	local notifycation_ui_mgr = notification_node.m_ui_manager
	if tolua.isnull( notifycation_ui_mgr ) then
        local ClsUIManager = require("ui/view/clsUIManager")
        notifycation_ui_mgr = ClsUIManager.new()
        notification_node:addChild(notifycation_ui_mgr, 100)
        notification_node.m_ui_manager = notifycation_ui_mgr
	end
	return notifycation_ui_mgr
end

function util.getRunningScene()
	return root_node
end

function util.getRunningSceneType()
	return cur_scene_type
end

function util.callRpc(prot_name, argsList, cb_prot, waitTime)
	argsList = argsList or {}
	if #argsList < 1 then
		SERVER_FUNC[prot_name]()
	else
		SERVER_FUNC[prot_name](unpack(argsList))
	end

	if cb_prot then
		require("module/rpc/rpcWait").wait(cb_prot, waitTime)
	end
end

function util.callRpcVarArgs(prot_name, ...)
    SERVER_FUNC[prot_name](...)
end

function util.regRpc(prot_name, handle)
	if type(prot_name) == "string" and type(handle) == "function" then
		require("module/rpc/rpc"):regRpc(prot_name, handle)
	else
		cclog("error!!!!!!!!!!!reg rpc fail")
		assert(0)
	end
end

function util.setLuaGC()
	local _pause = pause or 100
	local _stepmul = stepmul or 5000
	collectgarbage("setpause", _pause)
	collectgarbage("setstepmul", _stepmul)
end

function util.luaFullGc()
	for i = 1, 2, 1 do
		collectgarbage("collect")
	end
end

function util.dexToDec(str, length)
    local   num
    local   count=1;
    local   result=0;

	local revstr = str
    for i = length, 1, -1 do
		local a = string.sub(revstr,i,i)
		local bt = string.byte(a)

		if (( bt>=string.byte('0')) and ( bt<=string.byte('9'))) then
            num= bt-48
        elseif (( bt>=string.byte('a')) and ( bt<=string.byte('f'))) then
            num=bt-string.byte('a')+10
        elseif (( bt>=string.byte('A')) and ( bt<=string.byte('F'))) then
            num= bt-string.byte('A')+10
        else
            num=0
		end
        result=result+num*count
        count=count*16
    end
    return result
end

function util.colorDexToDec(str)
	assert(string.len(str) == 6, "dex color value should six bit")
	local red_dex = string.sub(str, 1, 2)
	local green_dex = string.sub(str, 3, 4)
	local blue_dex = string.sub(str, 5,6)

	local red = util.dexToDec(red_dex,2)
	local green = util.dexToDec(green_dex,2)
	local blue = util.dexToDec(blue_dex,2)

	return red, green, blue
end

function util.colorDexToDecNormalize(str)
	local r,g,b = util.colorDexToDec(str)
	return r/255, g/255, b/255
end

function util.colorNormalize(color)
	return color.r/255, color.g/255, color.b/255
end

function util.colorUnNormalize(color)
	return color.r*255, color.g*255, color.b*255
end

function util.probility(rate)
	rate = rate*10 or 1000
	local pro = math.random(1000)
	if pro > rate then return false end
	return true
end

GameUtil = util
