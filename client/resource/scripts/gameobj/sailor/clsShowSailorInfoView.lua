


---fmy0570
---航海士详细界面
local DataTools = require("module/dataHandle/dataTools")
local skill_info = require("game_config/skill/skill_info")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local SailorJobs = require("game_config/sailor/id_job")
local tools = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local UiCommon = require("ui/tools/UiCommon")
local tool = require("module/dataHandle/dataTools")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local sailor_info = require("game_config/sailor/sailor_info")
local ClsBaseView = require("ui/view/clsBaseView")

local voice_info = getLangVoiceInfo()
local ClsShowSailorInfoView = class("ClsShowSailorInfoView", ClsBaseView)

local STAR_NUM = 5
local SKILL_NUM = 5

local attrs_name = {
	"long_num",
	"defense_num",
	"near_num",
	"far_num",
}

local aptitude_name = {
	"far_bar_num",
	"far_progress",
	"near_bar_num",
	"near_progress",
	"defense_bar_num",
	"defense_progress",
	"long_bar_num",
	"long_progress",
}

local sailor_name = {
	"job_icon",
	"sailor_level",
	"seaman_name",
	"personality_info",
	"personality_tips",
	"prestige_num",---声望
	"level_num",
	"captain_head",
	"btn_close"
}

function ClsShowSailorInfoView:getViewConfig()
    return { 
        is_back_bg = true, 
    }
end

function ClsShowSailorInfoView:onEnter(sailor_id)
	self.sailor_id = sailor_id
    self.plist = {
        ["ui/hotel_ui.plist"] = 1,
        ["ui/skill_icon.plist"] = 1,
        ["ui/item_box.plist"] = 1,
        ["ui/partner.plist"] = 1,
    }

    self.effect_tab = {
        "tx_0133_green", -- e
        "tx_0133_green", -- d
        "tx_0133_blue",  --c
        "tx_0133_purple", --b
        "tx_0133_orange",  --a
        "tx_0133_orange",  --s
    }
    LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_info.json")
	self:addWidget(self.panel)

	self:initUI() 
end

function ClsShowSailorInfoView:initUI()
	---属性
	for k,v in pairs(attrs_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	---资质
	for k,v in pairs(aptitude_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	-- ---技能
	self.skill_bg = {}
	for i=1,SKILL_NUM do
		local skill_bg= getConvertChildByName(self.panel, "skill_bg_"..i)
		skill_bg:setVisible(false)

		self.skill_bg[i] = skill_bg	
			
		local skill_icon = getConvertChildByName(self.panel, "skill_icon_"..i)
		skill_icon:setVisible(false)
		self.skill_bg[i].skill_icon = skill_icon
	end

	---水手
	for k,v in pairs(sailor_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self:updateUI()

end

function ClsShowSailorInfoView:updateUI()
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()
    self.sailor_data = ownSailors[self.sailor_id] 

	self:updateSailorAndSkillUI()
	self:updateAttrsAndAptitudeUI()

	self.btn_close:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
		local clsSailorRecruitView = getUIManager():get("clsSailorRecruitView")
		if  clsSailorRecruitView and not tolua.isnull(clsSailorRecruitView)then
			clsSailorRecruitView:setButtonTouch(true)
		end

		-- local MainAwardUI = getUIManager():get("MainAwardUI")
		-- if  MainAwardUI and not tolua.isnull(MainAwardUI)then
		-- 	MainAwardUI:reateNewSailor()
		-- end
	end,TOUCH_EVENT_ENDED)
end

function ClsShowSailorInfoView:updateSailorAndSkillUI()

	self.captain_head:changeTexture(convertResources(self.sailor_data.res), UI_TEX_TYPE_LOCAL)

	local seaman_width = self.captain_head:getContentSize().width
	self.captain_head:setScale(108 / seaman_width)

	self.sailor_level:changeTexture(convertResources(STAR_SPRITE_RES[self.sailor_data.star].big), UI_TEX_TYPE_PLIST)
	local config = sailor_info[self.sailor_data.id]
	self.job_icon:changeTexture(convertResources(JOB_RES[config.job[1]]), UI_TEX_TYPE_PLIST)

	self.seaman_name:setText(self.sailor_data.name)
	self.personality_info:setText(sailor_info[self.sailor_id].nature)

	self.personality_tips:setText(sailor_info[self.sailor_id].nature_dec)

	self.level_num:setText("Lv."..self.sailor_data.level)
	self.prestige_num:setText(self.sailor_data.power)

	for i=1,STAR_NUM do
		self["star_"..i] = getConvertChildByName(self.panel, "star_"..i)
		if self.sailor_data.starLevel < i then
			self["star_"..i]:setVisible(false)
		end
	end

	---技能

	local skills = DataTools:getSkillInfo(self.sailor_data)
	--table.print(skills)
	for k,v in pairs(skills) do
 		local skill_bg = self.skill_bg[v.pos]
 		local skill = skill_info[v.id]
 		local skill_level = v.level
 		local skill_id = v.id 
 		skill_bg.skill_icon:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)
 		skill_bg.skill_icon:setVisible(true)
 		skill_bg:changeTexture(SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)

		skill_bg:setVisible(true)
 		skill_bg:setTouchEnabled(true)
        skill_bg:addEventListener(function ()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)

			getUIManager():create("gameobj/sailor/ClsShowSailorInfoSkillTips", {}, skill_id, skill_level, self.sailor_id)
        end, TOUCH_EVENT_ENDED)
	end
end

function ClsShowSailorInfoView:updateAttrsAndAptitudeUI()

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

	self.far_num:setText(attrs.remote)
	self.near_num:setText(attrs.melee)
	self.defense_num:setText(attrs.defense)
	self.long_num:setText(attrs.durable) 

	---资质
    for k, v in pairs(self.sailor_data.aptitudes) do
        if v.aptitudeName == "remote_range_value" then
            attrs.remote_range_value = v.aptitudeValue
            attrs.remote_range_value_max = v.aptitudeMax
        elseif v.aptitudeName == "defense_range_value" then
            attrs.defense_range_value = v.aptitudeValue
            attrs.defense_range_value_max = v.aptitudeMax
        elseif v.aptitudeName == "melee_range_value" then
            attrs.melee_range_value = v.aptitudeValue
            attrs.melee_range_value_max = v.aptitudeMax
        elseif v.aptitudeName == "durable_range_value" then
            attrs.durable_range_value = v.aptitudeValue
            attrs.durable_range_value_max = v.aptitudeMax
        end
    end

    self.far_progress:setPercent(attrs.remote_range_value / attrs.remote_range_value_max * 100)
    self.far_bar_num:setText(string.format("%s/%s", attrs.remote_range_value, attrs.remote_range_value_max))

    self.near_progress:setPercent(attrs.melee_range_value / attrs.melee_range_value_max * 100)
    self.near_bar_num:setText(string.format("%s/%s", attrs.melee_range_value, attrs.melee_range_value_max))

    self.defense_progress:setPercent(attrs.defense_range_value / attrs.defense_range_value_max * 100)
    self.defense_bar_num:setText(string.format("%s/%s", attrs.defense_range_value, attrs.defense_range_value_max))

    self.long_progress:setPercent(attrs.durable_range_value / attrs.durable_range_value_max * 100)
    self.long_bar_num:setText(string.format("%s/%s", attrs.durable_range_value, attrs.durable_range_value_max))
end


function ClsShowSailorInfoView:onExit()
	UnLoadPlist(self.plist)
end

return ClsShowSailorInfoView