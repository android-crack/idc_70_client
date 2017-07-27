--编制伙伴界面
local ClsDataTools = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local baozang_info = require("game_config/collect/baozang_info")
local sailor_info = require("game_config/sailor/sailor_info")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local skill_info = require("game_config/skill/skill_info")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsFleetPartner = class("ClsFleetPartner",require("ui/view/clsBaseView"))
local ClsScrollView = require("ui/view/clsScrollView")
local sailor_op_config = require("game_config/sailor/sailor_op_config")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local COL, ROW = 2, 5
local star_total = 4

local ClsItem = class("ClsItem", function () return UIWidget:create()end)
ClsItem.mkUi = function(self, index,data)
	self.data = data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_item.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	self.item_bg = getConvertChildByName(self.panel, "item_bg")
	self.item_icon = getConvertChildByName(self.panel, "item_icon")
	self.item_icon:setVisible(false)
	self.item_num = getConvertChildByName(self.panel, "item_amount")
	self.item_num:setText("")
	self.item_selected = getConvertChildByName(self.panel, "item_selected")
	self.item_text = getConvertChildByName(self.panel, "item_text")
	self.item_text:setText("")
	self.item_lock = getConvertChildByName(self.panel, "item_lock")

	if self.data then
		local data = self.data
		local item_type = data.type
		local base_data = data.data
		local show_tag = data.tag
		local quality = 1
		local count = 0
		if show_tag then
			self.item_text:setText(show_tag.text)	
			setUILabelColor(self.item_text, ccc3(dexToColor3B(show_tag.color)))
		end

		local item_res = nil
		local isLock = false
		local player_data = getGameData():getPlayerData()
		local my_level = player_data:getLevel()
		local my_nobility = getGameData():getNobilityData():getNobilityID()
		if item_type == BAG_PROP_TYPE_SAILOR_BAOWU then
			item_res = baozang_info[base_data.baowuId].res
			quality = base_data.color
			isLock = my_level < baozang_info[base_data.baowuId].limitLevel
		elseif item_type == BAG_PROP_TYPE_BOAT_BAOWU  then
			item_res = baozang_info[base_data.baowuId].res
			quality = base_data.step
			count = data.num
			isLock = my_level < baozang_info[base_data.baowuId].limitLevel
		elseif item_type == BAG_PROP_TYPE_FLEET then
			item_res = boat_info[base_data.id].res
			quality = base_data.quality
			local boat_msg = boat_attr[base_data.id] or {}
			isLock = my_nobility < (boat_msg.nobility_id or 0)
		elseif item_type == BAG_PROP_TYPE_ASSEMB or item_type == BAG_PROP_TYPE_COMSUME then
			item_res = base_data.baseData.res
			count = base_data.count
			quality = base_data.baseData.quality or base_data.baseData.level	
		end
		if count > 1 then
			self.item_num:setText(tostring(count))
		end
		self.item_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
		self.item_icon:setVisible(true)
		if quality > 0 then 
			local btn_res = string.format("item_box_%s.png", quality)
			self.item_bg:changeTexture(btn_res, UI_TEX_TYPE_PLIST)
		end
		self.item_lock:setVisible(isLock)
	else
		self.item_selected:setVisible(false)
		self.item_lock:setVisible(false)
	end
end

ClsItem.changeSelectState = function(self, state)
	if self.is_selected ~= state then
		if not tolua.isnull(self.item_selected) then
			self.item_selected:setVisible(state)
		end
	end
	self.is_selected = state
end

ClsItem.canClick = function(self)
	return self.data ~= nil
end
--------------
local ClsBoxCell = class("ClsBoxCell", require("ui/view/clsScrollViewItem"))

ClsBoxCell.initUI = function(self, cell_data)
	self.call_back = cell_data.call_back
	self.data = cell_data.data
	self.item_list = {}
	self.bounding_list = {}
	local item_width = self.m_width/COL 
	for i=1, COL do
		local item = ClsItem.new()
		item:mkUi(i, self.data[i])
		item:setPosition(ccp(item_width * (i - 1), 0))
		self:addChild(item)
		self.item_list[i] = item

		local item_size = CCSize(74, 73)
		local bounding_layer = display.newLayer()
		local width_dis = item_width - item_size.width
		local height_dis = self.m_height - item_size.height
		bounding_layer:setContentSize(CCSize(item_size.width, item_size.height))
		bounding_layer:setPosition(ccp(item_width * (i - 1)  + width_dis/2, height_dis/2))
		self:addCCNode(bounding_layer)
		self.bounding_list[i] = bounding_layer
	end
end

ClsBoxCell.onTap = function(self, x, y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)
	for k, button in pairs (self.bounding_list) do
		if not tolua.isnull(button) then
			if button:boundingBox():containsPoint(node_pos) then
				local select_item = self.item_list[k]
				if select_item:canClick() then
					self.call_back(select_item)
				end
			end
		end
	end
end
---------------------

local widget_name = {
	"btn_close",
	"right_panel",
	"sailor_level_icon", --星级
	"sailor_bg", --水手背景
	"sailor_icon", --水手头像
	"star_panel",
	"ship_bg",
	"ship_panel",
	"text_bg",
	-- "text_info", --船名字
	"text_info_name_1",
	"text_info_name_2",
	"text_warning", --不符文字
	"sailor_type_icon",
	"name_text", --水手大名字
	"personality_info", --描述1
	"personality_long_text", --大描述
	"power_panel",
	"power_num", --船舶战力
	"far_num", --远程伤害
	"near_num",
	"long_num",
	"defense_num",
	"btn_strengthen",
	"btn_autoequip",
	"btn_tips",
	"btn_lineup",
}

