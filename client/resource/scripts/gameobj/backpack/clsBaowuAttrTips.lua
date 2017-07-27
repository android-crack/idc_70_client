-- 水手宝物tips
-- Author: chenlurong
-- Date: 2016-07-04 17:40:57
--
local music_info=require("scripts/game_config/music_info")
local boat_attr = require("game_config/boat/boat_attr")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local baozang_info = require("game_config/collect/baozang_info")
local baowu_dismantling = require("game_config/collect/baowu_dismantling")
local base_attr_info = require("game_config/base_attr_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsBaowuAttrTips = class("ClsBaowuAttrTips", ClsBaseTipsView)

local NEED_ALERT_QUALITY = 4
function ClsBaowuAttrTips:getViewConfig(name_str, params, select_index, baowu_data, from_backpack)
	return ClsBaowuAttrTips.super.getViewConfig(self, name_str, params, select_index, baowu_data, from_backpack)
end

function ClsBaowuAttrTips:onEnter(name_str, params, select_index, baowu_data, from_backpack)
	self.select_index = select_index
	self.baowu_data = baowu_data
	self.baowu_attr_num = 2
	self.wash_attr_num = 4

	if from_backpack then--背包点击的船
		self:showBackpackBoatTips(name_str, params)
	else
		self:showEquipBoatTips(name_str, params)
	end
end

function ClsBaowuAttrTips:setViewEnabled()
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:setViewTouchEnabled(false)
	end

	local clsFleetPartner = getUIManager():get("ClsFleetPartner")
	if not tolua.isnull(clsFleetPartner) then 
		clsFleetPartner:setViewTouchEnabled(false)
	end
end

--显示装备宝物的数据
function ClsBaowuAttrTips:showEquipBoatTips(name_str, params)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_details.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	ClsBaowuAttrTips.super.onEnter(self, name_str, params, self.panel, true)

	self.baowu_icon = getConvertChildByName(self.panel, "baowu_icon")
	self.baowu_name = getConvertChildByName(self.panel, "ship_name")
	self.level_info = getConvertChildByName(self.panel, "level_info")
	self.attr_info = getConvertChildByName(self.panel, "attr_info")

	self.btn_download = getConvertChildByName(self.panel, "btn_discharge")
	self.btn_wash = getConvertChildByName(self.panel, "btn_dismantling")
	self.btn_wash_text = getConvertChildByName(self.panel,"btn_dismantling_text")

	self.attr_text_1 = getConvertChildByName(self.panel, "attr_text_1")
	self.attr_num_1 = getConvertChildByName(self.panel, "attr_num_1")
	self.attr_text_2 = getConvertChildByName(self.panel, "attr_text_2")
	self.attr_num_2 = getConvertChildByName(self.panel, "attr_num_2")

	self.power_num = getConvertChildByName(self.panel,"power_num") --宝物声望
	
	local baowu_info = baozang_info[self.baowu_data.baowuId]
	self.baowu_icon:changeTexture(convertResources(baowu_info.res), UI_TEX_TYPE_PLIST)
	self.baowu_name:setText(baowu_info.name)
    setUILabelColor(self.baowu_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[self.baowu_data.color])))

    self.level_info:setText(baowu_info.limitLevel)
    self.attr_info:setText(baowu_info.kind)

	for i=1,self.baowu_attr_num do
		local attr = self.baowu_data.attr[i]
		local attr_text = self["attr_text_" .. i]
		local attr_num = self["attr_num_" .. i]
		if attr then
			attr_text:setText(base_attr_info[attr.name].name)
			attr_num:setText("  " .. attr.value)
		else
			attr_text:setText("")
			attr_num:setText("")
		end
	end

	-- print("==========================================self.baowu_data")
	-- table.print(self.baowu_data)
	local partner_data = getGameData():getPartnerData()
	self.select_bag_equip = partner_data:getBagEquipInfo(self.select_index)

	local baowu_index = nil
	for i,v in ipairs(self.select_bag_equip.partnerBaowu) do
		if v == self.baowu_data.baowuKey then
			baowu_index = i
		end
	end

	self.power_num:setText(self.select_bag_equip.baowuPower[baowu_index])

	-- print("==========================================self.select_bag_equip")
	-- table.print(self.select_bag_equip)

	local refine_attr = {}
	local is_Surmount = 0
	for k,v in pairs(self.select_bag_equip.refineAttr) do
		if v.index == baowu_index then
			refine_attr = v.refine
			is_Surmount = v.isSurmount or 0
		end
	end

	self.wash_attr_list = {}
	for i=1,self.wash_attr_num do
		local wash_attr = {}
		wash_attr.attr = getConvertChildByName(self.panel, "wash_attribute_txt" .. i)
		self.wash_attr_list[i] = wash_attr

		local attr_info = refine_attr[i]
		if attr_info then
			wash_attr.attr:setText(base_attr_info[attr_info.attr].name .. ClsDataTools:getBaowuSpecialAttr(attr_info.attr, attr_info.value))
		    setUILabelColor(wash_attr.attr, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[attr_info.color])))
		else
			wash_attr.attr:setText("")
		end
	end

	--突破
	if(is_Surmount == 1)then
		self.btn_wash_text:setText(ui_word.BAOWU_TUPO_TIPS)
	end

	self.btn_download:setPressedActionEnabled(true)
	self.btn_download:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local partner_data = getGameData():getPartnerData()
		self:setViewEnabled()
		partner_data:askPartnerDownloadBaowu(self.select_index, self.baowu_data.baowuKey)
		self:close()
    end,TOUCH_EVENT_ENDED)

	self.btn_wash:setPressedActionEnabled(true)
	self.btn_wash:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		-- self:isExploreAlert(function()
			self:close()
			getUIManager():create("gameobj/backpack/clsBaowuRefineUI", nil, self.select_index, self.baowu_data.baowuKey)
		-- end)
    end,TOUCH_EVENT_ENDED)

    local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.TREASURE_WASH.value, {openBtn = self.btn_wash, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBaowuAttrTips"})	

	ClsGuideMgr:tryGuide("ClsBaowuAttrTips")
end

--显示背包宝物的tips
function ClsBaowuAttrTips:showBackpackBoatTips(name_str, params)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_info.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	ClsBaowuAttrTips.super.onEnter(self, name_str, params, self.panel, true)

	self.baowu_level_right = getConvertChildByName(self.panel, "baowu_level_r")
	self.baowu_icon_right = getConvertChildByName(self.panel, "baowu_icon_r")
	self.baowu_name_right = getConvertChildByName(self.panel, "ship_name_r")
	self.level_info_right = getConvertChildByName(self.panel, "level_info_r")
	self.attr_info_right = getConvertChildByName(self.panel, "attr_info_r")

	self.attr_text_right_1 = getConvertChildByName(self.panel, "attr_text_1_r")
	self.attr_value_right_1 = getConvertChildByName(self.panel, "attr_num_1_r")
	self.attr_arrow_right_1 = getConvertChildByName(self.panel, "arrow_attr_1")
	self.attr_text_right_2 = getConvertChildByName(self.panel, "attr_text_2_r")
	self.attr_value_right_2 = getConvertChildByName(self.panel, "attr_num_2_r")
	self.attr_arrow_right_2 = getConvertChildByName(self.panel, "arrow_attr_2")

	self.power_num_right = getConvertChildByName(self.panel,"power_num_r")

	self.wash_attr_right = {}
	for i=1,self.wash_attr_num do
		local wash_attr = {}
		wash_attr.attr = getConvertChildByName(self.panel, "wash_attribute_txt_r" .. i)
		wash_attr.attr:setText("")
		self.wash_attr_right[i] = wash_attr
	end

	self.btn_upload = getConvertChildByName(self.panel, "btn_change")
	self.btn_dismantling = getConvertChildByName(self.panel, "btn_dismantling")

	ClsGuideMgr:tryGuide("ClsBaowuAttrTips") 

	local baowu_info = baozang_info[self.baowu_data.baowuId]
	self.baowu_icon_right:changeTexture(convertResources(baowu_info.res), UI_TEX_TYPE_PLIST)
	self.baowu_name_right:setText(baowu_info.name)
    setUILabelColor(self.baowu_name_right, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[self.baowu_data.color])))
	
	local partner_data = getGameData():getPartnerData()
	self.select_bag_equip = partner_data:getBagEquipInfo(self.select_index)
	self.equip_sailor_id = self.select_bag_equip.id

    self.level_info_right:setText(baowu_info.limitLevel)
    self.power_num_right:setText(self.baowu_data.power)

    local player_data = getGameData():getPlayerData()
	local cur_level = player_data:getLevel()
	if cur_level < baowu_info.limitLevel then
		setUILabelColor(self.level_info_right, ccc3(dexToColor3B(COLOR_RED)))
	end
    local is_baowu_better = cur_level <= baowu_info.limitLevel

    self.attr_info_right:setText(baowu_info.kind)

	-- print("==========================================self.self.baowu_data")
	-- table.print(self.baowu_data)

	for i=1,self.baowu_attr_num do
		local attr = self.baowu_data.attr[i]
		local attr_text = self["attr_text_right_" .. i]
		local attr_num = self["attr_value_right_" .. i]
		local attr_arrow = self["attr_arrow_right_" .. i]
		attr_arrow:setVisible(false)
		if attr then
			attr_text:setText(base_attr_info[attr.name].name)
			attr_num:setText("  " .. attr.value)
		else
			attr_text:setText("")
			attr_num:setText("")
		end
	end

	local baowu_data = getGameData():getBaowuData()
	local equip_baowu_id
	local equip_baowu_index
	for i,v in ipairs(self.select_bag_equip.partnerBaowu) do
		if string.len(v) > 0 then
			local partner_baowu_info = baowu_data:getInfoById(v)
			if baozang_info[partner_baowu_info.baowuId].type == baowu_info.type then
				equip_baowu_id = v
				equip_baowu_index = i
			end
		end
	end

	-- print("==========================================self.select_bag_equip")
	-- table.print(self.select_bag_equip)

	-- 左侧同类型宝物信息显示
	if equip_baowu_id then--显示对比状态
		self.baowu_level_left = getConvertChildByName(self.panel, "baowu_level_l")
		self.baowu_icon_left = getConvertChildByName(self.panel, "baowu_icon_l")
		self.baowu_name_left = getConvertChildByName(self.panel, "ship_name_l")
		self.level_info_left = getConvertChildByName(self.panel, "level_info_l")
		self.attr_info_left = getConvertChildByName(self.panel, "attr_info_l")

		self.attr_text_left_1 = getConvertChildByName(self.panel, "attr_text_1_l")
		self.attr_value_left_1 = getConvertChildByName(self.panel, "attr_num_1_l")
		self.attr_text_left_2 = getConvertChildByName(self.panel, "attr_text_2_l")
		self.attr_value_left_2 = getConvertChildByName(self.panel, "attr_num_2_l")

		self.power_num_left = getConvertChildByName(self.panel,"power_num_l") --左侧战斗力

		local refine_attr = {}
		for i,v in pairs(self.select_bag_equip.refineAttr) do
			if v.index == equip_baowu_index then
				refine_attr = v.refine
			end
		end

		self.wash_attr_left = {}
		for i=1,self.wash_attr_num do
			local wash_attr_left = {}
			wash_attr_left.attr = getConvertChildByName(self.panel, "wash_attribute_txt" .. i)
			self.wash_attr_left[i] = wash_attr_left

			local right_wash_attr = self.wash_attr_right[i]

			local attr_info = refine_attr[i]
			if attr_info then
				right_wash_attr.attr:setText(base_attr_info[attr_info.attr].name .. ClsDataTools:getBaowuSpecialAttr(attr_info.attr, attr_info.value))
			    setUILabelColor(right_wash_attr.attr, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[attr_info.color])))
				wash_attr_left.attr:setText(base_attr_info[attr_info.attr].name .. ClsDataTools:getBaowuSpecialAttr(attr_info.attr, attr_info.value))
			    setUILabelColor(wash_attr_left.attr, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[attr_info.color])))
			else
				right_wash_attr.attr:setText("")
				wash_attr_left.attr:setText("")
			end
		end

		local baowu_left = baowu_data:getInfoById(equip_baowu_id)
		local baowu_info_left = baozang_info[baowu_left.baowuId]
		self.baowu_icon_left:changeTexture(convertResources(baowu_info_left.res), UI_TEX_TYPE_PLIST)
		self.baowu_name_left:setText(baowu_info_left.name)
	    setUILabelColor(self.baowu_name_left, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[baowu_left.color])))

	    self.level_info_left:setText(baowu_info_left.limitLevel)
	    self.attr_info_left:setText(baowu_info_left.kind)
	    self.power_num_left:setText(baowu_left.power)
    
	    local function changeCompareTag(target, cur_value, equip_value)
			local down_campare_res = "common_arrow_down.png"
			if cur_value ~= equip_value then
				target:setVisible(true)
				if cur_value < equip_value then
					target:changeTexture(down_campare_res, UI_TEX_TYPE_PLIST)
				end
			else
				target:setVisible(false)
			end
		end

	    for i=1,self.baowu_attr_num do
			local attr_left = baowu_left.attr[i]
			local attr_text = self["attr_text_left_" .. i]
			local attr_num = self["attr_value_left_" .. i]
			if attr_left then
				attr_text:setText(base_attr_info[attr_left.name].name)
				attr_num:setText("  " .. attr_left.value)

				local attr_right = self.baowu_data.attr[i]
				if attr_left.name == attr_right.name then
					local attr_arrow = self["attr_arrow_right_" .. i]
					changeCompareTag(attr_arrow, attr_right.value, attr_left.value)
				end
			else
				attr_text:setText("")
				attr_num:setText("")
			end
		end
	else
		self.bg_left = getConvertChildByName(self.panel, "bg_l")
		self.bg_left:setVisible(false)
		self.attr_arrow_right_1:setVisible(false)
		self.attr_arrow_right_2:setVisible(false)
	end

	self.btn_dismantling:setPressedActionEnabled(true)
	self.btn_dismantling:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
		if is_baowu_better and self.baowu_data.color >= NEED_ALERT_QUALITY then
			local dismantling_reward = self:getDismantlingReward(baowu_info.star, self.baowu_data.color)
			getUIManager():create("gameobj/backpack/clsBackpackDismantlyUI", nil, self.baowu_data.baowuKey, dismantling_reward, BAG_PROP_TYPE_SAILOR_BAOWU)
		else
			local baowu_data = getGameData():getBaowuData()
			baowu_data:askBaowuDisassemble(self.baowu_data.baowuKey)
		end
    end,TOUCH_EVENT_ENDED)

	self.btn_upload:setPressedActionEnabled(true)
	self.btn_upload:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local partner_data = getGameData():getPartnerData()
		partner_data:askPartnerUploadBaowu(self.select_index, self.baowu_data.baowuKey)
		self:close()
    end, TOUCH_EVENT_ENDED)

    local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.TREASURE_DISMANTLE.value, {openBtn = self.btn_dismantling, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBaowuAttrTips"})

end

function ClsBaowuAttrTips:getDismantlingReward(baowu_level, baowu_quality)
	local reward_data = {}
	local baowu_dismantling_data = baowu_dismantling[baowu_level]
	local rewards = baowu_dismantling_data["baowu_quality_" .. baowu_quality]
	for k,v in pairs(rewards) do
		reward_data[#reward_data + 1] = {key = ITEM_INDEX_PROP, value = v, id = k}
	end
	return reward_data
end

function ClsBaowuAttrTips:isExploreAlert(fun)
	if isExplore then
	    local port_info = require("game_config/port/port_info")
	    local Alert = require("ui/tools/alert")
	    local portData = getGameData():getPortData()
	    local portName = port_info[portData:getPortId()].name
	    local tips = require("game_config/tips")
	    local str = string.format(tips[77].msg, portName)
	    Alert:showAttention(str, function()
    		self:close()
		    if getGameData():getTeamData():isLock() then
            	Alert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
                return
            end
			---回港
			portData:setEnterPortCallBack(function() 
				getUIManager():create("gameobj/backpack/clsBackpackMainUI")
			end)
			portData:askBackEnterPort()

	    end, nil, nil, {hide_cancel_btn = true})	
	else
		fun()
	end
end

function ClsBaowuAttrTips:onExit()
end

return ClsBaowuAttrTips