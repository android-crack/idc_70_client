-- 游戏一启动的场景

local ClsVersonInfoLayer = class( "ClsVersonInfoLayer", function() return CCLayer:create() end )

local txt_version
function ClsVersonInfoLayer:ctor()
	self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)
	
	self:initUI()
end 

function ClsVersonInfoLayer:initUI()
	require("update/logMgr")
	txt_version = createBMFont({text = "", size = 20, x = display.right - 140, y  = display.top - 15, align = ui.TEXT_ALIGN_LEFT, color = ccc3(255,255,255)})
    self:addChild(txt_version)
end

function ClsVersonInfoLayer:onEnter()
	updateVersonInfo()
	
end 
function ClsVersonInfoLayer:onExit()
	
end 

function updateVersonInfo(step)
	local app_version = GTab.APP_VERSION
	local update_version = GTab.VERSION_UPDATE
	local step = step or "L1000"
	txt_version:setString(string.format("%s - %s - %s", app_version, update_version, step))
end

function hideVersionInfo(is_show)
	txt_version:setVisible(is_show)
end

return ClsVersonInfoLayer