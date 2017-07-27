
----主角技能解锁特效界面

local skill_info = require("game_config/skill/skill_info")
local CompositeEffect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")

local clsUnlockRoleSkill = class("clsUnlockRoleSkill", ClsBaseView)

local widget_name = {
	"skill_bg",
	"skill_icon",
	"skill_name",
	"explain_info",
	"bg",
}

function clsUnlockRoleSkill:getViewConfig(...)
    return {type =  UI_TYPE.TOP,
			is_back_bg = true, 
			}
end

function clsUnlockRoleSkill:onEnter(skillId)	
	self.resPlist = {
		["ui/shipyard_ui.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
	}	
	LoadPlist(self.resPlist)

	self.uiLayer = UILayer:create()
	self.skill_panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_unlock_skill.json")
	convertUIType(self.skill_panel)
	self.uiLayer:addWidget(self.skill_panel)
	local size = self.skill_panel:getContentSize()
	self.uiLayer:setPosition(ccp(display.cx - size.width/2, display.cy - size.height/2))
	self.uiLayer:setVisible(false)
	self:addChild(self.uiLayer)

	-- self:registerScriptTouchHandler(function(event, x, y)
	-- 	return self:onTouch(event, x, y) end, false, TOUCH_PRIORITY_RPCWAIT)
	self:regTouchEvent(self, function(eventType, x, y)
		self:closeView()
	end)
	self:setViewTouchEnabled(false)

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(function ( )
		CompositeEffect.new("tx_0180",display.cx + 27, display.cy + 62, self, 1, function ()
			self:initView(skillId)
		end)
	end))

   	array:addObject(CCDelayTime:create(2))
   	array:addObject(CCCallFunc:create(function (  )
   		self:setViewTouchEnabled(true)
   	end))

   	array:addObject(CCDelayTime:create(3))
   	array:addObject(CCCallFunc:create(function ()
   		self:closeView()
   	end))
  	self:runAction(CCSequence:create(array))	
end

function clsUnlockRoleSkill:initView(skillId)
	self.uiLayer:setVisible(true)
	local partner_data = getGameData():getPartnerData()	
	local skill_id = skillId
	--local skill_id = 3301
	local skill_level = 1

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.skill_panel, v)
	end

	local skill_attr = skill_info[skill_id]
	self.skill_name:setText(skill_attr.name)
	self.skill_icon:changeTexture(convertResources(skill_attr.res), UI_TEX_TYPE_PLIST)

	local sailor_data = getGameData():getSailorData()
	local desc_tab = sailor_data:getSkillDescWithLv(skill_id, skill_level)
	self.explain_info:setText(desc_tab.base_desc)
end

function clsUnlockRoleSkill:closeView()
	self:close()
	UnLoadPlist(self.resPlist)

	local upgradeLevel = getUIManager():get("upgradeLayer")
	if not tolua.isnull(upgradeLevel) then
		upgradeLevel:hideDialog()
	end
	local partner_data = getGameData():getPartnerData()	
	partner_data:clearRoleOpenSkillId(nil)
end



return clsUnlockRoleSkill
