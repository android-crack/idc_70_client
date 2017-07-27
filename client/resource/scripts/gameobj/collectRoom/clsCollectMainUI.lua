--收集界面

local ui_control = require("base.ui.ui_control")
local ui = require("base/ui/ui")
local portButtonEffect = require("gameobj/port/portButtonEffect")
local CompositeEffect= require("gameobj/composite_effect")
local missionGuide = require("gameobj/mission/missionGuide")
local UiCommon = require("ui/tools/UiCommon")
local RelicUI = require("gameobj/relic/collectNewRelicUI")
local on_off_info=require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

------------------------------------- 一些配置 ---------------------------------------
local order = {BG = 1, EFFECT = 2, MASK = 3, FONT = 4 }
local count_format = "%s/%s"          -- 按钮上数目显示的格式         

local res_tab = {
	plist = {
		["ui/collect_room.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
	}
}

local getTabelNum = function(tab, key)     -- (有的表中间是断的，获取不到真正的数目，所以写个循环获取)
	if not tab then return 0 end
	local num = 0
	for k, v in pairs(tab) do
		if key and v[key] == 1 then
			num = num + 1
		end
		if not key then 
			num = num + 1 
		end
	end
	return num
end

local btn_info = {
	btn_boat = {            -- 船舶按钮配置
		index = 1,
		amount_txt = "boat_amount",
		btn_text = ui_word.BOAT_MAIN_NAME,
		count = function() return getTabelNum(getGameData():getFriendDataHandler():getTempFriendShip()) end,    -- 获取拥有数目
		amount = function() return getTabelNum(require("game_config/boat/boat_info"), "collect") end,          -- 获取总数方法
	}, 
	btn_relic = {          -- 遗迹按钮配置
		index = 2,
		amount_txt = "relic_amount",
		btn_text = ui_word.BOAT_RELIC_VIEW_TITLE,
		count = function() return getTabelNum(getGameData():getRelicData():getOpenRelics()) end, 
		amount = function() return getTabelNum(require("game_config/collect/relic_info")) end,
	},
	btn_sailor = {          -- 水手按钮配置
		index = 3,
		amount_txt = "sailor_amount",
		btn_text = ui_word.PORT_SAILOR,
		count = function() return getTabelNum(getGameData():getFriendDataHandler():getTempFriendSailor()) end,  
		amount = function() return getGameData():getCollectData():getCollectSailorNum() end,         
	},
}
------------------------------------------ 配置 END --------------------------------------------

local ClsCollectMainUI = class("ClsCollectMainUI", require('ui/view/clsBaseView'))

ClsCollectMainUI.getViewConfig = function(self)
	return {
		hide_before_view = true,
	}
end

ClsCollectMainUI.onEnter = function(self, data)
	self.player_id = data.id
	self.bg_sea = nil
	self.btn_objs = {}						-- btn_boat, btn_sailor, btn_relic
	self.btn_txts = {}
	self.btn_amount = {}
	self.btn_effects = {}
	self.bg_effects = {}

	self:initUI()
	self:initEffects()
	self:askData()
end

ClsCollectMainUI.initUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_room.json")
	self:addWidget(panel)

	self.bg_sea = getConvertChildByName(panel, "bg_sea")
	self.bg_sea:runAction(self:createBgSeaAction())

	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	for k, v in pairs(btn_info) do
		local btn_obj = getConvertChildByName(panel, k)
		local btn_txt = getConvertChildByName(panel, k.."_text")
		local btn_amount = getConvertChildByName(panel, v.amount_txt)

		btn_obj:setTouchEnabled(false)			-- 数据来了再设置为可用
		btn_obj:setPressedActionEnabled(true)
		btn_obj:addEventListener(function()
			self:onBtnClick(k)
		end, TOUCH_EVENT_ENDED)

		portButtonEffect:playButtonEffect(btn_obj, btn_info[k].index, EFFECT_TYPE.SHORT)
		missionGuide:addGuideLayer(btn_info[k].index, {
			radius = btn_obj:getContentSize().width * 0.5, 
			pos = {x = btn_obj:getPosition().x,  y = btn_obj:getPosition().y}
		}, {layer = self, zorder = 1})

		btn_amount:setText(string.format(0, btn_info[k].amount()))

		self.btn_objs[k] = btn_obj
		self.btn_txts[k] = btn_txt
		self.btn_amount[k] = btn_amount
	end
end

ClsCollectMainUI.initEffects = function(self)
	self.bg_effects.clock = self:createCompositeEffect("tx_3001", 478, 270, self, 90000)

	self.bg_effects.lamp = self:createCompositeEffect("tx_3007", 526, 480, self, 90000)

	--candle lights
	local effectTb = {
		[1] = {x = 530, y = 406},
		[2] = {x = 545, y = 406},
		[3] = {x = 570, y = 406},
		[4] = {x = 582, y = 406},
		[5] = {x = 537, y = 340},
		[6] = {x = 548, y = 343},
		[7] = {x = 565, y = 341},
		[8] = {x = 573, y = 342},
		[9] = {x = 556, y = 428},
	}
	for i,v in ipairs(effectTb) do
		self.bg_effects["cl" .. i] = self:createCompositeEffect("tx_3010", v.x, v.y, self, 0, 0.4, 0.6)
	end

end

-- 请求水手和船舶数据
ClsCollectMainUI.askData = function(self)
	getGameData():getFriendDataHandler():askFriendOwnedBoats(self.player_id)

	self:receiveRelicsData()

	getGameData():getCollectData():askFriendOwnSailors(self.player_id, function()
		self:receiveSailorData()
	end)
end

ClsCollectMainUI.receiveBoatData = function(self)
	self:updateBtnNumber("btn_boat")
end

ClsCollectMainUI.receiveRelicsData = function(self)
	self:updateBtnNumber("btn_relic")
end

ClsCollectMainUI.receiveSailorData = function(self)
	self:updateBtnNumber("btn_sailor")
end

ClsCollectMainUI.updateBtnNumber = function(self, btn_name)
	local btn_obj = self.btn_objs[btn_name]
	local btn_amount = self.btn_amount[btn_name]

	local config = btn_info[btn_name]

	btn_obj:setTouchEnabled(true)
	btn_amount:setText(string.format(count_format, config.count(), config.amount()))
end

ClsCollectMainUI.onBtnClick = function(self, btn_name)
	local closeBtnEffect = function()
		portButtonEffect:closeButtonEffect(btn, false)
		missionGuide:clearGuideLayer()
	end

	if btn_name == "btn_boat" then
		closeBtnEffect()
		return self:onBtnBoatClick()
	end

	if btn_name == "btn_sailor" then 
		closeBtnEffect()
		return self:onBtnSailorClick()
	end

	if btn_name == "btn_relic" then
		return self:onBtnRelicClick(closeBtnEffect)
	end
end

ClsCollectMainUI.onBtnBoatClick = function(self)
	audioExt.playEffect(music_info.UI_FRIE.res)

	local firePanEffect= CompositeEffect.new("tx_3004", 8, 312, self, 1, function()
		getUIManager():create('gameobj/collectRoom/clsCollectBoatUI', nil, {id = self.player_id})
	end, nil, nil, true)

	firePanEffect:setZOrder(order.EFFECT)
end

ClsCollectMainUI.onBtnSailorClick = function(self)
	audioExt.playEffect(music_info.ROOM_BOOK2.res)

	local bookEffect = CompositeEffect.new("tx_3003", 480, 270, self, 1, function()
		getUIManager():create('gameobj/collectRoom/clsCollectSailorUI', nil, {player_id = self.player_id})
	end, nil, nil, true)

	bookEffect:setZOrder(order.EFFECT)
end

ClsCollectMainUI.onBtnRelicClick = function(self, cb_func)
	setRelicUIParentLayer(self)
	createRelicUI(self.player_id, cb_func)
end

ClsCollectMainUI.loadRes = function(self, current, count, func)
	local precent = current / count

	if not tolua.isnull(self._progress) then
		self._progress:setPercentage(precent * 100)
	end
	if not tolua.isnull(self._num) then
		self._num:setString(tostring(toint(precent * 100)) .."%")
	end
	if not tolua.isnull(self.light) then
		self._light:setPosition(display.cx - self.proWidth / 2 + precent * self.proWidth, display.cy * 0.2 + 5)
	end
	if current == count then
		require("gameobj/mainScene")
		if not tolua.isnull(self._light) then
			self._light:removeFromParentAndCleanup()
		end

		if func then
			func()
		end
	end
end

ClsCollectMainUI.createCompositeEffect = function(self, fileName, posX, posY, parent, duration, scaleX, scaleY)
	local effect = CompositeEffect.new(fileName, posX, posY, parent, duration, nil, nil, nil, true)
	if scaleX then
		effect:setScaleX(scaleX)
	end

	if scaleY then
		effect:setScaleY(scaleY)
	end

	effect:setZOrder(order.EFFECT)

	effect:setVisible(true)

	return effect
end

ClsCollectMainUI.createBgSeaAction = function(self)
	local moveStart = CCMoveBy:create(2.5, ccp(0,-12))
	local moveEnd = CCMoveBy:create(2.5, ccp(0,12))
	local seq = CCSequence:createWithTwoActions(moveStart, moveEnd)
	local repf = CCRepeatForever:create(seq)
	return repf
end

ClsCollectMainUI.onExit = function(self)
	for k, v in pairs(self.bg_effects) do
		if not tolua.isnull(v) then
			v:removeTexture()
		end
	end

	local ModulePortLoading = require("gameobj/port/portLoading")
	ModulePortLoading:clearPreloadByName("ClsCollectMainUI")

	ReleaseTexture(self)
end

loadCollectMainUI = function(func)
	local ModulePortLoading = require("gameobj/port/portLoading")
	ModulePortLoading:loading(func, res_tab, "clsCollectMainUI")
end

return ClsCollectMainUI
