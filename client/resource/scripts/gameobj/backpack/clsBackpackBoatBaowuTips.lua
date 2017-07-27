-- 船舶宝物tips
-- Author: chenlurong
-- Date: 2016-07-21 17:53:26
-- 

local music_info=require("scripts/game_config/music_info")
local ui_word = require("game_config/ui_word")
local base_attr_info = require("game_config/base_attr_info")
local baozang_info = require("game_config/collect/baozang_info")
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local dataTools = require("module/dataHandle/dataTools")

local ClsBackpackBoatBaowuTips = class("ClsBackpackBoatBaowuTips", ClsBaseTipsView)

function ClsBackpackBoatBaowuTips:getViewConfig(name_str, params, baowu_data, select_index)
	return ClsBackpackBoatBaowuTips.super.getViewConfig(self, name_str, params, baowu_data, select_index)
end

function ClsBackpackBoatBaowuTips:onEnter(name_str, params, baowu_data, select_index)
	self.select_index = select_index
	self.baowu_data = baowu_data
	self:showTips(name_str, params)
end

--显示数据
function ClsBackpackBoatBaowuTips:showTips(name_str, params)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship_baowu_tips.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	ClsBackpackBoatBaowuTips.super.onEnter(self, name_str, params, self.panel, true)

	self.panel:setPosition(ccp(265, 36))

	self.item_icon_bg = getConvertChildByName(self.panel, "equip_icon_bg")
	self.item_icon = getConvertChildByName(self.panel, "equip_icon")
	self.item_name = getConvertChildByName(self.panel, "name")
	self.property_info = getConvertChildByName(self.panel, "attr_info_1")
	self.property_info2 = getConvertChildByName(self.panel, "attr_info_2")
	self.info_text = getConvertChildByName(self.panel, "info_text")
	self.lv_num = getConvertChildByName(self.panel, "lv_num")
	self.own_num = getConvertChildByName(self.panel, "num_num")

	self.type_info = getConvertChildByName(self.panel, "type_info")
	self.equip_icon_bg_left = getConvertChildByName(self.panel, "equip_icon_bg_left")
	self.equip_icon_left = getConvertChildByName(self.panel, "equip_icon_left")
	self.equip_icon_bg_right = getConvertChildByName(self.panel, "equip_icon_bg_right")
	self.equip_icon_right = getConvertChildByName(self.panel, "equip_icon_right")
	self.item_need_num = getConvertChildByName(self.panel, "item_num")
	self.item_top = getConvertChildByName(self.panel, "item_top")
	self.item_panel = getConvertChildByName(self.panel, "item_panel")
	self.consume_panel = getConvertChildByName(self.panel,"consume_panel")
	self.consume_num = getConvertChildByName(self.panel,"consume_num")
	self.item_tips = getConvertChildByName(self.panel,"item_tips")

	self.btn_synthetic = getConvertChildByName(self.panel, "btn_synthetic")
	self.btn_use = getConvertChildByName(self.panel, "btn_use")

	local onOffData = getGameData():getOnOffData()
    onOffData:pushOpenBtn(on_off_info.SHIPYARD_ZBPAGE.value, {openBtn = self.btn_use, openEnable = true, btn_scale = 0.7, addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBackpackBoatBaowuTips"})

	local baowu_info = self.baowu_data
	local baowu_config = baozang_info[baowu_info.baowuId]
	local item_res = baowu_config.res
	self.item_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.equip_icon_left:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.item_name:setText(baowu_config.name)
	self.info_text:setText(baowu_config.desc)
	self.type_info:setText(baowu_config.kind)

	local quality = baowu_info.step
	setUILabelColor(self.item_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	self.item_icon_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)
	self.equip_icon_bg_left:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)

	if baowu_config.compose_baowu and baowu_config.compose_baowu ~= 0 then--有合成对象
		self.item_need_num:setText("x" .. baowu_config.compose_amount)
		local baowu_data_new = baozang_info[baowu_config.compose_baowu]
		self.equip_icon_right:changeTexture(convertResources(baowu_data_new.res), UI_TEX_TYPE_PLIST)
		local item_bg_res_new = string.format("item_box_%s.png", baowu_data_new.star)
		self.equip_icon_bg_right:changeTexture(item_bg_res_new, UI_TEX_TYPE_PLIST)
		self.item_tips:setText(string.format(ui_word.BAOWU_BOAT_COMPOSE_DESC_TIPS, baowu_config.compose_amount))
		self.item_panel:setVisible(true)
		self.item_top:setVisible(false)	
	else	
		self.item_top:setVisible(true)
		self.item_panel:setVisible(false)
	end

	local partner_data = getGameData():getPartnerData()
	self.select_bag_equip = partner_data:getBagEquipInfo(self.select_index)
	-- self.equip_sailor_id = self.select_bag_equip.id

    self.lv_num:setText(string.format(ui_word.ROOM_SALVALE_TIPS, baowu_config.level))

	self.left_num = baowu_info.amount - baowu_info.upload_amount
	self.own_num:setText(self.left_num)

	local attr_info = baowu_info.attr[1]
	if attr_info then
		local str = dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value)
		self.property_info:setText(base_attr_info[attr_info.name].name .. str)
	else
		self.property_info:setText("")
	end

	local attr_info2 = baowu_info.attr[2]
	if attr_info2 then
		local str = dataTools:getBoatBaowuAttr(attr_info2.name, attr_info2.value)
		self.property_info2:setText(base_attr_info[attr_info2.name].name .. str)
	else
		self.property_info2:setText("")
	end

	--need gold
	local need_gold = baowu_config.compose_consume or 0
	self.consume_panel:setVisible(need_gold > 0)
	self.consume_num:setText(need_gold)

	local player_data = getGameData():getPlayerData()
	if(player_data:getCash() < need_gold)then
		setUILabelColor(self.consume_num, ccc3(dexToColor3B(COLOR_RED)))
	end

	self.btn_synthetic:setPressedActionEnabled(true)
	self.btn_synthetic:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local player_info = getGameData():getPlayerData()
		if baowu_config.compose_baowu and baowu_config.compose_baowu == 0 then--有合成对象
			Alert:warning({msg = ui_word.BAOWU_BOAT_COMPOSE_MAX_TIPS})
		elseif player_info:getLevel() < baowu_config.compose_level then
			Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_LEVEL_STR, baowu_config.compose_level)})	
		elseif self.left_num < baowu_config.compose_amount then
			Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_NEED_STR, baowu_config.compose_amount)})
		elseif player_data:getCash() < need_gold then --加金币判断	
			Alert:warning({msg = ui_word.BAOWU_BOAT_COMPOSE_GOLD_TIPS})
			return
		else
			local baowu_data = getGameData():getBaowuData()
			baowu_data:askComposeBoatBaowu(baowu_info.baowuId)
		end
		self:close()
    end,TOUCH_EVENT_ENDED)

	self.btn_use:setPressedActionEnabled(true)
	self.btn_use:addEventListener(function()
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	    if ClsSceneManage:doLogic("checkAlert") then return end
		
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()

		if isExplore then
	        local port_info = require("game_config/port/port_info")
	        local portData = getGameData():getPortData()
	        local portName = port_info[portData:getPortId()].name
	        local tips = require("game_config/tips")
	        local str = string.format(tips[77].msg, portName)
	        Alert:showAttention(str, function()
					---回港
					if getGameData():getTeamData():isLock() then
		            	Alert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
		                return
		            end
					portData:setEnterPortCallBack(function() 
						getUIManager():create("gameobj/backpack/clsBackpackMainUI")
					end)
					portData:askBackEnterPort()

	        end, nil, nil, {hide_cancel_btn = true})	
	    else
			self:useItemOperate()
		end

    end,TOUCH_EVENT_ENDED)
end

function ClsBackpackBoatBaowuTips:useItemOperate()
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local skip_layer = missionSkipLayer:skipLayerByName("backpack_boat_equip", nil)
end

return ClsBackpackBoatBaowuTips