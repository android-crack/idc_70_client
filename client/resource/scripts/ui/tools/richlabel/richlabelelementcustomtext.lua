local ui_word = require("game_config/ui_word")
local richlabel_info = require("game_config/richlabel_info")
local richlabel_view_info = require("game_config/richlabel_view_info")
local port_info = require("game_config/port/port_info")

local ClsRichLabelElementCustomText = class("ClsRichLabelElementCustomText", function(param)
	return display.newSprite()
end)

function ClsRichLabelElementCustomText:ctor(param)
	self.text = param.text
	self.params = param.params
	self.type = param.type
	self.font = param.font or FONT_CFG_1
	self.font_size = param.size or 14
	self.color = param.color
	self.show_lab = param.label_node
	self.m_richlabel = param.richlabel
	self:init()
end

function ClsRichLabelElementCustomText:init()
	if nil == self.show_lab then
		local label = createBMFont({text = self.text, size = self.font_size, fontFile = self.font, color = ccc3(dexToColor3B(self.color))})
		self.show_lab = label
	end
	local label_size = self.show_lab:getContentSize()
	local item = require("ui/view/clsViewButton").new({labelNode = self.show_lab, x = label_size.width/2, y = label_size.height/2 + self.show_lab:getStrokeSize()/2})
	item:regCallBack(function()
			self:touchCallback()
		end)
	self:addChild(item)

	self.m_richlabel:regTouchEvent(item, function(...) return item:onTouch(...) end)
end

function ClsRichLabelElementCustomText:touchCallback()
	local DEF = require("ui/tools/richlabel/richlabeldef")
	if DEF.PARSE_TYPE.FORCE == self.type then
		--弹出提示
		if richlabel_info[self.type] then
			local ClsAlert = require("ui/tools/alert")
			ClsAlert:warning({msg = richlabel_info[self.type].tips})
		end
		
	elseif DEF.PARSE_TYPE.VIEW == self.type then
		--跳转页面
		local parent = getUIManager():get("ClsPortLayer")
		if tolua.isnull(parent) then
			return
		end
		
		for k, v in pairs(richlabel_view_info) do
			if v.word == self.params then
				local skipToLayer = require("gameobj/mission/missionSkipLayer")
				local skipMissLayer = skipToLayer:skipLayerByName(k, nil, parent)
				local needSkipEffect = skipToLayer:needSkipEffectByName(k)
				if needSkipEffect then
					needSkipEffect = false
				else
					needSkipEffect = true
				end
				if skipMissLayer then
                    local chatWithMissionGuideMainUI = ClsElementMgr:get_element("ClsChatWithMissionGuideMainUI")
    				if not tolua.isnull(chatWithMissionGuideMainUI) then
                        if chatWithMissionGuideMainUI:isShowMainPanel() then
                            chatWithMissionGuideMainUI:toChatBtnPanel()
                        end
    				end
					parent:addItem(skipMissLayer, nil, needSkipEffect)
				end
				return
			end
		end
		
	elseif DEF.PARSE_TYPE.PORT == self.type then
		--跳转港口
		for port_id, v in pairs(port_info) do
			if v.name and (v.name == self.params) then
				local now_id = getGameData():getPortData():getPortId() -- 当前港口
				if port_id and now_id ~= port_id then
					local supplyData = getGameData():getSupplyData()
					supplyData:askSupplyInfo(true, function()
							local mapAttrs = getGameData():getWorldMapAttrsData()
							mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_PORT, nil, function() end)
						end)
				end
				break
			end
		end
	else
		print("wmh print:  ERROR!!!!   self.type = ",self.type, T(" 不存在"))
	end
end

function ClsRichLabelElementCustomText:getText()
	return self.text
end

function ClsRichLabelElementCustomText:getType()
	return self.type
end

function ClsRichLabelElementCustomText:getTextColor()
	return self.color
end

function ClsRichLabelElementCustomText:getContentSize()
	return self.show_lab:getContentSize()
end

function ClsRichLabelElementCustomText:setTextColor(new_color)
	if new_color and self.show_lab then
		local parseString = require("ui/tools/richlabel/parse_string")
		new_color = parseString.getColorNum(new_color)
		self.color = new_color
		self.show_lab:setColor(ccc3(dexToColor3B(new_color)))
	end
end

return ClsRichLabelElementCustomText