local SAILOR_POS_2 = 2
local SAILOR_POS_3 = 3
local SAILOR_POS_4 = 4

local POS_2_NEED_LEVEL = 10 --2号位置水手需要10级
local POS_3_NEED_LEVEL = 15
local POS_4_NEED_LEVEL = 20

local EXIST_PARTNER = 1--- 有小伙伴存在

local FIRST_PARTNER_INDEX = 1 --第一个格子
local MAX_PARTNER_INDEX = 4 --最多4个小伙伴

local TAB_BOAT = 1
local TAB_EQUIP = 2

local FIRST_BAOWU = 1 --第一个宝物格子
local MAX_BAOWU = 3 --最多3个宝物格子

local FIRST_SKILL_INDEX = 1 --第一个技能
local MAX_SKILL_INDEX = 5

local DEFAULT_SKILL_MAIN = 2

local SKILL_MAIN_STATUS = 1

local TASK_RED_POINT = {
	on_off_info.APPOINT_SAILOR_1.value,
	on_off_info.APPOINT_SAILOR_2.value,
	on_off_info.APPOINT_SAILOR_3.value,
	on_off_info.APPOINT_SAILOR_4.value,
}

local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

ClsFleetPartner.getViewConfig = function(self)
	return {
		effect = UI_EFFECT.FADE,
		hide_before_view = true,
	}
