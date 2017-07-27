
local UpdateLayer = class( "UpdateLayer", function() return CCLayer:create() end )

local progressY = display.cy*0.4 - 15

---------------

function UpdateLayer:ctor() 
	self.ProgressBarUrl = {
			["background"] 	=  	"update/loadingBg.png",
			["foreground"]	= 	"update/loadingProcess.png",
			["rudder_bg"]	= 	"update/rudder_02.png",
			["rudder"]	= 	"update/rudder_01.png",
			["dialog_bg"] = "update/login_relink.png",
	}

	self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)
	self.count 	= 0
	self.sum	= 0
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local bg = display.newSprite(self.ProgressBarUrl.login_bg, display.cx, display.cy)
	self:addChild(bg)
	bg:setScale(display.width/bg:getContentSize().width)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	require("update/utils").playBgMusic()
	
	local touch_priority = 0
	self.layer = CCLayer:create()
	self:addChild(self.layer, 10)
	self.layer:registerScriptTouchHandler(function(eventType, x, y) 
		if eventType =="began" then 
			self:relink()
			return true
		end
	end, false, touch_priority, true)
	self.layer:setTouchEnabled(false)
	
	GTab.IS_UPDATEING = true
end

function UpdateLayer:updateResource()
	self.count 	= 0
	self.sum	= 0
	
    local function checkVersionHandler( needUpdateFileNumber )
		self:createLoadingProgressBar()	
		self.sum 	= needUpdateFileNumber 
		local rate = self.count / self.sum
        self.label:setString(rate .. "%" ) 
    end

    local function stepHandler()
		self.count 	=  self.count + 1
		local rate = tonumber( string.format("%.2f", self.count * 100 / self.sum ) )
        self.label:setString(rate .. "%" ) 
		self.loadingProgresBar:setPercentage( rate )
    end

    local function finishHandler()
    	print("download finish....")
		GTab.IS_UPDATEING = false
		require("start")
    end

    local function errHandler()
		self:showDisconnect()
    end

    require("update/updateInfo"):start(checkVersionHandler, stepHandler, finishHandler, errHandler)
end

local function compareVersion(str1, str2)
	local tab1 = string.split(str1, ".")
	local tab2 = string.split(str2, ".")
	local len1 = #tab1
	local len2 = #tab2
	if len1 ~= len2 then 
		return len1 - len2
	end 
	
	local result = 0
	for i = 1, len1 do
		local v1 = tonumber(tab1[i])
		local v2 = tonumber(tab2[i])
		result = v1 - v2
		if result ~= 0 then 
			return result
		end 
	end 
	return result
end 

function UpdateLayer:showDisconnect()
	local dialog_bg = display.newSprite(self.ProgressBarUrl.dialog_bg)
	dialog_bg:setPosition(display.cx, display.cy)
	local bg_size = dialog_bg:getContentSize()
	self.layer:addChild(dialog_bg)
	local label = ui.newTTFLabel({text = T("您的网络状况不佳，请点击任意地方确定再次进行游戏更新"), align = ui.TEXT_ALIGN_LEFT ,valign = ui.TEXT_ALIGN_CENTER, fontFile = FONT_CFG_1, color = ccc3(234, 230, 196), size=16,  dimensions = CCSize(300, 200), x  = bg_size.width/2 - 150 , y = bg_size.height/2})
	dialog_bg:addChild(label)
	self.layer:setTouchEnabled(true)
	
	if device.platform == "ios" then 
		local version = "1.7.10"
		if compareVersion(GTab.APP_VERSION, version) >= 0 then 
			local label = CCLabelTTF:create(T("了解更多"), "Arial", 30)
			label:setAnchorPoint(ccp(0.5, 0.5))
			label:setPosition(100, 30)
			local menuItem = CCMenuItemImage:create("update/update_btn_blue.png", "update/update_btn_blue.png")
			menuItem:addChild(label)
			menuItem:setScale(0.6)
			menuItem:registerScriptTapHandler(function()
				require("update/updateAlert"):showNetworkHelp(function() 
					self.layer:setTouchEnabled(true) 
				end)
				self.layer:setTouchEnabled(false)
			end )
			local menu = CCMenu:create()
			menu:addChild(menuItem)
			menu:setPosition(450, 30)
			dialog_bg:addChild(menu)
		end 
	end 
end 

function UpdateLayer:relink()
	self.layer:removeAllChildrenWithCleanup(true)
	self.layer:setTouchEnabled(false)
	self:updateResource()
end 


function UpdateLayer:createLoadingProgressBar()
	local download_sprite = display.newSprite(self.ProgressBarUrl.background)
	download_sprite:setPosition( CCPoint( display.cx, progressY ) )
    self:addChild(download_sprite,0)
 
    self.loadingProgresBar = CCProgressTimer:create(display.newSprite(self.ProgressBarUrl.foreground) )
    self.loadingProgresBar:setType(kCCProgressTimerTypeBar)
    self.loadingProgresBar:setMidpoint(ccp(0,1))  
    self.loadingProgresBar:setBarChangeRate(ccp(1, 0))
    self.loadingProgresBar:setPercentage(0)
    self.loadingProgresBar:setPosition(display.cx, progressY )   
    self:addChild(self.loadingProgresBar,1)

	local offset= 132
	local rudderAction= CCRotateBy:create(6, 720)
	local rudder = display.newSprite(self.ProgressBarUrl.rudder_bg)
	rudder:runAction(CCRepeatForever:create(rudderAction))
	rudder:setPosition( display.cx - offset, progressY)
	self:addChild(rudder)
	local compassAction = CCRotateBy:create(20, -720)
	local compass = display.newSprite(self.ProgressBarUrl.rudder)
	compass:setPosition( display.cx - offset, progressY)
	compass:runAction(CCRepeatForever:create(compassAction))
	self:addChild(compass)
end

function UpdateLayer:onEnter()
    self.label = ui.newTTFLabel({text = "", fontFile = FONT_CFG_1,size=16,x  = display.cx, y  = progressY,color = ccc3(255,255,255)})
    self:addChild(self.label,2)
	self:addChild(ui.newTTFLabel({text = T("检查更新..."), align = ui.TEXT_ALIGN_CENTER ,valign = ui.TEXT_ALIGN_CENTER,fontFile = FONT_CFG_1,color = ccc3(255,255,255),size=16,x  = display.cx , y  = progressY-35}))
    self:updateResource()
end

function UpdateLayer:onExit()
	for _, v in pairs(self.ProgressBarUrl) do	
		CCTextureCache:sharedTextureCache():removeTextureForKey(v)
	end
end

return UpdateLayer
