-- 港口阵营转换特效
-- Author: Ltian
-- Date: 2016-12-11 20:00:56
--

local ClsBaseView = require("ui/view/clsBaseView")
local port_power = require("game_config/mission/port_power")
local port_info = require("game_config/port/port_info")
local CompositeEffect = require("gameobj/composite_effect")
local ClsCommonFuns = require("scripts/gameobj/commonFuns")
local img_info = require("game_config/mission/power_to_port_img")

local ClsPortPowerChangeEffect = class("ClsPortPowerChangeEffect", ClsBaseView)

local touch_rect = CCRect(368, 148, 82, 66)

function ClsPortPowerChangeEffect:getViewConfig(...)
	return {
			type =  UI_TYPE.TIP,
			is_swallow = false,   
		}
end

local widget_name = {
	"main_forces_port",
	"main_forces_name",
	"main_forces_bg",
	"port_icon",
	"forces_icon",
	"clipp_panel",
	"tips",
}

function ClsPortPowerChangeEffect:onEnter(parameter)
	self.parameter = parameter
	self.res_plist = {
		["ui/force_icon.plist"] = 1
	}

	LoadPlist(self.res_plist)   	
	self:configUI()
end

function ClsPortPowerChangeEffect:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_forces.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.clipp_panel:setVisible(false)

	if self.parameter[1].power_id == 0 then --这种状态不弹框，只改港口颜色
		self:changeNewPowerPort()
		self:close()
		return
	end
	self.main_forces_bg:setOpacity(0)
	self.main_forces_bg:runAction(CCFadeIn:create(0.5))
	self:initUI()
end

local color_tab = {
	[0] = COLOR_YELLOW_STROKE,
	[1] = COLOR_RED_STROKE,
	[2] = COLOR_GREEN_STROKE,
	
}

function ClsPortPowerChangeEffect:initUI()
	if self.parameter[1] and self.parameter[1].power_id > 0 then --原来有阵营
		if self.parameter[2].change_describe ~= "" then
			self.clipp_panel:setVisible(true)
			self.tips:setText(self.parameter[2].change_describe)
		end

		local port_data = getGameData():getPortData()
		local port_id = port_data:getPortId() -- 当前港口id
		local port_info = require("game_config/port/port_info")
		local port_type = port_info[port_id].type
		local img = img_info[port_type].power_img[self.parameter[1].port_status + 1]
		self.port_icon:changeTexture(img, UI_TEX_TYPE_PLIST)
		local power_id = self.parameter[1].power_id
		self.main_forces_name:setText(port_power[power_id].name)
		local port_name = port_info[port_id].name
		self.main_forces_port:setText(port_name)
		local res = port_power[power_id].flagship_port_res
		res = convertResources(res)
		self.forces_icon:changeTexture(res, UI_TEX_TYPE_PLIST)
		local color = color_tab[self.parameter[1].port_status]
		if not color then
			color = COLOR_YELLOW_STROKE
		end

		setUILabelColor(self.main_forces_port, ccc3(dexToColor3B(color)))

		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCCallFunc:create(function()
			local len = ClsCommonFuns:utfstrlen(port_power[power_id].name) + 2
			local pos = ccp(self.main_forces_name:getPosition().x, self.main_forces_name:getPosition().y)
			local force_name_pos = self.main_forces_name:getParent():convertToWorldSpace(pos)
			pos = ccp(self.main_forces_port:getPosition().x, self.main_forces_port:getPosition().y)
			local force_port_pos = self.main_forces_port:getParent():convertToWorldSpace(pos)
			for i=1,len do
				local x = force_name_pos.x + (i -1) * 20
				local box_effect = CompositeEffect.new("tx_force_ash", x, force_name_pos.y + 10, self)
			end
			local port_len = ClsCommonFuns:utfstrlen(port_name) + 2
			for i=1,port_len do
				local x = force_port_pos.x + (i -1) * 20
				local box_effect = CompositeEffect.new("tx_force_ash", x, force_port_pos.y + 10, self)
			end
		end))
		array:addObject(CCDelayTime:create(1))
		array:addObject(CCCallFunc:create(function ( )
			self.main_forces_name:runAction(CCFadeOut:create(0.6))
			self.main_forces_port:runAction(CCFadeOut:create(0.6))
			self.forces_icon:runAction(CCFadeOut:create(0.6))
			self.port_icon:runAction(CCFadeOut:create(0.6))
		end))
		self:runAction(CCSequence:create(array))
		
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.1), CCCallFunc:create(function ( )
			self:initNewUI()
		end)))

	else
		self:initNewUI()
	end
	
