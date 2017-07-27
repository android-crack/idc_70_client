local UiWord = require("game_config/ui_word")
local BoatInfo = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local MusicInfo=require("game_config/music_info")
-------------------点击显示船舶详细信息-------------------------
local clsBoatDetail = class("clsBoatDetail", require'ui/view/clsBaseView')

function clsBoatDetail:getViewConfig()
	return {
		is_back_bg = true,
	}
end
function clsBoatDetail:onEnter(data)
	local id, isGrey = data.id, data.isGrey
	local armatureTable = data.armatureTable
	local BOAT_ATTR_LIST = data.BOAT_ATTR_LIST
	local BOAT_ATTR_VALUE = data.BOAT_ATTR_VALUE
	local getBoatName = data.getBoatName
	local POLICY = data.POLICY

	local bottle = display.newSprite("#collet_ship_bottle.png", display.cx - 20, display.cy + 55)
	local _key = BoatInfo[id].armature
	armatureTable[_key] = "armature/ship/" .. BoatInfo[id].armature .. "/".. BoatInfo[id].armature..".ExportJson"
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(armatureTable[_key])
	local ship = CCArmature:create(_key)
	ship:getAnimation():playByIndex(0)

	ship:setScale(180*2/ship:getContentSize().height)
	-- self:addChild(ship,1)
	self:addChild(ship)

	if boat_attr[id].level >= 60 then
		-- local lighting = GafFeatures:create("gaf/collect/tx_9014.gaf", true,  function()
		-- 	RemoveTextureForKey("gaf/collect/tx_9014.png")
		-- end)
		-- lighting:setPosition(ccp(-590, -245))
		-- lighting:setScale(2)
		-- self:addChild(lighting, 2)
		-- local waterGaf = GafFeatures:create("gaf/collect/tx_9015.gaf", true,  function()
		-- 	RemoveTextureForKey("gaf/collect/tx_9015.png")
		-- 	end)
		-- waterGaf:setPosition(ccp(-570, -270))
		-- waterGaf:setScale(2)
		-- self:addChild(waterGaf, 0)
		local CompositeEffect= require("gameobj/composite_effect")
		local lighting = CompositeEffect.new("tx_0027")
		lighting:setPosition(360, 238)
		lighting:setScale(2)
		self:addChild(lighting, 0)
		local waterGaf = CompositeEffect.new("tx_0026")
		waterGaf:setPosition(390, 300)
		waterGaf:setScale(2)
		self:addChild(waterGaf, 2)
	end

	local CompositeEffect= require("gameobj/composite_effect")
	local waterEffect=CompositeEffect.new("tx_3009",490,300, self)
	waterEffect:setScaleX(1.1)

	local shipPos = BoatInfo[id].effectPos
	ship:setPosition(shipPos[1], shipPos[2])
	local waterPos= BoatInfo[id].waterPos

	local bottle_bottom = display.newSprite("#collect_ship_bottom.jpg", 356, 55)
	self:addChild(bottle_bottom)
	self:addChild(bottle)

	local explain_bg = display.newSprite("#collect_ship_info.png", 815, 260)
	self:addChild(explain_bg)

	local explain = UiWord.BOAT_MAIN_COLLECT_TIPS --"船舶收集说明"

	explain = BoatInfo[id].explain

	for k,v in pairs(BOAT_ATTR_LIST) do
		local attr_label = createBMFont({text = tostring(v.name),
			fontFile = FONT_CFG_1,
			size = 16,
			color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),
			x = v.x,
			y = v.y
		})
		attr_label:setAnchorPoint(ccp(0, 0.5))
		self:addChild(attr_label)
	end
	for k,v in pairs(BOAT_ATTR_VALUE) do
		self[v.name] = createBMFont({text = "",
			size = 16,
			color = ccc3(dexToColor3B(COLOR_GREEN)),
			x = v.x,
			y = v.y
		})
		self[v.name]:setAnchorPoint(ccp(0, 0.5))
		self:addChild(self[v.name])
	end

	-- 船舶属性值设置
	self.range:setString(boat_attr[id].range)   --火炮射程
	self.speed:setString(boat_attr[id].speed)    --航行速度
	self.remote:setString(boat_attr[id].remote)  --火炮伤害
	self.melee:setString(boat_attr[id].melee)           --近战伤害
	self.durable:setString(boat_attr[id].durable)   --船舶耐久
	self.defense:setString(boat_attr[id].defense) -- 船舶防御

	local label_explain= createBMFont({color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),text = explain, fontFile = FONT_CFG_1,size = 16, x = explain_bg:getContentSize().width/2 + 5, y = 370, width = 255})
	local ship_name = getBoatName(id, POLICY.playerType)
	local labelName=createBMFont({text = ship_name, fontFile = FONT_TITLE, size = 18, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),x =14, y =400})
	labelName:setAnchorPoint(ccp(0,0.5))
	explain_bg:addChild(labelName)

	label_explain:setAnchorPoint(ccp(0.5,1))

	explain_bg:addChild(label_explain)

	-- local btnClose = MyMenuItem.new({image = "#common_btn_close1.png", imageSelected = "#common_btn_close2.png", x = FULL_SCREEN_CLOSEBTN_POS.x, y = FULL_SCREEN_CLOSEBTN_POS.y,sound = MusicInfo.COMMON_CLOSE.res})
	local param = {image = "#common_btn_close1.png", imageSelected = "#common_btn_close2.png", x = FULL_SCREEN_CLOSEBTN_POS.x, y = FULL_SCREEN_CLOSEBTN_POS.y,sound = MusicInfo.COMMON_CLOSE.res}
	local main_ui = getUIManager():get("ClsCollectBoatUI")
	local btnClose = self:createButton(param)
	self:addChild(btnClose)
	btnClose:regCallBack(function()
		self:close()
	end)

	local name = getBoatName(id, POLICY.playerType)
	local boatName=createBMFont({text = name, fontFile = FONT_TITLE, size = 30, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),x = 230, y = 142, width = 266,
		align=ui.TEXT_ALIGN_CENTER})
	boatName:setAnchorPoint(ccp(0,0.5))
	self:addChild(boatName)

end

function clsBoatDetail:bindClose( ... )
	-- print('-------------bindClose-----------')
	self:close()
end

function clsBoatDetail:onTouch()
	self:bindClose()
end

return clsBoatDetail
