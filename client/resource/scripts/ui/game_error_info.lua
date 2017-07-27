local GameErrorInfo = class("GameErrorInfo",function() 
	return CCLayerExtend.extend( CCLayerColor:create( ccc4(20, 20, 20, 100 ),  display.width, display.height ) )
end)


GameErrorInfo.errorMessage = nil
GameErrorInfo.traceback = nil

GameErrorInfo.SCROLL_VIEW_WIDTH = display.width 
GameErrorInfo.SCROLL_VIEW_HEIGHT = display.height
GameErrorInfo.SCROLL_VIEW_OFFSET_X = 100
GameErrorInfo.SCROLL_VIEW_OFFSET_Y = 0
local errCnt = 0
local errTotal = 1
function GameErrorInfo:ctor(errorMessage,traceback)
	if not IS_BUGALERT_OPEN then return end
	if errCnt > errTotal then return end
	GameErrorInfo.errorMessage = errorMessage
	GameErrorInfo.traceback = traceback

	self.uilayer = CCLayer:create()
	self:addChild(self.uilayer)

	self:initLockLayer()
	self:initBtns()
	local curScene = GameUtil.getRunningScene()
	if (not curScene) or tolua.isnull(curScene) then
		return
	end
	self:createScrollView()
	curScene:addChild(self, ZORDER_ERROR_INFO)
	errCnt = errCnt + 1
	
	
    self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)
end

function GameErrorInfo:onExit()
	errCnt = errCnt - 1
end

function GameErrorInfo:createScrollView()
    -- self.scrollview = UIScrollView:create()
    -- self.scrollview:setDirection(SCROLLVIEW_DIR_VERTICAL)
    -- self.scrollview:setSize(CCSizeMake(GameErrorInfo.SCROLL_VIEW_WIDTH , GameErrorInfo.SCROLL_VIEW_HEIGHT))
    -- self.scrollview:setInnerContainerSize(CCSizeMake(GameErrorInfo.SCROLL_VIEW_WIDTH , GameErrorInfo.SCROLL_VIEW_HEIGHT))
    -- self.scrollview:setBounceEnabled(true)
	-- self.uilayer:addWidget(self.scrollview)
    -- display.align(self.scrollview, display.TOP_CENTER)
	-- self.scrollview:setPosition(ccp(display.cx + self.SCROLL_VIEW_OFFSET_X, display.height + self.SCROLL_VIEW_OFFSET_Y))
    
	
    self.lblContent = CCLabelTTF:create()
    self.uilayer:addChild(self.lblContent)
    self.lblContent:setColor(ccc3(255, 255, 255))
    display.align(self.lblContent, display.TOP_LEFT)
    self.lblContent:setPosition(ccp(GameErrorInfo.SCROLL_VIEW_OFFSET_X, self.SCROLL_VIEW_HEIGHT))
    self.lblContent:setFontSize(20)
    self.lblContent:setDimensions(CCSizeMake(GameErrorInfo.SCROLL_VIEW_WIDTH, 0))
	self.lblContent:setString(tostring(GameErrorInfo.errorMessage) .. "\n" .. tostring(GameErrorInfo.traceback))
	
end

function GameErrorInfo:initLockLayer()
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(
		function (eventType,x,y)
			if eventType == "ended" then
				self:onTouchEnded(eventType,x,y)
			else
				return true
			end
		end , false, 0, true)
end
function GameErrorInfo:onTouchEnded(eventType,x,y)
	if eventType == "began" then
		return true
	elseif eventType == "moved" then
		--IGNORE
	elseif eventType == "ended" then
		--IGNORE
	end
end

function GameErrorInfo:onTouchMoved(x, y)
	return true
end

function GameErrorInfo:quitGame()
	self:removeFromParentAndCleanup(true)
	self = nil
end


function GameErrorInfo:initBtns()
	local menuItems = {}

	local quitLabel = CCLabelTTF:create("quit","Arial",25)
	local quitMenuItem = CCMenuItemLabel:create(quitLabel)
	quitMenuItem:setTag(1)
	quitMenuItem:registerScriptTapHandler(handler(self,self.quitGame))
	table.insert(menuItems,quitMenuItem)

	self.btnMenu = ui.newMenu(menuItems)
	self:addChild(self.btnMenu)
	
	self.btnMenu:setPosition(ccp(50,display.cy))
end


function GameErrorInfo:dispose()
	GameErrorInfo.errorMessage = nil
	GameErrorInfo.traceback = nil

	self:disposeLockLayer()
	self:removeFromParentAndCleanup(true)
end


function GameErrorInfo:checkErrorInfo()
	if (GameErrorInfo.errorMessage == nil) and (GameErrorInfo.traceback == nil) then return end
	GameErrorInfo.new(GameErrorInfo.errorMessage,GameErrorInfo.traceback)
end

return GameErrorInfo