end

function ClsPortPowerChangeEffect:initNewUI()
	self:changeNewPowerPort()
	if conditions then
		--todo
	end
	self:newEffet()
end

function ClsPortPowerChangeEffect:newEffet( ... )
	self.main_forces_name:runAction(CCFadeIn:create(0.5))
	local power_id = self.parameter[2].power_id
	if power_id > 0 then
		self.main_forces_name:setText(port_power[power_id].name)
		local res = port_power[power_id].flagship_port_res
		res = convertResources(res)
		local array = CCArray:create()
		array:addObject(CCFadeIn:create(0))
		array:addObject(CCCallFunc:create(
			function() self.forces_icon:changeTexture(res, UI_TEX_TYPE_PLIST) end))
		array:addObject(CCFadeOut:create(0))
		array:addObject(CCFadeIn:create(0.5))
		self.forces_icon:runAction(CCSequence:create(array))
	else
		self.main_forces_name:setVisible(false)
		self.forces_icon:setVisible(false)
	end
	
	local port_id = getGameData():getPortData():getPortId()
	local port_name = port_info[port_id].name
	self.main_forces_port:setText(port_name)

	local color = color_tab[self.parameter[2].port_status]
	if not color then
		color = COLOR_WHITE
	end
	setUILabelColor(self.main_forces_port, ccc3(dexToColor3B(color)))

	self.port_icon:runAction(CCFadeIn:create(0.5))
	self.main_forces_port:runAction(CCFadeIn:create(0.5))

	self:closeView()
end
--改变港口颜色
ClsPortPowerChangeEffect.changeNewPowerPort = function(self)
	if  self.parameter[2] and self.parameter[2].port_status then
		
		local port_data = getGameData():getPortData()
		local port_id = port_data:getPortId() -- 当前港口id
		local port_info = require("game_config/port/port_info")
		if not port_id or not port_info[port_id] then return end
		local port_type = port_info[port_id].type
		local img = img_info[port_type].power_img[self.parameter[2].port_status + 1]
		--以下动作执行只是为了解决changeTexture接口的bug
		local array = CCArray:create() 
		array:addObject(CCFadeIn:create(0))
		array:addObject(CCCallFunc:create(function()
			self.port_icon:changeTexture(img, UI_TEX_TYPE_PLIST)
		end))
		array:addObject(CCFadeOut:create(0))
		self.port_icon:runAction(CCSequence:create(array))
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			if port_layer.mainLayer.port_type then
				port_layer.mainLayer.port_type:changeTexture(img, UI_TEX_TYPE_PLIST)
			end
		end
		local color = color_tab[self.parameter[2].port_status]
		if not color then
			color = COLOR_YELLOW_STROKE
		end
		if not tolua.isnull(port_layer) then
			if port_layer.mainLayer.port_type then
				setUILabelColor(port_layer.mainLayer.port_name_text, ccc3(dexToColor3B(color)))
			end
		end

	end
end

function ClsPortPowerChangeEffect:closeView()
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1.5))
	array:addObject(CCFadeOut:create(0.4))
	array:addObject(CCCallFunc:create(function( )
		self:close()
	end))
	self.main_forces_bg:runAction(CCSequence:create(array))
end

function ClsPortPowerChangeEffect:onExit()
	UnLoadPlist(self.res_plist)
	if type(self.parameter.callback) == "function" then
		self.parameter.callback()
	end
end

return ClsPortPowerChangeEffect