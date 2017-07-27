local ui_word = require("scripts/game_config/ui_word")
local music_info = require("game_config/music_info")
local role_info = require("game_config/role/role_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsBlackObjCell = class("ClsPrivateObjCell", ClsScrollViewItem)

function ClsBlackObjCell:init(cell_date)
    self.root = UIWidget:create()
    self:addChild(self.root)
end

function ClsBlackObjCell:updateUI(cell_date, panel)
    self.root:removeAllChildren()
    self.data = cell_date

    local widegt_info = {
        [1] = {name = "head_container"},
        [2] = {name = "head_sp"},
        [3] = {name = "avatar_bg"},
        [4] = {name = "player_name"},
        [5] = {name = "player_level"},
        [6] = {name = "player_job"},
        [7] = {name = "bubble", num = "bubble_num"},
        [8] = {name = "btn_delete"}
    }
    for k, v in ipairs(widegt_info) do
        local item = getConvertChildByName(panel, v.name)
        if v.num then
            item.num = getConvertChildByName(item, v.num)
        end
        self[v.name] = item
    end

    self.head_container:setClippingEnable(true)
    self.bubble:setVisible(false)
    self.btn_delete:setVisible(true)
    self.btn_delete:setTouchEnabled(true)

    self.btn_delete:setPressedActionEnabled(true)
    self.btn_delete:addEventListener(function()--移除出黑名单
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local chat_data = getGameData():getChatData()
        chat_data:deleteBlack(self.m_cell_date.uid)
        chat_data:askJoinBlackList(self.m_cell_date.uid, 2)
    end, TOUCH_EVENT_ENDED)

    self.player_name:setText(self.data.name)
    local level = string.format("%s%s", ui_word.FRIEND_RANK_LV, self.data.level)
    self.player_level:setText(level)
    self.player_job:setText(JOB_TITLE[role_info[self.data.role].job_id])

    self.head_sp:changeTexture(string.format("ui/seaman/seaman_%s.png", self.data.icon), UI_TEX_TYPE_LOCAL)
    local icon_size = self.head_sp:getContentSize()
    local bg_size = self.avatar_bg:getSize()
    local scale =  bg_size.width / icon_size.width
    local height_scale = bg_size.height / icon_size.height
    if scale < height_scale then
        scale = height_scale
    end
    self.head_sp:setScale(scale)
end

local ClsBlackListUI = class("ClsBlackListUI", function() return UIWidget:create() end)
function ClsBlackListUI:ctor()

end

function ClsBlackListUI:updateView()
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

    local chat_data = getGameData():getChatData()
    local content = chat_data:getBlackList()
    if not content or #content < 1 then cclog("黑名单中没有人") return end

    self.list_view = ClsScrollView.new(357, 390, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/chat_pirate.json")
        return cell_ui
    end, {is_fit_bottom = true})

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsBlackObjCell.new(CCSize(360, 78), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(110, 27))
    self:addChild(self.list_view)
end

function ClsBlackListUI:addCell(info)
    local cell = ClsBlackObjCell.new(CCSize(380, 78), info)
    self.list_view:addCell(cell)
end

function ClsBlackListUI:deleteCell(uid)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == uid then
            self.list_view:removeCell(v)
            break
        end
    end
end

function ClsBlackListUI:enterCall()
    self:updateView()
end

return ClsBlackListUI