end
ClsFleetPartner.onEnter = function(self, tab, close_back)
	self.plist = {  
		["ui/staff.plist"] = 1,  
		["ui/skill_icon.plist"] = 1,
		["ui/backpack.plist"] = 1,
		["ui/item_box.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
		["ui/partner.plist"] = 1,
	}
	LoadPlist(self.plist)
	self.close_CB = close_back

	--编制界面
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/staff.json")
	convertUIType(panel)
	self:addWidget(panel)
	self.panel = panel

	self.partner = {}
	self.head_bg = {} --头像背景框
	self.icon_list = {} --有水手的头像
	self.unlock_icon = {} --未解锁的头像

	self.not_match_eff = {} --不匹配船特效列表
	self.not_match_sailor = {} -- 不匹配水手特效

	self:initUI()
	self:initData()

	self:regFunc()
	self:initBtns()

	self.guide_item_list = {
		[1] = {type = BAG_PROP_TYPE_FLEET, id = 2, key = "id", on_off_key = on_off_info.FOMATION_2_SELECT.value},
		[2] = {type = BAG_PROP_TYPE_FLEET, id = 23, key = "id", on_off_key = on_off_info.SHUANGWEI_SELECT.value, index = 2},
		[3] = {type = BAG_PROP_TYPE_FLEET, id = 5, key = "id", on_off_key = on_off_info.HANSE_SELECT.value,},
	}
end

ClsFleetPartner.initUI = function(self)
	-- missionGuide:disableAllGuide()
	-- 绑定json
	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	
	local task_data = getGameData():getTaskData()
	for k = 1, 4 do
		self.partner[k] = {}
		
		local click_panel = getConvertChildByName(self.panel, string.format("panel_%s", k))
		self.partner[k].click_panel = click_panel
		task_data:regTask(click_panel, {TASK_RED_POINT[k]}, KIND_CIRCLE, TASK_RED_POINT[k], 102, 85, true)

		--背景框
		self["sailor_bg_"..k] = getConvertChildByName(self.panel, string.format("sailor_bg_%s", k))
		self.partner[k].sailor_bg = self["sailor_bg_"..k]
		self.head_bg[k] = self["sailor_bg_"..k]


		local sailor_bg_selected = getConvertChildByName(self.panel, string.format("select_bg_%s", k))
		self.partner[k].sailor_bg_selected = sailor_bg_selected
		sailor_bg_selected:setVisible(false)

		--点击上阵
		local join_bg = getConvertChildByName(self.panel, string.format("text_bg_%s", k))
		self.partner[k].join_bg = join_bg
		join_bg:setVisible(false)

		local text_join = getConvertChildByName(self.panel, string.format("text_info_%s", k))
		self.partner[k].text_join = text_join

		--头像
		local sailor_icon = getConvertChildByName(self.panel, string.format("sailor_icon_%s", k))
		self.partner[k].sailor_icon = sailor_icon
		sailor_icon:setVisible(false)		

		--替换
		local exchange = getConvertChildByName(self.panel, string.format("exchange_%s", k))
		exchange:setVisible(false)
		self.partner[k].exchange = exchange		

		--水手星级等级更换层
		local sailor_panel = getConvertChildByName(self.panel, string.format("sailor_panel_%s", k))
		sailor_panel:setVisible(false)
		self.partner[k].sailor_panel = sailor_panel

		--水手星级
		local star_icon = getConvertChildByName(self.panel, string.format("sailor_level_icon_%s", k))
		self.partner[k].star_icon = star_icon

		--水手等级
		local sailor_level = getConvertChildByName(self.panel, string.format("sailor_level_num_%s", k))
		self.partner[k].sailor_level = sailor_level
		sailor_level:setVisible(false)

		--船舶皮肤
		self.skin_box = getConvertChildByName(self.panel, "skin_box")
		self.skin_icon = getConvertChildByName(self.panel, "skin_icon")
		self.skin_time_num = getConvertChildByName(self.panel, "skin_time_num")
		self.skin_txt = getConvertChildByName(self.panel, "skin_txt")


	end

	missionGuide:pushGuideBtn(on_off_info.APPOINT_SAILOR_2.value, {rect = CCRect(64, 306, 60, 60), guideLayer = self})
	missionGuide:pushGuideBtn(on_off_info.APPOINT_SAILOR_3.value, {rect = CCRect(64, 190, 60, 60), guideLayer = self})

	--宝物
	self.sailor_baowu = {}
	for i = FIRST_BAOWU, MAX_BAOWU do
		local temp = {}
		local bg_name = string.format("baowu_%d", i)
		local icon_name = string.format("icon_%d", i)
		local default_name = string.format("text_mid_%d", i)
		local baowu_name = string.format("text_%d", i)
		temp.baowu_bg = getConvertChildByName(self.panel, bg_name)
		temp.baowu_icon = getConvertChildByName(self.panel, icon_name)
		temp.default_name = getConvertChildByName(self.panel, default_name)
		temp.baowu_text = getConvertChildByName(self.panel, baowu_name)
		temp.baowu_bg:setTouchEnabled(false)

		temp.star_list = {}
		for star_index=1, star_total do
			temp.star_list[star_index] = getConvertChildByName(self.panel, string.format("star_%d_%d", i, star_index))
		end

		local icon_visible = temp.baowu_icon.setVisible
		temp.baowu_icon.setVisible = function(self, enable)
			icon_visible(self, enable)
			self:setTouchEnabled(enable)
		end
		temp.baowu_icon:setVisible(false)

		local default_visible = temp.default_name.setVisible
		temp.default_name.setVisible = function(self, enable)
			default_visible(self, enable)
			self:setTouchEnabled(enable)
		end
		temp.default_name:setVisible(true)

		temp.baowu_text:setText("")
		self.sailor_baowu[i] = temp
	end

	--技能
	self.sailor_skill = {}
	for i = FIRST_SKILL_INDEX, MAX_SKILL_INDEX do
		--背景框
		self.sailor_skill[i] = {}
		local skill_bg = getConvertChildByName(self.panel, string.format("skill_bg_%s", i))
		self.sailor_skill[i].skill_bg = skill_bg
		skill_bg:setVisible(false)

		local skill_icon = getConvertChildByName(self.panel, string.format("sikll_icon_%s", i))
		self.sailor_skill[i].skill_icon = skill_icon

		local skill_main_pic = getConvertChildByName(self.panel, string.format("main_%s", i))
		skill_main_pic:setVisible(false)
		self.sailor_skill[i].skill_main_pic = skill_main_pic
	end

	self.sailor_level_icon:setVisible(false)
	self.sailor_icon:setVisible(false)
	self.text_bg:setVisible(false)
	self.star_panel:setVisible(false)

	self.long_num:setText(0)
	self.far_num:setText(0)
	self.near_num:setText(0)
	self.defense_num:setText(0)
end

ClsFleetPartner.clearTips = function(self)
	if not tolua.isnull(self.tips) then
		self.tips:close()
	end
end


--皮肤盒子
ClsFleetPartner.updateSkinBoxUI = function(self, skin_data, boat_key, sailor_id)
	local partner_data = getGameData():getPartnerData()
	local ship_data = getGameData():getShipData()
	local boat = ship_data:getBoatDataByKey(boat_key)
	-- if skin_data then
	-- 	self.skin_box:setVisible(true)
	-- 	local boat_res = boat_info[boat.id].res		
	-- 	if skin_data.skin_enable == 0 then boat_res = skin_data.skin_res end	
	-- 	self.skin_icon:changeTexture(convertResources(boat_res) , UI_TEX_TYPE_PLIST)
	-- else
	-- 	self.skin_box:setVisible(true)
	-- end
	self.skin_box:setVisible(true)
	if skin_data then
		local item_info = require("game_config/propItem/item_info")
		local btn_res = string.format("item_box_%s.png", item_info[skin_data.item_id].quality)
		self.skin_box:changeTexture(btn_res, UI_TEX_TYPE_PLIST)
		self.skin_icon:setVisible(true)
		self.skin_txt:setVisible(false)
		
		local item_res = item_info[skin_data.item_id].res
		self.skin_icon:changeTexture(convertResources(item_res) , UI_TEX_TYPE_PLIST)
	else
		self.skin_icon:setVisible(false)
		self.skin_txt:setVisible(true)
	end
	self.skin_box:setTouchEnabled(true)
	self.skin_box:addEventListener(function()		
		local partner_data = getGameData():getPartnerData()
		if skin_data then
			getUIManager():create("gameobj/backpack/clsBoatSkinTips", nil, "ClsBoatSkinTips", nil, self.cur_select_partner, skin_data.item_id, boat_key, true)
		end

	end, TOUCH_EVENT_ENDED)
end

ClsFleetPartner.timeFarmat = function(self, remain_time)
	local show_time_str, time_tab = ClsDataTools:getCnTimeStr(remain_time)
	return show_time_str
end

--中间名字对齐
ClsFleetPartner.autoAdaptUIMid = function(self, remain_time)
	if not remain_time or remain_time == 0 then
		self.skin_time_num:setVisible(false)
	else
		self.skin_time_num:setVisible(true)
		local show_time_str = self:timeFarmat(remain_time)
		local pos_x = self.text_info_name_1:getPosition().x
		local name_width = self.text_info_name_1:getContentSize().width
		local plus_width = self.text_info_name_2:getContentSize().width
		local mid_pos = (plus_width - name_width)/2 + pos_x
		self.skin_time_num:getPosition()
		self.skin_time_num:setAnchorPoint(ccp(0.5, 0.5))
		self.skin_time_num:setPosition(ccp(mid_pos - 1, self.skin_time_num:getPosition().y))
		self.skin_time_num:setText(ui_word.SKIN_END_TIME..show_time_str)
	end
end

ClsFleetPartner.updateInfoView = function(self)
	if self.ship_sprite then 
		armature_manager:removeArmatureFileInfo(self.res_armature)
		if not tolua.isnull(self.ship_sprite) then
			self.ship_sprite:removeFromParentAndCleanup(true)
		end
	end

	self.skin_box:setVisible(false)
	local id = self.ids[self.cur_select_partner]
	local power = self.powers[self.cur_select_partner]
	local partner_attr = self.partner_attrs[self.cur_select_partner].partner_attrs

	local partner_data = getGameData():getPartnerData()
	local equip_bag_info = partner_data:getBagEquipInfoById(id)
	
	local sailor = self.own_sailors[id]

	local config = sailor_info[id]

	local has_partner = (self.cur_select_partner ~= nil)
	self.sailor_level_icon:setVisible(has_partner)

	self.sailor_icon:setVisible(has_partner)

	self.star_panel:setVisible(true)

	if sailor then --有水手
		self.sailor_level_icon:changeTexture(STAR_SPRITE_RES[sailor.star].big, UI_TEX_TYPE_PLIST)
		--头像
		self.sailor_icon:setVisible(true)
		self.sailor_icon:changeTexture(sailor.res, UI_TEX_TYPE_LOCAL)

		--星
		for i = 1, 5 do
			local star = getConvertChildByName(self.panel, string.format("star_%s", i))
			star:setVisible(i <= sailor.starLevel)
		end

		--描述1
		self.personality_info:setText(config.nature)
		self.personality_long_text:setText(config.nature_dec)

		local boat_key = self.boat_keys[self.cur_select_partner]
		--删除不匹配特效
		if not tolua.isnull(self.not_match_sailor) then
			self.not_match_sailor:removeFromParentAndCleanup(true)
		end

		if boat_key ~= 0 then

			local ship_data = getGameData():getShipData()
			local boat = ship_data:getBoatDataByKey(boat_key)
			local boat_config = ClsDataTools:getBoat(boat.id)
			
			local skin_data = partner_data:getBagEquipSkinByBoatKey(boat_key)
			local show_boat_id = boat.id
			local show_boat_name = boat.name
			local remain_time = 0
			if skin_data and skin_data.skin_enable == 1 then
				show_boat_id = skin_data.skin_id
				show_boat_name = skin_data.skin_name
				boat_config = ClsDataTools:getBoat(show_boat_id)
				remain_time = skin_data.skin_end_time
			end
			
			self:updateSkinBoxUI(skin_data, boat_key)
			--船名字
			self.text_bg:setVisible(true)
			self.text_info_name_1:setText(string.format("%s", show_boat_name))
			setUILabelColor(self.text_info_name_1, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))
			self.text_info_name_2:setText(string.format(" +%s", equip_bag_info.boatLevel))
			setUILabelColor(self.text_info_name_2,QUALITY_COLOR_STROKE[math.floor(equip_bag_info.boatLevel/10) +1])
			
			--不匹配
			local  match = partner_data:sailorMatchBoat(sailor.job[1], boat.id)
			if not match then
				local compositeEffect = require("gameobj/composite_effect")
				local effNode = compositeEffect.new("tx_0183", -10, 44, self.ship_panel, -1, nil, nil, nil, true)
				self.not_match_sailor = effNode
			end

			self.text_info_name_1:setVisible(match)
			self.text_info_name_2:setVisible(match)
			self.text_warning:setVisible(not match)
			self:autoAdaptUIMid(remain_time)
			--船
			self.res_armature = string.format("armature/ship/%s/%s.ExportJson", boat_config.effect, boat_config.effect)
			armature_manager:addArmatureFileInfo(self.res_armature)
			self.ship_sprite = CCArmature:create(boat_config.effect)
			self.ship_sprite:getAnimation():playByIndex(0)
			self.ship_sprite:setScale(0.25)
			self.ship_sprite:setPosition(ccp(64, 90 + boat_config.boatPos[2]))
			self.ship_sprite:setZOrder(1)
			self.ship_panel:addCCNode(self.ship_sprite)

			self.ship_panel:setTouchEnabled(true)
			self.ship_panel:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				getUIManager():create("gameobj/backpack/clsBoatAttrTips", nil, "ClsBoatAttrTips", {effect = false}, self.cur_select_partner + 1, nil, nil, true)
			end, TOUCH_EVENT_ENDED)
		else
			if not tolua.isnull(self.not_match_sailor) then
				self.not_match_sailor:removeFromParentAndCleanup(true)
			end
			self.text_bg:setVisible(false)
			self.ship_panel:setTouchEnabled(true)
			self.ship_panel:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				Alert:showJumpWindow(SHIP_NOT_ENOUGH)
			end, TOUCH_EVENT_ENDED)
		end
		self.power_num:setText(power)

		--水手属性
		self.long_num:setText(0)
		self.far_num:setText(0)
		self.near_num:setText(0)
		self.defense_num:setText(0)
		
		for k, v in pairs(partner_attr) do
			if v.name == "durable" then
				self.long_num:setText(v.value)
			elseif v.name == "remote" then
				self.far_num:setText(v.value)
			elseif v.name == "melee" then
				self.near_num:setText(v.value)
			elseif v.name == "defense" then
				self.defense_num:setText(v.value)
			end
		end

		--属性详情
		self.btn_tips:setPressedActionEnabled(true)
		self.btn_tips:addEventListener(function()
			local pos = self:convertToWorldSpace(ccp(295, 80))
			self.tips = getUIManager():create("gameobj/fleet/clsPartnerAttrTips",nil,self,pos,partner_attr,power)
		end, TOUCH_EVENT_ENDED)


		--职业
		self.sailor_type_icon:changeTexture(JOB_RES[sailor.job[1]], UI_TEX_TYPE_PLIST)
		self.name_text:setText(sailor.name)

		--宝物
		self.baowu_list = equip_bag_info.partnerBaowu

		for i = FIRST_BAOWU, MAX_BAOWU do
			self.sailor_baowu[i].baowu_text:setText("")
			self.sailor_baowu[i].default_name:setVisible(false)
			self.sailor_baowu[i].baowu_icon:setVisible(false)

			local quality = 1
			local baowu_equip_key = self.baowu_list[i]
			local baowu_len = string.len(baowu_equip_key)
			local baozang_config
			local refine_attr
			if baowu_equip_key and baowu_len > 0 then
				local baowu_data = getGameData():getBaowuData()
				local baowu_item_data = baowu_data:getInfoById(baowu_equip_key)
				if baowu_item_data then
					self.sailor_baowu[i].baowu_icon:setVisible(true)
					baozang_config = baozang_info[baowu_item_data.baowuId]
					quality = baowu_item_data.color
					--宝物图标
					self.sailor_baowu[i].baowu_icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
					self.sailor_baowu[i].baowu_text:setText(baozang_config.name)
					setUILabelColor(self.sailor_baowu[i].baowu_text, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))

					self.sailor_baowu[i].baowu_icon:addEventListener(function()
						audioExt.playEffect(music_info.COMMON_BUTTON.res)
						getUIManager():create("gameobj/backpack/clsBaowuAttrTips", nil, "ClsBaowuAttrTips", {effect = false}, self.cur_select_partner + 1, baowu_item_data)
					end, TOUCH_EVENT_ENDED)
				else
					self.sailor_baowu[i].default_name:setVisible(true)
					self.sailor_baowu[i].default_name:addEventListener(function()
						audioExt.playEffect(music_info.COMMON_BUTTON.res)
						Alert:showJumpWindow(SAILOR_BAOWU_NOT_ENOUGH)
					end, TOUCH_EVENT_ENDED)
				end

				for j,refine in ipairs(equip_bag_info.refineAttr) do
					if refine and refine.index == i then
						refine_attr = refine.refine
					end
				end
			else
				self.sailor_baowu[i].default_name:setVisible(true)
				self.sailor_baowu[i].default_name:addEventListener(function()
					audioExt.playEffect(music_info.COMMON_BUTTON.res)
					Alert:showJumpWindow(SAILOR_BAOWU_NOT_ENOUGH)
				end, TOUCH_EVENT_ENDED)
			end
			local star_level = 0
			if refine_attr then
				star_level = ClsDataTools:calBaowuStarLevel(refine_attr, baozang_config)
			end

			local sailor_baowu_icon = self.sailor_baowu[i]
			for star_index = 1, star_total do
				local star_icon = sailor_baowu_icon.star_list[star_index]
				if star_level > (star_index - 1) * 2 then
					star_icon:setVisible(true)
					local star_res = "common_star3.png"
					if (star_level - (star_index * 2)) >= 0 then
						star_res = "common_star1.png"
					end
					star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
				else
					star_icon:setVisible(false)
				end
			end

			local item_bg_res = string.format("item_treasure_%s.png", quality)
			self.sailor_baowu[i].baowu_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)
		end

		--技能
		local skills = ClsDataTools:getSkillInfo(sailor)
		local max_skill = DEFAULT_SKILL_MAIN +  sailor_op_config[sailor.star].skill_solt

		if max_skill > 5 then max_skill = 5 end
		for k = FIRST_SKILL_INDEX, MAX_SKILL_INDEX do
			self.sailor_skill[k].skill_bg:setVisible(false)
			self.sailor_skill[k].skill_main_pic:setVisible(false)
			if k <= max_skill then
				self.sailor_skill[k].skill_bg:changeTexture("skill_bg_1.png", UI_TEX_TYPE_PLIST)
				self.sailor_skill[k].skill_bg:setVisible(true)
				self.sailor_skill[k].skill_bg:setGray(true)
				self.sailor_skill[k].skill_icon:changeTexture("skill_add.png", UI_TEX_TYPE_PLIST)

				self.sailor_skill[k].skill_main_pic:setVisible(false)
				--选中技能
				self.sailor_skill[k].skill_bg:addEventListener(function()
					---水手技能开关判断

					local onOffData = getGameData():getOnOffData()
					if not onOffData:isOpen(on_off_info.SAILORSKILL_PAGE.value) then
						return 
					end

					getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor, 2, k)
				end, TOUCH_EVENT_ENDED)
			end
		end

		for k, v in pairs(skills) do
			local skill = skill_info[v.id]
			self.sailor_skill[v.pos].skill_bg:setGray(false)
			self.sailor_skill[v.pos].skill_bg:changeTexture(SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)
			---主动技能
			self.sailor_skill[v.pos].skill_main_pic:setVisible(skill.initiative == SKILL_MAIN_STATUS)
			--图标
			self.sailor_skill[v.pos].skill_icon:setVisible(true)
			self.sailor_skill[v.pos].skill_icon:changeTexture(string.sub(skill.res, 2, string.len(skill.res)), UI_TEX_TYPE_PLIST)
		end

		self.btn_autoequip:setPressedActionEnabled(true)
		self.btn_autoequip:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local partner_data = getGameData():getPartnerData()
			partner_data:askPartnerPrefetUpload(self.cur_select_partner + 1)
		end, TOUCH_EVENT_ENDED)

		self.btn_strengthen:setPressedActionEnabled(true)
		self.btn_strengthen:addEventListener(function ()
			getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor, 1)
		end, TOUCH_EVENT_ENDED)

		missionGuide:pushGuideBtn(on_off_info.PARTANER_UP.value, {rect = CCRect(608, 20, 90, 88), guideLayer = self})

		self:updateListView()

		self.btn_autoequip:setVisible(true)
		self.btn_strengthen:setVisible(true)
	else
		self.btn_autoequip:setVisible(false)
		self.btn_strengthen:setVisible(false)
	end
