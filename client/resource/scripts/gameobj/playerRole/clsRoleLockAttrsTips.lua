
---主角技能附加属性
---fmy

local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local attrs_role = require("game_config/role/attrs_role")
local ui_word = require("game_config/ui_word")

local ClsRoleLockAttrsItem = class("ClsRoleLockAttrsItem",ClsScrollViewItem)

local item_widget_name = {
	"skill",
	"skill_icon",
	"text",
	"unlock_text",
}

function ClsRoleLockAttrsItem:initUI(data)
	self.data = data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_lock_tips_list.json")
	self:addChild(self.panel)

	for k,v in pairs(item_widget_name) do
		self[v] = getConvertChildByName(self.panel,v)
	end

	self:updateUI()
end

function ClsRoleLockAttrsItem:updateUI()
	self.skill_icon:changeTexture(convertResources(self.data.icon), UI_TEX_TYPE_PLIST)
	self.text:setText(self.data.attr)

	local limit_level = self.data.level_limit
	local str = ui_word.ROLE_SKILL_ATTRS_UNLOCK
	local color = COLOR_GREEN

	local cur_level = getGameData():getBaseSkillData():getBaseSkillLimitLevel()
	if limit_level > cur_level then
		str = string.format(ui_word.ROLE_SKILL_ATTRS_LBL,limit_level)
		color = COLOR_RED
	end
	self.unlock_text:setText(str)
    setUILabelColor(self.unlock_text, ccc3(dexToColor3B(color)))

end

local ClsRoleLockAttrsTips = class("ClsRoleLockAttrsTips",ClsBaseView)

function ClsRoleLockAttrsTips:getViewConfig()
	return { 
		is_back_bg = true,
	}
end
function ClsRoleLockAttrsTips:onEnter()
	self.tips_panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_lock_tips.json")
	self:addWidget(self.tips_panel)

	self.pos = ccp(100,40)
	self.size_width = 288
	self.size_height = 434
	self:setPosition(self.pos)

	self:initUI()
	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)
end

function ClsRoleLockAttrsTips:initUI(  )
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
		self.list_view = nil
	end

	local cell_size	= CCSize(284, 60)

	self.list_view = ClsScrollView.new(284, 330, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(0, 30)) 
	self:addWidget(self.list_view)

	self.cells = {}

	local role_attr = getGameData():getBaseSkillData():getRoleSkillAttrs()
	local lock_attrs_list = role_attr

	for k,v in ipairs(lock_attrs_list) do
		local curCell = ClsRoleLockAttrsItem.new(cell_size, v)
		self.list_view:addCell(curCell)  		
		self.cells[#self.cells+1] = curCell
	end
end

function ClsRoleLockAttrsTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsRoleLockAttrsTips:onTouchBegan(x , y)
	if x > self.pos.x and x < self.pos.x + self.size_width and y > self.pos.y and y < self.pos.y + self.size_height then	
		return true
	else
		self:close()
		return false
	end
end

return ClsRoleLockAttrsTips
