
---小伙伴详细界面


local ClsUiTools = require("gameobj/uiTools")
local music_info = require("game_config/music_info")
local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local sailor_train_info = require("game_config/sailor/sailor_train_info")
local DataTools = require("module/dataHandle/dataTools")
local skill_info = require("game_config/skill/skill_info")
local Alert = require("ui/tools/alert")
local LoadingAction = require("gameobj/LoadingBarAction")
local on_off_info = require("game_config/on_off_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local UiCommon = require("ui/tools/UiCommon")
local CompositeEffect = require("gameobj/composite_effect")
local ClsRoleSkillTips = require("gameobj/playerRole/clsRoleSkillTips")
local ClsBaseView = require("ui/view/clsBaseView")
local sailor_op_config = require("game_config/sailor/sailor_op_config")


local ClsPartnerInfoView = class("ClsPartnerInfoView", ClsBaseView)

local btn_name = {
	{res="btn_property",lab = "btn_property_text"},
	--{res="btn_aptitude",lab = "btn_aptitude_text"},
	{res="btn_skill",lab = "btn_skill_text", on_off_key = on_off_info.SAILORSKILL_PAGE.value},
}

local widget_name ={
	"btn_close",
	"skill_panel",
	--"aptitude_panel",
	"property_panel",
	"partners_panel",
}

local TAB_ATTR = 1 --属性
local TAB_SKILL = 2 --技能 
local MAX_SATR_LEVEL = 5 --水手最大星
local MAX_SATR = 6   ---S级水手
local LEGEND_SAILOR_STAR = 7  ---传奇水手


local DURATION = 0.5 --进度条做满动画的时间

local TYPE_ADD_SKILL = 1  --添加水手技能
local TYPE_EXCHAGE_SKILL = 2 --交换水手技能
local TYPE_UP_SKILL = 3 ----升级水手技能

local MAIN_SKILL = 1 --主技能

local MAIN_SKILL_NUM = 2
local SKILL_NUM = 5
local SKILL_MAX_LEVEL = 5

function ClsPartnerInfoView:getViewConfig()
	return {
		is_back_bg = true,     
		effect = UI_EFFECT.DOWN,
	}
end

----小伙伴界面skill的位置
function ClsPartnerInfoView:onEnter(sailor_data, tab_tag, skill_pos, is_up_star)
	self.m_zhandouli  = getGameData():getPlayerData():getBattlePower()
	if tab_tag then
		self.select_panel = tab_tag 
	end

	if skill_pos then
		self.skill_pos = skill_pos
	end

	if is_up_star then
		self.is_up_star = is_up_star
	end

	self.key_open_list = {}
	self.sailor_data = sailor_data

	self.plist = {
		["ui/skill_icon.plist"] = 1,
		["ui/partner.plist"]  = 1,
		["ui/fleet_ui.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
		["ui/item_box.plist"] = 1,
		["ui/baowu.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.is_up_level = false

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner.json")

	self:addWidget(self.panel)

	audioExt.playEffect(music_info.PAPER_STRETCH.res)

	self:initUI()
end

function ClsPartnerInfoView:initUI()
	self.btns = {}
	for k, v in pairs(btn_name) do
		self[v.res] = getConvertChildByName(self.panel, v.res)
		self.btns[#self.btns + 1] = self[v.res]
		self[v.lab] = getConvertChildByName(self.panel, v.lab)
		self[v.res]:addEventListener(function ()
			setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		end,TOUCH_EVENT_BEGAN)

		if v.on_off_key then
			self[v.res].on_off_key = v.on_off_key
			self.key_open_list[v.on_off_key] = self[v.res]
			local onOffData = getGameData():getOnOffData()
			-- onOffData:pushOpenBtn(v.on_off_key, {openBtn = self[v.res], openEnable = true, addLock = true,
			--     btn_scale = 0.75, btnRes = "#common_btn_tab1.png", parent = "ClsPartnerInfoView"})
			if not onOffData:isOpen(v.on_off_key) then
				self[v.res]:setVisible(false)
			end
		end

		self[v.res]:addEventListener(function ()
			setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end,TOUCH_EVENT_CANCELED)        
		
		self[v.res]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:selectBtnTab(k)
		end,TOUCH_EVENT_ENDED)
	end

	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self:initBtn()
	self:updatePartnerInfo()

	local defuse = self.select_panel or TAB_ATTR
	self:selectBtnTab(defuse)

	if self.skill_pos and self.select_panel == TAB_SKILL then
		local index = self.skill_pos or 1

		self.skill_bg[index]:executeEvent(TOUCH_EVENT_BEGAN)
		self.skill_bg[index]:executeEvent(TOUCH_EVENT_ENDED)
	end   

	--self.btns[defuse]:executeEvent(TOUCH_EVENT_ENDED)
end

function ClsPartnerInfoView:selectBtnTab(tab)
	self.select_panel = tab

	for k,v in pairs(btn_name) do
		self[v.res]:setFocused(tab == k)
		self[v.res]:setTouchEnabled(tab ~= k)

		local color = COLOR_TAB_UNSELECTED
		if tab == k then
			color = COLOR_TAB_SELECTED
		end
		setUILabelColor(self[v.lab], ccc3(dexToColor3B(color)))   
	end 
	self:updatePanelView()     
end

function ClsPartnerInfoView:open(key)
	if self.key_open_list[key] and not tolua.isnull(self.key_open_list[key]) then
		self.key_open_list[key]:setVisible(true)
	end
end

function ClsPartnerInfoView:updatePanelView()
	self:showPanelView(self.select_panel)

	self.last_select_skill = nil

	if self.select_panel == TAB_ATTR then
		self:updateAttrPanel()
	elseif self.select_panel == TAB_SKILL then
		self:updateSkillPanel()
	end 
	ClsGuideMgr:tryGuide("ClsPartnerInfoView")      
end

function ClsPartnerInfoView:updatePartnerInfo()
	local partner_name = {
		"captain_head",
		"seaman_name",
		"btn_exp_add",
		"exp_progress",
		"captain_level",
		"exp_num",   
		"star_panel",
		"job_icon",
		"sailor_level",
		"personality_tips", ---优先
		"personality_info",  ---个性 
		--"star_all_num",
		"star_cost_num",
		--"star_num",
		"star_now_num",
		"btn_star_text",
		"btn_star",
		"star_icon",
		--"btn_wake",
		"star_icon",
	}  
	for k, v in pairs(partner_name) do
		self[v] = getConvertChildByName(self.partners_panel, v)
	end
	local config = sailor_info[self.sailor_data.id]

	self.seaman_name:setText(self.sailor_data.name)
	self.captain_head:changeTexture(config.res, UI_TEX_TYPE_LOCAL)

	local seaman_width = self.captain_head:getContentSize().width
	self.captain_head:setScale(108 / seaman_width)

	self.sailor_level:changeTexture(STAR_SPRITE_RES[self.sailor_data.star].big, UI_TEX_TYPE_PLIST)

	--职业
	self.job_icon:changeTexture(JOB_RES[config.job[1]] ,UI_TEX_TYPE_PLIST)
	local pos = self.seaman_name:getPosition()
	local size = self.seaman_name:getContentSize()
	local size_pic = self.job_icon:getContentSize()
	self.job_icon:setPosition(ccp(pos.x-size.width/2-size_pic.width/2,pos.y))
	--星星
	self.stars = {}
	--self.pos_world = {}
	for i = 1, 5 do
		self["star_"..i] = getConvertChildByName(self.star_panel, "star_" .. i)
		self.stars[i] = self["star_"..i]
		self["star_"..i]:setVisible(i <= self.sailor_data.starLevel)

		--local pos = self["star_"..i]:getPosition()
		--local pos_world = self["star_"..i]:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
		---self.pos_world[i] = pos_world
	end
	self.old_star_level = self.sailor_data.starLevel

	---升级按钮，进度条，经验值,等级
	self.btn_exp_add:setPressedActionEnabled(true)
	self.btn_exp_add:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local pos = self:convertToWorldSpace(ccp(130, 173))

		self.tips = getUIManager():create("gameobj/partner/clsUpExpTips", {}, self, self.sailor_data.id , pos)

	end,TOUCH_EVENT_ENDED)

	local sailor_star = self.sailor_data.star
	local exp = SAILOR_STAR_EXP[sailor_star]
	local max_exp = sailor_exp_info[self.sailor_data.level][exp]
	local old_exp_percent = self.sailor_data.exp / max_exp * 100
	self.exp_progress:setPercent(old_exp_percent)

	self.exp_num:setText(string.format(ui_word.PARTNER_INFO_EXP, self.sailor_data.exp, max_exp))
	self.captain_level:setText(string.format("Lv.%s", self.sailor_data.level))
	self.old_level = self.sailor_data.level

	---个性
	self.personality_info:setText(config.nature)
	---优先攻击
	self.personality_tips:setText(config.nature_dec)

	--升星按钮
	if self.sailor_data.starLevel == MAX_SATR_LEVEL then
		self.btn_star_text:setText(ui_word.SAILOR_USE_GOODS_ADD_GRADE_TIPS)
	else
		self.btn_star_text:setText(ui_word.SAILOR_USE_GOODS_ADD_STAR_TIPS)
	end

	self.btn_star:setPressedActionEnabled(true)
	self.btn_star:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:upSailorStar()
	end, TOUCH_EVENT_ENDED)

	---星章
	self:updateAttrStarNum()
	local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.UPSTAR.value, {openBtn = self.btn_star, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsPartnerInfoView"})  
	onOffData:pushOpenBtn(on_off_info.SALILOR_DEVELOP_UPGRADE.value, {openBtn = self.btn_exp_add, openEnable = true, 
		addLock = true, btnRes = "#common_mark_add2.png", parent = "ClsPartnerInfoView"})  

	ClsGuideMgr:tryGuide("ClsPartnerInfoView") 

	if self.is_up_star then
		self.btn_star:disable()
		self.btn_exp_add:disable()
	end
end

function ClsPartnerInfoView:updateAttrStarNum()
	local config = sailor_info[self.sailor_data.id]

	---升星需要道具数量，id
	local up_star_need_num = sailor_op_config[self.sailor_data.star].upstar_consume_count 
	local up_star_item_id = sailor_op_config[self.sailor_data.star].upstar_consume 

	---升阶需要道具数量，id
	if self.sailor_data.starLevel == MAX_SATR_LEVEL then
		up_star_need_num = sailor_op_config[self.sailor_data.star].upstep_consume_count 
		up_star_item_id = sailor_op_config[self.sailor_data.star].upstep_consume 
	end

	local propDataHandle = getGameData():getPropDataHandler()
	local item = propDataHandle:hasPropItem(up_star_item_id)
	local have_num = 0
	if item then
		have_num = item.count
	end

	self.star_cost_num:setText(have_num)
	self.star_now_num:setText(string.format("/%s", up_star_need_num))

	if have_num < up_star_need_num then
		setUILabelColor(self.star_cost_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.star_cost_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end

	self.star_icon:changeTexture(SAILOR_UP_STAR_ITEM_PIC[up_star_item_id] ,UI_TEX_TYPE_PLIST)
	local star_level = self.sailor_data.starLevel
	local star = self.sailor_data.star 
	if star_level == MAX_SATR_LEVEL and (star == MAX_SATR or star == LEGEND_SAILOR_STAR)then
		self.star_now_num:setVisible(false)
		self.star_cost_num:setVisible(false)
		self.star_icon:setVisible(false)
	else
		self.star_now_num:setVisible(true)
		self.star_cost_num:setVisible(true)
		self.star_icon:setVisible(true)       
	end
end

function ClsPartnerInfoView:updateAttrPanel()
	local attr_name = {
		"far_num",
		"near_num",
		"defense_num",
		"long_num",
		"circle",
	}

	for k, v in pairs(attr_name) do
		self[v] = getConvertChildByName(self.property_panel, v)
	end

	local attrs = {}

	for k, v in pairs(self.sailor_data.attrs) do
		if v.attrName == "durable" then
			attrs.durable = v.attrValue
			attrs.maxDurable = v.attrRadarVertex
		elseif v.attrName == "defense" then
			attrs.defense = v.attrValue
			attrs.maxDefense = v.attrRadarVertex

		elseif v.attrName == "remote" then
			attrs.remote = v.attrValue
			attrs.maxRemote = v.attrRadarVertex

		elseif v.attrName == "melee" then
			attrs.melee = v.attrValue
			attrs.maxMelee = v.attrRadarVertex
		end

	end

	if self.old_attrs_remote then
		UiCommon:numberEffect(self.far_num, self.old_attrs_remote, attrs.remote)
		UiCommon:numberEffect(self.near_num, self.old_attrs_melee, attrs.melee)
		UiCommon:numberEffect(self.defense_num, self.old_attrs_defense, attrs.defense)
		UiCommon:numberEffect(self.long_num, self.old_attrs_durable, attrs.durable)
	else
		self.far_num:setText(attrs.remote)
		self.near_num:setText(attrs.melee)
		self.defense_num:setText(attrs.defense)
		self.long_num:setText(attrs.durable)     
	end

	self.old_attrs_remote = attrs.remote
	self.old_attrs_melee = attrs.melee
	self.old_attrs_defense = attrs.defense
	self.old_attrs_durable = attrs.durable   

	---多边形
	if not tolua.isnull(self.draw_node) then
		self.draw_node:removeFromParentAndCleanup(true)
	end
	local attr_list = {
		attrs.remote/attrs.maxRemote,
		attrs.melee/attrs.maxMelee,
		attrs.defense/attrs.maxDefense, 
		attrs.durable/attrs.maxDurable
	}

	local max_num = 1---self:getMaxNum(attr_list)
	local radius  = 74 
	local draw_node = self:drawLine(max_num, attr_list, radius)
	self.circle:addCCNode(draw_node)
	self.draw_node = draw_node 
end

function ClsPartnerInfoView:drawLine(max_num ,attr_list, radius)
	
	local max = max_num
	local far = attr_list[1]*(radius / max)
	local naer = attr_list[2]*(radius / max)
	local defense = 0 - attr_list[3]*(radius / max)
	local long = 0 - attr_list[4]*(radius / max)

	local layer = UILayer:create()
	local draw_node = CCDrawNode:create()
	local color = ccc4f(1, 0, 0, 0.2)
	local border_color = ccc4f(1, 0, 0, 0.2)
	local points = CCPointArray:create(4)

	points:add(ccp(0, far))
	points:add(ccp(long, 0))
	points:add(ccp(0, defense))
	points:add(ccp(naer, 0))
	draw_node:drawPolygon(points, color, 1, border_color)
	layer:addChild(draw_node)
	return layer
end

function ClsPartnerInfoView:getMaxNum(attr)
	local max_num = 0  
	for i = 1, #attr do
		if max_num < attr[i] then
			max_num = attr[i]
		end
	end
	return max_num  
end

function ClsPartnerInfoView:clearTips()
	if getUIManager():get("ClsPartnerSkillBookTips") then
		getUIManager():get("ClsPartnerSkillBookTips"):close()
	end
	if getUIManager():get("clsRoleSkillTips") then
		getUIManager():get("clsRoleSkillTips"):close()
	end

	if getUIManager():get("ClsUpExpTip") then
		getUIManager():get("ClsUpExpTip"):close()
	end

	self.skill_pos = nil
end

function ClsPartnerInfoView:updateSkillPanel()
	local skill_name = {
		"btn_change",
		"btn_up",
		"skill_details_icon",
		"skill_details_name",
		"skill_details_text_2",
		"skill_details_text_1",
		"skill_details_level",
		--"text_btn_panel",
		"skill_btn_panel",
		"skill_details_name_0",
		"skill_details_time", ---冷却时间
	}
	for k, v in pairs(skill_name) do
		self[v] = getConvertChildByName(self.skill_panel, v)
	end

	local skill_guide_layer = CCLayer:create()
	self.skill_panel:addCCNode(skill_guide_layer)

	--E,D,C,B,A,S
	self.skill_book = {165, 165, 166, 167, 168, 169} --水手品质对应的技能书

	---local config = sailor_info[self.sailor_data.id]
	local config = sailor_op_config[self.sailor_data.star]
	local partner_data = getGameData():getPartnerData()

	self.skill_bg = {}    
	for i=1,SKILL_NUM do
		---技能背景
		self["skill_passivity_bg_"..i] = getConvertChildByName(self.skill_panel, "skill_passivity_bg_" .. i)

		self["skill_passivity_bg_"..i]:setVisible(config.skill_solt + MAIN_SKILL_NUM >= i)
		self.skill_bg[i] = self["skill_passivity_bg_"..i]

		self["skill_passivity_bg_"..i]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if not self.is_up_star then
				self:createSkillTips(i,TYPE_ADD_SKILL) 
			end
		   
		end, TOUCH_EVENT_ENDED)

		---选中背景
		local skill_selected_bg = getConvertChildByName(self.skill_panel, "skill_selected_" .. i)
		self.skill_bg[i].skill_selected_bg = skill_selected_bg

		---加号
		local skill_add = getConvertChildByName(self.skill_panel, "skill_add_" .. i)
		skill_add:setOpacity(100)
		self.skill_bg[i].skill_add = skill_add

		---名字框 
		local text_panel = getConvertChildByName(self.skill_panel, "text_panel_" .. i)
		text_panel:setVisible(false)
		self.skill_bg[i].text_panel = text_panel

		---名字
		local name = getConvertChildByName(self.skill_panel, "skill_name_" .. i)
		self.skill_bg[i].name = name

		---等级
		local level = getConvertChildByName(self.skill_panel, "skill_level_" .. i)
		self.skill_bg[i].level = level

		---主动图标
		local skill_main_pic = getConvertChildByName(self.skill_panel, "skill_activity_bg_" .. i)
		self.skill_bg[i].skill_main_pic = skill_main_pic 
	end


	local skills = DataTools:getSkillInfo(self.sailor_data)

	local sailor_data = getGameData():getSailorData()
	for k, v in pairs(skills) do
		local skill_bg = self.skill_bg[v.pos]
		skill_bg.skill_id = v.id
		local skill = skill_info[v.id]

		--背景框
		skill_bg:changeTexture(SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)
		skill_bg.skill_quality = SAILOR_SKILL_BG[skill.quality]
		--名字
		skill_bg.name:setText(skill.name)

		skill_bg.skill_main_pic:setVisible(skill.initiative == MAIN_SKILL)

		--等级
		skill_bg.level:setText(string.format("Lv.%s / Lv.%s", v.level, skill.max_lv))          
		if v.pos > MAIN_SKILL_NUM then
			skill_bg.level:setText(string.format("Lv.%s / Lv.%s", v.level, SKILL_MAX_LEVEL)) 
		end
	  

		skill_bg:addEventListener(function()
			if self.last_select_skill ~= v.pos then
				skill_bg:changeTexture(skill_bg.skill_quality, UI_TEX_TYPE_PLIST)
			end
		end, TOUCH_EVENT_CANCELED)

		skill_bg.skill_add:setOpacity(255)
		skill_bg.skill_add:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)
		skill_bg.text_panel:setVisible(true)


		skill_bg:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if self.last_select_skill and self.last_select_skill ~= v.pos then
				self.skill_bg[self.last_select_skill]:changeTexture(self.skill_bg[self.last_select_skill].skill_quality, UI_TEX_TYPE_PLIST)
			end

			self.skill_details_icon:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)
			self.skill_details_name:setText(skill.name)
			self.skill_details_level:setText(string.format("(Lv.%s)", v.level))

			---技能描述
			local desc_tab = sailor_data:getColorSkillDescWithLv(v.id, v.level, self.sailor_data.id)
			local skill_des = desc_tab.base_desc
			if skill.skill_ex_id == "" then
				skill_des = desc_tab.base_desc..desc_tab.child_desc
			end
			if self.rich_label then
				self.rich_label:removeFromParentAndCleanup(true)
				self.rich_label= nil  
			end
			self.rich_label = createRichLabel(skill_des, 243, 60, 14)
			self.rich_label:setAnchorPoint(ccp(0,1))
			local set_y = 0 
			if skill.max_level_des == "" then
				set_y = -10
			end
			self.rich_label:setPosition(ccp(0,set_y))
			self.skill_details_text_2:addCCNode(self.rich_label)
			self.skill_details_text_2:setText("")

			--self.skill_details_text_1:setVisible(skill.max_level_des ~= "")
			local max_level_str = string.format("$(c:COLOR_CAMEL)%s%s%s",ui_word.SAILOR_SKILL_MAX_LEVEL_LAB,skill.max_level_des,ui_word.MAX_SKILL_NO_ACTIVE)
			if v.level >= skill.max_lv then
				max_level_str = string.format("$(c:COLOR_CAMEL)%s$(c:COLOR_GREEN)%s$(c:COLOR_CAMEL)%s",ui_word.SAILOR_SKILL_MAX_LEVEL_LAB,skill.max_level_des,ui_word.MAX_SKILL_ACTIVE)
			end

			if skill.max_level_des == "" then
				max_level_str = ""
			end

			if self.max_level_lable then
				self.max_level_lable:removeFromParentAndCleanup(true)
				self.max_level_lable = nil  
			end

			local size = self.rich_label:getSize()
			--local lab = string.format("$(c:COLOR_CAMEL)%s",ui_word.SAILOR_SKILL_MAX_LEVEL_LAB)
			self.max_level_lable = createRichLabel(max_level_str, 243, 60, 14)

			self.max_level_lable:setAnchorPoint(ccp(0,1))

			self.max_level_lable:setPosition(ccp(0, -size.height -6))
			self.skill_details_text_2:addCCNode(self.max_level_lable)
			self.skill_details_text_1:setText("")

			self.skill_details_time:setText(string.format(ui_word.SAILOR_SKILL_COOL_TIME, skill.cooling_time))
			self.skill_details_time:setVisible(skill.cooling_time ~= 0)
		  
			self.skill_btn_panel:setTouchEnabled(true)
			self.skill_btn_panel:addEventListener(function ()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)

				local pos = self.skill_btn_panel:convertToWorldSpace(ccp(-205, 65))
				local temp = {}
				temp.pos = pos
				temp.skill = v.id
				temp.skill_level = v.level
				temp.sailor_id = self.sailor_data.id
				--self.tips = ClsRoleSkillTips.new(self, temp, true)
				self.tips = getUIManager():create("gameobj/playerRole/clsRoleSkillTips",{},self, temp, true)
	
			end, TOUCH_EVENT_ENDED)

			self.last_select_skill = v.pos

			for i=1,SKILL_NUM do
				self.skill_bg[i].skill_selected_bg:setVisible(i == self.last_select_skill)
			end
			self.btn_change:setVisible(self.last_select_skill > MAIN_SKILL_NUM)
			self.btn_change:setTouchEnabled(self.last_select_skill > MAIN_SKILL_NUM)
			self.btn_up:setVisible(self.last_select_skill > MAIN_SKILL_NUM)
			self.btn_up:setTouchEnabled(self.last_select_skill > MAIN_SKILL_NUM)  

		end, TOUCH_EVENT_ENDED)
	end


	if #skills > 0 then
		local index = self.last_select_skill or 1

		if index <= #skills then
			self.skill_bg[index]:executeEvent(TOUCH_EVENT_BEGAN)
			self.skill_bg[index]:executeEvent(TOUCH_EVENT_ENDED)
		end

		if #skills <= MAIN_SKILL_NUM then
			self.btn_change:setVisible(false)
			self.btn_change:setTouchEnabled(false)
			self.btn_up:setVisible(false)
			self.btn_up:setTouchEnabled(false)         
		end
	end

	--更换按钮
	self.btn_change:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local skill_id = self.skill_bg[self.last_select_skill].skill_id 
		self:createSkillTips(self.last_select_skill, TYPE_EXCHAGE_SKILL, skill_id)
	end, TOUCH_EVENT_ENDED)

	--升级按钮
	self.btn_up:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local skill_id = self.skill_bg[self.last_select_skill].skill_id 
		self:createSkillTips(self.last_select_skill, TYPE_UP_SKILL, skill_id)
	end, TOUCH_EVENT_ENDED)


	if self.is_up_star then
		self.btn_up:disable()
		self.btn_change:disable()
	end
