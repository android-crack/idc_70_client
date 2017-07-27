local ClsBaseView = require("ui/view/clsBaseView")
local ClsChatExpand = class("ClsChatExpand", ClsBaseView)

function ClsChatExpand:getViewConfig()
    return {
        name = "ClsChatExpand",
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsChatExpand:onEnter(parameter)
    self.parameter = parameter
    self:setIsWidgetTouchFirst(true)
    self:configUI()
    self:configEvent()
end

function ClsChatExpand:configUI()
    local cells = self.parameter.cells
    
    local new_pos_x = 475
    local new_pos_y = 453
    for k, v in ipairs(cells) do
        local cell_size = v:getContentSize()
        local cell_height = cell_size.height
        new_pos_y = new_pos_y - cell_height
        v:setPosition(ccp(new_pos_x, new_pos_y))
        self:addWidget(v)
    end
end

function ClsChatExpand:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            self:close()
            return false
        end
    end)
end

return ClsChatExpand