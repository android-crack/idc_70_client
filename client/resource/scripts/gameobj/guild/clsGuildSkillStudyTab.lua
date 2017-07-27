



local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")

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


local ClsGuildSkillStudyTab = class("ClsGuildSkillStudyTab",ClsBaseView)


local SKILL_NUM = 6
local GOODS_NUM = 4

---技能的层数8
local SKILL_MAX_LEVEL = 40
---每层技能学习5级
local STUDY_SKILL_MAX_LEVEL = 5

local skill_key_goods = {
	["remote"] = guild_skill_study_remote,
	["melee"] = guild_skill_study_melee,
	["durable"] = guild_skill_study_durable,
	["defense"] = guild_skill_study_defense,
	["load"] = guild_skill_study_load,
	["speed"] = guild_skill_study_speed,	
}


local study_skill_key_goods = {
	["remote"] = guild_skill_remote,
	["melee"] = guild_skill_melee,
	["durable"] = guild_skill_durable,
	["defense"] = guild_skill_defense,
	["load"] = guild_skill_load,
	["speed"] = guild_skill_speed,
}


local study_name = {
	"main_skill_icon",
	"skill_info_name",
	"skill_info_txt",
	"skill_lv_num_l",
	"skill_lv_num_r",
	"skill_effect_info_l",
	"skill_effect_info_r",
	"had_num",
	"need_num",
	"study_btn"
}

function ClsGuildSkillStudyTab:getViewConfig()
	local effect_type = UI_EFFECT.DOWN
	local ClsGuildSkillResearchMain = getUIManager():get("ClsGuildSkillResearchMain")

	if not tolua.isnull(ClsGuildSkillResearchMain) then
		local effect_status = ClsGuildSkillResearchMain:getDownEffectStatus()
		if effect_status then
			effect_type = 0
		end
	end
	
    return {
        is_swallow = false,
        effect = effect_type,
    }
end

