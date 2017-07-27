require("gameobj/explore/exploreDialog")
require("module/explore/exploreConfig")
require("gameobj/explore/explore3d")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")

--请不要使用这个函数 除非了解场景切换协议
function startExploreScene()
	local function createLayer()
		local explore_data = getGameData():getExploreData()
		local running_scene = GameUtil.getRunningScene()

		local explore_layer = getUIManager():create("gameobj/explore/exploreLayer")
		-- ui
		local explore_ui = getUIManager():create("gameobj/explore/exploreUI", nil, explore_layer)

		explore_layer:initExploreInfo()

		getUIManager():create("gameobj/explore/clsExploreBlankLayer") --探索遮罩层
		getUIManager():create("gameobj/explore/clsExploreBackLayer") --用来做删除探索上打开所有界面之用。

		setNetPause(false)
		ClsDialogSequene:resumeQuene("LoginLayer")

		ClsDialogSequene:resumeQuene("battle_scene")

	end

	local function mkExploreScene()
		local ModuleExploreLoading = require("gameobj/explore/exploreLoading")
		local plist = {
			["ui/skill_icon.plist"] = 1,
			["ui/relic/relic_icon.plist"] = 1,
			["ui/relic/relic.plist"] = 1,
			["ui/guild_badge.plist"] = 1,
			["ui/title_name.plist"] = 1,
			["ui/title_icon.plist"] = 1,
			["ui/explore_sea.plist"] = 1,
			["ui/head_frame.plist"] = 1,
			["ui/ship_icon.plist"] = 1,
			["ui/force_icon.plist"] = 1,
			["ui/arena_rank.plist"] = 1, -- 竞技场
		}
		ModuleExploreLoading:loading(createLayer, plist)
	end

    setNetPause(true)
	-- 显示loading 界面
	require("gameobj/loadingUI"):show(function()
		GameUtil.runScene(mkExploreScene, SCENE_TYPE_EXPLORE)
	end)


end

-- 获取探索UI
function getExploreUI()
	return getUIManager():get("ExploreUI")
end

function getExploreLayer()
	return getUIManager():get("ExploreLayer")
end

-- 获取探索scene
function getExploreScene()
	return GameUtil.getRunningScene()
end
