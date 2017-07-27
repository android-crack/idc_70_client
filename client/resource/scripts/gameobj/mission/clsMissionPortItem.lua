local ui_word = require("scripts/game_config/ui_word")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local skipToLayer = require("gameobj/mission/missionSkipLayer")
local on_off_info=require("game_config/on_off_info")
local seaforce_config = require("game_config/mission/seaforce_boat_config")
local music_info=require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsMissionPortItem = class("ClsMissionPortItem", ClsScrollViewItem)

--特殊任务完成条件特殊处理
local special_comp_tbl = {
	['1332'] = {complete_condition = 2, complete_key = "invest"},
}
local MISSION_STATUS_TAG = {
	ui_word.STR_MISSION_ACCEPT_TAG,--1未完成
	ui_word.STR_MISSION_FINISH_TAG,--2已完成
}
local mission_name_color = {
	[ui_word.MAIN_TASK] = {name = ui_word.MAIN_TASK_WORD, color = COLOR_YELLOW},
	[ui_word.BRANCH_TASK] = {name = ui_word.BRANCH_TASK_WORD, color = COLOR_ORANGE},
	[ui_word.DAILY_TASK] = {name = ui_word.DAILY_TASK_WORD, color = COLOR_ORANGE},
	[ui_word.MISSION_SAILOR] = {name = ui_word.SHOW_MISSION_SAILOR, color = COLOR_ORANGE},
	[ui_word.RELIC_TASK] = {name = ui_word.BOAT_RELIC_VIEW_TITLE, color = COLOR_ORANGE},
	[ui_word.MISSION_WORLD_MISSION] = {name = ui_word.MISSION_WORLD_MISSION, color = COLOR_ORANGE},
	[ui_word.CITY_TASK] = {name = ui_word.CITY_TASK, color = COLOR_ORANGE},
	[ui_word.TRADE_TASK] = {name = ui_word.TRADE_TASK, color = COLOR_ORANGE},
}
local function resetPos(obj, off_set)
	local pos = obj:getPosition()
	obj:setPosition(ccp(pos.x, pos.y + off_set))
end

--创建每个内置支线文本内容
local function createBranchLabel(mission_info)
	if not mission_info or not mission_info.desc then return end
	local lable = ""
	for k, v in ipairs(mission_info.desc) do
		local COLOR_TAG = "$(c:COLOR_WHITE)"
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
		local progress_label = string.format("$(c:COLOR_YELLOW)(%s/%s)", tostring(mission_info.missionProgress[1].value), tostring(mission_info.complete_sum[1]))
		lable = lable.." "..progress_label
	end
	return lable
end

--创建多重主线任务富文本显示
function ClsMissionPortItem:createMultiLineLabel(rich_labels, total_height)
	local extra_height = 0
	local mission = self.mission
	for index, extra_info in ipairs(rich_labels) do
		local text = extra_info.label_txt
		local rich_label = nil
		self.mission_label[index] = {}
		if self.branch_exc_tbl and self.branch_exc_tbl[extra_info.port_index] then
			local branch_mission = self.branch_exc_tbl[extra_info.port_index]
			text = createBranchLabel(branch_mission)
			rich_labels[index] = text
			self.mission_label[index].mid = branch_mission.id
			self.mission_label[index].port_index = nil
		else
			self.mission_label[index].mid = mission.id
			self.mission_label[index].port_index = extra_info.port_index
		end
		rich_label = createRichLabel(text, 150, 30, 14, 4)
		self.mission_label[index].obj = rich_label
		self:addCCNode(rich_label)
	end
	--调整每个富文本位置对齐
	if #self.mission_label == 1 then
		local off_set = 5
		local richLabel = self.mission_label[1].obj
		local label_height = richLabel:getContentSize().height
		local pos_y = (total_height - label_height)/2
		if pos_y < 0 then 
			pos_y = off_set
			extra_height = richLabel:getContentSize().height + pos_y
		elseif label_height < 20 then
			pos_y = pos_y + off_set
		end
		richLabel:setPosition(11, pos_y)			
	else
		for i = #self.mission_label, 1, -1 do
			local _obj = self.mission_label[i].obj
			_obj:setPosition(11, 5 + extra_height)
			extra_height = extra_height + _obj:getContentSize().height
		end
	end
	return extra_height
end

