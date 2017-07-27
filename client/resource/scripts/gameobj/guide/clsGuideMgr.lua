local guide_conf = require("game_config/guide/guide_info")
local ClsGuideLayer = require("gameobj/guide/clsGuideLayer")

local ClsGuideMgr = {}
local guideMap = {} -- 指引数据记录总表

local GREEN_GUIDE_TAG = "btn_green"
local FINGER_ZORDER = 168
local GUIDE_MASK_TYPE_BEGIN_EXPLORE = 1
local GUIDE_MASK_TYPE_ENTER_PORT_UI = 2
local GUIDE_MASK_TYPE_AUTO_SEARCH = 3

function ClsGuideMgr:addGuide(mid, list, isByGreen, not_need_fast_guide)
	local mission = getMissionInfo()[mid]
	if not mission then return end
	local guideList = list or mission.mission_guide
	if not guideList then return end

	guideMap[mid] = {
		["curGuide"] = 1,
		["guideType"] = mission.guide_parameter,
		["guideList"] = guideList,
		["isByGreen"] = isByGreen,
	}

	if mission.dialog_guide and tonumber(mission.dialog_guide) > 0 and not not_need_fast_guide then
		local panel_name = self:getGuideBaseView(guideList[1])
		self:tryGuide(panel_name)
	end	
end

function ClsGuideMgr:cleanGuide(mid)
	if guideMap[mid] then
		self:cleanGuideLayer(mid)
		guideMap[mid] = nil
	end
end

function ClsGuideMgr:cleanAllGuide()
	for mid, _ in pairs(guideMap) do
		self:cleanGuide(mid)
	end
	guideMap = {}
end

--返回需要加指引的对象，还有坐标,触摸区域等
function ClsGuideMgr:getGuidePanelByKey(guide_key, mid)
	if not guide_key or not guide_conf[guide_key] or not guide_conf[guide_key].panel_step then return end

	if guide_key == GREEN_GUIDE_TAG then
		local port_mission_ui = getUIManager():get("ClsTeamMissionPortUI")
		if tolua.isnull(port_mission_ui) or not mid then return end
		local guide_ui, pos, touch_rect = port_mission_ui:getGuideInfo(mid)
		if not tolua.isnull(guide_ui) then
			return guide_ui, pos.x, pos.y, touch_rect
		end
		return
	end

	local parent = nil
	local touch_rect = nil
	local pos = nil
	for index, name in ipairs(guide_conf[guide_key].panel_step) do
		if index == 1 then
			parent = getUIManager():get(name)
		else
			parent = parent[name]
		end
		if not parent then 
			-- print("填表指引中的某一步断了，找不到添加指引的对象！！")
			return 
		end
	end

	if type(parent) == "function" then
		local func = parent
		local condition = guide_conf[guide_key].condition
		parent, pos, touch_rect = func(condition)
		-- print("走外部函数接口！！！")
	else
		pos = guide_conf[guide_key].guide_pos
		touch_rect = guide_conf[guide_key].guide_rect
	end

	if not tolua.isnull(parent) then
		if not pos and not touch_rect then
			local parent_anchor_point = parent:getAnchorPoint()
			local widget_size = nil
			if parent.addCCNode and type(parent.addCCNode) == "function" then
				widget_size = parent:getSize()
			else
				widget_size = parent:getContentSize()
			end

			if parent_anchor_point.x == 0 and parent_anchor_point.y == 0 then
				pos = ccp(widget_size.width / 2, widget_size.height / 2)
				touch_rect = CCRect(0, 0, widget_size.width, widget_size.height)
			else
				pos = ccp(0, 0)
				touch_rect = CCRect(pos.x - widget_size.width / 2, pos.y - widget_size.height / 2, widget_size.width, widget_size.height)
			end
		end
		return parent, pos.x, pos.y, touch_rect
	end
end

function ClsGuideMgr:getGuideBaseView(key)
	if not key or not guide_conf[key] then return end
	local panel_step = guide_conf[key].panel_step
	return panel_step[1]
end

function ClsGuideMgr:openNextGuide(mid)
	if not mid then return end
	self:cleanGuideLayer(mid)
	guideMap[mid].curGuide = guideMap[mid].curGuide + 1
	-- print("点钟了下一部指引~~~~~~~~~~~~~~~~~~~~~")
	local panel_name = self:getGuideBaseView(guideMap[mid].guideList[guideMap[mid].curGuide])
	if panel_name then
		self:tryGuide(panel_name)
	end
end

