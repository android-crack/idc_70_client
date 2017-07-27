local ui_word = require("scripts/game_config/ui_word")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local skipToLayer = require("gameobj/mission/missionSkipLayer")
local on_off_info=require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local uiTools = require("gameobj/uiTools")
local Alert = require("ui/tools/alert")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsMissionItem = class("ClsMissionItem", ClsScrollViewItem)
local ClsCommonFuns = require("gameobj/commonFuns")

local widget_name = {
	"task_name",
	"task_type",
	"task",
	"task_info",
	"btn_give_up",
	"task_goal",
	"award_num_1",
	"award_num_2",
	"award_num_3",
	"award_icon_1",
	"award_icon_2",
	"award_icon_3",
	"award_panel",
	"award_text",
}

local GREEN_TAG_LIMIT = 4
--特殊任务完成条件特殊处理
local special_comp_tbl = {
	['1332'] = {complete_condition = 2, complete_key = "invest"},
}
local MISSION_STATUS_TAG = {
	ui_word.STR_MISSION_ACCEPT_TAG,--1未完成
	ui_word.STR_MISSION_FINISH_TAG,--2已完成
}

local function resetPos(obj, off_set)
	local pos = obj:getPosition()
	obj:setPosition(ccp(pos.x, pos.y + off_set))
end

function ClsMissionItem:createRichLabelText(mission_info)
	if not mission_info or not mission_info.desc then return end
	local lable = ""

	for k, v in ipairs(mission_info.desc) do
		local COLOR_TAG = "$(c:COLOR_BROWN)"
		local green_tag = string.find(v, "#", 0)
		if green_tag then
			COLOR_TAG = "$(c:COLOR_GREEN)"
			lable = lable..COLOR_TAG..string.sub(v, green_tag + 1)
		else
			if v == "" then
				lable = lable..COLOR_TAG..""
			end
			lable = lable..COLOR_TAG..v
		end
	end

	if mission_info.complete_sum and type(mission_info.complete_sum[1]) == "number" and mission_info.complete_sum[1] > 1 then
		local progress_label = string.format("$(c:COLOR_BROWN)(%s/%s)", tostring(mission_info.missionProgress[1].value), tostring(mission_info.complete_sum[1]))
		lable = lable.." "..progress_label
	end

	return lable
end

local mission_name_color = {
	[ui_word.MAIN_TASK] = {name = ui_word.MAIN_TASK_WORD, color = COLOR_GREEN},
	[ui_word.BRANCH_TASK] = {name = ui_word.BRANCH_TASK_WORD, color = COLOR_BLUE},
	[ui_word.DAILY_TASK] = {name = ui_word.DAILY_TASK_WORD, color = COLOR_YELLOW},
	[ui_word.MISSION_SAILOR] = {name = ui_word.SHOW_MISSION_SAILOR, color = COLOR_ORANGE},
	[ui_word.RELIC_TASK] = {name = ui_word.BOAT_RELIC_VIEW_TITLE, color = COLOR_ORANGE},
	[ui_word.MISSION_WORLD_MISSION] = {name = ui_word.MISSION_WORLD_MISSION, color = COLOR_ORANGE},
	[ui_word.CITY_TASK] = {name = ui_word.CITY_TASK, color = COLOR_ORANGE},
	[ui_word.TRADE_TASK] = {name = ui_word.TRADE_TASK, color = COLOR_ORANGE},
}

