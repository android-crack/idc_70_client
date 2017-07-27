-- 船舶装备tips
-- Author: Ltian
-- Date: 2016-12-08 15:34:03
--
local ClsBaseView = require("ui/view/clsBaseView")
local baozang_info = require("game_config/collect/baozang_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local base_attr_info = require("game_config/base_attr_info")
local ui_word = require("game_config/ui_word")
local music_info = require("scripts/game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local dataTools = require("module/dataHandle/dataTools")

local ClsEquipItem = class("ClsEquipItem", ClsScrollViewItem)
local widget_name = {
	"sale_band_bg",
	"equip_icon",
	"black_title",
	"black_info_2",
	"black_info_1",
	"blue_bg",
	"equip_bg",
	"equip_level",
}

function ClsEquipItem:initUI(cell_date )
	self.data = cell_date
	self.equip_info = cell_date.data.data
	self.base_data = baozang_info[self.equip_info.baowuId]  --宝物基础信息

	self.lock = false
	self.panel = self.m_cell_ui
	self.index = cell_date.index
	self.callback = cell_date.callback
	self.panel:setPosition(ccp(0, 5))
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.blue_bg:setVisible(false)
	self.sale_band_bg:setVisible(false)
	self:freashUI()
end

function ClsEquipItem:freashUI()
	local quality = self.equip_info.step
	self.black_title:setText(self.base_data.name) --名字
	setUILabelColor(self.black_title, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
	local item_res = self.base_data.res
	self.equip_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST) --icon

	self.equip_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, self.base_data.level))
	setUILabelColor(self.equip_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
	
	local btn_res = string.format("item_box_%s.png", quality)
	self.equip_bg:changeTexture(btn_res, UI_TEX_TYPE_PLIST)  --iocnd底框
			
	--属性
	local attr_info = self.equip_info.attr[1]
	if attr_info then
		local str = dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value)
		self.black_info_2:setText(base_attr_info[attr_info.name].name .. str)
	else
		self.black_info_2:setText("")
	end
	local attr_info2 = self.equip_info.attr[2]
	if attr_info2 then
		local str = dataTools:getBoatBaowuAttr(attr_info2.name, attr_info2.value)
		self.black_info_1:setText(base_attr_info[attr_info2.name].name .. str)
	else
		self.black_info_2:setText("")
	end
end

function ClsEquipItem:onTap(x, y)
	self.blue_bg:setVisible(true)
	self.callback(self.index, self.equip_info.baowuId)
end

function ClsEquipItem:unSelect()
	self.blue_bg:setVisible(false)
end

function ClsEquipItem:updateUI(cell_date, cell_ui)

end

local ClsShipEquipTips = class("ClsShipEquipTips", ClsBaseView)

local touch_rect = CCRect(375, 20, 380, 450)
local site_to_pos = {
	{610, 60},
	{500, 20},
	{730, 20}
}

function ClsShipEquipTips:getViewConfig(...)
    return {
    	type =  UI_TYPE.TIP,
		is_swallow = true,   
	}
end

function ClsShipEquipTips:onEnter(parameter)
	self.parameter = parameter
	self.equip_list = parameter.equip_list
    self.res_plist = {}
    LoadPlist(self.res_plist)
    self:configUI(parameter)
    self:configEvent()
end

local widget_panel_name = {
	"sale_band_bg",
	"equip_icon",
	"black_title",
	"black_info_2",
	"black_info_1",
	"blue_bg",
	"black_item_bg",
	"btn_equip_text",
	"equip_level",
}

