-- 断线重登陆/连接界面 this is a ui obj

local ui_word = require("game_config/ui_word")
local UiCommon = require("ui/tools/UiCommon")

----------------------------UI------------------------------
local function newUILayer()
	return CCLayer:create()
end

local LoginRelinkUI = class("LoginRelinkUI", newUILayer)

function LoginRelinkUI:ctor(scene)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if not runningScene then return end

	LoadPlist({
	})

	local function __onTouch(eventType, x, y)
		if eventType == "began" then
			if not tolua.isnull(self.dlgLinking) then
				if self.dlgLinking:isVisible() then
					if self.dlgLinking:getOpacity() < 1 then --如果是在这个东东在隐藏状态的时候，不要把触摸吃掉
						return false
					end
				end
			end
			return true
		end
	end

	self:setZOrder(TOPEST_ZORDER)
	self:registerScriptTouchHandler(__onTouch, false, TOUCH_PRIORITY_RPCTIPS, true)
	self:setTouchEnabled(true)

	runningScene:addChild(self)
end


function LoginRelinkUI:__mkBtn(reLinkCB, backLoginCB, hide_again)
	local btn_again = MyMenuItem.new({image = UI_RES.RES_COM_BLUEWIDE_BTN_1, imageSelected = UI_RES.RES_COM_BLUEWIDE_BTN_2, x = 155, y = 50,
		text = ui_word.ONCE_AGAIN, fsize = 16, fontFile = FONT_BUTTON, scale= SMALL_BUTTON_SCALE, fcolor = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	btn_again:regCallBack(reLinkCB)
	
	local btn_back = MyMenuItem.new({image = UI_RES.RES_COM_BLUEWIDE_BTN_1, imageSelected = UI_RES.RES_COM_BLUEWIDE_BTN_2, x = 315, y = 50,
		text = ui_word.BACK_LOGIN, fsize = 16, scale= SMALL_BUTTON_SCALE, fontFile = FONT_BUTTON,fcolor = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	btn_back:regCallBack(backLoginCB)
	
	if hide_again then
		btn_again:setVisible(false)
		btn_back:setPosition(ccp(235, 50))
	end

	return MyMenu.new({btn_again, btn_back}, TOUCH_PRIORITY_RPCTIPS-1)
end

function LoginRelinkUI:__mkDailog(text, dialogItem, lbx, lby)
	local des_lb_width = 430
	local relinkDailog = {text = "", size = 16, x = 260, y = 130}
	relinkDailog.text = text
	relinkDailog.fontFile = FONT_CFG_1
	relinkDailog.color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))
	local dialog = getChangeFormatSprite("ui/bg/bg_award.png")
	local labelDes = createBMFont(relinkDailog)
	if lbx and lby then
		labelDes:setPosition(lbx, lby)
	else
		if labelDes:getContentSize().width > des_lb_width then
			relinkDailog.width = des_lb_width
			labelDes = createBMFont(relinkDailog)
		end
		labelDes:setPosition(dialog:getContentSize().width/2, dialog:getContentSize().height/2 + 30)
	end

	dialog:setPosition(display.cx, display.cy)
	dialog:addChild(dialogItem)
	dialog:addChild(labelDes)
	self:addChild(dialog)
	dialog.label = labelDes

	return dialog
end

function LoginRelinkUI:hide()
	self:clearWaitingScheduler()

	if not tolua.isnull(self.dlgRelink) then
		self.dlgRelink:setVisible(false)
	end

	if not tolua.isnull(self.dlgReLogin) then
		self.dlgReLogin:setVisible(false)
	end

	if not tolua.isnull(self.dlgLinking) then
		self.dlgLinking:setVisible(false)
		self.dlgLinking:stopAllActions()
	end

	if not tolua.isnull(self.dlgwaitingLogin) then
		self.dlgwaitingLogin:setVisible(false)
	end

	if not tolua.isnull(self.dlgParseWait) then
		self.dlgParseWait:setVisible(false)
	end

	if not tolua.isnull(self) then
		self:setTouchEnabled(false)
	end
end

function LoginRelinkUI:removeSomeView()
	local dialogQuene = require("gameobj/quene/clsDialogQuene")
	dialogQuene:resetQuene()
end

local function reLinkCB()
	local start_and_login_data = getGameData():getStartAndLoginData()
	start_and_login_data:setConnectClickCount()
	local module_game_rpc = require("module/gameRpc")
	--module_game_rpc.closeSocket()
	module_game_rpc.linkSocket()
end


local function backLoginCB()
	require("module/gameRpc").reStartGame()
end

function LoginRelinkUI:mkReLoginDialog(callBack, tips_str, hide_again)
	self:removeSomeView()

	local lootDataHandle = getGameData():getLootData()
	if lootDataHandle.isLootedding then return end

	self:hide()
	self:setTouchEnabled(true)
	if not tolua.isnull(self.dlgReLogin) then
		self.dlgReLogin:setVisible(true)
		return
	end
	local contect_str = tips_str or ui_word.LOGIN_RELINK_SERVER_FAILE
	local menu = self:__mkBtn(reLinkCB, backLoginCB, hide_again)
	print("------------------重登------------------------")
	self.dlgReLogin = self:__mkDailog(contect_str, menu)
end

function LoginRelinkUI:mkLinkingDialog(is_time_out)
	--圆形进度条
	self:removeSomeView()
	cclog("Show link wait dialog.")
	self:hide()
	self:setTouchEnabled(true)
	if self.dlgLinking and not tolua.isnull(self.dlgLinking) then
		self.dlgLinking:setVisible(true)
	else
		local rdx, rdy = 170, 110
		local lbx, lby = 320, 110
		local uiAni = UiCommon:mkLoadingRudder(rdx, rdy)
		self.dlgLinking = self:__mkDailog(ui_word.LOGIN_RELINK_LOADING, uiAni, lbx, lby)
		self.dlgLinking.eff_spr = uiAni
		self.dlgLinking:setCascadeOpacityEnabled(true)
	end
	self.dlgLinking:stopAllActions()

	print("------------------重连------------------------")
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(3))
	arr:addObject(CCCallFunc:create(function()
			self.dlgLinking:setOpacity(255)
		end))
	if is_time_out then
		arr:addObject(CCDelayTime:create(5))
		arr:addObject(CCCallFunc:create(function()
				self:mkReLoginDialog()
			end))
	end
	self.dlgLinking:runAction(CCSequence:create(arr))
	self.dlgLinking:setOpacity(0)
end

function LoginRelinkUI:mkWaitingLoginDialog(left_time)
	self:removeSomeView()

	self:hide()
	self:setTouchEnabled(true)
	self.left_time = left_time
	local contect_str = string.format(ui_word.LOGIN_WAITING_LOGIN_TIPS, self.left_time)
	self.dlgWaitingScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			if self.left_time <= 0 then
				self:hide()
				local login_layer = getUIManager():get("LoginLayer")
				if login_layer and not tolua.isnull(login_layer) then
					login_layer:setViewTouchEnabled(true)
				end
			end
			self.left_time = self.left_time - 1
			if not tolua.isnull(self.dlgwaitingLogin) then
				self.dlgwaitingLogin.label:setString(string.format(ui_word.LOGIN_WAITING_LOGIN_TIPS, self.left_time))
			end
		end, 1, false)

	if not tolua.isnull(self.dlgwaitingLogin) then
		self.dlgwaitingLogin:setVisible(true)
		return
	end
	local btn_sure = MyMenuItem.new({image = UI_RES.RES_COM_BLUEWIDE_BTN_1, imageSelected = UI_RES.RES_COM_BLUEWIDE_BTN_2, x = 235, y = 50,
		text = ui_word.MAIN_OK, fsize = 16, fontFile = FONT_BUTTON, scale= SMALL_BUTTON_SCALE, fcolor = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	btn_sure:regCallBack(function()
		self:hide()
	end)
	local menu = MyMenu.new({btn_sure}, TOUCH_PRIORITY_RPCTIPS-1)
	print("------------------等待冷却------------------------")
	self.dlgwaitingLogin = self:__mkDailog(contect_str, menu)
end

function LoginRelinkUI:mkParseWaitDialog()
	self:removeSomeView()

	self:hide()
	self:setTouchEnabled(true)

	print("------------------连接socket后解析中------------------------")
	if not tolua.isnull(self.dlgParseWait) then
		self.dlgParseWait:setVisible(true)
		return
	end
	local rdx, rdy = 170, 110
	local lbx, lby = 320, 110
	local uiAni = UiCommon:mkLoadingRudder(rdx, rdy)
	self.dlgParseWait = self:__mkDailog(ui_word.LOGIN_FILE_PARSE_WAIT_TIPS, uiAni, lbx, lby)
	self.dlgParseWait.eff_spr = uiAni
end

function LoginRelinkUI:clearWaitingScheduler()
	if self.dlgWaitingScheduler then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.dlgWaitingScheduler)
		self.dlgWaitingScheduler = nil
	end
end

local uiObj = nil

function LoginRelinkUI:maintainObj(scene)
	if not tolua.isnull(uiObj) then 
		uiObj:removeFromParentAndCleanup(true)
	end 
	uiObj = LoginRelinkUI.new(scene)

	return uiObj
end

function LoginRelinkUI:getCurUIObj()
	return uiObj
end 


return LoginRelinkUI