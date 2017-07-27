-- 船只洗练界面选择船只界面
-- Author: chenlurong
-- Date: 2016-11-09 15:33:39
--

local boat_info = require("game_config/boat/boat_info")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseView = require("ui/view/clsBaseView")

local col = 3
local row = 4

local ClsFleetRefineItem = class("ClsFleetRefineItem", function () 
		return UIWidget:create()
	end)

function ClsFleetRefineItem:mkUi(index, data)
	self.data = data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_xilian_ship_list.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	self.item_text = getConvertChildByName(self.panel, "ship_xilian_txt")
	self.item_icon = getConvertChildByName(self.panel, "ship_pic")
	self.item_icon:setVisible(false)
	self.item_text:setVisible(true)
	self.item_text:setText("")

	if self.data then
		local data = self.data
		local base_data = data.data

		local show_tag = data.tag
		local item_res = boat_info[base_data.id].res

		self.item_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
		self.item_icon:setVisible(true)

		if show_tag then
			self.item_text:setText(show_tag.text)
			setUILabelColor(self.item_text, ccc3(dexToColor3B(show_tag.color)))
		end
	end
end

function ClsFleetRefineItem:canClick()
	return self.data ~= nil
end

---------------------------------------------------------------------------
local ClsFleetRefineCell = class("ClsFleetRefineCell", require("ui/view/clsScrollViewItem"))

function ClsFleetRefineCell:initUI(cell_data)
	self.data = cell_data.data
	self.call_back = cell_data.call_back
	self.item_list = {}
	self.bounding_list = {}
	local item_width = self.m_width / col 
	for i = 1, col do
		local item = ClsFleetRefineItem.new()
		item:mkUi(i, self.data[i])
		item:setPosition(ccp(item_width * (i - 1), 0))
		self:addChild(item)
		self.item_list[i] = item

		local item_size = CCSize(65, 66)
		local bounding_layer = display.newLayer()
		local width_dis = item_width - item_size.width
		local height_dis = self.m_height - item_size.height
		bounding_layer:setContentSize(CCSize(item_size.width, item_size.height))
		bounding_layer:setPosition(ccp(item_width * (i - 1)  + width_dis / 2, height_dis / 2))
		self:addCCNode(bounding_layer)
		self.bounding_list[i] = bounding_layer
	end
end

function ClsFleetRefineCell:onTap(x, y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)
	for k, button in pairs (self.bounding_list) do
		if button:boundingBox():containsPoint(node_pos) then
			local select_item = self.item_list[k]
			if select_item:canClick() then
				self.call_back(select_item, x, y)
			end
		end
	end
end

-------------------------------------------------------------------------------------------
local ClsFleetRefineChooseUI = class("ClsFleetRefineChooseUI", ClsBaseView)


--页面参数配置方法，注意，是静态方法
function ClsFleetRefineChooseUI:getViewConfig()
    return {
        name = "ClsFleetRefineChooseUI",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        -- effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end

function ClsFleetRefineChooseUI:onEnter(partner_index, backpack_key, call_back)
	self.backpack_key = backpack_key
	self.partner_index = partner_index
	self.call_back = call_back
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_xilian_ship.json")
    convertUIType(panel)
    self:addWidget(panel)

	panel:setPosition(ccp(722, 68))

	local cell_list = {}


	local width = 192
	local height = 264
	local list_x = 735
	local list_y = 87
	local list_cell_size = CCSize(width, height / row)

	self.list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
    self.list_view:setPosition(ccp(list_x, list_y))
    self:addWidget(self.list_view)
    
    self.cell_list = {}
    self.select_backpack_item = nil

	
	local bag_data_hanlder = getGameData():getBagDataHandler()
	local data_list = bag_data_hanlder:getBackpackData(BAG_PROP_TYPE_FLEET, self.partner_index, true)
	
	local item_data_list = {}
	local item_count = 0
	for bag_type,data in pairs(data_list) do
		for k,v in pairs(data.list) do
			local is_selected = false
			if self.backpack_key and self.backpack_key == v.data.guid then
				is_selected = true
			end
			if not is_selected then
				item_count = item_count + 1
				item_data_list[#item_data_list + 1] = v
			end
		end
	end

	local item_max = math.max(item_count, col * row)
	local row_item_list = nil
	local cell_data = {}
	for i=1,item_max do
		local index = (i - 1) % col + 1
		if index == 1 then
			cell_data = {}		
		end

		local item_data = item_data_list[i]
		cell_data[#cell_data + 1] = item_data

		if (i == item_max) or (i % col == 0) then
			local cell_spr = ClsFleetRefineCell.new(list_cell_size, {data = cell_data, index = math.ceil(i / col), call_back = function(item, x, y)
				self.call_back(item, x, y)
			end})
			self.cell_list[#self.cell_list + 1] = cell_spr
		end

		if i == 1 then
			missionGuide:pushGuideBtn(on_off_info.WASHBOAT_SELECT.value,{rect = CCRect(735, 293, 65, 40), guideLayer = running_scene})
		end
	end

	self.list_view:addCells(self.cell_list)

	self.ship_touch_rect = CCRect(list_x, list_y, width, height)
	self:regTouchEvent(self, function(eventType, x, y)
		if eventType == "began" then
			if not self.ship_touch_rect:containsPoint(ccp(x, y)) then
				self:close()
				return true
			end
		end
	end)
end

return ClsFleetRefineChooseUI