function ClsShipEquipTips:configUI(parameter)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_equip_panel.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for k,v in pairs(widget_panel_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.btn_equip = getConvertChildByName(self.panel, "btn_equip")
	self.btn_equip_text:setZOrder(self.btn_equip_text:getZOrder() + 1)
	self.btn_equip:disable()
	local site = parameter.site
	local pos = ccp(site_to_pos[site][1], site_to_pos[site][2])
	self.panel:setPosition(pos)
	self.touch_rect = CCRect(pos.x, pos.y, 225, 340)
	self:initEquipList()
	self:initOldEquip()

	self.getGuideObj = function()
		return self:getGuideInfo()
	end
	ClsGuideMgr:tryGuide("ClsShipEquipTips")
end
--已经装备的宝物
function ClsShipEquipTips:initOldEquip()
	local partner_data = getGameData():getPartnerData()
	local bag_equip_data = partner_data:getBagEquipInfoById(self.parameter.id)
	local boat_equip_data = bag_equip_data.boatBaowu
	local baowu_key = boat_equip_data[self.parameter.site]
	if tonumber(baowu_key) > 0 then
		local baowu_data_handler = getGameData():getBaowuData()
		local baowu_info = baowu_data_handler:getInfoById(baowu_key)
		local base_data = baozang_info[baowu_info.baowuId] 
		
		local quality = baowu_info.step
		self.black_title:setText(base_data.name) --名字
		setUILabelColor(self.black_title, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
		local item_res = base_data.res
		self.equip_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST) --icon

		
		local btn_res = string.format("item_box_%s.png", quality)
		self.black_item_bg:changeTexture(btn_res, UI_TEX_TYPE_PLIST)  --iocnd底框
				
		--属性
		local attr_info = baowu_info.attr[1]
		if attr_info then
			local str = dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value)
			self.black_info_2:setText(base_attr_info[attr_info.name].name .. str)
		else
			self.black_info_2:setText("")
		end
		local attr_info2 = baowu_info.attr[2]
		if attr_info2 then
			local str = dataTools:getBoatBaowuAttr(attr_info2.name, attr_info2.value)
			self.black_info_1:setText(base_attr_info[attr_info2.name].name .. str)
		else
			self.black_info_2:setText("")
		end
		self.blue_bg:setVisible(true)
		self.btn_equip:active()
		self.btn_equip_text:setText(ui_word.SHIPYARD_DOWN)
		self.equip_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, base_data.level))
		setUILabelColor(self.equip_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
	else
		self.equip_icon:setVisible(false)
		self.sale_band_bg:setVisible(false)
		self.black_info_1:setText("")
		self.black_info_2:setText("")
		self.equip_level:setText("")
		self.black_title:setText(ui_word.SAILOR_EQUIK)
	end
end

function ClsShipEquipTips:getGuideInfo()
	if not self.cells or #self.cells == 0 then return end
	local guide_layer = self.list_view:getInnerLayer()
	for k, cell in ipairs(self.cells) do
		if k == 1 then
			local world_pos = cell:convertToWorldSpace(ccp(110, 32))
			local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
			local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
			return guide_layer, guide_node_pos, {['w'] = 220, ['h'] = 64}
		end
	end
end

function ClsShipEquipTips:changeBtnLabel()
	local partner_data = getGameData():getPartnerData()
	local bag_equip_data = partner_data:getBagEquipInfoById(self.parameter.id)
	local boat_equip_data = bag_equip_data.boatBaowu
	local baowu_key = boat_equip_data[self.parameter.site]
	if tonumber(baowu_key) > 0 then
		self.btn_equip_text:setText(ui_word.STR_CHANGE)
	else
		self.btn_equip_text:setText(ui_word.SHIPYARD_UP)
	end
end

function ClsShipEquipTips:initEquipList()
	if not self.list_view or tolua.isnull(self.list_view) then
		local site = self.parameter.site
		local pos = ccp(site_to_pos[site][1], site_to_pos[site][2])
		self.list_view = ClsScrollView.new(220, 218, true, function()
            local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_equip_list.json")
            return cell_ui
        end, {is_fit_bottom = true})
	    self.list_view:setPosition(ccp(pos.x + 2, pos.y + 60))
	    self:addWidget(self.list_view)
	end
	
    self.cells = {}
    local cell_size = CCSize(220, 68)
   	index = 1

    for k, v in ipairs(self.equip_list) do
		self.cells[index] = ClsEquipItem.new(cell_size, {index = index, data = v, callback = function (index, baowu_key)
			self:clickItem(index, baowu_key)
		end})
		index = index + 1
	end
    self.list_view:addCells(self.cells)
end

function ClsShipEquipTips:clickItem(index, baowu_key)
	if type(self.last_select) == "number" and self.last_select ~= index then
		local cell = self.cells[self.last_select]
		if not tolua.isnull(cell) then
			cell:unSelect()
		end
	end
	self.last_select = index
	self.select_baowu_key = baowu_key
	self.btn_equip:active()
	self.blue_bg:setVisible(false)
	self:changeBtnLabel()
end

function ClsShipEquipTips:configEvent()
	self:regTouchEvent(self, function(eventType, x, y)
		local touch_point = ccp(x, y)
		local touch_rect
		is_in = self.touch_rect:containsPoint(touch_point)
		if not is_in then
			self:onTouchCB()
		end
	end)

	self.btn_equip:setPressedActionEnabled(true)
	self.btn_equip:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local partner_data = getGameData():getPartnerData()
		local bag_equip_data = partner_data:getBagEquipInfoById(self.parameter.id)
		local boat_equip_data = bag_equip_data.boatBaowu
		local baowu_key = boat_equip_data[self.parameter.site]
		local partner_data = getGameData():getPartnerData()
		if not self.last_select and baowu_key then
			partner_data:askBoatDownloadBaowu(self.parameter.partner_index, baowu_key, self.parameter.site)
		else
			partner_data:askBoatUploadBaowu(self.parameter.partner_index, self.select_baowu_key, self.parameter.site)
		end
		
		self:closeView()
	end, TOUCH_EVENT_ENDED)
end

function ClsShipEquipTips:onTouchCB()
	self:closeView()
end

function ClsShipEquipTips:closeView()
	self:close()
end

function ClsShipEquipTips:onExit()
	UnLoadPlist(self.res_plist)
end

return ClsShipEquipTips