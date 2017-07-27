local sailor_info = require("game_config/sailor/sailor_info")
local nobility_data = require("game_config/nobility_data")
local area_info = require("game_config/port/area_info")
local music_info = require("game_config/music_info")
local uiTools = require("gameobj/uiTools")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local cell_info = {
    [1] = {name = "head_icon"},
    [2] = {name = "state_text"},
    [3] = {name = "player_title"},
    [4] = {name = "player_name"},
    [5] = {name = "player_level"},
    [6] = {name = "area_name"},
    [7] = {name = "gold_icon"},
    [8] = {name = "gold_num"},
    [9] = {name = "player_power_num"},
    [10] = {name = "win_panel"},
    [11] = {name = "fail_panel"},
    [12] = {name = "select_pic"}
}

local ClsPlunderCell = class("ClsPlunderCell", ClsScrollViewItem)

function ClsPlunderCell:updateUI(cell_date, panel)
	local data = cell_date
	self.btn_tab = {}

	for k, v in ipairs(cell_info) do
        local item = getConvertChildByName(panel, v.name)
        item.name = v.name
        self[v.name] = item
    end

    --头像
    local player_photo_id = nil
    if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
        player_photo_id = 101
    else
        player_photo_id = tonumber(data.icon)
    end

    self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
    local head_size = self.head_icon:getContentSize()
    self.head_icon:setScale(90 / head_size.height)

    --点击头像出现船长信息
    self.head_icon:setTouchEnabled(true)
    self.head_icon:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, cell_date.target_id)
    end, TOUCH_EVENT_ENDED)

    --登录状态
    self.state_text:setVisible(true)
    local last_login_time_text, latest_login_time = uiTools:getLoginStatus(data.lastLoginTime)
    self.state_text:setText(last_login_time_text)
    self.state_text:setOpacity(255)--先还原
    if data.lastLoginTime ~= ONLINE then
        self.state_text:setOpacity(255 / 2)
    end

    --爵位
    local nobility_info = nobility_data[data.nobility]
    if nobility_info then
        self.player_title:setVisible(true)
        self.player_title:changeTexture(convertResources(nobility_info.peerage_before), UI_TEX_TYPE_PLIST)
    else
        self.player_title:setVisible(false)
    end

    self.player_name:setText(data.name)
    self.player_level:setText(string.format("Lv.%s", data.level))
    self.area_name:setText(area_info[data.area].name)
    local reward_icon = "common_icon_coin.png"
    if data.is_gold ~= 0 then
        reward_icon = "common_icon_diamond.png"
    end
    self.gold_icon:changeTexture(reward_icon, UI_TEX_TYPE_PLIST)
    self.gold_num:setText(math.abs(data.result))
    self.player_power_num:setText(data.zhandouli)

    self.win_panel:setVisible(data.is_win ~= 0)
    self.fail_panel:setVisible(data.is_win == 0)
end

function ClsPlunderCell:onTap(x, y)

end

local ClsPlunderReportUI = class("ClsPlunderReportUI", function() return UIWidget:create() end)
function ClsPlunderReportUI:ctor()
    self:configUI()
    self:updateListView()
end

function ClsPlunderReportUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_prestige.json")
    self:addChild(self.panel)
end

function ClsPlunderReportUI:updateListView(content)
	if not content then
		local loot_data_handler = getGameData():getLootData()
		content = loot_data_handler:getPlunderReport()
	end

	--不论有无数据都先清空列表
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

	if not content then cclog("没有掠夺数据") return end

	self.list_view = ClsScrollView.new(785, 420, true, function()
		local cell = GUIReader:shareReader():widgetFromJsonFile("json/friend_report_cell2.json")
        return cell
    end)

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsPlunderCell.new(CCSize(768, 104), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, 13))
    self:addChild(self.list_view)
end

function ClsPlunderReportUI:updateListCell(info)
    if tolua.isnull(self.list_view) then return end

    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.id == info.id then
            v.m_cell_date = info
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end
end

return ClsPlunderReportUI