end


ClsFleetPartner.setBaowuAndBoatTouchEnable = function(self, enable)
	for i = FIRST_BAOWU, MAX_BAOWU do
		self.sailor_baowu[i].baowu_bg:setTouchEnabled(enable)
	end

	self.ship_panel:setTouchEnabled(enable)
end

ClsFleetPartner.updateListView = function(self)
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
		self.list_view = nil
	end

	self.cell_list = {}
	self.data_list = {}
	self.select_backpack_item = nil

	local rect = CCRect(748, 30, 180, 375)
	local list_cell_size = CCSizeMake(rect.size.width, rect.size.height / (ROW - 0.4))
	self.list_view = ClsScrollView.new(180, 375, true,function()end, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(756, 95))
	self:addWidget(self.list_view)

	local bag_data_hanlder = getGameData():getBagDataHandler()

	local data_list = {}
	if self.cur_select_partner then
		data_list = bag_data_hanlder:getFleetPartnerData(self.cur_select_partner + 1)
	end
	
	local item_data_list = {}
	local item_count = 0

	-- 船舶皮肤

	for i, data in ipairs(data_list) do
		local list = data.list
		for k, v in pairs(list) do
			item_count = item_count + 1
			v.sort = item_count
			item_data_list[#item_data_list + 1] = v
		end
	end

	table.sort(item_data_list, function(a, b)
		local a_tag = 0
		local b_tag = 0
		if a.tag then
			a_tag = a.tag.value
		end
		if b.tag then
			b_tag = b.tag.value
		end
		if a_tag ~= b_tag then
			return a_tag > b_tag
		end
		return a.sort < b.sort
	end)
	

	local item_max = math.max(item_count, COL * ROW)
	local row_item_list = nil
	for i = 1, item_max do
		local index = (i - 1) % COL + 1
		if index == 1 then
			cell_data = {}		
		end

		local item_data = item_data_list[i]
		cell_data[#cell_data + 1] = item_data

		if (i == item_max) or (i % COL == 0) then
			local cell_spr = ClsBoxCell.new(list_cell_size, {data = cell_data, index = math.ceil(i / COL), call_back = function(item) self:selectItem(item)end})
			self.cell_list[#self.cell_list + 1] = cell_spr
		end
		self.data_list[i] = item_data
	end

	self.list_view:addCells(self.cell_list)
	missionGuide:pushGuideBtn(on_off_info.FOMATION_BOXSELECT.value, {guideLayer=self,rect = CCRect(750, 386, 72, 70)})

	self.getBoatGuideObj = function(condition)
		return self:getGuideInfo(condition)
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(function()
		ClsGuideMgr:tryGuide("ClsFleetPartner")	
	end))

	self:runAction(CCSequence:create(array))
end

ClsFleetPartner.getGuideInfo = function(self, condition)
	if tolua.isnull(self.list_view) then return end
	--local parent_ui = self.list_view:getInnerLayer()
	local item_id = condition.item_id

	for k, cell in ipairs(self.data_list) do
		if cell.data.id == item_id then
			local cell = self.cell_list[math.ceil(k / 2)]
			local world_pos = cell:convertToWorldSpace(ccp(35 + math.ceil((k - 1) % 2) * 104, 40))
			local parent_pos = cell:convertToWorldSpace(ccp(0,0))
			local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
			return cell, guide_node_pos, {['w'] = 80, ['h'] = 75}
		end
	end
end

ClsFleetPartner.initData = function(self)
	local partner_data = getGameData():getPartnerData()

	partner_data:askForPartnersInfo()
end

ClsFleetPartner.selectItem = function(self, item)
	if self.select_backpack_item then
		self.select_backpack_item:changeSelectState(false)
	end
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	item:changeSelectState(true)
	self.select_backpack_item = item

	local select_type = item.data.type
	if select_type == BAG_PROP_TYPE_FLEET then
		getUIManager():create("gameobj/backpack/clsBoatAttrTips", nil, "ClsBoatAttrTips", {effect = false}, self.cur_select_partner + 1, item.data.data.guid, true, true)
	elseif select_type == BAG_PROP_TYPE_SAILOR_BAOWU then
		getUIManager():create("gameobj/backpack/clsBaowuAttrTips", nil, "ClsBaowuAttrTips", {effect = false}, self.cur_select_partner + 1, item.data.data, true)
	else
		local sailor_id = self.ids[self.cur_select_partner]
		local boat_key = self.boat_keys[self.cur_select_partner]
		getUIManager():create("gameobj/backpack/clsBoatSkinTips", nil, "ClsBoatSkinTips", nil, sailor_id, item.data.data.id, boat_key)
	end
end

ClsFleetPartner.updateView = function(self)

	self:setViewTouchEnabled(true)
	for i = FIRST_PARTNER_INDEX, MAX_PARTNER_INDEX do
		self:backToOriPos(i)
	end

	local partner_data = getGameData():getPartnerData()
	self.partner_info = partner_data:getPartnersInfo()

	self.ids = self.partner_info.ids
	self.boat_keys = self.partner_info.boat_keys
	self.powers = self.partner_info.powers
	self.partner_attrs = self.partner_info.partner_attrs

	local sailor_data = getGameData():getSailorData()
	self.own_sailors = sailor_data:getOwnSailors()

	local ship_data = getGameData():getShipData()
	local task_data = getGameData():getTaskData()
	--有伙伴显示
	self.has_partner = {}
	if not self.ids then return end 
	for k, v in pairs(self.ids) do
		local cur_partner = self.partner[k]
		cur_partner.sailor_icon:setVisible(v ~= 0)
		cur_partner.join_bg:setVisible(v == 0)
		cur_partner.click_panel:setTouchEnabled(true)
		cur_partner.sailor_bg:setGray(v == 0)
		cur_partner.sailor_panel:setVisible(v ~= 0)
		cur_partner.sailor_level:setVisible(v ~= 0)
		task_data:onOffEffect(TASK_RED_POINT[k])

		if v ~= 0 then  --有伙伴数据
			local sailor = self.own_sailors[v]
			table.insert(self.has_partner, k)

			--头像
			cur_partner.sailor_icon:changeTexture(sailor_info[v].res, UI_TEX_TYPE_LOCAL)
			self.icon_list[k] = cur_partner.sailor_icon
			--品质
			cur_partner.star_icon:changeTexture(STAR_SPRITE_RES[sailor.star].big, UI_TEX_TYPE_PLIST)

			--等级
			cur_partner.sailor_level:setText(string.format("Lv.%s", sailor.level))

			local boat_key = self.boat_keys[k]

			--删除不匹配特效
			if not tolua.isnull(self.not_match_eff[k]) then
				self.not_match_eff[k]:removeFromParentAndCleanup(true)
			end

			if boat_key ~= 0 then
				local boat = ship_data:getBoatDataByKey(boat_key)
				local match = partner_data:sailorMatchBoat(sailor.job[1], boat.id)

				--不匹配
				if not match then
					local compositeEffect = require("gameobj/composite_effect")
					local effNode = compositeEffect.new("tx_0183", 98, 55, cur_partner.sailor_panel, -1, nil, nil, nil, true)
					effNode:setZOrder(2)
					self.not_match_eff[k] = effNode
				end
			else
				if not tolua.isnull(self.not_match_eff[k]) then
					self.not_match_eff[k]:removeFromParentAndCleanup(true)
				end
			end

		else

			--没有水手
			cur_partner.text_join:setText(ui_word.FLEET_ADD_BOAT)
			cur_partner.sailor_bg:setGray(false)

			
			local player_data = getGameData():getPlayerData()
			local player_level = player_data:getLevel()
			--2号位10级，3号位15级，4号为20级
			if k == SAILOR_POS_2 then
				if player_level < POS_2_NEED_LEVEL then
					cur_partner.text_join:setText(string.format(ui_word.FLEET_UNLOCK_LEVEL, POS_2_NEED_LEVEL))
					cur_partner.click_panel:setTouchEnabled(false)
					cur_partner.sailor_bg:setGray(true)
					self.unlock_icon[k] = cur_partner.sailor_icon
				end
			elseif k == SAILOR_POS_3 then
				if player_level < POS_3_NEED_LEVEL then
					cur_partner.text_join:setText(string.format(ui_word.FLEET_UNLOCK_LEVEL, POS_3_NEED_LEVEL))
					cur_partner.click_panel:setTouchEnabled(false)
					cur_partner.sailor_bg:setGray(true)
					
					self.unlock_icon[k] = cur_partner.sailor_icon
				end
			elseif k == SAILOR_POS_4 then
				if player_level < POS_4_NEED_LEVEL then
					cur_partner.text_join:setText(string.format(ui_word.FLEET_UNLOCK_LEVEL, POS_4_NEED_LEVEL))
					cur_partner.click_panel:setTouchEnabled(false)
					cur_partner.sailor_bg:setGray(true)
					self.unlock_icon[k] = cur_partner.sailor_icon
				end
			end

			--上阵小伙伴
			cur_partner.click_panel:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				getUIManager():create("gameobj/port/clsAppointSailorUI", {}, true, k)

			end, TOUCH_EVENT_ENDED)
		end
	end
	
	if #self.has_partner >= EXIST_PARTNER then
		self:select_a_partner(self.cur_select_partner or self.has_partner[FIRST_PARTNER_INDEX])
		-- self:initTabs()
		self:updateInfoView()
	else
		self.btn_autoequip:setVisible(false)
		self.btn_strengthen:setVisible(false)
	end

	--布阵
	self.btn_lineup:setPressedActionEnabled(true)
	self.btn_lineup:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/fleet/clsRoleLineUp")	
	end, TOUCH_EVENT_ENDED)

