local ui_word = require("scripts/game_config/ui_word")
local role_info = require("game_config/role/role_info")
local ClsScrollView = require("ui/view/clsScrollView")
local music_info = require("game_config/music_info")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsPrivateObjCell = class("ClsPrivateObjCell", ClsScrollViewItem)

function ClsPrivateObjCell:updateUI(cell_date, panel)
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

    local func = self.bubble.setVisible
    function self.bubble:setVisible(enable, num)
        func(self, enable)
        if enable then
            self.num:setText(num)
        end
    end

    self.btn_delete:setPressedActionEnabled(true)
    self.btn_delete:addEventListener(function()--删除聊天记录
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local chat_data = getGameData():getChatData()
        chat_data:deleteMsgRecord(self.data.uid)
    end, TOUCH_EVENT_ENDED)

    local chat_data = getGameData():getChatData()
    local not_read_num = chat_data:getNotReadByUid(self.data.uid)
    self.bubble:setVisible(not_read_num > 0, not_read_num)
    self.btn_delete:setVisible(not_read_num <= 0)
    self.btn_delete:setTouchEnabled(not_read_num <= 0)

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

function ClsPrivateObjCell:onTap(x, y)
    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, self.data)
    main_ui:executeSelectTabLogic(INDEX_PLAYER)
end

local ClsPrivateObjUI = class("ClsPrivateObjUI", function() return UIWidget:create() end)
function ClsPrivateObjUI:ctor()

end

function ClsPrivateObjUI:updateView()
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

    local chat_data = getGameData():getChatData()
    local content = chat_data:getList(DATA_PRIVATE)
    
    if not content or #content < 1 then cclog("没有和你私聊的人") return end

    self.list_view = ClsScrollView.new(355, 390, true, function()
    	local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/chat_pirate.json")
        return cell_ui
    end, {is_fit_bottom = true})

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsPrivateObjCell.new(CCSize(360, 78), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(113, 29))
    self:addChild(self.list_view)
end

function ClsPrivateObjUI:enterCall()
    self:updateView()
end

function ClsPrivateObjUI:updateCell(info)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == info.uid then
            self.list_view:moveCellByIndex(v, 1)
            v.m_cell_date = info
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end
end

function ClsPrivateObjUI:deleteCell(uid)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == uid then
            self.list_view:removeCell(v)
            break
        end
    end
end

function ClsPrivateObjUI:addCell(info)
    if not tolua.isnull(self.list_view) then
        local cell = ClsPrivateObjCell.new(CCSize(360, 78), info)
        self.list_view:addCellByIndex(cell, 1)
    else
        self:updateView()
    end
end

return ClsPrivateObjUI
