-- 主角技能 属性技能界面弹框
local ui_word = require("game_config/ui_word")
local base_skill_desc = require("game_config/role/base_skill_desc")
local base_skill_attr = require("game_config/role/base_skill_attr")

local JOB_STR = 
{
	"adventurer_",
	"navy_",
	"pirate_",
}

local ATTR_STR = 
{
	"remote",
	"melee",
	"defense",
	"durable",
}

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRoleAttrSkillTip = class("ClsRoleAttrSkillTip", ClsBaseView)

local tip_widget_name = 
{
	"skill_icon",
	"skill_name",
	"skill_text_1",
	"skill_text_2",
	"skill_level",
	"skill_desc",
}

function ClsRoleAttrSkillTip:getViewConfig()
    return {
        effect = UI_EFFECT.SCALE,
		is_back_bg = true, 
    }
end

function ClsRoleAttrSkillTip:onEnter(index, pos)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_upgrade_tips.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	pos = ccp(display.cx,display.cy)
	panel:setPosition(pos)
	self:addWidget(panel)

	for k, v in ipairs(tip_widget_name) do
		self[v] = getConvertChildByName(panel, v)
	end

	self:regTouchEvent(self, function(event, x, y)
		if event == "began" then
			self:close()
			return true
		end
	end)

	self:mkUI(index)
end

function ClsRoleAttrSkillTip:mkUI(index)
	local info = base_skill_desc[index]
	if not info then return end

	self.skill_icon:changeTexture(info.icon, UI_TEX_TYPE_PLIST)

	self.skill_name:setText(info.name)

	self.skill_desc:setText(info.desc)

	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()

	local skill_lv = getGameData():getBaseSkillData():getLevelByType(index)

	self.skill_level:setText(string.format(ui_word.SHIPYARD_LEVEL_TEXT, skill_lv))

	local index_str = JOB_STR[data.profession] .. ATTR_STR[index]

	local attr = base_skill_attr[skill_lv]
	if attr then
		self.skill_text_1:setText(info.attr .. "+" .. attr[index_str])
	else
		self.skill_text_1:setText("——")
	end

	attr = base_skill_attr[skill_lv + 1]
	if attr then
		self.skill_text_2:setText(info.attr .. "+" .. attr[index_str])
	else
		self.skill_text_2:setText("——")
	end
end

return ClsRoleAttrSkillTip