end

function ClsPartnerInfoView:setSelectSkillTips(pos)
	self.last_select_skill = pos 
end

function ClsPartnerInfoView:createSkillTips(skill_pos, skill_add_type, skill_id)
	local pos = self:convertToWorldSpace(ccp(145, 40))

	if getUIManager():get("ClsPartnerSkillBookTips") then
		getUIManager():get("ClsPartnerSkillBookTips"):close()
	end
	self.tips = getUIManager():create("gameobj/partner/clsPartnerSkillBookTips",{},self, self.sailor_data.id , pos, skill_pos, skill_add_type, skill_id)
end

function ClsPartnerInfoView:showPanelView(tab)  
	self.property_panel:setVisible(TAB_ATTR == tab)
	self.skill_panel:setVisible(TAB_SKILL == tab)
end


function ClsPartnerInfoView:excFun()
	local sailorData = getGameData():getSailorData()
	--sailorData:saveFireSailorId(self.sailor_data.id)
	sailorData:upStepNewSailor(self.sailor_data.id)
end

function ClsPartnerInfoView:showTip(sailor)
	 local star = {
		"D",
		"C",
		"B",
		"A",
		"S",
		"S",
	}

	self:excFun()
end

--升星
function ClsPartnerInfoView:upSailorStar()
	self.btn_star:setTouchEnabled(false)

	local sailor = self.sailor_data
	local config = sailor_info[sailor.id]  

	local star = sailor.star
	local starLevel = sailor.starLevel

	--S级5星
	if star > MAX_SATR_LEVEL and starLevel >= MAX_SATR_LEVEL then
		Alert:warning({msg = ui_word.THIS_SAILOR_MAX_STEP, size = 26})---THIS_SAILOR_MAX_STEPUP_TO_MAX_STEP
		self.btn_star:setTouchEnabled(true)
		return
	end

	local up_star_item_id = sailor_op_config[sailor.star].upstar_consume
	if sailor.starLevel >= MAX_SATR_LEVEL then
		up_star_item_id = sailor_op_config[sailor.star].upstep_consume
	end

	local propDataHandle = getGameData():getPropDataHandler()
	local item = propDataHandle:hasPropItem(up_star_item_id)

	local need_num = 0
	if item then
		need_num = item.count
	end

	---升阶
	local consume_upstep = sailor_op_config[sailor.star].upstep_consume_count
	if sailor.starLevel >= MAX_SATR_LEVEL then --升阶换高级航海士
		local upstep_need_star = consume_upstep
		if need_num < upstep_need_star then
			Alert:showJumpWindow(CHAPTER_STAR_NOT_ENOUGH, self)
		else
			self:showTip(sailor)                        
		end
		self.btn_star:setTouchEnabled(true) 
		return
	end

	---升星
	local consume_upstar = sailor_op_config[sailor.star].upstar_consume_count
	local up_star_need_num = consume_upstar or 0
	--如果航海星章不足提示
	if need_num < up_star_need_num then
		Alert:showJumpWindow(CHAPTER_STAR_NOT_ENOUGH, self)
		self.btn_star:setTouchEnabled(true)
		return
	end

	local sailor_data = getGameData():getSailorData()
	sailor_data:askForUpStep(sailor.id)
