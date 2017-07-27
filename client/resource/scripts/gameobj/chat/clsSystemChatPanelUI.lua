local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local offset = 5
local ClsSystemListCell = require("gameobj/chat/clsSystemListCell")

local ClsSystemChatPanelUI = class("ClsSystemChatPanelUI", function() return UIWidget:create() end)
function ClsSystemChatPanelUI:ctor()
    self:configUI()
end

function ClsSystemChatPanelUI:configUI()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/chat_system.json")
end

function ClsSystemChatPanelUI:updateView()
    self:createListView()
end

function ClsSystemChatPanelUI:enterCall()
    self:updateView()
end

function ClsSystemChatPanelUI:createListView()
	if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

    local chat_data = getGameData():getChatData()
    local content = chat_data:getList(DATA_SYSTEM)

    if not content or #content < 1 then cclog("没有系统消息") return end

    self.list_view = ClsScrollView.new(355, 395, true, function()
    	
    end, {is_fit_bottom = true})

    self.cells = {}
    for k = #content, 1, -1 do
        local cell = ClsSystemListCell.new(CCSize(355, 40), content[k])
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(110, 27))
    self:addChild(self.list_view)
end

function ClsSystemChatPanelUI:addCell(msg)
    if not tolua.isnull(self.list_view) then
        local cell = ClsSystemListCell.new(CCSize(355, 40), msg)
        self.list_view:addCell(cell)
        self.list_view:scrollEndPos()
    else
        self:createListView()
    end
end

return ClsSystemChatPanelUI