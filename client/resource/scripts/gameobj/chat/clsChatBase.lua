--聊天左下角面板和聊天主界面的基类
--暂时不用

local ClsChatBase = class("ClsChatBase", function() return UIWidget:create() end)

function ClsChatBase:ctor(paramter)
    local json_name = paramter.json_res
    local path = string.format("json/%s", json_name)
    self.panel = GUIReader:shareReader():widgetFromJsonFile(path)
    self:addChild(self.panel)
end

--object 表示谁运行该动画
--pre_call_back 表示该动画执行之前要做的操作
--behind_call_back 表示该动画执行之后要做的操作
--action_time 表示动画执行的时间
--is_show表示显示还是隐藏

function ClsChatBase:performAction(object, is_show, action_time)
    if tolua.isnull(object) then return end      --判断执行动画对象存不存在
    if object.is_showing then return end         --判断对象是否正在执行动画中
    if object.is_show == is_show then return end --判断设置的状态和当前状态是否相同

    object.is_showing = true --正在显示当中
    local action_time = action_time or 0

    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function() 
        if is_show then
            if type(object.show_pre_call) == "function" then
                object.show_pre_call()
                object.show_pre_call = nil
            elseif type(object.default_show_pre_call) == "function" then
                object.default_show_pre_call()
            end
        else
            if type(object.hide_pre_call) == "function" then
                object.hide_pre_call()
                object.hide_pre_call = nil
            elseif type(object.default_hide_pre_call) == "function" then
                object.default_hide_pre_call()
            end
        end
    end))

    local scale = nil
    local scale_action = nil
    if not is_show then
        scale = CCScaleTo:create(action_time, 0, 1)
        scale_action = CCEaseBackIn:create(scale)
    else
        scale = CCScaleTo:create(action_time, 1, 1)
        scale_action = CCEaseBackOut:create(scale)
    end
    array:addObject(scale_action)

    array:addObject(CCCallFunc:create(function()
        if is_show then
            if type(object.show_end_call) == "function" then
                object.show_end_call()
                object.show_end_call = nil
            elseif type(object.default_show_end_call) == "function" then
                object.default_show_end_call()
            end
        else
            if type(object.hide_end_call) == "function" then
                object.hide_end_call()
                object.hide_end_call = nil
            elseif type(object.default_hide_end_call) == "function" then
                object.default_hide_end_call()
            end
        end
        object.is_showing = false 
        object.is_show = is_show --最终状态
        object:setVisible(is_show)
    end))

    object:runAction(CCSequence:create(array))
end

--界面隐藏之前的回调
function ClsChatBase:setHidePreCall(call)
    if not self.action_bg.default_hide_pre_call then
        self.action_bg.default_hide_pre_call = call
    end
    self.action_bg.hide_pre_call = call
end

--界面隐藏之后的回调
function ClsChatBase:setHideEndCall(call)
    if not self.action_bg.default_hide_end_call then
        self.action_bg.default_hide_end_call = call
    end
    self.action_bg.hide_end_call = call
end

--界面显示之前的回调
function ClsChatBase:setShowPreCall(call)
    if not self.action_bg.default_show_pre_call then
        self.action_bg.default_show_pre_call = call
    end
    self.action_bg.show_pre_call = call
end

--界面显示之后的回调
function ClsChatBase:setShowEndCall(call)
    if not self.action_bg.default_show_end_call then
        self.action_bg.default_show_end_call = call
    end
    self.action_bg.show_end_call = call
end

function ClsChatBase:getChatBg()
    return self.action_bg
end

return ClsChatBase