end

function ClsPartnerInfoView:initBtn()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		--audioExt.playEffect(music_info.PAPER_STRETCH.res)
		
		self:closeView()
	end,TOUCH_EVENT_ENDED)
	
end

---升星刷新
function ClsPartnerInfoView:updateStarNum()
	audioExt.playEffect(music_info.SAILOR_STAR_UP.res)

	local sailor = self.sailor_data
	local d_star = sailor.starLevel - self.old_star_level

	if d_star > 0 then
		
		for k, v in pairs(self.stars) do
			v:setVisible(k <= sailor.starLevel)
			if k == sailor.starLevel then
				local effect_tx = "tx_0024" 
				local effect_bg = CompositeEffect.new(effect_tx, 0, 0, v, nil, nil, nil, nil, true)
				effect_bg:setScale(0.44)
			end
		end

		if sailor.starLevel == MAX_SATR_LEVEL then
			self.btn_star_text:setText(ui_word.SAILOR_USE_GOODS_ADD_GRADE_TIPS)
		else
			self.btn_star_text:setText(ui_word.SAILOR_USE_GOODS_ADD_STAR_TIPS)
		end

		self.btn_star:setTouchEnabled(true)
		self.old_star_level = sailor.starLevel
	else
		for k, v in pairs(self.stars) do
			v:setVisible(k <= sailor.starLevel)
		end
		self.btn_star:setTouchEnabled(true)
	end

	self:updateStarView()
