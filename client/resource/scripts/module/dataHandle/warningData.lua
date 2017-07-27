local element_mgr = require("base/element_mgr")
local ClsWarningItem = class("ClsWarningItem", function() return display.newSprite() end)

local MAX = 4 -- 最多显示个数
local MAX_NUM = 4
local UPDATE_TIME = 0.05 --刷新频率（秒）

local ALHPA_PER_UPDATE = 25 -- 每次刷新减少的透明度
local DELAY_TIME = 1.5  -- 默认停留时间（秒）

function ClsWarningItem:ctor(data)
    self.data = data

    self.sp = nil
    self.label = nil
    self.label2 = nil
    self.delay_time = nil

    self:mkUI()
end

function ClsWarningItem:mkUI()
    local time = self.data.time or 2 -- 没有使用

    local msg = self.data.msg
    local color = self.data.color or ccc3(dexToColor3B(COLOR_CREAM_STROKE))
    local label_width = self.data.label_width or 230
    local label_height = self.data.label_height or 8
    local label_anchor = ccp(0.5, 0.5)

    local msg2 = self.data.msg_2
    local color2 = self.data.color_2 or color
    local label2_width = self.data.label_2_height or 230
    local label2_height = self.data.label_2_width or 8
    local label2_anchor = ccp(0.5, 0.5)

    if msg2 then
        label_anchor = ccp(1, 0.5)
        label2_anchor = ccp(0, 0.5)
    end

    local fate_out_delay = self.data.fate_out_delay or 0
    self.delay_time = fate_out_delay + DELAY_TIME

    --local size = self.data.size or 16
    local size = 16
    self.label = createRichLabel(msg, label_width, label_height, size, nil, nil, true)
    self.label:ignoreAnchorPointForPosition(false)
    self.label:setAnchorPoint(label_anchor)

    local sp_width = 0
    local sp_height = 0

    local label_content_size = self.label:getSize()
    sp_width = sp_width + label_content_size.width
    sp_height = math.max(sp_height, label_content_size.height)
    if msg2 then
        self.label2 = createRichLabel(msg2, label2_width, label2_height, size, nil, nil, true)
        self.label2:setAnchorPoint(label2_anchor)

        local label2_content_size = self.label2:getContentSize()
        sp_width = sp_width + label2_content_size.width
        sp_height = math.max(sp_height, label2_content_size.height)
    end
    
    local add_width_n = self.data.add_width or 0
    sp_width = sp_width + 20 + 2 * add_width_n
    sp_height = sp_height + 20

    local frame = display.newSpriteFrame("common_tips.png")
    self.sp = CCScale9Sprite:createWithSpriteFrame(frame)
    self.sp:setContentSize(CCSize(sp_width, sp_height))
    self.sp:addChild(self.label)

    if msg2 then
        self.label:setPosition(ccp(sp_width / 2 + 10, sp_height / 2))
        self.label2:setPosition(ccp(sp_width / 2 + 15, sp_height / 2))
        self.sp:addChild(self.label2)
    else
        self.label:setPosition(ccp(sp_width / 2, sp_height / 2))
    end
    
    local zorder = self.data.zorder or TOP_ZORDER
    self:setAnchorPoint(ccp(0, 0.5))
    self:setContentSize(self.sp:getContentSize())
    self:addChild(self.sp)
    self:setZOrder(zorder)
end

function ClsWarningItem:setNodesOpacity(alpha)
    if tolua.isnull(self) then return end
    local orginal_alpha = self:getOpacity()
    if orginal_alpha < alpha then return end

    self:setOpacity(alpha)
    self.sp:setOpacity(alpha)
    self.label:setOpacity(alpha)
    if self.label2 then
        self.label2:setOpacity(alpha)
    end
end

function ClsWarningItem:updateNodesOpacity()
    if tolua.isnull(self) then return end
    self.delay_time = self.delay_time - UPDATE_TIME
    if self.delay_time > 0 then return end

    local alpha = self:getOpacity() - ALHPA_PER_UPDATE
    if alpha <= 0 then alpha = 0 end

    self:setOpacity(alpha)
    self.sp:setOpacity(alpha)
    self.label:setOpacity(alpha)
    if self.label2 then
        self.label2:setOpacity(alpha)
    end
end

function ClsWarningItem:removeCallBack()
    if tolua.isnull( self ) then return end
    if self.data.remove_call_back then
        self.data.remove_call_back()
    end
    self:removeFromParentAndCleanup(true)
end

function ClsWarningItem:setItemPosition(pos)
    if tolua.isnull( self ) then return end
    self:setPosition(pos)
end

function ClsWarningItem:getItemSize()
    if tolua.isnull( self ) then return end
    return self:getContentSize()
end

function ClsWarningItem:getItemOpacity()
    if tolua.isnull(self) then return end
    return self:getOpacity()
end


local ClsWarningList = class("WarningList")
function ClsWarningList:ctor()
    self.list = {}
end

function ClsWarningList:addItem(data, max, off_y)
    MAX = max or MAX_NUM

    if #self.list >= MAX then
        local last_item = table.remove(self.list)
        last_item:removeCallBack()
        last_item = nil
    end

    local item = ClsWarningItem.new(data)
    table.insert(self.list, 1, item)

    local y = off_y or 150

    for k, v in pairs(self.list) do
        local alpha = (MAX - k + 1) * 255 / MAX -- 根据item所处位置改变不透明度
        v:setNodesOpacity(alpha)
        v:setItemPosition(ccp(display.cx, display.top - y))

        local size = v:getItemSize()
        if size then
            y = y + size.height
        end
    end

    local prizon_ui = getUIManager():get("ClsPrizonUI")

    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    if not tolua.isnull(prizon_ui) or auto_trade_data:inAutoTradeAIRun() then
        local running_scene = GameUtil.getNotification()
        running_scene:addChild(item, 50) 
    else 

        local curScene = GameUtil.getRunningScene()
        if not tolua.isnull(curScene) then
            curScene:addChild(item, ZORDER_ALERT)            
        end
    end

    if not self.warning_handle then
        local scheduler = CCDirector:sharedDirector():getScheduler()
        local function changeItemsOpacity()
            if #self.list == 0 then
                scheduler:unscheduleScriptEntry(self.warning_handle)
                self.warning_handle = nil
                return
            end

            -- 改变不透明度
            for k, v in pairs(self.list) do
                v:updateNodesOpacity()
            end

            -- 删除不透明度为0的tips
            for i = #self.list, 1, -1 do
                local alpha = self.list[i]:getItemOpacity()
                if alpha == 0 then
                    local last_item = table.remove(self.list)
                    last_item:removeCallBack()
                    last_item = nil
                end
            end
        end

        self.warning_handle = scheduler:scheduleScriptFunc(function()
            changeItemsOpacity()
        end, UPDATE_TIME, false)
    end
end


local ClsWarningData = class("WarningData")

function ClsWarningData:ctor()
    self:clearData()
    self.list = ClsWarningList.new()
end

function ClsWarningData:clearData()
    self.delay_warning_info_queue = {}
end

function ClsWarningData:addItem(data, max, off_y)
    self.list:addItem(data, max, off_y)
end

function ClsWarningData:addDelayPlayItem(item)
    table.insert(self.delay_warning_info_queue, item)
end

function ClsWarningData:play()
    if #self.delay_warning_info_queue > 0 then
        for _, warning_info in ipairs(self) do
            self.list:addItem(warning_info)
        end
    end
    self.delay_warning_info_queue = {}
end

function ClsWarningData:resume()
 -- body
end

function ClsWarningData:pause()
 -- body
end

return ClsWarningData