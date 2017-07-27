
---fmy0570
---爵位提升特效
local CompositeEffect = require("gameobj/composite_effect")
local nobility_data = require("game_config/nobility_data")
local UiCommon = require("ui/tools/UiCommon")
local ClsDataTools = require("module/dataHandle/dataTools")
local uiTools = require("gameobj/uiTools")
local music_info=require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()
local ClsNobilityUpLevelEffect = class('ClsNobilityUpLevelEffect', require('ui/view/clsBaseView'))

function ClsNobilityUpLevelEffect:getViewConfig()
	return {
		is_back_bg = true
	}
	
end

function ClsNobilityUpLevelEffect:onEnter(call_back)
	self.plist = {
		["ui/cityhall_ui.plist"] = 1,
	}
	LoadPlist(self.plist)
	self.callBack = call_back
	self:regTouchEvent(self, function(event, x, y)
	return self:onTouch(event, x, y) end)

	self:initUI()
end


function ClsNobilityUpLevelEffect:initUI()

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/cityhall_up_build_boat.json")
	self:addWidget(self.panel)

	self.ship_panel = getConvertChildByName(self.panel, "ship_panel")
	self.boat_name = getConvertChildByName(self.panel, "boat_name")
	local arrow = getConvertChildByName(self.panel, "arrow")
	arrow:setVisible(false)


	local nobility_id = getGameData():getNobilityData():getCurrentNobilityData().next
	--local shipData = getGameData():getShipData()
	--local ship_name = shipData:getNobilityBoatName(nobility_id)
	

	local player_data = getGameData():getPlayerData()
	local boat_id = nobility_data[nobility_id].boat_ids[player_data:getProfession()]

	local ship_name = boat_info[boat_id].name
	self.ship_name = ship_name

	self.boat_name:setText(ship_name)

	self:showArmatureBoat(boat_id,self.ship_panel)
	self:playNobilityLevelUpEffect()
end


function ClsNobilityUpLevelEffect:showArmatureBoat(boat_id, node)

	local boat_config = ClsDataTools:getBoat(boat_id)
	self.boat_res = boat_config.res
	local res_armature = string.format("armature/ship/%s/%s.ExportJson", boat_config.effect, boat_config.effect)
	armature_manager:addArmatureFileInfo(res_armature)	
	self.ship_show_sprite = CCArmature:create(boat_config.effect)
	self.ship_show_sprite:getAnimation():playByIndex(0)
	node:addCCNode(self.ship_show_sprite)

	self.ship_show_sprite:setScale(0.4)
	-- local set_opacity = 255
	-- self.ship_show_sprite:setOpacity(set_opacity)
	self.ship_show_sprite:setPosition(boat_config.boatPos[1] +90, boat_config.boatPos[2] + 65)
end


function ClsNobilityUpLevelEffect:playNobilityLevelUpEffect(  )
	-- 声望提升特效节点
	self.node_effect_prestige = UIWidget:create()
	self:addWidget(self.node_effect_prestige)


	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function (  )
		CompositeEffect.new("tx_txt_rank_up", display.cx - 15 , display.cy*2+150, self)
	end))
	array:addObject(CCDelayTime:create(0.6))
	array:addObject(CCCallFunc:create(function (  )
		self:playPrestigeEffect()		
	end))
	self:runAction(CCSequence:create(array))

end

function ClsNobilityUpLevelEffect:playPrestigeEffect()
	local function callback( )
		-- print(debug.traceback())
		-- print(' ------------------- callback 声望')
	end
	local end_num = getGameData():getPlayerData():getBattlePower()
	--print("============================升级后的声望",end_num)
	--local start_num = self.start_power
	local show_time = 2

	-- 只显示增加的声望值
	local effect_ui = self:createPrestigeEffectUI(end_num, 0, show_time, callback)
	local pos = ccp(display.cx-250, display.cy-320)

	local effect_layer = UIWidget:create()
	effect_layer:setPosition(pos)
	effect_layer:addChild(effect_ui)
	effect_layer:setScale(0.7)

	local wgt = self.node_effect_prestige
	wgt:removeAllChildren()
	wgt:addChild(effect_layer)
end


function ClsNobilityUpLevelEffect:createPrestigeEffectUI(value,start_num, show_time, call_back)
	local layer = UIWidget:create()
	local effect_layer = UIWidget:create()
	local start_number = start_num or 0
	local label_zhandouli = createBMFont({text = start_number, size = 20, color = ccc3(dexToColor3B(COLOR_YELLOW_STROKE)), fontFile = FONT_NUM_COMBAT})
	local label_pic

	-- 只显示增加的声望.不显示总声望
	if start_num then
		label_pic = display.newSprite("ui/txt/txt_prestige_total_1.png")
	else
		label_pic = getChangeFormatSprite("ui/txt/txt_get_force.png")
	end

	label_pic:setScale(0.6)
	layer:addChild(effect_layer)
	audioExt.playEffect(music_info.PRESTIGE_RAISE.res)

	local effect_node = CompositeEffect.new("tx_0184_stop", display.cx, display.cy, effect_layer, nil, nil, nil, nil, true)
	local pos_x,pos_y = display.cx ,display.cy

	local array_action = CCArray:create()
	array_action:addObject(CCDelayTime:create(0.6))
	array_action:addObject(CCCallFunc:create(function (  )
		label_zhandouli:setPosition(ccp(pos_x+480, pos_y-25))
	end) )

	layer:addCCNode(label_zhandouli)
	layer:addCCNode(label_pic)

	array_action:addObject(CCMoveTo:create(0.3, ccp(500,pos_y-25)))
	array_action:addObject(CCDelayTime:create(0.2))
	array_action:addObject(CCCallFunc:create(function ()
		UiCommon:numberEffect(label_zhandouli, start_number or 0, value, 30)
	end) )

	label_zhandouli:runAction(CCSequence:create(array_action))


	local array_action_pic = CCArray:create()
	array_action_pic:addObject(CCDelayTime:create(0.6))
	array_action_pic:addObject(CCCallFunc:create(function ()
		label_pic:setPosition(ccp(pos_x-370, 288))
	end))

	array_action_pic:addObject(CCMoveTo:create(0.3, ccp(402, 288)))


	label_pic:runAction(CCSequence:create(array_action_pic))

	local function callBack()
		if type(call_back) == "function" then
			call_back()
			--self:close()
		end
	end


	local array_action = CCArray:create()
	array_action:addObject(CCDelayTime:create(show_time or 3))
	array_action:addObject(CCCallFunc:create(function ()
		callBack()
	end))
	layer:runAction(CCSequence:create(array_action))


	layer.touchCallBack = function()
		callBack()
	end

	layer.close = callBack


	layer.onExit = function(layer)
		--self:close()
	end
	return layer
end


function ClsNobilityUpLevelEffect:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsNobilityUpLevelEffect:onTouchBegan(x , y)
	--self.callBack()
	self:getBoatEffect()
	self.callBack()
	self:close()
	return false
end

function ClsNobilityUpLevelEffect:getBoatEffect(  )
	local call_back = function (  )	
	end
	local boat_res = self.boat_res
	local name = self.ship_name
	local pos = ccp(60,230)

	local clsNobilityUI = getUIManager():get("clsNobilityUI")
	if not tolua.isnull(clsNobilityUI) then
	    uiTools:showGetRewardEfffect(clsNobilityUI, call_back, boat_res, nil,
	    ccp(display.cx, display.cy), pos, name, true)

	end
end


function ClsNobilityUpLevelEffect:onExit()
	UnLoadPlist(self.plist)
	self.callBack()
end

return ClsNobilityUpLevelEffect