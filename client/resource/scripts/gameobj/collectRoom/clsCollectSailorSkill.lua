-- 收藏室水手技能tips
local DataTools = require("module/dataHandle/dataTools")
local sailor_info = require("game_config/sailor/sailor_info")
local skill_info = require("game_config/skill/skill_info")
local music_info = require("game_config/music_info")

local ClsCollectSailorSkill = class("ClsCollectSailorSkill", function()
	local layer = UIWidget:create()
	-- layer:setContentSize(CCSizeMake(216, 234))
	return layer
end)

local MAIN_SKILL = 1
function ClsCollectSailorSkill:ctor(parent, sailor_id, pos)
	self.parent = parent
	self.sailor_id = sailor_id

	-- local uiLayer = UILayer:create()
	local uiLayer = UIWidget:create()
	btn_panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_normal_skill.json")
	convertUIType(btn_panel)
	uiLayer:addChild(btn_panel)
	self:addChild(uiLayer)
	self:setPosition(ccp(365, 210))
	self.panel = btn_panel

	local background = getConvertChildByName(self.panel, "bg")
	self.size = background:getContentSize()

	self:setTouchEnabled(true)

	self:initUI()
end

function ClsCollectSailorSkill:onExit()
end

function ClsCollectSailorSkill:initUI()
	local widget_name = {
		"skill_icon_1",
		"skill_icon_2",
		"skill_active_1",
		"skill_active_2",
		"skill_bg_1",--技能按钮1
		"skill_bg_2",
		"skill_selected_1", --技能选中图标1
		"skill_selected_2",
		"skill_title", --技能名字
		"skill_effect_1", --技能描述1
		"skill_effect_2",
	}

	local layer = {}
	for k, v in pairs(widget_name) do
		layer[v] = getConvertChildByName(self.panel, v)
	end

	local sailor_config = sailor_info[self.sailor_id]

	--技能
	for i = 1, 2 do
		layer["skill_icon_" .. i]:setVisible(false)
	end

	local skills = DataTools:getSkillInfo(sailor_config)

	local sailorData = getGameData():getSailorData()

	local skill_btns = {}
	for k, v in pairs(skills) do
		layer["skill_icon_" .. k]:setVisible(true)
		local skill = skill_info[v.id]
		layer["skill_icon_" .. k]:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)
		layer["skill_bg_" .. k]:changeTexture(SAILOR_SKILL_BG[skill.quality], SAILOR_SKILL_BG[skill.quality], SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)

		layer["skill_active_" .. k]:setVisible(skill.initiative == MAIN_SKILL)

		skill_btns[k] = layer["skill_bg_" .. k]
		skill_btns[k].skill_selected = layer["skill_selected_" .. k]
		layer["skill_bg_" .. k]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end, TOUCH_EVENT_BEGAN)

		layer["skill_bg_" .. k]:addEventListener(function()
			layer.skill_title:setText(skill.name)

			local short_desc = sailorData:getSkillShortDesc(v.id)
			layer.skill_effect_1:setText(short_desc)
			layer.skill_effect_2:setVisible(false)

			for i = 1, #skill_btns do
				skill_btns[i].skill_selected:setVisible(k == i)
				-- skill_btns[i]:setTouchEnabled(k ~= i)
			end
		end, TOUCH_EVENT_ENDED)
	end
	layer["skill_bg_" .. 1]:executeEvent(TOUCH_EVENT_ENDED)
end


function ClsCollectSailorSkill:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsCollectSailorSkill:onTouchBegan(x , y)

	self.parent:clearTips()
	return false
end


return ClsCollectSailorSkill
