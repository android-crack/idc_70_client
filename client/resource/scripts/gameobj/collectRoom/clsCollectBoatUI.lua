
local MusicInfo=require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ListView = require("ui/tools/ListView")
local BoatInfo = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local CommonFunc = require("gameobj/commonFuns")
local UiWord = require("game_config/ui_word")
local UiCommon = require("ui/tools/UiCommon")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")

require("module/rpcs/rpc_friend")

local BOAT_ATTR_LIST = {
	{name = UiWord.COLLECT_BOAT_RANGE, x = 154, y = 78},
	{name = UiWord.COLLECT_BOAT_REMOTE, x = 304, y = 78},
	{name = UiWord.COLLECT_BOAT_DURABLE, x = 454, y = 78},
	{name = UiWord.COLLECT_BOAT_SPEED, x = 154, y = 50},
	{name= UiWord.COLLECT_BOAT_MELEE, x = 304, y = 50},
	{name = UiWord.COLLECT_BOAT_DEFENSE, x = 454, y = 50},
}

local BOAT_ATTR_VALUE = {
	{name = "range", x = 242, y = 77},
	{name = "remote", x = 392, y = 77},
	{name = "durable", x = 542, y = 77},
	{name= "speed", x = 242, y = 49},
	{name = "melee", x = 392, y = 49},
	{name = "defense", x = 542, y = 49},
}

local attr_val_by_boatid
attr_val_by_boatid = function(id, index)

end

local POLICY = {TYPE_FRIEND = 2, TYPE_SELF = 1}
local boatNameLabelList = {}
local armatureTable = {}

--点击船信息
local getBoatName
getBoatName = function(id, policyType)
	local orgName = BoatInfo[id].orgName
	if orgName then return orgName end
	return BoatInfo[id].name
end

--------------------------------

local addSpriteBottle
addSpriteBottle = function(icon)
	local spriteShipCover = display.newSprite("#collet_ship_bottle.png", 225, 135)
	spriteShipCover:setScale(0.5)
	icon:setContentSize(CCSize(450,270))
	icon:setScale(0.7)
	icon:addChild(spriteShipCover, 10)
end

