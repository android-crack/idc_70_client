local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local boat_type_icon = require("game_config/boat/boat_type_icon")
local ClsShipyardShipItem = class("ClsShipyardShipItem", require("ui/view/clsScrollViewItem"))

local icon_by_index = {
	[1] = "common_icon_flagship.png",
	[2] = "partner_num_2.png",
	[3] = "partner_num_3.png",
	[4] = "partner_num_4.png",
	[5] = "partner_num_5.png",
}

function ClsShipyardShipItem:initUI(data)
    self:setTouchEnabled(true)
    self.sailor_id = data.sailor_id 
    self.partner_index = data.index 
    self.call_back = data.call_back
    self:mkUi()
end

function ClsShipyardShipItem:getSkinData()
    local partner_data = getGameData():getPartnerData()
    local partner_info = partner_data:getBagEquipInfoById(self.sailor_id)
    if partner_info.boatKey ~= 0 then
        local skin_data = partner_data:getBagEquipSkinByBoatKey(partner_info.boatKey)
        
        if skin_data and skin_data.skin_enable == 1 then
            print("skin_data.skin_enable", skin_data.skin_enable)
            return skin_data
        end
    end
    
end

function ClsShipyardShipItem:mkUi()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_ship_item.json")
    convertUIType(self.panel)
    self:addChild(self.panel)
    
    self.fleet_boat_select = getConvertChildByName(self.panel, "ship_select")
    self.ship_pic = getConvertChildByName(self.panel, "ship_pic")
    self.ship_name = getConvertChildByName(self.panel, "ship_name")
    local num_icon = getConvertChildByName(self.panel, "num_icon")
    local type_icon = getConvertChildByName(self.panel, "type_icon")
    num_icon:setVisible(false)
    type_icon:setVisible(false)
    
    if self.sailor_id ~= 0 then
    	local partner_data = getGameData():getPartnerData()
    	local partner_info = partner_data:getBagEquipInfoById(self.sailor_id)
        --TODO --ltf
    	if partner_info.boatKey ~= 0 then
	    	local ship_data = getGameData():getShipData()
			local boat = ship_data:getBoatDataByKey(partner_info.boatKey)
            local skin_data = self:getSkinData()
			local ship_res = boat_info[boat.id].res
            local ship_name = boat.name
            if skin_data then
                ship_res = skin_data.skin_res
                ship_name = skin_data.skin_name
            end
			self.ship_pic:changeTexture(convertResources(ship_res), UI_TEX_TYPE_PLIST)
			self.data = partner_info
			self.ship_name:setText(ship_name)
			setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))

			local icon = icon_by_index[self.partner_index]

            num_icon:setVisible(true)
            type_icon:setVisible(true)

			num_icon:changeTexture(icon, UI_TEX_TYPE_PLIST)
			type_icon:changeTexture(boat_type_icon[boat_attr[boat.id].fi_type].boat_icon, UI_TEX_TYPE_PLIST)
		else
    		self.ship_pic:setVisible(false)
    		self.ship_name:setText("")
    	end
    else
    	self.ship_pic:setVisible(false)
    	self.ship_name:setText("")
    end

	self.fleet_boat_select:setVisible(false)
end

function ClsShipyardShipItem:setSelectStatus(select)
    self.fleet_boat_select:setVisible(select)
end

function ClsShipyardShipItem:onTap(x, y)
	if self.call_back then
        self.call_back(x, y, self)
    end
end

return ClsShipyardShipItem