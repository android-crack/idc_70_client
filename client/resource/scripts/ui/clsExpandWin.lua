local ClsBaseView = require("ui/view/clsBaseView")
local ClsExpandWin = class("clsExpandWin", ClsBaseView)

local bg_min_width = 108
local bg_min_height = 46
local bianju = 10
local top_offset = 1
local left_offset = 1
local offset_h = 1--cell之间的最小间距

function ClsExpandWin:getViewConfig()
    return {
    	name = "ClsExpandWin",
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsExpandWin:onEnter(parameter)
	self:setIsWidgetTouchFirst(true)
	self.parameter = parameter
    parameter.pos = parameter.pos or ccp(0, 0)
	self.convert_node = CCNode:create()
	self:addChild(self.convert_node)
	self:configUI()
	self:configEvent()
end

function ClsExpandWin:configUI()
	local bg = UIImageView:create()
    
    local pic = "common_9_popup.png"
    if self.parameter.pic ~= nil then
        pic = self.parameter.pic
    end

    bg:loadTexture(pic, UI_TEX_TYPE_PLIST)
    bg:setAnchorPoint(ccp(0, 0))
    bg:setScale9Enable(true)
    bg:setCapInsets(CCRect(0, 0, 0, 0))
    bg:setScale9Size(CCSize(bg_min_width, bg_min_height))
    self:addWidget(bg)

    local cells = self.parameter.cells
    local cells_height = 0
    local cell_width = 0
    for k, v in ipairs(cells) do
    	local cell_size = v:getContentSize()
    	cell_height = cell_size.height
    	cell_width = cell_size.width
    	cells_height = cells_height + cell_height
    end

    bianju = self.parameter.bianju or bianju
    local total_height = bianju * 2 + cells_height + offset_h * (#cells - 1) + top_offset * 2 
    local total_width = bianju * 2 + cell_width + 2 * left_offset
    bg:setScale9Size(CCSize(total_width, total_height))

    self.width = total_width
    self.height = total_height

    local new_pos_x = bianju + left_offset + 1
    local new_pos_y = total_height - bianju - top_offset - cell_height

    for k, v in ipairs(cells) do
    	v:setPosition(ccp(new_pos_x, new_pos_y - 1))
        new_pos_y = new_pos_y - (offset_h + cell_height)
    	bg:addChild(v)
    end

    if self.parameter.pos_type == nil then
        self.parameter.pos_type = POS_TYP.CENTER
    end

    local new_pos_y = 0
    if self.parameter.pos_type == POS_TYP.CENTER then
        new_pos_y = self.parameter.pos.y - total_height / 2
    elseif self.parameter.pos_type == POS_TYP.BOTTOM then
        new_pos_y = self.parameter.pos.y
    end
    self:setPosition(ccp(self.parameter.pos.x, new_pos_y))
end

function ClsExpandWin:getHeight()
    return self.height
end

function ClsExpandWin:getWidth()
    return self.width
end

function ClsExpandWin:configEvent()
	self:regTouchEvent(self, function(event_type, x, y)
		local pos = self.convert_node:convertToNodeSpace(ccp(x, y))
		local not_at_rect = not CCRect(0, 0, self.width, self.height):containsPoint(pos)
        if event_type == "began" then
            local item = self.parameter.item
            if not tolua.isnull(item) then
                local world_pos = item:getWorldPosition()
                local touch_x = x - world_pos.x
                local touch_y = y - world_pos.y
                if touch_x > 0 and touch_y > 0 and touch_x < item:getWidth() and touch_y < item:getHeight() and not_at_rect then
                    return false
                end
            end
            if not_at_rect then
                self:close()
                return false
            end
            return true
        end
    end)
end

return ClsExpandWin