end


--选中的伙伴所属的格子index
ClsFleetPartner.select_a_partner = function(self, index)
	self.cur_select_partner = index

	if self.last_select_index then
		self.partner[self.last_select_index].sailor_bg_selected:setVisible(false)
		self.partner[self.last_select_index].exchange:setVisible(false)
	end
	
	self.partner[index].sailor_bg_selected:setVisible(true)
	self.partner[index].exchange:setVisible(true)

	self.last_select_index = index
end

ClsFleetPartner.onTouch = function(self, event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end

ClsFleetPartner.onTouchBegan = function(self, x, y)
	-- if self.touch_partner_key then 
	-- 	print("----------------onTouchBegan------touch_partner_key--false--")
	-- 	return false 
	-- end
	self.touch_x, self.touch_y = x, y
	local max_dis = 60

	self.touch_partner_key = nil  --拖动的icon
	if self.touch_rect:containsPoint(ccp(x, y)) then
		for k, v in pairs(self.icon_list) do
			local pos = v:getPosition()
			local dis = Math.distance(pos.x, pos.y, x, y)
			if dis < max_dis and self.icon_list[k] then
				self.touch_partner_key = k
				self.partner[self.touch_partner_key].click_panel:setTouchEnabled(false)
				return true 
			end 
		end
	end
	return false
end

ClsFleetPartner.onTouchMoved = function(self, x, y)
	if not self.touch_partner_key then return end 
	if self.touch_rect:containsPoint(ccp(x, y)) then

		if x - self.touch_x < 12 and y - self.touch_y < 12 then
			return
		end

		self.icon_list[self.touch_partner_key]:setZOrder(10)
		self.icon_list[self.touch_partner_key]:setPosition(ccp(x, y))
	end
end

ClsFleetPartner.onTouchEnded = function(self, x, y)
	if self.touch_partner_key == nil then
		return
	end

	-- self.partner[self.touch_partner_key].click_panel:setTouchEnabled(true)
	if math.abs(self.touch_x - x) < 12 and  math.abs(self.touch_y - y) < 12 then
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:setHeadPosByIndex(self.icon_list[self.touch_partner_key], self.touch_partner_key)

		if self.cur_select_partner and self.cur_select_partner == self.touch_partner_key then
			--print("=======已经选中的===")
			local text = ui_word.FLEEL_GO_TO_SAILOR_LIST
			Alert:showAttention(text, function()
				getUIManager():create("gameobj/port/clsAppointSailorUI", {}, true, self.cur_select_partner)
			end) 

		else 
			self:select_a_partner(self.touch_partner_key)
			self:updateInfoView()
		end

		self.touch_partner_key = nil
		return
	end

	-- self.partner[self.touch_partner_key].click_panel:setTouchEnabled(true)
	local partner_data = getGameData():getPartnerData()
	local cur_select_key = nil --选中的头像位置
	local max_dis = 56
	
	for k, v in pairs(self.head_bg) do
		local pos = v:getPosition()

		local dis = Math.distance(pos.x, pos.y, x, y)
		if dis < max_dis and not self.unlock_icon[k] then
			cur_select_key = k
			break 
		end 
	end


	-- 返回之前的位置
	if cur_select_key == nil or self.touch_partner_key == cur_select_key then

		--print("=========返回=====")
		self:setHeadPosByIndex(self.icon_list[self.touch_partner_key], self.touch_partner_key)

	-- 2个小伙伴替换位置
	elseif self.icon_list[cur_select_key] then
	
		--print("=========替换位置=====")
		self.icon_list[cur_select_key], self.icon_list[self.touch_partner_key] = self.icon_list[self.touch_partner_key], self.icon_list[cur_select_key]
		
		self:setHeadPosByIndex(self.icon_list[cur_select_key], cur_select_key)
		self:setHeadPosByIndex(self.icon_list[self.touch_partner_key], self.touch_partner_key)

		self.cur_select_partner = cur_select_key
		partner_data:askForChangePos(self.touch_partner_key, cur_select_key)

	--换到空位置
	else
		--print("=========换到空位置=====")
		self.icon_list[cur_select_key] = self.icon_list[self.touch_partner_key]

		self:setHeadPosByIndex(self.icon_list[cur_select_key], cur_select_key)
		self.icon_list[self.touch_partner_key] = nil

		self.cur_select_partner = cur_select_key
		partner_data:askForChangePos(self.touch_partner_key, cur_select_key)
	end

	self.touch_partner_key = nil
end

ClsFleetPartner.backToOriPos = function(self, index)
	self:setHeadPosByIndex(self.partner[index].sailor_icon, index)
end

--设置头像的显示位置
ClsFleetPartner.setHeadPosByIndex = function(self, icon, key)
	if not tolua.isnull(icon) then

		if self.head_bg[key] then 
			local pos = self.head_bg[key]:getPosition()
			icon:setZOrder(2)
			icon:setPosition(ccp(pos.x, pos.y + 8))
		end 
	end
end

ClsFleetPartner.initBtns = function(self)
	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		if type(self.close_CB) == "function" then
			self.close_CB()
		end
		self:effectClose()
	end, TOUCH_EVENT_ENDED)
end

ClsFleetPartner.regFunc = function(self)
	self:regTouchEvent(self, function(...) return self:onTouch(...) end, self.m_touch_priority)
	self.touch_rect = CCRect(0, 12, 192, 502)
end


ClsFleetPartner.onExit = function(self)
end

return ClsFleetPartner