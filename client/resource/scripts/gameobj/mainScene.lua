require("base/cocos_common/event_trigger")
require("module/eventHandlers")
require("module/gameBases")
require("gameobj/mainInit3d")
require("tick")
require("gameobj/explore/explore3d")
require("gameobj/battle/battleInit3d")
require("gameobj/explore/exploreScene")
require("gameobj/mission3d/mission3dScene")

local boat_info = require("game_config/boat/boat_info")

local music_info = require("game_config/music_info")

local last_layer = nil
local select_layer = nil
local goal_layer = nil
local item_tab = nil

local Item = {}
local function createPortLayer()
	audioExt.stopMusic()
    audioExt.stopAllEffects()

    getUIManager():create("gameobj/port/clsPortLayer", nil, true, function()
		local portData = getGameData():getPortData()
	    portData:checkEnterPortCallBack()
	end)
	-- select_layer = last_layer
	-- select_layer.tag = TYPE_LAYER_PORT
	local running_scene = GameUtil.getRunningScene()
	-- running_scene:addChild(last_layer)
	running_scene:registerScriptHandler(function(event)
		if event == "exit" then 
			local ModulePortLoading = require("gameobj/port/portLoading")
			ModulePortLoading:clearAll()
		end 
	end )
	
	if item_tab ~= nil and Item[item_tab.name] then 
		Item[item_tab.name](item_tab.index)
	end 
    showAchieveView()
    setNetPause(false)
end 

local function mkMainScene()
	local res_tab = {
		plist = {
			["ui/port_main.plist"] = 1,
			["ui/title_icon.plist"] = 1,
			["ui/relic/relic_icon.plist"] = 1,
			["ui/ship_icon.plist"] = 1,
			["ui/baowu.plist"] = 1,
			["ui/activity_ui.plist"] = 1,
			["ui/port/people.plist"] = "RGBA4444",
			["ui/title_name.plist"] = 1,
			["ui/item_box.plist"] = 1,
			["ui/port_cargo.plist"] = 1,
			["ui/friend_ui.plist"] = 1,
		},
		
		armature = {
			["effects/tx_0122.ExportJson"] = 1, --交易所
			["effects/tx_0123.ExportJson"] = 1, --酒馆
			["effects/tx_0124.ExportJson"] = 1, --市政厅
			["effects/tx_0125.ExportJson"] = 1, --船厂
			["effects/tx_0126.ExportJson"] = 1, --仓库
			["effects/tx_0129.ExportJson"] = 1, --商会
			["effects/tx_0131.ExportJson"] = 1, --编制
			["effects/tx_0186.ExportJson"] = 1, --爵位
			["effects/tx_0187.ExportJson"] = 1, --组队
			["effects/tx_0196.ExportJson"] = 1, --技能
		},
		
		image = {
			
		},
	}
	
	-------------------------加载组队船armature-------------------------------
	local team_data = getGameData():getTeamData()
    local team_list = team_data:getMyTeamInfo()
    if team_list then
    	local my_team = team_list.info
    	for i,v in ipairs(my_team) do
    		local boat_id = v.flagShip
        	local boat = boat_info[boat_id]
        	local key = boat.armature
    		local boat_armtrue = "armature/ship/"..key.."/"..key..".ExportJson"
    		res_tab.armature[boat_armtrue] = 1
    	end
    end
    ----------------------------------------------------------
	local ModulePortLoading = require("gameobj/port/portLoading")
	ModulePortLoading:loading(createPortLayer, res_tab, "port")
end


function showAchieveView()
    local achieveData = getGameData():getAchieveData()
    local rewardLayer = achieveData:getRewardLayer()
    rewardLayer:start()
end

function getLastLayer()
    return last_layer
end

function startMainScene()
	local function createScene()
		GameUtil.runScene(mkMainScene, SCENE_TYPE_PORT)

		--指引重开
		local portLayer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(portLayer) then
			local delayTime = 3
			local dAction = CCDelayTime:create(delayTime)
			local cFunc = CCCallFunc:create(function()
				local missionGuide = require("gameobj/mission/missionGuide")
				missionGuide:resumeOpenGuide()
			end)
			portLayer:runAction(CCSequence:createWithTwoActions(dAction, cFunc))
		end
		local playersDetailData = getGameData():getPlayersDetailData()
		playersDetailData:tryToLoadLoaclPlayersInfo() --加载保存在本地的玩家信息文件
		playersDetailData:tryToSaveBakPlayerInfo()
	end
	
	local port_id = getGameData():getSceneDataHandler():getSceneId()
	local port_info = require("game_config/port/port_info")
	local port_cfg_item = port_info[port_id]
	local load_bg_str = nil
	local is_flip_x = false
	if port_cfg_item then
		local port_set_item = require("module/dataHandle/dataTools"):getPortSet(port_cfg_item.portType)
		if port_set_item then
			load_bg_str = port_set_item.res
		end
		if port_cfg_item.flipX > 0 then
			is_flip_x = true
		end
	end

	setNetPause(true)
	-- 显示loading 界面
	require("gameobj/loadingUI"):show(createScene, {load_bg_path = load_bg_str, is_flip_x = is_flip_x})
end

function getMainScene()
    return GameUtil.getRunningScene()
end