end

---刷新星章显示
function ClsPartnerInfoView:updateStarView()
 
	if getUIManager():isLive("ClsSailorListView") then
		getUIManager():get("ClsSailorListView"):updateStarNum()
	end
	self:updateAttrStarNum()  
end

function ClsPartnerInfoView:getUpLevelSailorId()
	return self.sailor_data.id
end

----升级刷新
function ClsPartnerInfoView:updateExpNum(data,call_back)

	-- local sailor = self.sailor_data
	-- local sailor_id = sailor.id


	local sailor = data

	local d_level = sailor.level - self.old_level
	--经验进度
	local exp = SAILOR_STAR_EXP[sailor.star]
	local max_exp = sailor_exp_info[sailor.level][exp]

	local cur_exp_percent = sailor.exp / max_exp * 100
	local time = DURATION * cur_exp_percent / 100
	self.call_back = call_back

	if d_level > 0 then
		local arr = CCArray:create()
		for i = 1, d_level do
			arr:addObject(CCCallFunc:create(function()
				self:progressAction(self.exp_progress, 100, DURATION) 
				if self.sailor_upgrade then
					self.sailor_upgrade:removeFromParentAndCleanup(true)
					self.sailor_upgrade = nil 
				end
				self.sailor_upgrade = CompositeEffect.new("tx_sailor_upgrade", 0, 0, self.exp_progress, nil, nil, nil, nil, true)

				audioExt.playEffect(music_info.SAILOR_LEVEL_UP.res) 
				if self.old_level < sailor.level then
					UiCommon:numberEffect(self.captain_level,tonumber(self.old_level), tonumber(self.old_level)+1, nil, nil, "Lv.")
					self.old_level = self.old_level + 1  
				end
				  
			end))
			arr:addObject(CCDelayTime:create(DURATION))
			arr:addObject(CCCallFunc:create(function()
				self.exp_progress:setPercent(0)
			end)) 
		end

		arr:addObject(CCCallFunc:create(function()
			self:progressAction(self.exp_progress, cur_exp_percent, time)         
			--等级
			self.exp_num:setText(string.format(ui_word.PARTNER_INFO_EXP, sailor.exp, max_exp))
			self.old_level = sailor.level
			call_back()              
		end))

		local endSeq = CCSequence:create(arr)
		self.exp_progress:runAction(endSeq)
	else
		self:progressAction(self.exp_progress, cur_exp_percent, time)
		UiCommon:numberEffect(self.captain_level, tonumber(sailor.level), tonumber(sailor.level), nil, nil, "Lv.")
		self.exp_num:setText(string.format(ui_word.PARTNER_INFO_EXP, sailor.exp, max_exp))
		call_back()
	end

	self.is_up_level = true
