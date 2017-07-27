local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local offset = 5

local pic_info_by_index = {
    [INDEX_GUILD] = {pic = "#chat_box_guild.png", txt = ui_word.CHAT_GUILD_KIND},
    [INDEX_WORLD] = {pic = "#chat_box_world.png", txt = ui_word.CHAT_WORLD_KIND},
    [INDEX_SYSTEM] = {pic = "#chat_box_system.png", txt = ui_word.SYSTEM_NAME},
}

local ClsSystemListCell = class("ClsSystemListCell", ClsScrollViewItem)
function ClsSystemListCell:updateUI(cell_date, panel)
    local data = cell_date

    --创建最左边的频道图片
    local icon = nil
    local name = nil

    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    local cur_channel = main_ui:getCurrentChannel()
    local pic_info = pic_info_by_index[cur_channel]
    icon = pic_info.pic
    name = pic_info.txt

    local kind_pic = display.newSprite(icon)
    local pic_size = kind_pic:getContentSize()
    local label = createBMFont({text = name, size = 14, fontFile = FONT_COMMON, color = ccc3(dexToColor3B(COLOR_WHITE))})
	self.m_chat_label = label
    label:setPosition(ccp(pic_size.width / 2, pic_size.height / 2))
    kind_pic:addChild(label)

    local cell_width = self:getWidth()
    local rich_label_width = cell_width - pic_size.width - 3 * offset

    local height = 34
    local font_size = 14
    local vertical_space = 0

    local chat_data = getGameData():getChatData()
    local str = cell_date.message
    if not chat_data:isColorStart(str) then
        str = string.format('$(c:COLOR_BROWN)%s', str)
    end
    str = string.gsub(str, "COLOR_WHITE", 'COLOR_BROWN')
    str = string.gsub(str, "MOREN_COLOR", 'COLOR_BROWN')
    
    local rich_label = createRichLabel(str, rich_label_width, height, font_size, vertical_space)
    local rich_size = rich_label:getSize()
 
    local cell_height = math.max(pic_size.height, rich_size.height)
    self:setHeight(cell_height + 2 * offset)

    local pic_width = pic_size.width
    local pic_height = pic_size.height

    local pic_pos = ccp((offset + pic_width / 2), (cell_height - offset - pic_height / 2))
    kind_pic:setPosition(pic_pos)

    rich_label:ignoreAnchorPointForPosition(false)
    rich_label:setAnchorPoint(ccp(0, 1))
    local rich_pos = ccp((2 * offset + pic_width), (cell_height - offset))
    rich_label:setPosition(rich_pos)
    
    rich_label:regTouchFromView(getUIManager():get("ClsChatComponent"), 1)

    rich_label:judgeIsCanTouch(function(x, y)
        if not self.m_scroll_view:isInViewByPos(x, y) then 
            return false
        end
        return true
    end)

    self:addCCNode(kind_pic)
    self:addCCNode(rich_label)
    self:updateListPos()
end

function ClsSystemListCell:onLongTap(x, y)
	if not tolua.isnull(self.m_chat_label) then
		local chat_component = getUIManager():get("ClsChatComponent")
		local main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
		local cur_panel = main_ui:getCurPanel()
        if type(cur_panel.setEidtBoxStr) == "function" then
    		cur_panel:setEidtBoxStr(self.m_chat_label:getString())
    		require("ui/tools/alert"):warning({msg = ui_word.STR_HAS_COPY})
        end
	end
end

function ClsSystemListCell:updateListPos()
    if tolua.isnull(self.m_scroll_view) then return end
    self.m_scroll_view:updateScoreViewSize()
    self.m_scroll_view:openUpdateTimer()
end

return ClsSystemListCell