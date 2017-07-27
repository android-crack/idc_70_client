-- 探索加载界面
local UiCommon = require("ui/tools/UiCommon")
local UI_WORD = require("game_config/ui_word")
local loading_tips_info = require("game_config/loading_tips_info")

local ModuleExploreLoading = {}
function ModuleExploreLoading:loading(callback, explore_ui_plist)
	self.loadTable = {
		plist = explore_ui_plist,
		image = {
			["explorer/map/land/port.png"] = true,
			["explorer/map/land/relic.png"] = true,
			["explorer/map/land/ice.png"] = true,
			["explorer/map/land/new_grass.png"] = true,
			["explorer/map/land/new_land.png"] = true,
			["explorer/map/land/new_snow.png"] = true,
			["explorer/map/land/grass_tree.png"] = true,
			["explorer/map/land/grass_stone.png"] = true,
			["explorer/map/land/snow_tree.png"] = true,
			["explorer/map/land/snow_river.png"] = true,
			["explorer/map/land/sand_tree.png"] = true,
			["explorer/map/land/sand_stone.png"] = true,
			["explorer/map/land/transition.png"] = true,
			["explorer/map/land/grass_mound.png"] = true,
			["explorer/map/land/sand_mound.png"] = true,
			["world_map/world_map.jpg"] = true,
		},
	}
	
	local invest_data = getGameData():getInvestData()
	if not invest_data:isSendAllPort() then
		invest_data:sendAllPortInvestInfo()
	end
	invest_data:sendGetPortInvestSailor()
	require("gameobj/loadingUI"):start(self.loadTable, callback)
end

function ModuleExploreLoading:clearPreload()
	require("module/preload/preload_mgr").clearPreLoad(self.loadTable)
end 

return ModuleExploreLoading
