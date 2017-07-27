-- radio单选按钮
local RadioButton = class("RadioButton")

local SHOW_TIPS_TIME = 1
function RadioButton:ctor(items)
    if not items or #items < 0  then return end
    self.items = items
    self.start_time = 0

    self.lastItem = nil
    self.selectedItem = nil
    for k, v in pairs(self.items) do
        v:addEventListener(function()
            self.start_time = os.time()
        end, TOUCH_EVENT_BEGAN)
        v:addEventListener(function()
            self.end_time = os.time()
            if self.end_time - self.start_time >= SHOW_TIPS_TIME then

                self:setSelectedItem(v, true)
                self:setLongSelectedItem(v)
            else
                self:setSelectedItem(v, true)
            end

        end, TOUCH_EVENT_ENDED)
        v:addEventListener(function()
            if self.selectedItem ~= nil and v == self.selectedItem then
                v:setFocused(true)
            end
        end, TOUCH_EVENT_CANCELED)
    end
end

function RadioButton:addLongSelectedEvent(func)
    self.longSelectedEvent = func
end

function RadioButton:setLongSelectedItem(item)
    item:setFocused(true)
    if self.longSelectedEvent then
        self.longSelectedEvent(item) --true:有音效
    end
end

function RadioButton:addSeletedEvent(func)
    self.selEvent = func
end

function RadioButton:addUnSeletedEvent(func)
    self.unSelEvent = func
end

--默认选中时，不需要有音效
function RadioButton:setSelectedItem(item, need_effect)
    -- item:executeEvent(TOUCH_EVENT_ENDED)
    item:setFocused(true)
    -- 是否重新触发选择事件
    if self.selectedItem ~= nil and item ~= self.selectedItem then
        self.selectedItem:setFocused(false)
        if self.unSelEvent then
            self.unSelEvent(self.selectedItem)
        end
    end

    self.selectedItem = item

    if self.selEvent then
        self.selEvent(item, need_effect) --true:有音效
    end

    self.lastItem = item

end

function RadioButton:clearSelectedItem()
    if not tolua.isnull(self.selectedItem) then
        self.selectedItem:setFocused(false)
    end

    if self.unSelEvent then
        self.unSelEvent(self.selectedItem)
    end
end

function RadioButton:getSelectedItem()
    return self.selectedItem
end

return RadioButton
