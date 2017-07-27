-- 小伙伴属性tips
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ui_word = require("game_config/ui_word")

-- local ClsPartnerAttrTips= class("ClsPartnerAttrTips", function()
-- 	-- local layer = display.newLayer()
-- 	-- layer:setContentSize(CCSizeMake(370, 370))
-- 	return display.newLayer()
-- end)
local ClsPartnerAttrTips = class("ClsPartnerAttrTips",require("ui/view/clsBaseView"))

local widget_name = {
	"power_num",
	"range_num", --火炮射程
	"speed_num", --航行速度
	"far_num",  --远程伤害
	"near_num", --近战伤害
	"long_num", --船舶耐久
	"defense_num", --船舶防御

	"ran_hit_num", --命中等级
	"ran_dodge_num", --闪避等级
	"ran_crits_num", --暴击等级
	"ran_anti_crits_num", --抗暴等级
	"damageIncrease_num", --伤害增幅
	"damageReduction_num", --伤害减免
}

function ClsPartnerAttrTips:getViewConfig()
    return {
        effect = UI_EFFECT.SCALE,
        is_back_bg = true,
    }
end
function ClsPartnerAttrTips:onEnter(parent, pos, partner_attr, power)
	self.parent = parent
	self.partner_attr = partner_attr
	self.power = power

   	local panel = GUIReader:shareReader():widgetFromJsonFile("json/staff_attribute_tips.json")
   	convertUIType(panel)
   	self:addWidget(panel)
   	panel:setPosition(pos)
	self.panel = panel

	self:regTouchEvent(self, function(...) return self:onTouch(...) end, self.m_touch_priority)
	self:initUI()
end

function ClsPartnerAttrTips:initUI()
		-- 绑定json
	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	-- print("====self.partner_attr")
	-- table.print(self.partner_attr)
	self.power_num:setText(self.power)

	--水手属性
	for k, v in pairs(self.partner_attr) do
		if v.name == "range" then
			self.range_num:setText(v.value)
		elseif v.name == "speed" then
			self.speed_num:setText(v.value)
		elseif v.name == "remote" then
			self.far_num:setText(v.value)
		elseif v.name == "melee" then
			self.near_num:setText(v.value)
		elseif v.name == "durable" then
			self.long_num:setText(v.value)
		elseif v.name == "defense" then
			self.defense_num:setText(v.value)

		elseif v.name == "hit" then
			self.ran_hit_num:setText(v.value)
		elseif v.name == "dodge" then
			self.ran_dodge_num:setText(v.value)
		elseif v.name == "crits" then
			self.ran_crits_num:setText(v.value)
		elseif v.name == "antiCrits" then
			self.ran_anti_crits_num:setText(v.value)
		elseif v.name == "damageIncrease" then
			self.damageIncrease_num:setText(v.value)
		elseif v.name == "damageReduction" then
			self.damageReduction_num:setText(v.value)
		end
	end

end


function ClsPartnerAttrTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsPartnerAttrTips:onTouchBegan(x , y)
		self.parent:clearTips()
		return false
	-- if x > self.pos.x and x < self.pos.x + self.size_width and y > self.pos.y and y < self.pos.y + self.size_height then
	-- 	return true
	-- else
	-- 	self.parent:clearTips()
	-- 	return false
	-- end
end


return ClsPartnerAttrTips
