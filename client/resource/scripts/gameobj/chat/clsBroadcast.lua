local ClsBaseView = require("ui/view/clsBaseView")
local ClsBroadcast = class("ClsBroadcast", ClsBaseView)

local max_width = 900--实际上会被忽略
local offset = 5 --让创建的富文本的高度比容器少offset
local speed = 120 --移动速度

function ClsBroadcast:getViewConfig()
    return {
    	name = "ClsBroadcast",
        type = UI_TYPE.NOTICE,
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsBroadcast:onEnter(parameter)
	self:configUI()
    self:broadcast()
end

function ClsBroadcast:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_notice.json")
    self:addWidget(self.panel)

    self.view_panel = getConvertChildByName(self.panel, "view_panel")
    self.notice_text = getConvertChildByName(self.panel, "notice_text")
    self.notice_text:setVisible(false)
    self.view_panel:setClippingEnable(true)
end

function ClsBroadcast:broadcast()
    local broadcast_data = getGameData():getBroadcastData()
    local broadcast_list = broadcast_data:getBroadcastList()
    local index = broadcast_data:getCurrentScrolledIndex()
    local cur_msg = broadcast_list[index]
    if cur_msg then
        broadcast_data:setScrolledMessageNum()
    else
        self:close()
        return
    end 
    local view_pos = self.view_panel:getPosition()
    local view_size = self.view_panel:getSize()

    local show_txt = nil
    local have_color = self:isHaveColor(cur_msg.message)
    if not have_color then
        show_txt = string.format("$(c:COLOR_WHITE)%s", cur_msg.message)
    else
        show_txt = string.format("%s", cur_msg.message)
    end

    local label = createRichLabel(show_txt, max_width, (view_size.height - offset), 14, nil, true)
    self.view_panel:addCCNode(label)
    local pos_x = view_size.width
    local pos_y = (view_size.height - label:getSize().height) / 2
    label:setPosition(ccp(pos_x, pos_y))

    local arr = CCArray:create()
    local move_time = (label:getSize().width + view_size.width) / speed

    local x_move_by = -(label:getSize().width + view_size.width)
    local move_action  = CCMoveBy:create(move_time, ccp(x_move_by, 0))
    arr:addObject(move_action)
    arr:addObject(CCCallFunc:create(function() 
        self:broadcast()
    end))

    local move = CCSequence:create(arr)
    label:runAction(move)
end

--这个信息原本就有颜色
function ClsBroadcast:isHaveColor(msg)
    local match_str = string.find(msg, "$%(c:COLOR_(.-)%)")
    return match_str ~= nil
end

return ClsBroadcast