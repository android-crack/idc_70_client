local uiTools = require("gameobj/uiTools")
local music_info=require("game_config/music_info")
local ClsMissionItem = require("gameobj/mission/clsMissionItem")
local ClsBaseView = require("ui/view/clsBaseView")
---
local ClsScrollView = require("ui/view/clsScrollView")

local ClsMissionMainUI = class("ClsMissionMainUI", ClsBaseView)

function ClsMissionMainUI:getViewConfig()
    return {
        name = "ClsMissionMainUI",
        effect = UI_EFFECT.DOWN, 
        is_back_bg = true,
    }
end

local widget_name = {
	"btn_close",
}
function ClsMissionMainUI:onEnter()
	self.plists = {
		["ui/material_icon.plist"] = 1, 
		["ui/mission.plist"] = 1,
	}
	LoadPlist(self.plists)
	self:mkUI()
end

function ClsMissionMainUI:mkUI()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/main_task_list.json")
	convertUIType(panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(panel, v)
	end
	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
	self:addWidget(panel)
	if not isExplore then
		self:updateMissionList()
	end
end

local function checkIsInLine(main_line, branch_line)
	if not main_line then return end

	local temp_main_id = nil
	local temp_branch_id = nil
	local branch_tag = string.find(branch_line.id, "_", 0)
	local main_tag = string.find(main_line.id, "_", 0)
	if branch_tag then
		temp_branch_id = string.sub(branch_line.id, 1, branch_tag - 1)
	else
		temp_branch_id = branch_line.id
	end
	if main_tag then
		temp_main_id = string.sub(main_line.id, main_tag - 1)
	else
		temp_main_id = main_line.id
	end

	for index, threshold in ipairs(main_line.mission_before) do
		if tonumber(temp_branch_id) <= threshold and tonumber(temp_branch_id) > tonumber(temp_main_id) then
			return true, index
		end
	end
end

function ClsMissionMainUI:updateMissionList()
	local mission_data_handler = getGameData():getMissionData()
	local mission_list = mission_data_handler:getMissionAndDailyMissionInfo()
	if not mission_list then
		return
	end
	if self.list_view then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end
	self.cells = {}
	self.list_view = ClsScrollView.new(756, 425, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/main_task_info.json")
		return cell_ui
	end)
	local multi_main_line_mission = nil
	local mission = {}
	local normal_mission = {}
	for i,v in ipairs(mission_list) do
		if v.mission_before then
			multi_main_line_mission = v
		else
			local is_in_line, change_index = checkIsInLine(multi_main_line_mission, v)
			if multi_main_line_mission and is_in_line then
				if not multi_main_line_mission.branch_exchange then multi_main_line_mission.branch_exchange = {} end
				multi_main_line_mission.branch_exchange[change_index] = v
			else
				table.insert(normal_mission, v)
			end
		end
	end	
	if multi_main_line_mission then table.insert(mission, multi_main_line_mission) end
	for i, v in ipairs(normal_mission) do
		table.insert(mission, v)
	end
	for i,v in ipairs(mission) do
		self.cells[i] = ClsMissionItem.new(CCSize(750, 132), v)
	end	
	self.list_view:addCells(self.cells)
	self.list_view:setPosition(ccp(113, 48))
	self:addWidget(self.list_view)
end

function ClsMissionMainUI:getListView()
	return self.list_view
end

function ClsMissionMainUI:closeView(call_back)
	self:close("ClsMissionMainUI")
    if call_back and type(call_back) == "function" then
		call_back()
	end
end

function ClsMissionMainUI:onExit()
	if self.plists then
        UnLoadPlist(self.plists)
    end
end

return ClsMissionMainUI
