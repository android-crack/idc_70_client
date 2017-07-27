
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsChatBubble = class("ClsChatBubble", ClsScrollViewItem)

local top_offset = 5
local left_offset = 5
local jiantou_bianju = 8

function ClsChatBubble:init()
    self.root = UIWidget:create()--用于更新
    self:addChild(self.root)
end

function ClsChatBubble:configUI()
    local cell_info = {
        [1] = {name = "name"},          --名称
        [2] = {name = "btn_avatar_bg"}, --相框
        [3] = {name = "bubble"},
        [4] = {name = "head_container"},
        [5] = {name = "head_sp"},
        [6] = {name = "text_bg"},
        [7] = {name = "chat"},
    }

    for k, v in ipairs(cell_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end
    --self.head_container:setClippingEnable(true)
end

function ClsChatBubble:createRichLable(data)
    local chat_data = getGameData():getChatData()
    local str = data.message
    if not chat_data:isColorStart(str) then
        str = string.format('$(c:COLOR_BROWN)%s', str)
    end

    str = string.gsub(str, "COLOR_WHITE", 'COLOR_BROWN')
    str = string.gsub(str, "MOREN_COLOR", 'COLOR_BROWN')
    --创建富文本
    local txt_width = 210
    local txt_height = 34
    local font_size = 16
    local label = createRichLabel(str, txt_width, txt_height, font_size, nil, nil, nil, true)

    if chat_data:isAudio(data.message) then--语音
        label:setButtonElementCallback(function(vid)
            require("ui/tools/QSpeechMgr")
            local speech = getSpeechInstance()
            speech:playAudio(vid)
        end)

        local speek_btn = label:getButtonElement()
        if speek_btn and not tolua.isnull(speek_btn) then
            local f = "@@%d+@@"
            local x, y  = string.find(data.message, f)
            local time = 1
            if x and y then
                time = string.sub(data.message, x + 2, y - 2)
            end
            
            local labelName = createBMFont({text = time .."s", size = 16, color = ccc3(dexToColor3B(COLOR_BROWN))})
            labelName:setAnchorPoint(ccp(0, 0.5))
            labelName:setPosition(25, 14)
            speek_btn:addChild(labelName)
            local voice_pic = display.newSprite("#chat_play_wave.png")
            voice_pic:setPosition(12, 14)
            speek_btn:addChild(voice_pic)
        end
    end
    self.bubble:addCCNode(label)

    label:judgeIsCanTouch(function(x, y)
        if not self.m_scroll_view:isInViewByPos(x, y) then 
            return false
        end
        return true
    end)
    
    label:regTouchFromView(getUIManager():get("ClsChatComponent"), 1)
    return label
end

function ClsChatBubble:setBubbleSize(label)
    local label_size = label:getSize()
    local label_width, label_height = label_size.width, label_size.height
    local bubble_total_width = label_width + 2 * left_offset + jiantou_bianju
    local bubble_total_height = label_height + 2 * top_offset
    self.bubble:setScale9Size(CCSize(bubble_total_width, bubble_total_height))

    return {
        left_offset = left_offset,
        top_offset = top_offset,
        bubble_total_width = bubble_total_width,
        bubble_total_height = bubble_total_height,
        jiantou_bianju = jiantou_bianju,
    }
end

function ClsChatBubble:createHead(data)
    local icon = string.format("ui/seaman/seaman_%s.png", data.senderIcon)
    local sp_pos = self.head_sp:getPosition()

    local head_icon = display.newSprite(icon)
    head_icon:setPosition(ccp(sp_pos.x, sp_pos.y))
    self.head_container:addCCNode(head_icon)

    local icon_size = head_icon:getContentSize()
    local bg_size = self.btn_avatar_bg:getSize()

    local scale =  bg_size.width / icon_size.width
    local height_scale = bg_size.height / icon_size.height

    if scale < height_scale then
        scale = height_scale
    end

    head_icon:setScale(scale*0.7)
end

function ClsChatBubble:updateListPos()
    if tolua.isnull(self.m_scroll_view) then return end
    self.m_scroll_view:updateScoreViewSize()
    self.m_scroll_view:openUpdateTimer()
end

return ClsChatBubble