function ClsGuildSkillStudyTab:onEnter(tab)
	self.res_plist ={
		-- ["ui/guild_badge.plist"] = 1,
		-- ["ui/guild_ui.plist"] = 1,
		-- ["ui/skill_icon.plist"] = 1,
		-- ["ui/item_box.plist"] = 1,
		-- ["ui/port_cargo.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self.default = tab or 1 
	self:initUI()
	self:askData()
end
function ClsGuildSkillStudyTab:initUI(  )

	self.m_zhandouli = getGameData():getPlayerData():getBattlePower()
	self.study_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_institute_learn.json")
	self.study_panel:setVisible(false)
	self:addWidget(self.study_panel)	
end

function ClsGuildSkillStudyTab:askData()
	local guild_research_data = getGameData():getGuildResearchData()
	guild_research_data:askResearchData()	
	guild_research_data:askStudyData()	
end

function ClsGuildSkillStudyTab:getBattlePower(  )
	return self.m_zhandouli
end

function ClsGuildSkillStudyTab:setBattlePower(power)
	self.m_zhandouli = power
end

function ClsGuildSkillStudyTab:initStudyView(  )
	self.study_panel:setVisible(true)

	local guild_research_data = getGameData():getGuildResearchData()
	self.research_data = guild_research_data:getResearchData()
	self.study_data = guild_research_data:getStudySkillData()

	for k,v in pairs(study_name) do
		self[v] = getConvertChildByName(self.study_panel, v)
	end

	--学习技能
	self.study_skill_btn = {}

	for i=1,SKILL_NUM do
		local skill_btn = getConvertChildByName(self.study_panel, "skill_"..i)
		self.study_skill_btn[i] = skill_btn

		local skill_icon = getConvertChildByName(self.study_panel, "skill_icon_"..i)
		self.study_skill_btn[i].skill_icon = skill_icon

		local skill_selected = getConvertChildByName(self.study_panel, "skill_selected_"..i)
		self.study_skill_btn[i].skill_selected = skill_selected

		local skill_level_num = getConvertChildByName(self.study_panel, "skill_level_num_"..i)
		self.study_skill_btn[i].skill_level_num = skill_level_num

	end

	self:updateStudyView(self.default_study_skill)
end


function ClsGuildSkillStudyTab:getSkillInfoByKay(key,data)
	for k,v in pairs(data) do
		if v.key == key then
			return v 
		end
	end
end

function ClsGuildSkillStudyTab:updateStudyView(tab)

	for k,v in pairs(guild_skill_info) do
		local btn = self.study_skill_btn[k]

		local skill_key = v.name

		local skill_info = self:getSkillInfoByKay(skill_key, self.study_data)
		local skill_level = skill_info.level

		local max_level = 0	

		if self.research_data then
			local guild_research_data = getGameData():getGuildResearchData()
			local skill_complate_num, research_level = guild_research_data:getSkillComplateNumAndLimit()
			--max_level = guild_skill_lv_control[research_level].skill_lv_limit
			local research_data = self:getSkillInfoByKay(skill_key, self.research_data)
			max_level = research_data.level
		end

		btn.skill_level_num:setText(string.format("%s/%s",skill_level, max_level))

		btn.skill_icon:changeTexture(convertResources(v.guild_skill_icon), UI_TEX_TYPE_PLIST)
		btn.skill_selected:setVisible(false)

		btn:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateStudySkillInfo(k)
		end, TOUCH_EVENT_ENDED)


	end

	self.default_study_skill = tab or 1
	self:updateStudySkillInfo(self.default_study_skill)
end

function ClsGuildSkillStudyTab:updateStudySkillInfo(tab)

	self.default_study_skill = tab 
	local skill_info = guild_skill_info[tab]

	local skill_key = skill_info.name

	local skill_data = self:getSkillInfoByKay(skill_key,self.study_data)
	local skill_level = skill_data.level
	local skill_level_next =  skill_level + 1

	if skill_level_next > SKILL_MAX_LEVEL then
		skill_level_next = SKILL_MAX_LEVEL
	end

	self.skill_lv_num_l:setText("Lv."..skill_level)
	self.skill_lv_num_r:setText("Lv."..skill_level_next)


	local skill_add = 0
	if study_skill_key_goods[skill_key][skill_level] then
		skill_add = study_skill_key_goods[skill_key][skill_level].skill_add
	end
	self.skill_effect_info_l:setText(skill_info.guild_skill_txt.."+"..skill_add)

	local skill_add_next = study_skill_key_goods[skill_key][skill_level_next].skill_add
	self.skill_effect_info_r:setText(skill_info.guild_skill_txt.."+"..skill_add_next)


	self.main_skill_icon:changeTexture(convertResources(skill_info.guild_skill_icon),UI_TEX_TYPE_PLIST)
	self.skill_info_name:setText(skill_info.guild_skill_name)
	self.skill_info_txt:setText(skill_info.guild_skill_desc)

	local guild_shop_data = getGameData():getGuildShopData()
	local contribute = guild_shop_data:getContribute()

	self.contribute = contribute
	self.had_num:setText(contribute)
	

	local skill_use_contribution = study_skill_key_goods[skill_key][skill_level_next].skill_use_contribution
	self.skill_use_contribution = skill_use_contribution

	self.need_num:setText(skill_use_contribution)

	if contribute < skill_use_contribution then
		setUILabelColor(self.had_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.had_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end

	for k,v in pairs(self.study_skill_btn) do
		v.skill_selected:setVisible(tab == k)
	end

	self.study_btn:setPressedActionEnabled(true)
	self.study_btn:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.contribute < skill_use_contribution then
			Alert:showJumpWindow(CONTRIBUTE_NOT_ENOUGH)
		else
			local guild_research_data = getGameData():getGuildResearchData()
			guild_research_data:askStudySkill(skill_key)			
		end

	end,TOUCH_EVENT_ENDED)	

end


function ClsGuildSkillStudyTab:updateContributionLab( )
	local guild_shop_data = getGameData():getGuildShopData()
	local contribute = guild_shop_data:getContribute()
	self.had_num:setText(contribute)
	if contribute < self.skill_use_contribution then
		setUILabelColor(self.had_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.had_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end
	self.contribute = contribute
end


function ClsGuildSkillStudyTab:onExit( )
	UnLoadPlist(self.res_plist)
end



return ClsGuildSkillStudyTab