end


function ClsPartnerInfoView:progressAction(progressBar, cur, time)
	if not tolua.isnull(progressBar) then
		local lastPercent = progressBar:getPercent()
		local runTime = (cur - lastPercent) * time / 100
		
		LoadingAction.new(cur, lastPercent, runTime, progressBar)
	end
end

function ClsPartnerInfoView:closeView()
	self:close()

	if getUIManager():isLive("ClsSailorListView") then
		getUIManager():get("ClsSailorListView"):closeSailorViewCB()
	end

	if getUIManager():isLive("clsAppointSailorUI") then
		getUIManager():get("clsAppointSailorUI"):closeSailorViewCB()
	end

	if getUIManager():isLive("ClsFleetPartner") then
		getUIManager():get("ClsFleetPartner"):initData()
	end

	local clsSailorRecruitView = getUIManager():get("clsSailorRecruitView")
	if  clsSailorRecruitView and not tolua.isnull(clsSailorRecruitView)then
		clsSailorRecruitView:setButtonTouch(true)
	end
end

function ClsPartnerInfoView:upStepRefreshUI()

	audioExt.playEffect(music_info.SAILOR_LETTER_UP.res)
	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function (  )

		local star_effect = CompositeEffect.new("tx_sailor_trans_appear", 71, 14, self.star_panel, 2,function (  )
			self:creaetFlyEffect()
		end , nil, nil, true)
		
		for i=1,5 do
			self["star_"..i]:setVisible(false)
		end        
	end))

	array:addObject(CCDelayTime:create(3))
	array:addObject(CCCallFunc:create(function (  )
		self:initUI()
	end))
	self:runAction(CCSequence:create(array))   
