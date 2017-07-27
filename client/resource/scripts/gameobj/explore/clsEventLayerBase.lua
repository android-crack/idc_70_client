--
-- Author: lzg0496
-- Date: 2016-12-07 21:20:10
-- function: 事件管理基类

local clsEventLayerBase = class("clsEventLayerBase", function()
    return CCLayer:create()
end)

function clsEventLayerBase:ctor()
    self.m_event_list = {}
    self.m_custom_event_list = {}
    self.m_event_pos_cache = {}

    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self.m_active_event = {
        order = {},
        keys = {},
    }
    self.m_active_btn = nil

    self.m_ui_view = nil

    self.m_is_release = false
end

function clsEventLayerBase:hasActiveKey(key)
    if self.m_active_event.keys[key] then
        return true
    end
    return false
end

function clsEventLayerBase:removeActiveKey(key)
    if self:hasActiveKey(key) then
        for i, info in ipairs(self.m_active_event.order) do
            if info.key == key then
                table.remove(self.m_active_event.order, i)
                self:tryToRemoveUnActiveBtn(key)
                break
            end
        end
        self.m_active_event.keys[key] = nil
    end
end

function clsEventLayerBase:addActiveKey(key, get_btn_callback, is_first)
    if not self:hasActiveKey(key) then
        local info = {key = key, callback = get_btn_callback}
        self.m_active_event.keys[key] = true
        if is_first then
            table.insert(self.m_active_event.order, 1, info)
        else
            table.insert(self.m_active_event.order, info)
        end
    end
end

function clsEventLayerBase:tryToRemoveUnActiveBtn(key)
    if not tolua.isnull(self.m_active_btn) then
        if self.m_active_btn.active_event_key == key then
            self.m_active_btn:removeFromParentAndCleanup(true)
            self.m_active_btn = nil
        end
    end
end

function clsEventLayerBase:getUiView()
    return self.m_ui_view
end

function clsEventLayerBase:update(dt)
    for _, event_obj in pairs(self.m_custom_event_list) do
        event_obj:update(dt)
    end
    
    for _, event_obj in pairs(self.m_event_list) do
        event_obj:update(dt)
    end
    self:updateActiveEventHander(dt)
end

function clsEventLayerBase:updateActiveEventHander(dt)
    if tolua.isnull(self.m_active_btn) then
        self.m_active_btn = nil
        if self.m_active_event.order[1] then
            local info = self.m_active_event.order[1]
            self.m_active_btn = info.callback()
            self.m_active_btn.active_event_key = info.key
            self.m_active_btn:setPosition(ccp(display.cx + 70, display.cy + 65))
            self:getUiView():addChild(self.m_active_btn, 10000)
        end
    else
        local key = nil
        if self.m_active_event.order[1] then
            key = self.m_active_event.order[1].key
        end
        if not key then
            self:tryToRemoveUnActiveBtn(self.m_active_btn.active_event_key)
        elseif key ~= self.m_active_btn.active_event_key then
            self:tryToRemoveUnActiveBtn(self.m_active_btn.active_event_key)
        end
    end
end

function clsEventLayerBase:deleteEventById(eid)
    local event_obj = self.m_event_list[eid]
    if event_obj then
        if event_obj:getIsDelayDelete() then
            return
        end
        event_obj:release()
    end
    self.m_event_list[eid] = nil
    self.m_event_pos_cache[eid] = nil
end

function clsEventLayerBase:forceDeleteById(eid)
    local event_obj = self.m_event_list[eid]
    if event_obj then
        event_obj:release()
    end
    self.m_event_list[eid] = nil
    self.m_event_pos_cache[eid] = nil
end


function clsEventLayerBase:removeEventById(eid)
    local target_event_obj = self.m_event_list[eid]
    if target_event_obj then
        self.m_event_list[eid] = nil
        self.m_event_pos_cache[eid] = nil
        target_event_obj:release()
    end
end

function clsEventLayerBase:removeCustomEventById(event_id)
    local event_obj = self.m_custom_event_list[event_id]
    if event_obj then
        event_obj:release()
        self.m_custom_event_list[event_id] = nil
        self.m_event_pos_cache[event_id] = nil
    end
end


function clsEventLayerBase:release()
    self.m_is_release = true
    for _, event_obj in pairs(self.m_custom_event_list) do
        event_obj:release()
    end
    for _, event_obj in pairs(self.m_event_list) do
        event_obj:release()
    end
    self.m_event_pos_cache = {}
end

function clsEventLayerBase:getIsRelease()
	return self.m_is_release
end

function clsEventLayerBase:onEnter()
end

function clsEventLayerBase:onExit()
end

return clsEventLayerBase
