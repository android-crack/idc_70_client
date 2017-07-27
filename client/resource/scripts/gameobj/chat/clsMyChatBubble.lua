local ui_word = require("scripts/game_config/ui_word")
local ClsChatBubble = require("gameobj/chat/clsChatBubble")
local ClsMyChatBubble = class("ClsMyChatBubble", ClsChatBubble)
local Alert = require("ui/tools/alert")

function ClsMyChatBubble:updateUI(cell_date, panel)
    self.root:removeAllChildren()
    self.cell_date = cell_date
    self:configUI()
end

function ClsMyChatBubble:onLongTap(x, y)
	if not tolua.isnull(self.m_chat_richlabel) then
		local chat_component = getUIManager():get("ClsChatComponent")
        local main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
        local cur_panel = main_ui:getCurPanel()
        if type(cur_panel.setEidtBoxStr) == "function" then
            cur_panel:setEidtBoxStr(self.m_chat_richlabel:getStringText())
            Alert:warning({msg = ui_word.STR_HAS_COPY})
        end
	end
end

function ClsMyChatBubble:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/chat_me.json")
    self.root:addChild(self.panel)
    self.super.configUI(self)

    local data = self.cell_date
    local label = self:createRichLable(data)
	self.m_chat_richlabel = label
    local label_size = label:getSize()
    local base_data = self:setBubbleSize(label)

    local offset_x = (base_data.bubble_total_width - base_data.jiantou_bianju - label_size.width) / 2
    local pos_x = offset_x - base_data.bubble_total_width

    local offset_y = (base_data.bubble_total_height - label_size.height) / 2
    local pos_y = offset_y - base_data.bubble_total_height
    label:setPosition(ccp(pos_x, pos_y))

    local player_data = getGameData():getPlayerData()
    self.name:setText(string.format(ui_word.NAME_BOX_WITH_TIME, player_data:getName(), os.date("%H:%M", data.time)))
    self.name:setVisible(data.sender ~= GAME_SYSTEM_ID)

    self:createHead(data)

    self.main_chat_me = getConvertChildByName(self.panel, "main_chat_me")
    local origin_size = self.main_chat_me:getSize()
    local origin_width = origin_size.width

    local head_size = self.btn_avatar_bg:getSize()
    local head_height = head_size.height
    local top_offset = 15
    local name_offset = 20
    local juli = head_height / 4
    local bottom_offset = 10
    local bubble_height = math.max((3 * head_height) / 4, base_data.bubble_total_height)
    local cell_height = juli + bottom_offset + bubble_height

    local bg_avatar_pos = self.btn_avatar_bg:getPosition()
    local bubble_pos = self.bubble:getPosition()
    local name_pos = self.name:getPosition()
    local head_container_pos = self.head_container:getPosition()

    local cell_size = CCSize(origin_width, cell_height)
    self.main_chat_me:setSize(cell_size)
    self.chat:setSize(cell_size)
    self:setHeight(cell_height)

    self.btn_avatar_bg:setPosition(ccp(bg_avatar_pos.x, cell_height - top_offset - head_height / 2))
    self.bubble:setPosition(ccp(bubble_pos.x, cell_height - top_offset - head_height / 4))
    self.name:setPosition(ccp(name_pos.x, cell_height - name_offset))

    self:updateListPos()
end

return ClsMyChatBubble