end


function ClsPartnerInfoView:creaetFlyEffect()

	local pos = self.sailor_level:getPosition()
	local pos_world = self.sailor_level:getParent():convertToWorldSpace(ccp(pos.x,pos.y))
	local array = CCArray:create()
	for i=1,5 do
		array:addObject(CCCallFunc:create(function (  )
			local params = {}
			local fly_effect = CompositeEffect.new("tx_sailor_trans_fly", 0, 0, self)
			local pos_star = self["star_"..i]:getPosition()
			local pos_star_world = self["star_"..i]:getParent():convertToWorldSpace(ccp(pos_star.x, pos_star.y))

			params.x = pos_star_world.x
			params.y = pos_star_world.y
			params.tx = pos_world.x
			params.ty = pos_world.y
			params.onComplete = function ()
				fly_effect:removeFromParentAndCleanup(true)
				fly_effect = nil 
				CompositeEffect.new("tx_sailor_trans", 0, 0, self.sailor_level, nil, nil, nil, nil, true)
			end
			fly_effect:shootTo(params)            
		end))
		array:addObject(CCCallFunc:create(function ( )
				self:shakeScene()
		end))
		array:addObject(CCDelayTime:create(0.1))

	end
	self:runAction(CCSequence:create(array))
end

function ClsPartnerInfoView:shakeScene()
	local runScene = GameUtil.getRunningScene() 
	local array = CCArray:create()
	array:addObject(CCMoveBy:create(0.05, ccp(0,3)))
	array:addObject(CCMoveBy:create(0.05, ccp(-3,0)))
	array:addObject(CCMoveBy:create(0.05, ccp(0,-3)))
	array:addObject(CCMoveBy:create(0.05, ccp(3,0)))
	array:addObject(CCCallFunc:create(function ()
		runScene:setPosition(ccp(0,0))
	end))
	local actionc = CCRepeat:create(CCSequence:create(array), 1)
	runScene:runAction(actionc) 
end


function ClsPartnerInfoView:getCloseBtn()
	return self.btn_close
end


function ClsPartnerInfoView:onExit()
	UnLoadPlist(self.plist)
end

function ClsPartnerInfoView:onFinish()
	if self.call_back then
		self.call_back()
	end

	if self.is_up_level then
		local curZhandouli  = getGameData():getPlayerData():getBattlePower()
		if(curZhandouli > self.m_zhandouli)then
			local DialogQuene = require("gameobj/quene/clsDialogQuene")
			local clsBattlePower = require("gameobj/quene/clsBattlePower")
			DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = curZhandouli,oldPower = self.m_zhandouli}))
		end
	end
end

return ClsPartnerInfoView