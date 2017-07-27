require("ui/view/clsUIManager")
local gui = nil
function getUIManager()
	if tolua.isnull(gui) then
		return {
			get = function() end,
			close = function() end,
			isLive = function() end,
			create = function() end,
			removeAllView = function() end,
		}
	end
	return gui
end
function setUIManager(ui_manager)
	gui = ui_manager
end
require("base/cocos_common/audioExt")
require("base/cocos_common/event_trigger")
require("base/colorRGB")
-- require("tick.lua")
require("language")
require("appController")
require("module/gameUtil")
require("module/eventHandlers")
require("module/font_util")
require("module/mathFuns")
require("module/util_3D")
require("module/gameBases")

preloadFile("game_config/preload_list")
