

---fmy0570
---航海士技能弹框
local skill_info = require("game_config/skill/skill_info")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsShowSailorInfoSkillTips = class("ClsShowSailorInfoSkillTips", ClsBaseView)

local skill_name = {
	"skill_title",
	"skill_info",
	"skill_level",
}

function ClsShowSailorInfoSkillTips:onEnter(skill_id, sk_level, sailor_id)

	self.skill_id = skill_id
	self.sk_level = sk_level
	self.sailor_id = sailor_id

   	local skill_panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_info_btn.json")
	self:addWidget(skill_panel)
	self.pos = ccp(350,150)	
	self:setPosition(self.pos)

	for k,v in pairs(skill_name) do
		self[v] = getConvertChildByName(skill_panel, v)
	end

	self.size_width = 300
	self.size_height = 100
	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)

	self:initUI()	
end

function ClsShowSailorInfoSkillTips:initUI()
	local skill_title = skill_info[self.skill_id].name
	self.skill_title:setText(skill_title)
	self.skill_level:setText("Lv."..self.sk_level)


	local sailor_data = getGameData():getSailorData()
	local desc_tab = sailor_data:getSkillShortDesc(self.skill_id)
	self.skill_info:setText(desc_tab)

end

function ClsShowSailorInfoSkillTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsShowSailorInfoSkillTips:onTouchBegan(x , y)

	if x > self.pos.x and x < self.pos.x + self.size_width and y > self.pos.y and y < self.pos.y + self.size_height then	
		return true

	else
		self:close()
		return false
	end
end

function ClsShowSailorInfoSkillTips:onExit()
	
end
return ClsShowSailorInfoSkillTips