--为指引对象添加指引层
function ClsGuideMgr:addGuideLayer(guide_info)
	local mid = guide_info.missionId
	guide_info.guideType = guideMap[mid].guideType
	guide_info.effectName = getMissionInfo()[mid].guide_finger
	self:cleanGuideLayer(mid)
	local parent_ui = guide_info.parent
	-- print("guide_info", guide_info)
	local guide_layer = ClsGuideLayer.new(guide_info)	
	guideMap[mid].guideLayer = guide_layer
	if type(parent_ui.addCCNode) == "function" then
		parent_ui:addCCNode(guide_layer)
	elseif type(parent_ui.addChild) == "function" then
		parent_ui:addChild(guide_layer)
	end
	guide_layer:setZOrder(FINGER_ZORDER)
	-- print("添加指引层，看出不出来，看不到可能是位置不对！！")

	guide_layer:setCallFunc(function(needTryGuide)
		if needTryGuide then
			self:openNextGuide(mid)
		else
			self:openNextGuide(nil)
			self:cleanGuide(mid)
		end
	end)
end

--点中区域把当前指引层内存和标志置空
function ClsGuideMgr:cleanGuideLayer(mid)
	if not mid or not guideMap[mid] then return end
	if not tolua.isnull(guideMap[mid].guideLayer) then
		guideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		guideMap[mid].guideLayer = nil
	end
end

-- 参数panel_name必须为界面baseView
function ClsGuideMgr:tryGuide(panel_name)
	-- print("panel_name", panel_name)
	if not panel_name then return end

	local guides_tab = {}
	-- print("=======================================")
	-- table.print(guideMap)
	-- print("---------------------------------------")
	for mid, info in pairs(guideMap) do
		local _guide_key = info.guideList[info.curGuide]
		if _guide_key then
			local _panelName = self:getGuideBaseView(_guide_key)
			if _panelName == panel_name then
				local parent_ui, x, y, touch_rect = self:getGuidePanelByKey(_guide_key, mid)
				if parent_ui then
					-- print("返回的添加指引对象不为空！！！")
					if not guides_tab[_guide_key] then 
						guides_tab[_guide_key] = {} 
					end
					table.insert(guides_tab[_guide_key], {parent = parent_ui, missionId = mid, x = x, y = y, rect = touch_rect, baseView = _panelName})
				end
			end
		end
	end

	for guide_key, content_list in pairs(guides_tab) do
		if guide_key == GREEN_GUIDE_TAG then
			self:handleGreenGuide(content_list)
		else
			self:handleNormalGuide(content_list, guide_key)
		end
	end
end

function ClsGuideMgr:jumpFirstGuide(mid)
	if guideMap[mid] then
		if not tolua.isnull(guideMap[mid].guideLayer) then
			guideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		end
		guideMap[mid].curGuide = 2
	end
end

function ClsGuideMgr:handleGreenGuide(guide_list)
	-- print("走重登绿字指引流程！！！")
	local ui_word = require("game_config/ui_word")
	local mission_conf = getMissionInfo()
	local old_guide_index --记录已添加过指引特效
	local main_guide_index --主线绿字优先添加
	for index, info in ipairs(guide_list) do
		if guideMap[info.missionId] and not tolua.isnull(guideMap[info.missionId].guideLayer) then 
			old_guide_index = index
		end
		if mission_conf[info.missionId] and mission_conf[info.missionId].type == ui_word.MAIN_TASK then
			main_guide_index = index
		end
	end

	if old_guide_index then
		if main_guide_index then
			if main_guide_index ~= old_guide_index then
				self:jumpFirstGuide(guide_list[old_guide_index].mid)
				self:addGuideLayer(guide_list[main_guide_index])
				return
			end
		end
		self:addGuideLayer(guide_list[old_guide_index]) 
	else
		if main_guide_index then
			self:addGuideLayer(guide_list[main_guide_index])
		else
			self:addGuideLayer(guide_list[1])
		end
	end
end

function ClsGuideMgr:handleNormalGuide(guide_list, guide_key)
	for _, info in ipairs(guide_list) do --避免重复添加
		if guideMap[info.missionId] and not tolua.isnull(guideMap[info.missionId].guideLayer) then 
			-- print("指引已经存在，重复添加，是同帧内存标志没清！！")
			return 
		end
	end
	-- print("走一般界面指引流程！！")
	self:addGuideLayer(guide_list[1])
end

-- 点击任务框走重登指引流程
function ClsGuideMgr:changeMissionGuide(mid)
	if guideMap[mid] and guideMap[mid].isByGreen then return end
	local mission_conf = getMissionInfo()[mid]
	if not mission_conf or not mission_conf.super_mission_guide_1 or #(mission_conf.super_mission_guide_1) <= 1 then return end

	self:cleanGuide(mid)
	self:addGuide(mid, mission_conf.super_mission_guide_1, true, true)
	if guideMap[mid] then
		guideMap[mid].curGuide = 2
	end
