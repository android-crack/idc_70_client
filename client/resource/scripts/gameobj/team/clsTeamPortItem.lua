-- 港口界面小组队框item
-- Author: pyq
-- Date: 2016-08-21 0:00:00
--
local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local nobility_conf = require("game_config/nobility_data")
local ClsCommonFuns = require("gameobj/commonFuns")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsTeamPortItem = class("ClsTeamPortItem", ClsScrollViewItem)
local music_info = require("game_config/music_info")

local CLICK_TEAM_MEMBER = 1
local MEMBER_CLICK_OWN = 2
local MEMBER_CLICK_OTHER = 3

local widget_name = {
	"member_name",
	"member_level",
	"head_pic",
	"type_icon",
	"title_pic",
	"main_icon",
}

function ClsTeamPortItem:updateUI(cell_date, panel)
	self.data = cell_date
	self.expand_win = nil
	-- print("打印队员数据结构：===========")
	-- table.print(self.data)
	-- print("-----------------------------")
	convertUIType(panel)
	for _, name in pairs(widget_name) do
		self[name] = getConvertChildByName(panel, name)
	end

	local limit_len = 4
	local team_member_name = self.data.name
	local name_len = ClsCommonFuns:utfstrlen(team_member_name)
	if name_len > limit_len then
		team_member_name = ClsCommonFuns:utf8sub(team_member_name, 1, limit_len) .. "..."
	end
	self.member_name:setText(team_member_name)

	if self.data.is_leader then
		self.main_icon:setVisible(true)
	end
	if self.data.isRed then
		self.member_name:setColor(ccc3(dexToColor3B(COLOR_RED)))
	end
	self.member_level:setText("Lv."..self.data.grade)

	local nobilityMsg =	nobility_conf[self.data.nobility] or {}
	local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
	file_name = convertResources(file_name)
	self.title_pic:changeTexture(file_name , UI_TEX_TYPE_PLIST)

    local sailor_id = tonumber(self.data.icon)
    local icon_str = sailor_info[sailor_id].res
    local role_job_pic = JOB_RES[self.data.profession]
    self.head_pic:changeTexture(icon_str, UI_TEX_TYPE_LOCAL)
	self.type_icon:changeTexture(role_job_pic, UI_TEX_TYPE_PLIST)
    self.select_index = cell_date.order
end

function ClsTeamPortItem:onTap(x, y)
	if self.expand_win and not tolua.isnull(self.expand_win) then
		getUIManager():close("ClsTeamExpandWin")
		self.expand_win = nil
		return
	end

    local window = getUIManager():create("gameobj/team/clsTeamExpandWin", nil, {
        ["select_uid"] = self.data.uid,
        ["item"]       = self,
    })   

    local team_mission_ui = getUIManager():get("ClsTeamMissionPortUI")
	if not tolua.isnull(team_mission_ui) and not tolua.isnull(window) then
		local size = team_mission_ui.btn_arrow:getContentSize()
		local off_set_x, off_set_y = window:getWidth(), window:getHeight()
		local pos = team_mission_ui.btn_arrow:convertToWorldSpace(ccp(size.width/2,-size.height/2))
		window:setPosition(pos.x - off_set_x, pos.y - off_set_y)
	end

	self.expand_win = window
end

function ClsTeamPortItem:setTouch(enable)
end

function ClsTeamPortItem:onExit()
end

return ClsTeamPortItem