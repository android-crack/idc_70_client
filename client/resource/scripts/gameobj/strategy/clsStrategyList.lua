local strategy_conf = require("game_config/strategy/strategy_conf")
local strategy_text = require("game_config/strategy/strategy_text")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsStrategyItem = class("ClsStrategyItem", require("ui/view/clsScrollViewItem"))
local ClsStrategyList = class("ClsStrategyList", function()
	return UIWidget:create() 
end)

function ClsStrategyList:ctor(tab, index)
	self._tab = tab
	self._index = index
	self.list_width = 620
	self.list_height = 324

	if self._tab then
		if not self._index then
            local BIG_TITLE = 10
            local text = strategy_text[BIG_TITLE..self._tab].content
			self:updateList(text)
		else
            self:updateList(strategy_text[self._index].content)
		end
	end
end

function ClsStrategyList:updateList(strategy_content)
    if not tolua.isnull(self.m_list) then
        self.m_list:removeFromParent()
    end

    self.m_list = ClsScrollView.new(self.list_width, self.list_height, true, nil, {is_fit_bottom = true})
    self.m_list:setPosition(ccp(261, 101))
    self:addChild(self.m_list)

    local cells = {}
    for _, info in ipairs(strategy_content or {}) do
        local text_content = info[1]
        local font_size = info[2] or 16
        local font_color = info[3] or COLOR_BROWN
        local label = createBMFont({text = text_content, anchor=ccp(0,0), fontFile = FONT_COMMON, size = font_size, align = ui.TEXT_ALIGN_LEFT, 
            width = self.list_width, color = ccc3(dexToColor3B(font_color))})
        local size = label:getContentSize()
        if string.len(text_content) <= 0 then
            size.width = self.list_width
            if font_size then
                size.height = 16*font_size
            end 
        end
        local cell = ClsStrategyItem.new(CCSize(size.width, size.height))
        cells[#cells + 1] = cell
        cell:addCCNode(label)
    end
    self.m_list:addCells(cells)
end

return ClsStrategyList