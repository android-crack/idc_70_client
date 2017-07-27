--界面最基础的类(可以根据整个游戏的界面特性添加相应属性或者方法)
local missionGuide = require("gameobj/mission/missionGuide")
local element_mgr = require("base/element_mgr")
local OFFSET = 10       --偏移量

--parameter是new时传过来的参数
local function createLayer(parameter)
    local create_layer = display.newLayer()

    if type(parameter) ~= "table" then return create_layer end
    
    if parameter.opacity then
        create_layer = CCLayerColor:create(ccc4(0, 0, 0, parameter.opacity))
    end

    if parameter.add_scene then
        local running_scene = GameUtil.getRunningScene()
        if tolua.isnull(running_scene) then return end
        running_scene:addChild(create_layer)
    end

    return create_layer
end

local ClsViewBase = class("ClsViewBase", createLayer)

function ClsViewBase:ctor(parameter)
    -- json 资源
    self.json_res = nil
    -- 来自json文件的panel
    self.panel = nil
    -- 用于承载panel
    self.ui_layer = nil
    -- 需要用到的plist
    self.plists = nil
    --ui_layer的触摸优先级
    self.priority = nil
    self:initialize(parameter)
end

-- 统一刷新接口，方便在element_mgr对象中直接调用刷新
function ClsViewBase:updateView()
    -- todo
end

-- 所有界面统一关闭接口，有些操作不能在onExit函数中进行，
-- 如果在关闭界面时有其他附带操作，重写此函数即可
function ClsViewBase:destroy()
    self:removeFromParentAndCleanup(true)
end

function ClsViewBase:initialize(parameter)
    if parameter then
        self.json_res = parameter.json_res
        self.plists = parameter.plists
        self.priority = parameter.priority
        if self.plists then
            LoadPlist(self.plists)
        end
    end
    element_mgr:add_element(self.__cname, self)
    self:registerEvent()
    self:loadJson()
end

function ClsViewBase:setTouchPriority(priority)
    self.ui_layer:setTouchPriority(priority)
end

function ClsViewBase:registerEvent()
    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)
end

function ClsViewBase:loadJson()
    if not self.json_res then return end
    self.ui_layer = UILayer:create()
    if self.priority then
        self.ui_layer:setTouchPriority(self.priority)
    end
    local path = string.format("json/%s", self.json_res)
    self.panel = createPanelByJson(path)
    self.ui_layer:addWidget(self.panel)
    self:addChild(self.ui_layer)
end

--这个可以根据情况增加paramter
function ClsViewBase:registerScriptTouchEvent(parameter)
    local is_event_rect = parameter.is_event_rect--当前提供的区域是否是事件区域
    local touch_rect = parameter.rect or CCRect(0, 0, display.width, display.height)
    local touch_priority = parameter.priority or 300
    local function onTouch(event_type, x, y)
        local touch_node_pos = self:convertToNodeSpace(ccp(x, y))
        if event_type == "began" then
            if is_event_rect then
                if touch_rect:containsPoint(touch_node_pos) then
                    return self:onTouchBegan(x, y)
                end
            else
                if not touch_rect:containsPoint(touch_node_pos) then
                    return self:onTouchBegan(x, y)
                end
            end
        elseif event_type == "ended" then
            self:onTouchEnded(x, y)
        elseif event_type == "moved" then
            self:onTouchMoved(x, y)
        elseif event_type == "cancelled" then
            self:onTouchCancelled()
        end
    end

    self:registerScriptTouchHandler(onTouch, false, touch_priority, true)
    self:setTouchEnabled(true)
end

--避免移动也做操作
function ClsViewBase:onTouchBegan(x, y)
    self.drag = {
        start_x = x,     --第一次触摸的位置
        start_y = y,
        is_tap = true,
    }
    return true
end

function ClsViewBase:onTouchMoved(x, y)
    if self.drag.is_tap then
        if math.abs(y - self.drag.start_y) >= OFFSET or math.abs(x - self.drag.start_x) >= OFFSET then
            self.drag.is_tap = false
        end
    end
end

function ClsViewBase:onTouchCancelled(x, y)
    self.drag = nil
end

function ClsViewBase:onTouchEnded(x, y)
    if self.drag.is_tap then

    end
end

function ClsViewBase:onEnter()
    
end

function ClsViewBase:onExit()
    -- missionGuide:enableAllGuide()
    element_mgr:del_element(self.__cname)
    if self.plists then
        UnLoadPlist(self.plists)
    end
end

return ClsViewBase