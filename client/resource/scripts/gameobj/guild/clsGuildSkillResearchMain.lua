
---商会技能研究所主界面

local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")

local guild_skill_speed = require("game_config/guild/guild_skill_speed")
local guild_skill_remote = require("game_config/guild/guild_skill_remote")
local guild_skill_defense = require("game_config/guild/guild_skill_defense")
local guild_skill_durable = require("game_config/guild/guild_skill_durable")
local guild_skill_melee = require("game_config/guild/guild_skill_melee")
local guild_skill_load = require("game_config/guild/guild_skill_load")

local guild_skill_study_speed = require("game_config/guild/guild_skill_study_speed")
local guild_skill_study_remote = require("game_config/guild/guild_skill_study_remote")
local guild_skill_study_defense = require("game_config/guild/guild_skill_study_defense")
local guild_skill_study_durable = require("game_config/guild/guild_skill_study_durable")
local guild_skill_study_melee = require("game_config/guild/guild_skill_study_melee")
local guild_skill_study_load = require("game_config/guild/guild_skill_study_load")

local guild_skill_info = require("game_config/guild/guild_skill_info")
local guild_skill_lv_control = require("game_config/guild/guild_skill_lv_control")

local goods_info = require("game_config/port/goods_info")

local ClsGuildSkillResearchMain = class("ClsGuildSkillResearchMain",ClsBaseView)


local RESEARCH_TAB_TAG = 1
local STUDY_TAB_TAG = 2
local BOAT_DONATE_TAB_TAG = 3

local SKILL_NUM = 6
local GOODS_NUM = 4

---技能的层数8
local SKILL_MAX_LEVEL = 8
---每层技能学习5级
local STUDY_SKILL_MAX_LEVEL = 5

local tab_name = {
    {res = "tab_research", lab = "tab_research_txt", },
    {res = "tab_study", lab = "tab_study_txt"},	
    -- {res = "tab_build", lab = "tab_build_txt", on_off_key = on_off_info.GRADUATE_BUILD.value, task_keys = {on_off_info.GRADUATE_BUILD_BUILDBUTTON.value}},
}


local study_skill_key_goods = {
	["remote"] = guild_skill_remote,
	["melee"] = guild_skill_melee,
	["durable"] = guild_skill_durable,
	["defense"] = guild_skill_defense,
	["load"] = guild_skill_load,
	["speed"] = guild_skill_speed,
}


local skill_key_goods = {
	["remote"] = guild_skill_study_remote,
	["melee"] = guild_skill_study_melee,
	["durable"] = guild_skill_study_durable,
	["defense"] = guild_skill_study_defense,
	["load"] = guild_skill_study_load,
	["speed"] = guild_skill_study_speed,	
}


function ClsGuildSkillResearchMain:getViewConfig()
    return {
        is_back_bg = true,
        effect = UI_EFFECT.DOWN,
    }
end


function ClsGuildSkillResearchMain:onEnter(tab)
	self.res_plist ={
		["ui/guild_badge.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
		["ui/port_cargo.plist"] = 1,
	}
	LoadPlist(self.res_plist)
	self.is_finish_effect = false

	self.default = tab or 1 

	self:initUI()	
end

function ClsGuildSkillResearchMain:onCreateFinish(  )
    self.is_finish_effect = true
end

function ClsGuildSkillResearchMain:getDownEffectStatus(  )
	return self.is_finish_effect
end

function ClsGuildSkillResearchMain:initUI( )
	self.ui_layer = UIWidget:create()
	self.institute_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_institute.json")
	self.institute_panel:setVisible(false)
	convertUIType(self.institute_panel)
	self.ui_layer:addChild(self.institute_panel)
	self:addWidget(self.ui_layer)

	self.ui_title = getConvertChildByName(self.institute_panel, "ui_title")
	self.close_btn = getConvertChildByName(self.institute_panel, "close_btn")

	local on_off_data = getGameData():getOnOffData()
	local task_data = getGameData():getTaskData()
	for k,v in pairs(tab_name) do
		self[v.res] = getConvertChildByName(self.institute_panel, v.res)	
		self[v.lab] = getConvertChildByName(self.institute_panel, v.lab)	
		self[v.res]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:defaultSelectView(k)
		end,TOUCH_EVENT_ENDED)
		if v.on_off_key then
			self[v.res]:setVisible(on_off_data:isOpen(v.on_off_key))
		end
		if v.task_keys then
			task_data:regTask(self[v.res], v.task_keys, KIND_RECTANGLE, v.on_off_key, 74, 33, true)
		end
	end
    self:btnCallBack()
    self:updateUI()
end

function ClsGuildSkillResearchMain:open()
	local on_off_data = getGameData():getOnOffData()
	for k, v in pairs(tab_name) do
		if v.on_off_key then
			self[v.res]:setVisible(on_off_data:isOpen(v.on_off_key))
		end
	end
end


function ClsGuildSkillResearchMain:updateUI(  )
	self.institute_panel:setVisible(true)
	--local guild_research_data = getGameData():getGuildResearchData()
	--self.research_data = guild_research_data:getResearchData()
	--self.study_data = guild_research_data:getStudySkillData()

	--print("----------------商会研究所数据")
	--table.print(self.research_data)
	--table.print(self.study_data)

    self:defaultSelectView(self.default)	
end

function ClsGuildSkillResearchMain:updateGuildSkillLevel()
	local guild_research_data = getGameData():getGuildResearchData()
	local skill_complate_num, research_level = guild_research_data:getSkillComplateNumAndLimit()

	if not tolua.isnull(self.ui_title) then
		self.ui_title:setText(string.format(ui_word.STR_GUILD_SKILL_LEVEL_TAB,research_level))	
	end
end

function ClsGuildSkillResearchMain:btnCallBack(  )
	self.close_btn:setPressedActionEnabled(true)
	self.close_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		if not tolua.isnull(self.select_view) then
			self.select_view:close()
		end
		self:close()
	end,TOUCH_EVENT_ENDED)
end


function ClsGuildSkillResearchMain:defaultSelectView(tab)
	self.default = tab 
	for k,v in pairs(tab_name) do
		--self[v.panel]:setVisible(k == tab)
		self[v.res]:setFocused(tab == k)
		self[v.res]:setTouchEnabled(tab ~= k)

		if tab == k then
			setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
		end

	end
	if self.select_view then
		self.select_view:close()
		self.select_view = nil 
	end

	if tab == RESEARCH_TAB_TAG then
		self.select_view = getUIManager():create("gameobj/guild/clsGuildSkillResearchTab")
	elseif tab == STUDY_TAB_TAG then
		self.select_view = getUIManager():create("gameobj/guild/clsGuildSkillStudyTab")
	-- elseif tab == BOAT_DONATE_TAB_TAG then
	-- 	self.select_view = getUIManager():create("gameobj/guild/clsBoatDonateUI")
	end

end

function ClsGuildSkillResearchMain:closeMySelf(  )

	if not tolua.isnull(self.select_view) then
		self.select_view:close()
	end	
	self:close()
end


function ClsGuildSkillResearchMain:onExit( )
	UnLoadPlist(self.res_plist)
end

return ClsGuildSkillResearchMain