function ClsMissionPortItem:getMissionLabel()
	local mission = self.mission
	local rich_labels = {}
	local lable = ""
	if type(mission.desc) ~= "table" then
		lable = mission.desc or " "
	else
		for k, v in ipairs(mission.desc) do
			local isLineChange = string.find(v, "@", 0)
			local green_tag = string.find(v, "#", 0)
			local COLOR_TAG = "$(c:COLOR_WHITE)"
			if isLineChange then --遇到换行符
				table.insert(rich_labels, {["label_txt"] = lable, ["port_index"] = #rich_labels + 1})
				lable = COLOR_TAG..string.sub(v, isLineChange + 1)
			elseif green_tag then
				COLOR_TAG = "$(c:COLOR_GREEN)"
				lable = lable..COLOR_TAG..string.sub(v, green_tag + 1)
			else
				if v == "" then
					lable = lable..COLOR_TAG..""
				end
				lable = lable..COLOR_TAG..v
			end
			if k == #mission.desc then
				table.insert(rich_labels, {["label_txt"] = lable, ["port_index"] = #rich_labels + 1})
			end
		end
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
					self.branch_exc_tbl = {}
				end
			end
		end
	end
	return lable, rich_labels
end

--补充添加其他任务类型可能新增的文本,如进度等
function ClsMissionPortItem:suppleMissionLabel(lable)
	local mission = self.mission
	if mission.complete_sum and type(mission.complete_sum[1]) == "number" then
		--and mission.complete_sum[1] > 1 then
		if mission.type == ui_word.MISSION_WORLD_MISSION then
			local WM_TYPE = {
				['explore_event'] = 'explore_event',
				['business'] = 'business',
				['battle'] = 'battle',
				["teambattle"] = "teambattle",
			}
			local wm_type = WM_TYPE
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
			if mission.complete_sum[1]>1 then
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
				lable = string.format("%s$(c:COLOR_YELLOW)(%s/%s)", lable, progress, tostring(mission.complete_sum[1]))
			end
		end
	end
	if mission.status_tag then
		local tag_label = string.format("$(c:COLOR_GREEN)[%s]", MISSION_STATUS_TAG[mission.status_tag])
		lable = lable..tag_label
	end
	return lable
end

function ClsMissionPortItem:createDetailBtn(btn_info)
	local label = createBMFont({text = btn_info.btn_text, size = btn_info.text_size, 
		x = btn_info.cell_pos.x, y = btn_info.cell_pos.y})
	self.detail_btn = display.newScale9Sprite(btn_info.res, btn_info.pos.x, btn_info.pos.y)
	self.detail_btn.call_back = btn_info.call_back
	self.detail_btn:setAnchorPoint(btn_info.anchor_point)
	self.detail_btn:setContentSize(CCSize(btn_info.width, btn_info.height))
	self.detail_btn:addChild(label)
	self:addCCNode(self.detail_btn)
end

function ClsMissionPortItem:updateUI(cell_date, panel)
	if cell_date and cell_date.is_detail_btn then
		self:createDetailBtn(cell_date)
		panel:removeFromParent()
		return
	end

	self.mission_label = {}
    self.mission = cell_date
    self.branch_exc_tbl = self.mission.branch_exchange
    convertUIType(panel)
	self.task_title = getConvertChildByName(panel, "task_title")
	self.task_name = getConvertChildByName(panel, "task_name")
	self.btn_collect = getConvertChildByName(panel, "btn_get")
	self.task_list = getConvertChildByName(panel, "task_list")
	self.btn_collect:setVisible(false)

	local extra_height = 0 --九宫格需要自适应的大小
	local mission = self.mission
	local off_set_y = 18
	local total_height = self.task_title:getPosition().y - off_set_y
	------------------------任务名，类型-----------------------------
	local type_name = mission_name_color[mission.type].name
	local type_color = mission_name_color[mission.type].color
	self.task_title:setText(type_name)
	self.task_title:setColor(ccc3(dexToColor3B(type_color)))
	self.task_name:setColor(ccc3(dexToColor3B(type_color)))
	self.task_name:setText(mission.name)
	
	if mission.type ~= ui_word.DAILY_TASK and mission.type ~= ui_word.MISSION_WORLD_MISSION and mission.status == STATUS_FINISHED then
		ClsGuideMgr:cleanGuide(mission.id)
		self.btn_collect:setVisible(true)
		self.btn_collect:setTouchEnabled(true)
		self.btn_collect:setPressedActionEnabled(true)
		self.btn_collect:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.btn_collect:setTouchEnabled(false)
			self:showMissionRewards(mission)
		end, TOUCH_EVENT_ENDED)
	else
		local label, rich_labels = self:getMissionLabel()
		label = self:suppleMissionLabel(label)

		if mission.mission_before then
			extra_height = self:createMultiLineLabel(rich_labels, total_height)
		else
			if #rich_labels > 1 then--普通多点描述任务
				local _off_set = 5
				for k = #rich_labels, 1, -1 do
					local richLabel = createRichLabel(rich_labels[k].label_txt, 150, 30, 14, 4)
					self:addCCNode(richLabel)
					richLabel:setPosition(11, _off_set + extra_height)
					extra_height = extra_height + richLabel:getContentSize().height
				end
			else
				local rich_label = createRichLabel(label, 150, 34, 14, 3)--一般单点描述任务
				local height = rich_label:getContentSize().height
				if height < 20 then
					rich_label:setPosition(9, 24)
				else
					if height > total_height then
						extra_height = height + 5 --描述过长需要自适应
					end
					rich_label:setPosition(9, 8)
				end
				self:addCCNode(rich_label)
			end
		end
	end
	--需要自适应扩展九宫格
	local size = self.task_list:getSize()
	if extra_height > 0 then
		local new_height = size.height + extra_height - total_height
		self.task_list:setScale9Enable(true)
		self.task_list:setScale9Size(CCSize(size.width, new_height))

		resetPos(self.task_title, extra_height - total_height)
		resetPos(self.task_name, extra_height - total_height)

		local list_view = getUIManager():get("ClsTeamMissionPortUI"):getListView()
		self:setHeight(new_height + 3)
		list_view:updateScoreViewSize()
	end
end

local match_key = {
	["exp"] = ITEM_INDEX_EXP,
	["cash"] = ITEM_INDEX_CASH,
	["gold"] = ITEM_INDEX_GOLD,
	["honour"] = ITEM_INDEX_HONOUR,
	["silver"] = ITEM_INDEX_CASH,
	["power"] = ITEM_INDEX_TILI,
	["rum"] = ITEM_INDEX_HONOUR,
}
--任务框领奖
function ClsMissionPortItem:showMissionRewards(mission_data)
	if not mission_data then return end
	local mission_data_handler = getGameData():getMissionData()
	mission_data_handler:clearShowAcceptByChatMission()

	if mission_data.wipe_box and mission_data.wipe_box == 1 then
		mission_data_handler:askGetMissionReward(mission_data.id)
	else
		local rewardInfos = {}
		for k,v in pairs(mission_data.reward_list) do
			local rewardInfo = {}
			if match_key[k] then
				rewardInfo.key = match_key[k]
			elseif k == "starcrest" then
				rewardInfo.id = 50
				rewardInfo.key = ITEM_INDEX_PROP
			elseif k == "shipyard_may" then
				rewardInfo.id = 63
				rewardInfo.key = ITEM_INDEX_PROP

			elseif k == "royal" then
				rewardInfo.key = ITEM_INDEX_HONOUR
			end
			if rewardInfo.key then
				rewardInfo.value = tonumber(v)
				rewardInfos[#rewardInfos + 1] = rewardInfo
			end
		end
		ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = rewardInfos, callBackFunc = function()
    		if tolua.isnull(self) then return end
			local mission_data_handler = getGameData():getMissionData()
			mission_data_handler:askGetMissionReward(mission_data.id)
    	end}))
	end
end

local function isClickObj(widget, touch_x, touch_y)
	if not tolua.isnull(widget) then
		local origin_pos = widget:convertToWorldSpace(ccp(0,0))
		local _size = widget:getContentSize()
		local _rect = CCRect(origin_pos.x, origin_pos.y, _size.width, _size.height)
		local is_touch = _rect:containsPoint(ccp(touch_x, touch_y))
		if is_touch and widget.call_back and type(widget.call_back) == "function" then
			widget.call_back()
		end
		return is_touch
	end
end

--检测是否点击到多重主线任务的富文本
function ClsMissionPortItem:checkIsClick(x, y)
	if #self.mission_label < 1 then return end
	for i, info in ipairs(self.mission_label) do
		if isClickObj(info.obj, x, y) then
			return true, info.mid, info.port_index
		end
	end
end

--检测是否是重登完成状态
function ClsMissionPortItem:checkIsFinish()
	local mission_data_handler = getGameData():getMissionData()
	local mission_list = mission_data_handler:getMissionAndDailyMissionInfo()
	for _, v in pairs(mission_list) do
		if v.id == self.mission.id then
			if v.status == MISSION_STATUS_COMPLETE then
				self:showMissionRewards(v)
				return true
			end
			break
		end
	end
end

function ClsMissionPortItem:onTap(x,y)
	if isClickObj(self.detail_btn, x, y) or not self.mission then return end
	local is_click, click_mission_id, _port_index = self:checkIsClick(x, y)
	if is_click and click_mission_id then
		self.mission = getMissionInfo()[click_mission_id]
		if self:checkIsFinish() then return end
	else
		if #self.mission_label == 1 then
			local info = self.mission_label[1]
			self.mission = getMissionInfo()[info.mid]
			_port_index = info.port_index
			if self:checkIsFinish() then return end
		end
	end

	ClsGuideMgr:changeMissionGuide(self.mission.id)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	--领奖状态
	if self.mission.type ~= ui_word.DAILY_TASK and self.mission.status == STATUS_FINISHED then
		return
	end
	local team_data = getGameData():getTeamData()
	if (team_data:isInTeam() and not team_data:isTeamLeader()) then
		local ERROR_INDEX = 591
		local text = require("game_config/error_info")[ERROR_INDEX].message
		Alert:warning({msg = text, size = 26})
		return
	end
	if isExplore then
		self:exploreToMission(_port_index)
	else
		self:portToMission(_port_index)
	end
end

function ClsMissionPortItem:toGoBackPort()
	local port_info = require("game_config/port/port_info")
    local Alert = require("ui/tools/alert")
    local portData = getGameData():getPortData()
    local portName = port_info[portData:getPortId()].name
    local tips = require("game_config/tips")
    local str = string.format(tips[77].msg, portName)
    Alert:showAttention(str, function()
		portData:setEnterPortCallBack(function()
		end)
		portData:askBackEnterPort()
    end, nil, nil, {hide_cancel_btn = true})
end

function ClsMissionPortItem:toNewPort(params)
	if params.target_id then
		getGameData():getWorldMapAttrsData():goOutPort(params.target_id, EXPLORE_NAV_TYPE_PORT, nil, nil, {is_world_mission = params.is_world_mission})
	end
end

function ClsMissionPortItem:toPoint(params)
	if params.pos then
		getGameData():getWorldMapAttrsData():goOutPort(nil, EXPLORE_NAV_TYPE_POS, nil, nil, {pos = params.pos, name = params.name, callBack = params.callBack, is_world_mission = params.is_world_mission})
	end
end

function ClsMissionPortItem:toWhirlPool(params)
	if params.whirlPoolId then
		getGameData():getWorldMapAttrsData():goOutPort(params.whirlPoolId, EXPLORE_NAV_TYPE_WHIRLPOOL)
	end
end

function ClsMissionPortItem:toRewardPirate(params)
	if params.pos then
		getGameData():getWorldMapAttrsData():goOutPort(nil, EXPLORE_NAV_TYPE_REWARD_PIRATE, nil, nil, {pos = params.pos, name = params.name, callBack = params.callBack})
	end
end

function ClsMissionPortItem:toSalveShip(params)
	if params.pos then
		getGameData():getWorldMapAttrsData():goOutPort(nil, EXPLORE_NAV_TYPE_SALVE_SHIP, nil, nil, {pos = params.pos, name = params.name, callBack = params.callBack})
	end
end

function ClsMissionPortItem:toRelic(params)
	if params.relicId then
		getGameData():getWorldMapAttrsData():goOutPort(params.relicId, EXPLORE_NAV_TYPE_RELIC)
	end
end

function ClsMissionPortItem:toPanel(params)
	if params.skip_key then
		skipToLayer:skipLayerByName(params.skip_key)
	end
end

local GO_BACK_PORT = 1
local GO_TO_OTHER_PORT = 2
local GO_TO_POINT = 3
local GO_TO_WHIRLPOOL = 4
local GO_TO_REWARD_PIRATE = 5
local GO_TO_SALVE_SHIP = 6
local GO_TO_RELIC = 7
local GO_TO_PANEL = 8

local event_by_handle = {
	[GO_BACK_PORT] = {handle = ClsMissionPortItem.toGoBackPort,},
	[GO_TO_OTHER_PORT] = {handle = ClsMissionPortItem.toNewPort,},
	[GO_TO_POINT] = {handle = ClsMissionPortItem.toPoint,},
	[GO_TO_WHIRLPOOL] = {handle = ClsMissionPortItem.toWhirlPool,},
	[GO_TO_REWARD_PIRATE] = {handle = ClsMissionPortItem.toRewardPirate,},
	[GO_TO_SALVE_SHIP] = {handle = ClsMissionPortItem.toSalveShip,},
	[GO_TO_RELIC] = {handle = ClsMissionPortItem.toRelic,},
	[GO_TO_PANEL] = {handle = ClsMissionPortItem.toPanel,},
}

local function checkIsPanelSkip(skip_info)
	local guideIndex = 1
	if type(skip_info) == "table" and type(skip_info[guideIndex]) == "table" then
		local skipTab = skip_info[guideIndex].skip
		if skipTab then
			local panel_skip = skipTab[2]
			if panel_skip and panel_skip == "explore_panel" then
				return true
			end
		end
	end
end

function ClsMissionPortItem:exploreToMission(special_port_index)
	local missionInfo = self.mission
	if not missionInfo then return end

	if missionInfo.type == ui_word.CITY_TASK then
		getGameData():getCityChallengeData():whenClickMission()
		return
	end

	local portData = getGameData():getPortData()
	local portId  = portData:getPortId() -- 当前港口
	local misPort = missionInfo.guide
	local skip_key = nil
	local mission_handle = nil
	local params = {}
	local is_explore_to_panel = checkIsPanelSkip(missionInfo.skip_info)

	local guideIndex = 1
	local index = 1
	if type(missionInfo.guide) == "table" then
		for k,v in pairs(missionInfo.guide) do
			local portId = missionInfo.guide[index]
			if not missionGuide:judgeMissionFinishByPort(missionInfo, portId) then
				guideIndex = index
				break
			else
				index = index + 1
			end
		end
	end
	if special_port_index then
		guideIndex = special_port_index
	end

	local function cancelCB()
		-- if not tolua.isnull(self) then
		-- 	team_mission_port:setTouch(true)
		-- end
	end
	local mission_data_handler = getGameData():getMissionData()
	local mission_info = getMissionInfo()
	if type(missionInfo.id) == "number" and mission_info[missionInfo.id] and mission_info[missionInfo.id].camp then
		mission_data_handler:setSelectMissionId(missionInfo.id)
	end
	local mission_data_handler = getGameData():getMissionData()
	mission_data_handler:clearShowAcceptByChatMission()

	if missionInfo.type == ui_word.DAILY_TASK then
		if missionInfo.skip_info == "ports" then
			if missionInfo.json_info["portId"] then
				misPort = {missionInfo.json_info["portId"]}
			elseif missionInfo.json_info["battleInfo"] then

				if missionInfo.status == STATUS_FINISHED then
					misPort = missionInfo.json_info["start_port"]
					params.target_id = misPort
					self:toNewPort(params)
					cancelCB()
					return
				else
					skip_key = "battle_pos"
				end

			elseif missionInfo.json_info["wreckInfo"] then

				if missionInfo.status == STATUS_FINISHED then
					misPort = missionInfo.json_info["start_port"]
					params.target_id = misPort
					self:toNewPort(params)
					cancelCB()
					return
				else
					skip_key = "ship_pos"
				end
			end
		else
			skip_key = missionInfo.skip_info
		end
	elseif missionInfo.type == ui_word.MISSION_WORLD_MISSION then
		if self.mission.info.cfg.type == 'business' then
			local json = json.decode(self.mission.info.data)
			if json and json.port then
				misPort = {}
				table.insert(misPort, json.port)
				guideIndex = 1
			end
		else
			local is_nav = false
			if (self.mission.info.cfg.type == 'battle' or self.mission.info.cfg.type == "teambattle") and self.mission.info.status == 1 then
				is_nav = true
			end
			if is_nav then
				local pos_x,pos_y = missionInfo.info.cfg.position_explore[1]+2,missionInfo.info.cfg.position_explore[2]+2
				local str = missionInfo.info.cfg.name
				getGameData():getWorldMapAttrsData():goOutPort(nil, EXPLORE_NAV_TYPE_POS, nil, nil, {pos = {pos_x,pos_y}, name = str, is_world_mission = missionInfo.id})
			end
			skip_key = 'world_mission_pos'
		end
	else
		mission_data_handler:setPortSelectMisId(missionInfo.id, guideIndex)
		skip_key = skipToLayer:getSkipName(missionInfo.id, guideIndex)
	end

	local function cancelCB()
	-- 	if not tolua.isnull(self) then
	-- 		team_mission_port:setTouch(true)
	-- 	end
	end
	if not misPort and skip_key then
		if skip_key == "explore_pos" then
			local target_pos = missionInfo.explore_pos
			mission_handle = GO_TO_POINT
			params.name = ui_word.MISSION_END_WORLD
			if missionInfo.sea_pos and missionInfo.sea_pos > 0 then
				params.name = seaforce_config[missionInfo.sea_pos].name
			end
			local traget_name = target_pos.name
			if traget_name then params.name = traget_name end
			params.pos = {target_pos.x, target_pos.y}
		elseif missionInfo.guidewp and missionInfo.guidewp > 0 then
			mission_handle = GO_TO_WHIRLPOOL
			params.whirlPoolId = missionInfo.guidewp
		elseif skip_key == "battle_pos" then --悬赏据点位置
			local pos =  missionInfo.json_info["battleInfo"]
			mission_handle = GO_TO_REWARD_PIRATE
			params.pos = {pos.position_x, pos.position_y}
		elseif skip_key == "ship_pos" then --悬赏沉船位置
			local pos = missionInfo.json_info["wreckInfo"]
			mission_handle = GO_TO_SALVE_SHIP
			params.pos = {pos.position_x, pos.position_y}
		elseif skip_key == "yijiX_explore" then
			mission_handle = GO_TO_RELIC
			params.relicId = missionInfo.guideyj
		elseif skip_key == "world_mission_pos" then
			mission_handle = GO_TO_POINT
			params.is_world_mission = missionInfo.id
		elseif is_explore_to_panel then --海上跳转界面通用
			mission_handle = GO_TO_PANEL
			params.skip_key = skip_key
		else
			mission_handle = GO_BACK_PORT
		end
	elseif misPort and portId ~= misPort[guideIndex] then
		if misPort[guideIndex] == 0 then
			cancelCB()
			return
		end
		mission_handle = GO_TO_OTHER_PORT
		params.target_id = misPort[guideIndex]
		if missionInfo.type == ui_word.MISSION_WORLD_MISSION then
			params.is_world_mission = missionInfo.id
		end
	else
		mission_handle = GO_BACK_PORT
	end
	params.callBack = cancelCB
	event_by_handle[mission_handle].handle(self, params)
	cancelCB()
end

function ClsMissionPortItem:portToMission(special_port_index)
	if self.mission.single_treasure then
		if getGameData():getTeamData():isInTeam() then
			Alert:warning({msg = ui_word.TREASURE_TEAM_TIP, size = 26})
		else
			GameUtil.callRpc("rpc_server_enter_lead_cangbao_bay", {})
		end
		return
	end
	if self.mission.type == ui_word.MISSION_SAILOR then --传记任务要判断相信的功能有没有开放
		local mission_data_handler = getGameData():getMissionData()
		if not self.mission.skip_info then
			return
		end
		local skip = self.mission.skip_info[1].skip[1]
		local is_open, error_index = mission_data_handler:getSkipIsOpen(skip)
		if not is_open then
			local error_info = require("game_config/error_info")
			local text = error_info[error_index].message
			Alert:warning({msg = text, size = 26})
			return
		end
	end

	if self.mission.type == ui_word.MISSION_WORLD_MISSION then
		if self.mission.info.cfg.type == 'business' then
			local json = json.decode(self.mission.info.data)
			if json and json.port then
				local portId  = getGameData():getPortData():getPortId()
				if json.port ~= portId then
					getGameData():getWorldMapAttrsData():goOutPort(json.port, EXPLORE_NAV_TYPE_PORT, nil, nil, {is_world_mission = self.mission.id})
				end
			end
		end
		-- 战斗类留导航 其他类型去除导航.
		local is_nav = false
		if (self.mission.info.cfg.type == 'battle' or self.mission.info.cfg.type == "teambattle") and self.mission.info.status == 1 then
			is_nav = true
		end
		if is_nav then
			local pos_x,pos_y = self.mission.info.cfg.position_explore[1]+2,self.mission.info.cfg.position_explore[2]+2
			local str = self.mission.info.cfg.name
			getGameData():getWorldMapAttrsData():goOutPort(self.mission.info.id, EXPLORE_NAV_TYPE_POS,nil,nil,{navType = EXPLORE_NAV_TYPE_POS, pos = {pos_x,pos_y}, name = str, is_world_mission = self.mission.id})
		end
		return
	end

	if self.mission.type == ui_word.CITY_TASK then
		getGameData():getCityChallengeData():whenClickMission()
		return
	end

	local data = self.mission
	if not data then
		return
	end
	
	local guideIndex = 1
	local index = 1
	if type(data.guide) == "table" then
		for k,v in pairs(data.guide) do
			local portId = data.guide[index]
			if not missionGuide:judgeMissionFinishByPort(data, portId) then
				guideIndex = index
				break
			else
				index = index + 1
			end
		end
	end
	if special_port_index then
		guideIndex = special_port_index
	end

	local mission_data_handler = getGameData():getMissionData()
	local mission_info = getMissionInfo()
	if type(data.id) == "number" and mission_info[data.id] and mission_info[data.id].camp then
		mission_data_handler:setSelectMissionId(data.id)
	end
	local mission_data_handler = getGameData():getMissionData()
	mission_data_handler:clearShowAcceptByChatMission()

	local portData = getGameData():getPortData()
	local portId  = portData:getPortId() -- 当前港口
	local misPort = data.guide
	local isSkip = nil
	if data.type == ui_word.DAILY_TASK then
		if data.completeTips then
			isSkip = "guild_task"
		else
			isSkip = data.skip_info
		end
	else
		mission_data_handler:setPortSelectMisId(data.id, guideIndex)
		isSkip = skipToLayer:getSkipName(data.id, guideIndex)
	end

	--若玩家不在目的港口，则直接出海去目的港口
	--港口跳转回调解决异步加载触摸问题
	function cancelCB()
		-- if not tolua.isnull(self) then
		-- 	mission_port:setTouch(true)
		-- end
	end
	if misPort then
		if portId ~= misPort[guideIndex] then
			if data.guide_notout and data.guide_notout <= 0 then
				local supplyData = getGameData():getSupplyData()
				supplyData:askSupplyInfo(true, function()
					local mapAttrs = getGameData():getWorldMapAttrsData()
					if misPort[guideIndex] == 0 then --0代表直接出海
						mapAttrs:goOutPort(portId, EXPLORE_NAV_TYPE_NONE, nil, cancelCB, cancelCB)
					else
						mapAttrs:goOutPort(misPort[guideIndex], EXPLORE_NAV_TYPE_PORT, nil, cancelCB, cancelCB)
					end
				end)
				return
			end
		end
	end
	if isSkip then
		if isSkip == "ports" then
			local port_data = getGameData():getPortData()
			local port_id = port_data:getPortId() -- 当前港口
			local goal_port_id = nil
			local stronghold_id = nil
			local is_just_go_b = false
			local mission_attck_pirate = false
			local mission_salve_ship = false
			local pos_x = nil
			local pos_y = nil
			--添加是否是悬赏任务的判断
			if data.type == ui_word.DAILY_TASK then
				if data.json_info["portId"] then
					goal_port_id = data.json_info["portId"]
				elseif data.json_info["battleInfo"] then
					mission_attck_pirate = true
					pos_x = data.json_info["battleInfo"]["position_x"]
					pos_y = data.json_info["battleInfo"]["position_y"]
				elseif data.json_info["wreckInfo"] then
					mission_salve_ship = true
					pos_x = data.json_info["wreckInfo"]["position_x"]
					pos_y = data.json_info["wreckInfo"]["position_y"]
				end

				stronghold_id = data.json_info.checkpointId

				local mapAttrs = getGameData():getWorldMapAttrsData()
				if goal_port_id and mapAttrs:isNewPort(goal_port_id) then
					Alert:warning({msg = ui_word.PORT_NOT_OPEN , size = 26})
					cancelCB()
					return
				end

				local portPveData = getGameData():getPortPveData()
				if stronghold_id and not portPveData:isStrongHoldOpen(stronghold_id) then
					Alert:warning({msg = ui_word.PVE_STRONGHOLD_NOT_OPEN , size = 26})
					cancelCB()
					return
				end

				if nil == goal_port_id and stronghold_id == nil then
                    is_just_go_b = true
                end
			else
				if misPort then
					goal_port_id = misPort[guideIndex]
				end

			end

			if goal_port_id then
				if port_id ~= goal_port_id then
					if goal_port_id == 0 then
						local mapAttrs = getGameData():getWorldMapAttrsData()
						mapAttrs:goOutPort(goal_port_id, EXPLORE_NAV_TYPE_NONE, nil, cancelCB, cancelCB)
					else
						local supplyData = getGameData():getSupplyData()
						supplyData:askSupplyInfo(true, function()
						local mapAttrs = getGameData():getWorldMapAttrsData()
						mapAttrs:goOutPort(goal_port_id, EXPLORE_NAV_TYPE_PORT, nil, cancelCB, cancelCB)
						end)
					end
				else

					if mission_info[data.id].targetarrive_complete > 1 then
						GameUtil.callRpc("rpc_server_port_arrive", {port_id})
						cancelCB()
					else
						local mission_data_handler = getGameData():getMissionData()
        				mission_data_handler:askIfHaveBattle(nil, port_id)
					end
				end


			elseif stronghold_id then
				local supplyData = getGameData():getSupplyData()
				supplyData:askSupplyInfo(true, function()
					local mapAttrs = getGameData():getWorldMapAttrsData()
					mapAttrs:goOutPort(stronghold_id, EXPLORE_NAV_TYPE_SH, nil, cancelCB, cancelCB)
				end)

			else
				if is_just_go_b then
					if mission_attck_pirate or mission_salve_ship then

						local explore_type = EXPLORE_NAV_TYPE_REWARD_PIRATE
						if mission_salve_ship then
							explore_type = EXPLORE_NAV_TYPE_SALVE_SHIP
						end

						local supplyData = getGameData():getSupplyData()
						supplyData:askSupplyInfo(true, function()
							local mapAttrs = getGameData():getWorldMapAttrsData()
							local params ={pos = {pos_x, pos_y}}
							mapAttrs:goOutPort(nil, explore_type, nil, cancelCB, params)
						end)
						cancelCB()
						return
					end

                    local supplyData = getGameData():getSupplyData()
                	supplyData:askSupplyInfo(true, function()
	                    local mapAttrs = getGameData():getWorldMapAttrsData()
	                    mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE, nil, cancelCB, cancelCB)
                    end)

                -- else
                --     mission_port:setTouch(true)
                end
			end
		elseif isSkip == "explore_pos" then --去海上某个点
			local supplyData = getGameData():getSupplyData()
			supplyData:askSupplyInfo(true, function()
				local mapAttrs = getGameData():getWorldMapAttrsData()
				local target_pos = self.mission.explore_pos
				local traget_name = self.mission.explore_pos.name

				local explore_name = ui_word.MISSION_END_WORLD
				if self.mission.sea_pos and self.mission.sea_pos > 0 then
					explore_name = seaforce_config[self.mission.sea_pos].name
				end
				if traget_name then explore_name = traget_name end

				local params ={pos = {target_pos.x, target_pos.y}, name = explore_name}
				mapAttrs:goOutPort(nil, EXPLORE_NAV_TYPE_POS, nil, cancelCB, params)
			end)
			return
		elseif data.guidewp and data.guidewp > 0 then
			local supplyData = getGameData():getSupplyData()
			supplyData:askSupplyInfo(true, function()
				local mapAttrs = getGameData():getWorldMapAttrsData()
				mapAttrs:goOutPort(data.guidewp, EXPLORE_NAV_TYPE_WHIRLPOOL, nil, cancelCB, cancelCB)
			end)
		elseif isSkip == "yijiX_explore" then --去海上遗迹
			local supplyData = getGameData():getSupplyData()
			supplyData:askSupplyInfo(true, function()
				local mapAttrs = getGameData():getWorldMapAttrsData()
				mapAttrs:goOutPort(data.guideyj, EXPLORE_NAV_TYPE_RELIC, nil, cancelCB, cancelCB)
			end)
			return
		else
			local parent = getUIManager():get("ClsPortLayer")
			if tolua.isnull(parent) then
				return
			end

			local skip_info = data.skip_info
			local skipParams = nil
			if type(skip_info) == "table" then
				local skipTab = skip_info[guideIndex].skip
				skipParams = skipTab[2]
			end

			local function toMission()
				if isSkip ~= "arena" then
					skipToLayer:skipLayerByName(isSkip, skipParams, parent)
				else
					getUIManager():create("gameobj/arena/clsArenaMainUI")
				end
			end
			toMission()
		end
		return
	end
	cancelCB()
end

return ClsMissionPortItem