-- 水手技能tips
local skill_info = require("game_config/skill/skill_info")
local boat_attr = require("game_config/boat/boat_attr")
local ui_word = require("game_config/ui_word")
local dataTools = require("module/dataHandle/dataTools")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsRoleSkillTips= class("ClsRoleSkillTips", ClsBaseView)

local SAILOR_SKILL_MAX_LEVEL = 5
local MAIN_SKILL_STATUS = 1

function ClsRoleSkillTips:getViewConfig()
    return {
        effect = UI_EFFECT.SCALE,    --(选填) ui出现时的播放特效
		is_back_bg = true, 
    }
end

function ClsRoleSkillTips:onEnter(parent, temp, tips_pos)
	self.parent = parent
	self.temp = temp
	self.tips_pos = tips_pos

   	local btn_panel = GUIReader:shareReader():widgetFromJsonFile("json/fleet_set_skill.json")
	self:addWidget(btn_panel)

	self.panel = btn_panel
	btn_panel:setPosition(temp.pos)
	self.btn_panel = btn_panel

	local background = getConvertChildByName(self.panel, "skill_panel")
	self.size = background:getContentSize()

	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)

	
	self:runAction(CCFadeTo:create(0.24 , 0.5 * 255))

    self:initBaseUI()

	self:initSailorSkillUI()
end

--水手技能
function ClsRoleSkillTips:initSailorSkillUI()
	local skill = nil
	local sailor_data = getGameData():getSailorData()
	local desc_tab = nil
	local desc_tab_next = nil
	local skill_des = nil 
	local skill_next_des = nil 

	if self.temp.skill then
		skill = skill_info[self.temp.skill]

		desc_tab = sailor_data:getColorSkillDescWithLv(self.temp.skill, self.temp.skill_level, self.temp.sailor_id)
		skill_des = desc_tab.base_desc

        if skill.skill_ex_id == "" then
            skill_des = desc_tab.base_desc..desc_tab.child_desc
        end	

		self.skill_max_level = skill.max_lv
		-- if self.tips_pos then
		-- 	self.skill_max_level = SAILOR_SKILL_MAX_LEVEL
		-- end 
		if self.temp.skill_level < self.skill_max_level then
			desc_tab_next = sailor_data:getColorSkillDescWithLv(self.temp.skill, self.temp.skill_level+1, self.temp.sailor_id)
			skill_next_des = desc_tab_next.base_desc

			if skill.skill_ex_id == "" then
				skill_next_des = desc_tab_next.base_desc..desc_tab_next.child_desc
			end	
		end
	else

		local ownSailors = sailor_data:getOwnSailors()
		local skills = dataTools:getSkillInfo(ownSailors[self.temp.sailor_id])

		desc_tab = sailor_data:getSkillShortDesc(skills[1].id)

		skill = skill_info[skills[1].id]
	end
	

	--技能图标
	self.skill_icon:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)

	--技能图标背景
	self.skill_icon_bg:changeTexture(convertResources(SAILOR_SKILL_BG[skill.quality]), UI_TEX_TYPE_PLIST)

	--名字
	self.skill_name:setText(skill.name)

	--主技能图标
	self.skill_activity_bg:setVisible(skill.initiative == MAIN_SKILL_STATUS)

	--满级lable
	self.skill_max_text:setVisible(skill.max_level_des ~= "")
	self.skill_max_des_text:setVisible(skill.max_level_des ~= "")

	local max_level_str = string.format("$(c:COLOR_CAMEL)%s%s",skill.max_level_des,ui_word.MAX_SKILL_NO_ACTIVE)
	if self.temp.skill_level >= self.skill_max_level then
		max_level_str = string.format("$(c:COLOR_GREEN)%s$(c:COLOR_CAMEL)%s",skill.max_level_des,ui_word.MAX_SKILL_ACTIVE)
	end

	local max_level_lable = createRichLabel(max_level_str, 335, 60, 14)
	max_level_lable:setAnchorPoint(ccp(0,0.5))
	self.skill_max_des_text:addCCNode(max_level_lable)
	self.skill_max_des_text:setText("")

	if self.rich_label then
	    self.rich_label:removeFromParentAndCleanup(true)
	    self.rich_label= nil 
	    if self.temp.skill_level < self.skill_max_level then
			self.rich_label_next:removeFromParentAndCleanup(true)
			self.rich_label_next= nil  
		end 
	end
	local font_size = 15
	if self.tips_pos then
		font_size = 14
	end
	self.rich_label = createRichLabel(skill_des, 335, 60, font_size)
	self.rich_label:setAnchorPoint(ccp(0,1))
	self.rich_label:setPosition(ccp(-165,0))
	self.skill_text_1:addCCNode(self.rich_label)	
	self.skill_text_1:setText("")

	if self.temp.skill_level < self.skill_max_level then
		self.rich_label_next = createRichLabel(skill_next_des, 335, 60, font_size)
		self.rich_label_next:setPosition(ccp(-165,0))

	else
		local str = string.format("$(c:COLOR_GRASS_STROKE)%s",ui_word.SAILOR_SKILL_MAX_LEVEL)
		self.rich_label_next = createRichLabel(str, 335, 60, 18)
		self.rich_label_next:setPosition(ccp(-30,0))
		self.skill_text_3:setVisible(false)
	end
	self.rich_label_next:setAnchorPoint(ccp(0,1))
	self.skill_text_2:addCCNode(self.rich_label_next)
	self.skill_text_2:setText("")

	self.skill_type:setText(string.format(ui_word.SAILOR_SKILL_COOL_TIME, skill.cooling_time))--skill.baseExplain

	self.skill_type:setVisible(skill.cooling_time ~= 0)

	self.skill_use:setText(skill.usingType)
end

function ClsRoleSkillTips:initBaseUI()
	--技能图标

	local widget_name = {
		"skill_icon",
		"skill_icon_bg",
		"skill_name",
		"skill_text_1",
		"skill_text_2",
		"skill_text_3",
		"skill_type",
		"skill_use",
		"skill_activity_bg",
		"skill_max_text",
		"skill_max_des_text",
	}

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

end


function ClsRoleSkillTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsRoleSkillTips:onTouchBegan(x , y)

	self:close()
	--self.parent:clearTips()
	return false
end


return ClsRoleSkillTips