local addSpriteBoat
addSpriteBoat = function(self, icon, id, isGrey)
	local CompositeEffect= require("gameobj/composite_effect")
	local boatCfg = boat_attr[id]
	if boatCfg ~= nil then
		local name = getBoatName(id, POLICY.playerType)
		local boatNameLabel = createBMFont({text = name, size = 22,fontFile=FONT_MICROHEI_BOLD, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 177, y = 44.5, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
		icon:addChild(boatNameLabel, 20)

		boatNameLabelList[id] = boatNameLabel

		if boatCfg.level >= 60 then
			local lighting = CompositeEffect.new("tx_0027")
			lighting:setPosition(185, 85)
			icon:addChild(lighting, 2)
			local waterGaf = CompositeEffect.new("tx_0026")
			waterGaf:setPosition(190, 124)
			icon:addChild(waterGaf, 0)
		end
		local ship = nil
		local _key = BoatInfo[id].armature
		armatureTable[_key] = "armature/ship/"..BoatInfo[id].armature.."/"..BoatInfo[id].armature..".ExportJson"
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(armatureTable[_key])
		ship = CCArmature:create(_key)
		ship:getAnimation():playByIndex(0)

		local shipScale = 180/ship:getContentSize().height
		ship:setScale(shipScale)
		icon:addChild(ship,1)
		local waterEffect=CompositeEffect.new("tx_3009",250,145,icon)
		waterEffect:setScaleX(0.58)
		waterEffect:setScaleY(0.7)

		if isGrey then
			ship:setOpacity(255*0.4)
		else
			ship:setOpacity(255)
		end
		local shipPos = BoatInfo[id].sEffectPos
		ship:setPosition(shipPos[1], shipPos[2])
	end
	return
end

local addCollectedIcon = function(self, icon)
	local c_icon = display.newSprite("ui/txt/txt_stamp_collect.png")
	c_icon:setPosition(ccp(75, 210))
	icon:addChild(c_icon)
end

local ShipListCell = class("ShipListCell", require("ui/view/clsScrollViewItem"))

ShipListCell.initUI = function(self, data)
	self.parentLayer = data.node
	self.boatIdList = data.list
	self.root_node = display.newNode()
	self.root_node:setZOrder(11000)
end

ShipListCell.updateUI = function(self, data,ui)
	self:setData(data.cellData.data)
end

ShipListCell.setData = function(self, cellData)
	self:removeAllChildrenWithCleanup(true)
	self.cellData = cellData
	local rows, cols = 2, 3
	local rowHeight = 242
	local colWidth = 310
	self.buttons = {}
	local startX = 0
	local y = 288
	local curIndex = 0
	for row = 1, rows do
		local x = startX
		for column = 1, cols do
			curIndex =  (row-1) * 3 + column

			local boatCfg = self.cellData[curIndex]
			if boatCfg ~= nil then
				local boatId = boatCfg.id
				local icon = CCNode:create()
				icon:setPosition(ccp(x, y))
				addSpriteBottle(icon)
				local notGrey = self.boatIdList[boatId]
				addSpriteBoat(self, icon, boatId, not notGrey)
				if notGrey then addCollectedIcon(self, icon) end
				icon.id = boatId
				self:addChild(icon)
				self.buttons[#self.buttons + 1] = icon
				x = x + colWidth
			end
		end
		y = y - rowHeight
	end
end

ShipListCell.onTouchBegan = function(self, x, y)
	self.button = self:checkButton(x, y)
	if self.button then
		self.button:setScale(0.5)
	end
end

ShipListCell.onTouchCancelled = function(self, x, y)
	if self.button then
		self.button:setScale(0.7)
	end
end

ShipListCell.onTap = function(self, x, y)
	-- self.button = self:checkButton(x, y)
	if self.button then
		self.button:setScale(0.7)
		if self.button.id then
			local isGrey = self.boatIdList[self.button.id]
			if POLICY.playerType == POLICY.TYPE_SELF or isGrey then
				audioExt.playEffect(MusicInfo.BOTTLE_ENLARGE.res)

				local data = {}
				data.id = self.button.id
				data.state = isGrey
				data.armatureTable = armatureTable
				data.BOAT_ATTR_LIST = BOAT_ATTR_LIST
				data.BOAT_ATTR_VALUE = BOAT_ATTR_VALUE
				data.getBoatName = getBoatName
				data.POLICY = POLICY
				self.bind_ui_list = self.bind_ui_list or {}
				self.bind_ui_list[#self.bind_ui_list+1] = getUIManager():create("gameobj/collectRoom/clsBoatDetailUI",nil,data)
				-- table.print(self.bind_ui_list)
			else
				Alert:warning({msg = UiWord.BOAT_FRIEND_NOT_GET_BOAT, size = 26})
			end

		end
	end
end

ShipListCell.onUnTap = function(self)
end

ShipListCell.checkButton = function(self, x, y)
	local pos = ccp(x, y)
	for i = 1, #self.buttons do
		local button = self.buttons[i]
		if button:boundingBox():containsPoint(pos) then
			return button
		end
	end
	return nil
end

local ClsCollectBoatUI = class("ClsCollectBoatUI", ClsBaseView)

ClsCollectBoatUI.onEnter = function(self, data)
	resPlist = {
		["ui/collect_ship.plist"] = 1,
	}
	self.bind_ui_list = {}
	LoadPlist(resPlist)
	self.listCellTab = {}

	local playerData = getGameData():getPlayerData()
	local myUid = playerData:getUid()

	local count = 0
	for k,v in pairs(BoatInfo) do
		count = count + 1
	end
	self.boatCount = count

	if data.id == myUid then
		POLICY.playerType = POLICY.TYPE_SELF
		self:getBoatIdList()

		self:initUi(playId)
	else
		POLICY.playerType = POLICY.TYPE_FRIEND
		self:getBoatIdList()
		self:initUi(playId)
	end

	-- self:regEvent()
end

ClsCollectBoatUI.updateView = function(self)
	local rect = CCRect(20, 0, 920, 540)

	local boatInfo = {}
	for k, v in pairs(BoatInfo) do
		if v.collect == 1 then
			table.insert(boatInfo, v)
		end
	end
	local sortFunc = function(a, b) return a.collect_boat < b.collect_boat end
	table.sort(boatInfo, sortFunc)

	local cellDatas = {}
	local cellData = {}
	local index = 0
	for k, v  in pairs(boatInfo) do
		index = index + 1

		local ceilIndex = math.ceil(index / 6)
		local positionIndex = index % 6
		if positionIndex == 0 then
			cellData[6] = v
			cellDatas[ceilIndex] = cellData
			cellData = {}
		else
			cellData[positionIndex] = v
		end

		if index == #boatInfo then
			cellDatas[ceilIndex] = cellData
			cellData = {}
		end
	end

	for pageIndex = 1, #cellDatas do
		local size = CCSize(display.width,rect.size.height)
		local data = {}
		data.list = self.boatIdList
		data.node = self
		data.cellData = {}
		data.cellData.index = pageIndex
		data.cellData.data =cellDatas[pageIndex]
		local cell = ShipListCell.new(size,data,{is_widget = false})
		-- cell:setData()
		self.listCellTab[#self.listCellTab + 1] = cell
	end



	self.list = ClsScrollView.new(920+20,500,false,nil,{is_widget = false})
	self.list:addCells(self.listCellTab)
	self.list:setTouch(true)

	self.list:regTouch(self)
	self.list:setZOrder(1)

	self:addChild(self.list)
end

ClsCollectBoatUI.initUi = function(self, playerUid)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_boat.json")
	self:addWidget(panel)

	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setTouchEnabled(true)
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(function()
		audioExt.playEffect(MusicInfo.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	local amount_label = getConvertChildByName(panel, "tips_num")
	amount_label:setText(self:getBoatCollectAmount())

	self:updateView()
end

ClsCollectBoatUI.getBoatCollectAmount = function(self)
	local count = #getGameData():getFriendDataHandler():getTempFriendShip()
	local amount = 0
	for k, v in pairs(BoatInfo) do
		if v["collect"] == 1 then
			amount = amount + 1 
		end
	end
	return string.format("(%s/%s)", count, amount)
end

--[[
--获取用户所有船
]]
ClsCollectBoatUI.getBoatIdList = function(self)
	self.boatIdList = {}
	-- local collectData = getGameData():getCollectData()

	local FriendDataHandle = getGameData():getFriendDataHandler()
	local boatList = FriendDataHandle:getTempFriendShip()
	boatList = boatList or {}

	for k, v in pairs(boatList) do
		self.boatIdList[v] = true
	end
end


ClsCollectBoatUI.updateBoatName = function(self, id, name)

	local label = boatNameLabelList[id]
	if label == nil then cclog(T("更新船舶名字失败")) return end
	label:setString(name)
end

ClsCollectBoatUI.setTouch = function(self, enable)
	if not tolua.isnull(self.list) then
		self.list:setTouchEnabled(enable)
	end
	if not tolua.isnull(self.menu) then
		self.menu:setEnabled(enable)
	end
end

-- ClsCollectBoatUI.regEvent = function(self)
ClsCollectBoatUI.onExit = function(self)
	UnLoadPlist(resPlist)
	UnLoadArmature(armatureTable)
	RemoveTextureForKey("ui/bg/bg_colloct_shelf.jpg")
	RemoveTextureForKey("ui/txt/txt_stamp_collect.png")
end

return ClsCollectBoatUI