end

--重置指引为第一步
function ClsGuideMgr:resetMissionGuide(mid)
	if guideMap[mid].curGuide then
		guideMap[mid].curGuide = 1
	end
	self:cleanGuideLayer(mid)
end

--任务开启指引
function ClsGuideMgr:openGuideByMission(mission_info, guide_list, is_by_green_word)
	local mid = mission_info.id
	local guide_list = guide_list or mission_info.mission_guide
	if not guide_list then return end
	if guideMap[mid] then
		self:resetMissionGuide(mid)
	end
	if is_by_green_word then
		self:cleanGuide(mid)
		self:addGuide(mid, guide_list, true)
	end
	-- 开启第一步指引
	local panel_name = self:getGuideBaseView(guide_list[1])	
	self:tryGuide(panel_name)
end

function ClsGuideMgr:enableAllGuide()
	for _, guideInfo in pairs(guideMap) do
		local guideLayer = guideInfo.guideLayer
		if not tolua.isnull(guideLayer) then
			guideLayer:setVisible(true)
		end
	end	
end

function ClsGuideMgr:disableAllGuide()
	for _, guideInfo in pairs(guideMap) do
		local guideLayer = guideInfo.guideLayer
		if not tolua.isnull(guideLayer) then
			guideLayer:setVisible(false)
		end
	end	
end

function ClsGuideMgr:hideOrShowGuide(mid, enable)
	if not guideMap[mid] then return end
	local guide_layer = guideMap[mid].guideLayer
	if not tolua.isnull(guide_layer) then
		guide_layer:setVisible(enable)
	end
end

function ClsGuideMgr:checkHasStrengthGuide() --是否有强制指引
	local mission_list = getGameData():getMissionData():getMissionInfo()
	for _,info in ipairs(mission_list) do
		if info.status == MISSION_STATUS_DOING and info.guide_parameter == 1 then
			return true
		end
	end
end

--一个任务对应多个港口的进度完成条件
--判断该任务的相应港口的部分进度是否已完成(某个任务info，港口ID)
function ClsGuideMgr:judgeMissionFinishByPort(missionBase, portId)
	local isFinish = true
	if not missionBase or not portId then
		return isFinish
	end
	local playerData = getGameData():getPlayerData()
	local sailorData = getGameData():getSailorData()
	local ownSailors = table.clone(sailorData:getOwnSailors())
	local skipInfo = missionBase.skip_info
	local guideTable = missionBase.guide
	local skipIndex = 0
	local missionDyn = playerData:getMission(missionBase.id)
	if not missionDyn then
		return isFinish
	end
	local completeSum = missionBase.complete_sum
	local missionProgress = missionDyn.missionProgress
	if not completeSum or not missionProgress then
		return isFinish
	end

	if type(guideTable) == "table" then
		for k, v in pairs(guideTable) do
			if v == portId then
				skipIndex = k
				break
			end
		end
	end

	if skipIndex <= 0 or not completeSum[skipIndex] then
		return isFinish
	end

	if type(missionProgress) == "number" then
		if missionProgress < completeSum[skipIndex] then
			isFinish = false 
		end
	elseif type(missionProgress) == "table" then
		local curNum = 0
		local curIndex = 0
		for k,v in pairs(missionProgress) do
			if v.index then
				curIndex = v.index + 1
			else
				curIndex = 0
			end
			if curIndex == skipIndex then
				curNum = v.value
				break
			end
		end
		if curNum < completeSum[skipIndex] then
			isFinish = false 
		end
	end
	return isFinish
end

--添加海上屏蔽层
function ClsGuideMgr:needGuideMaskLayer(mType)
	mType = mType or GUIDE_MASK_TYPE_BEGIN_EXPLORE
	if mType == GUIDE_MASK_TYPE_BEGIN_EXPLORE then
		local exploreData = getGameData():getExploreData()
		local goalInfo = exploreData:getGoalInfo()
		if not goalInfo then
			return false
		end
		if goalInfo.navType and goalInfo.navType ~= EXPLORE_NAV_TYPE_PORT then
			return false
		end
		if goalInfo.isLoot then
			return false
		end
	end

	local mission_conf = getMissionInfo()
	for mid, _ in pairs(guideMap) do
		if mission_conf[mid].sea_parameter and mission_conf[mid].sea_parameter == 1 then
			return true
		end
	end
	return false
end

return ClsGuideMgr