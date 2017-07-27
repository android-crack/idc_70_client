local ui_word = require("game_config/ui_word")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsGuidePortLayer = class("ClsGuidePortLayer", ClsBaseView)

function ClsGuidePortLayer:getViewConfig()
    return {
        name = "ClsGuidePortLayer",
        is_swallow = false
    }
end

function ClsGuidePortLayer:onEnter()
	if not isExplore and DEBUG > 0 then
		--todo 调试添加绿字任务跳过菜单
		local skipLb = createBMFont({text = ui_word.TASK_GUIDE_SKIP, size = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
		local skipBtn = MyMenuItem.new({labelNode=skipLb, x = 798, y=525})
		skipBtn:regCallBack(function()
			ClsGuideMgr:cleanAllGuide()
		end)
		local skipMenu = MyMenu.new(skipBtn)
		self:addChild(skipMenu, ZORDER_MISSION)
	end
end

function ClsGuidePortLayer:onExit()
end

return ClsGuidePortLayer