--2017/02/17
--create by wmh0497
--用于显示3d的任务页面

require("gameobj/explore/exploreDialog")
require("module/explore/exploreConfig")
require("gameobj/explore/explore3d")

--请不要使用这个函数 除非了解场景切换协议
function startMission3dScene(mission3d_id, params)
	--保证进入这个场景时停止扣食物补给
	if getUIManager():isLive("ExploreLayer") then
		getGameData():getSupplyData():askIsStopFood(true)
	end
	local mission3d_cfg = require(string.format("gameobj/mission3d/mission3d_cfg_juqing%s", mission3d_id))
	local function mkMission3dScene()
		require("module/preload/preload_mission3d").start_preload(mission3d_cfg, function()
				getUIManager():create("gameobj/mission3d/clsMission3dUiView", nil, mission3d_cfg, params)
				setNetPause(false)
			end)
	end

	setNetPause(true)
	-- 显示loading 界面
	require("gameobj/loadingUI"):show(function()
			GameUtil.runScene(mkMission3dScene, SCENE_TYPE_MISSION3D)
		end)
end