function ClsMissionItem:updateUI(cell_date, panel)
	self.mission = cell_date
	convertUIType(panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(panel, v)
	end

	local extra_height = 0
	local rich_labels = {}
	local branch_exc_tbl = self.mission.branch_exchange
	local mission = self.mission
	local type_name = mission_name_color[mission.type].name
	local type_color = mission_name_color[mission.type].color
	self.task_type:setText(type_name)
	self.task_name:setText(mission.name)
	if mission.complete_describe and mission.complete_describe[1] then
		self.task_info:setText(mission.complete_describe[1])
	else
		self.task_info:setVisible(false)
	end

	local lable = ""
	if type(mission.desc) ~= "table" then
		lable = mission.desc
	else
		local is_too_long = false
		local green_tag_num = 0
		for k, v in ipairs(mission.desc) do
			local isLineChange = string.find(v, "@", 0)
			local green_tag = string.find(v, "#", 0)
			local COLOR_TAG = "$(c:COLOR_BROWN)"
			if isLineChange then --遇到换行符
				table.insert(rich_labels, {["label_txt"] = lable, ["port_index"] = #rich_labels + 1})
				lable = COLOR_TAG..string.sub(v, isLineChange + 1)
			elseif green_tag then
				COLOR_TAG = "$(c:COLOR_GREEN)"
				green_tag_num = green_tag_num + 1
				if mission.mission_before or green_tag_num < GREEN_TAG_LIMIT then
					lable = lable..COLOR_TAG..string.sub(v, green_tag + 1)
				elseif not is_too_long then
					is_too_long = true
					lable = lable.."..."
				end 
			else
				if v == "" then
					lable = lable..COLOR_TAG..""
				end
				if is_too_long then
					if ClsCommonFuns:utfstrlen(v) > 1 then
						lable = lable..COLOR_TAG..v
					end
				else
					lable = lable..COLOR_TAG..v
				end
			end
			if k == #mission.desc then
				table.insert(rich_labels, {["label_txt"] = lable, ["port_index"] = #rich_labels + 1})
			end
		end
	end
	if mission.complete_sum and type(mission.complete_sum[1]) == "number" then
		if mission.type == ui_word.MISSION_WORLD_MISSION then
			local world_mission_type = {
				['explore_event'] = 'explore_event',
				['business'] = 'business',
				['battle'] = 'battle',
				["teambattle"] = "teambattle",
			}
			local wm_type = world_mission_type
			local _type = mission.info.cfg.type
			lable = string.format("%s$(c:COLOR_GREEN)", lable)
			if _type == wm_type.explore_event then
				local str = string.format("(%d/%d)", mission.missionProgress[1].value, mission.complete_sum[1])

					lable = string.format(lable,str)
			elseif _type == wm_type.business then
				local json = json.decode(mission.info.data)
				local good_name_str
				local num_str
				if json then
					num_str = mission.complete_sum[1]
					if json.port then
						local port_info = require("game_config/port/port_info")
						local port_name = port_info[json.port].name
						lable = string.format(lable,port_name,num_str)
					end
				end
			elseif _type == wm_type.battle or _type == wm_type.teambattle then
				lable = string.format(lable,mission.info.cfg.name)
			end
		else
			if mission.complete_sum[1] > 1 then
				local progress = tostring(self.mission.missionProgress[1].value)
				if special_comp_tbl[mission.id] then
					local temp = 0
					for _, info in ipairs(self.mission.missionProgress) do
						if info.key == special_comp_tbl[mission.id].complete_key and info.value >= special_comp_tbl[mission.id].complete_condition then
							temp = temp + 1
						end
					end
					progress = tostring(temp)
				end
				lable = string.format("%s$(c:COLOR_BROWN)(%s/%s)", lable, progress, tostring(mission.complete_sum[1]))
			end
		end
	end
	if mission.status_tag then
		local tag_label = string.format("$(c:COLOR_GREEN)[%s]", MISSION_STATUS_TAG[mission.status_tag])
		lable = lable..tag_label
	end

	--过滤已完成内置支线任务
	if mission.mission_before then
		if #rich_labels > 1 then
			local delete_tbl = {}
			local temp = {}
			local missionDyn = getGameData():getPlayerData():getMission(mission.id)
			for index, info in ipairs(missionDyn.missionProgress) do
				if info.value > 0 then
					delete_tbl[index] = true
				end
			end
			for i, v in ipairs(rich_labels) do
				if not delete_tbl[i] then
					table.insert(temp, v)
				end
			end
			rich_labels = temp
			if #(mission.complete_sum) >= 3 then
				if #rich_labels > 1 then
					table.remove(rich_labels, #rich_labels)
				else
					branch_exc_tbl = {}
				end
			end
		end
	end

	if #rich_labels > 1 or mission.mission_before then
		self.task_info:setVisible(false)
		if mission.mission_before then
			for index, extra_info in ipairs(rich_labels) do
				local text = extra_info.label_txt
				if branch_exc_tbl and branch_exc_tbl[extra_info.port_index] then
					local branch_mission = branch_exc_tbl[extra_info.port_index]
					text = self:createRichLabelText(branch_mission)
					rich_labels[index].label_txt = text
				end
			end
		end

		local _y = self.task_goal:getPosition().y
		for k = 1, #rich_labels do
			local richLabel = createRichLabel(rich_labels[k].label_txt, 500, 22, 14, 5)
			self:addCCNode(richLabel)
			richLabel:setPosition(80, _y - extra_height - 11)
			extra_height = extra_height + richLabel:getContentSize().height
		end
	else
		local rich_label = createRichLabel(lable, 500, 20, 14)
		rich_label:setPosition(80, 62)
		self:addCCNode(rich_label)
	end

	self:initRewardUI()
	self:initOtherMissionUI()
end

--处理世界任务等另类型的ui显示
function ClsMissionItem:initOtherMissionUI()
	local mission = self.mission
	if mission.type == ui_word.MISSION_WORLD_MISSION then
		if mission.info.cfg.give_up and mission.info.cfg.give_up > 0 then return end
		if mission.info.cfg.mission_txt then
			self.task_info:setVisible(true)
			self.task_info:setText(mission.info.cfg.mission_txt)
		end
		self.btn_give_up:setPressedActionEnabled(true)
		self.btn_give_up:addEventListener(function()
			-- 删除世界任务操作二次确认框
			local function world_mission_give_up_callback()
				if mission.info.cfg.type == "teambattle" then
					getGameData():getWorldMissionData():askGiveUpTeamMission(mission.info.id)
				else
					getGameData():getWorldMissionData():askGiveUpMission(mission.info.id)
				end
			end
			local str = string.format(ui_word.WORLD_MISSION_GIVE_UP_COMFIRE,tostring(need_strength))
			Alert:showAttention(str,world_mission_give_up_callback)
			self:closeAction(function()
			end)
		end,TOUCH_EVENT_ENDED)
		self.btn_give_up:setTouchEnabled(true)
		self.btn_give_up:setVisible(true)
		self.btn_give_up:setPosition(ccp(629,60))
	end
end

function ClsMissionItem:initRewardUI()
	if self.mission.reward_list then
		local reward_tbl = getGameData():getMissionData():getMissionRewardList(self.mission.reward_list)
		if #reward_tbl > 0 then
			self.award_panel:setVisible(true)
			self.award_text:setVisible(true)
			for k,v in ipairs(reward_tbl) do
				self["award_num_"..k]:setVisible(true)
				self["award_icon_"..k]:setVisible(true)
				self["award_num_"..k]:setText(v.num)
				self["award_icon_"..k]:changeTexture(v.res , UI_TEX_TYPE_PLIST)
			end
		end
	end
end

function ClsMissionItem:closeAction(fun)
	local mission_main_ui = getUIManager():get("ClsMissionMainUI")
	if not tolua.isnull(mission_main_ui) then
		mission_main_ui:closeView(fun)
	end
end

function ClsMissionItem:onTap(x,y)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	self:closeAction()
end

return ClsMissionItem
