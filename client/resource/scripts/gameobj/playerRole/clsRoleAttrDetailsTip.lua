local ClsBaseView = require("ui/view/clsBaseView")

local ClsRoleAttrDetailsTip = class("ClsRoleAttrDetailsTip", ClsBaseView)

local JSON_URL = "json/main_buff.json";

function ClsRoleAttrDetailsTip:getViewConfig()
	return {
		is_swallow = false,
		is_back_bg = false,       -- 半透明黑背景
		effect = UI_EFFECT.SCALE, -- 特效
		type = UI_TYPE.TIP,  
	}
end

function ClsRoleAttrDetailsTip:onCtor(data)-- {name: xxx, tips_txt:xxxx, pos: ccp(100,100)}
	local panel = GUIReader:shareReader():widgetFromJsonFile( JSON_URL )
	self:addWidget(panel)

	local tips_panel = getConvertChildByName(panel, "buff_exp_tips")
	tips_panel:setAnchorPoint(ccp(0, 0))
	tips_panel:setPosition(ccp(0, -10))

	self:setPosition(ccp(display.cx, display.cy))

	self.m_view_root_spr:setPosition(ccp(data.pos.x - 35, data.pos.y - 230))

	self["buff_name"] = getConvertChildByName(panel, "buff_name")
	self["buff_tips"] = getConvertChildByName(panel, "buff_tips")

	self.buff_name:setVisible(false)

	self.buff_tips:setText(data.tips_txt)
	self.buff_tips:setPosition(ccp(10, 16))

	tips_panel:setSize(CCSize(self.buff_tips:getContentSize().width + 22, 35))

	self:regTouchEvent(self, function(event, x, y)
		if event =="began" then 
			self:close()
		end
	end)
end

function ClsRoleAttrDetailsTip:onEnter(data) 
	
end

return ClsRoleAttrDetailsTip