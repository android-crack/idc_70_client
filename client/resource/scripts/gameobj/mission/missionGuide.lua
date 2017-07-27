---任务指引
require("gameobj/mission/missionGuideLayer")

local on_off_info = require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")
local element_mgr = require("base/element_mgr")

local FINGER_ZORDER = 999999991
local MissionGuide = {}
local panelGuideMap = {}
local guideBtns = {}
local guideMaskLayer = {}

local defaultGuideRadius = 125
local curGuideKey = nil
local curGuideRect = CCRectMake(0,0,0,0)
local isGuideByOrder = true

function MissionGuide:init()
	local onSceneTouchEnd = function(x,y)
		if curGuideRect:containsPoint(sceneTouchPos) then
			--cclog("===============================curGuideRect:containsPoint true x="..(curGuideRect.origin.x).." y="..(curGuideRect.origin.y).." w="..(curGuideRect.size.width).." h="..(curGuideRect.size.height))
			isGuideByOrder = true
		else
			--cclog("===============================curGuideRect:containsPoint false x="..(curGuideRect.origin.x).." y="..(curGuideRect.origin.y).." w="..(curGuideRect.size.width).." h="..(curGuideRect.size.height))
			isGuideByOrder = false
		end
	end
	RegTrigger(EVENT_SCENE_TOUCH_END, onSceneTouchEnd)
end


MissionGuide.GUIDE_MASK_TYPE_BEGIN_EXPLORE = 1
MissionGuide.GUIDE_MASK_TYPE_ENTER_PORT_UI = 2
MissionGuide.GUIDE_MASK_TYPE_AUTO_SEARCH = 3

--添加屏蔽层
function MissionGuide:needGuideMaskLayer(mType)
	mType = mType or self.GUIDE_MASK_TYPE_BEGIN_EXPLORE
	if mType == self.GUIDE_MASK_TYPE_BEGIN_EXPLORE then
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
	for mid, _ in pairs(panelGuideMap) do
		if mission_conf[mid].sea_parameter and mission_conf[mid].sea_parameter == 1 then
			return true
		end
	end
	return false
end

--添加点击特效
function MissionGuide:addGuideLayer(key, guideItem, parent, mid)
	if true then return end
	if self:isGuideLayerExsit(key) then return end
	if not mid or not panelGuideMap[mid] or not panelGuideMap[mid].guideList then return end
	if not tolua.isnull(panelGuideMap[mid].guideLayer) then
		panelGuideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		panelGuideMap[mid].guideLayer = nil
	end
	local zorder = nil
	local parent = parent.layer
	if tolua.isnull(parent) then return end 
	if not zorder then zorder = FINGER_ZORDER end

	guideItem.key = key
	guideItem.radius = guideItem.radius or defaultGuideRadius
	if guideItem.radius >= defaultGuideRadius*2 then
		guideItem.radius = defaultGuideRadius
	end
	guideItem.guideType = panelGuideMap[mid].guideType

	local isNeedOpen = false
	if panelGuideMap[mid].guideList and #panelGuideMap[mid].guideList > 0 then
		local guideOnInfo = panelGuideMap[mid].guideList[1]
		if guideOnInfo.need_open == 1 then isNeedOpen = true end
		guideItem.effectName = guideOnInfo.effect_name
	end

	guideItem.isDelay = false
	local onOffData = getGameData():getOnOffData()
	if isNeedOpen and not onOffData:isOpen(key) then guideItem.isDelay = true end
	if guideItem.rect and not guideItem.pos then
		guideItem.pos = {}
		guideItem.pos.x = guideItem.rect.origin.x + guideItem.rect.size.width / 2
		guideItem.pos.y = guideItem.rect.origin.y + guideItem.rect.size.height / 2
	end
	local guideLayer = createMissionGuideLayer(guideItem)
	panelGuideMap[mid].guideLayer = guideLayer

	guideLayer:setCallFunc(function(key, needTryGuide)
		if needTryGuide then
			self:openNextGuide(mid)
		else
			self:openNextGuide(nil)
			self:cleanGuide(mid)
		end
	end)
	guideLayer:setExitCallFunc(function()
		-- if not tolua.isnull(self.skipMenu) then
		-- 	self.skipMenu:removeFromParentAndCleanup(true)
		-- end
	end)
	if type(parent.addCCNode) == "function" then
		parent:addCCNode(guideLayer)
	elseif type(parent.addChild) == "function" then
		parent:addChild(guideLayer)
	end
	guideLayer:setZOrder(zorder)

	local guideWorldPos = guideLayer:convertToWorldSpace(ccp(guideItem.pos.x, guideItem.pos.y))

	curGuideKey = key
	curGuideRect.origin.x = guideWorldPos.x - guideItem.radius
	curGuideRect.origin.y = guideWorldPos.y - guideItem.radius
	curGuideRect.size.width = guideItem.radius*2
	curGuideRect.size.height = guideItem.radius*2

	if guideItem.callBack ~= nil then
		guideItem.callBack(curGuideKey)
	end

	if DEBUG > 0 then
		local runScene = GameUtil.getRunningScene()
		if not tolua.isnull(runScene) then
			local skipLb = createBMFont({text = ui_word.TASK_GUIDE_SKIP, size = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
			--todo 调试添加绿字任务跳过菜单
			local skipBtn = MyMenuItem.new({labelNode=skipLb, x=890, y=525})
			skipBtn:regCallBack(function()
				self:cleanGuide(mid)
				if not tolua.isnull(skipBtn) then
					skipBtn:removeFromParentAndCleanup(true)
				end
			end)
			panelGuideMap[mid].skipMenu = MyMenu.new(skipBtn, TOUCH_PRIORITY_MISSION-1)
			runScene:addChild(panelGuideMap[mid].skipMenu, ZORDER_MISSION)
		end
	end
	return guideLayer
end

function MissionGuide:isGuideLayerExsit(key)
	for mid, guideInfo in pairs(panelGuideMap) do
		local guideIndex = guideInfo.curGuide
		if guideInfo.guideList[guideIndex] then
			local _key = guideInfo.guideList[guideIndex].value
			if _key == key and not tolua.isnull(guideInfo.guideLayer) then
				return true, mid
			end
		end	
	end
end

--todo:已经废弃的接口，不过为了兼容之前的，暂时保留
function MissionGuide:clearGuideLayer(key)	
end

function MissionGuide:openNextGuide(mid)
	if not mid then return end

	if not tolua.isnull(panelGuideMap[mid].guideLayer) then
		panelGuideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		panelGuideMap[mid].guideLayer = nil
	end
	if not tolua.isnull(panelGuideMap[mid].skipMenu) then
		panelGuideMap[mid].skipMenu:removeFromParentAndCleanup(true)
	end
	panelGuideMap[mid].curGuide = panelGuideMap[mid].curGuide + 1

	local key = self:getMissionGuideKey(mid)
	if key then
		self:openGuide(key, nil, mid)
	-- else
	-- 	self:judgeAddGuideMask(mid)
	end
end

---将任务表里的按钮name提取到表里
function MissionGuide:getGuideMap(mission_tab, guide_key)
	local guidesTab = mission_tab.mission_guide
	if guidesTab == nil then return nil end
	local guides = guidesTab[guide_key]
	if guides == nil or type(guides) ~= "string" or string.len(guides) <= 1 then return nil end
	local guideMap = {}
	while(true) do	
		local i, j = string.find(guides, ",")
		if j then
			local cap = string.sub(guides, 0, j - 1)
			table.insert(guideMap, cap)
			guides = string.sub(guides, j + 1)
		else
			table.insert(guideMap, guides)
			break
		end
	end
	return guideMap
end

function MissionGuide:getSuperGuideMap(mission_tab, guide_key, guide_index)
	guide_key = guide_key or 1
	guide_index = guide_index or 1
	local guidesTab = mission_tab["super_mission_guide_"..guide_index]
	if guidesTab == nil then return nil end
	local guides = guidesTab[guide_key]
	if guides == nil or type(guides) ~= "string" or string.len(guides) <= 1 then return nil end
	local guideMap = {}
	while(true) do	
		local i, j = string.find(guides, ",")
		if j then
			local cap = string.sub(guides, 0, j - 1)
			table.insert(guideMap, cap)
			guides = string.sub(guides, j + 1)
		else
			table.insert(guideMap, guides)
			break
		end
	end
    -- 测试多语言用代码
    -- for i = 2, #guideMap do
        -- guideMap[i] = T(guideMap[i])
    -- end
	return guideMap
end

--重新开启指引(每次到达港口时调用，为了到达另一港口时出现当前选择的任务指引)
function MissionGuide:resumeOpenGuide()
end

function MissionGuide:getMissionGuideKey(mid)
	if not panelGuideMap[mid] then return end
	local _curGuide = panelGuideMap[mid].curGuide
	local guideOnInfo = panelGuideMap[mid].guideList[_curGuide]
	if guideOnInfo then return guideOnInfo.value end
end

function MissionGuide:getGuideKeyTbl()
	local key_tbl = {}
	for mid, info in pairs(panelGuideMap) do
		local key_value = self:getMissionGuideKey(mid)
		if key_value then
			key_tbl[key_value] = mid
		end
	end
	return key_tbl
end

local function resetMissionGuide(mid)
	if panelGuideMap[mid].curGuide then
		panelGuideMap[mid].curGuide = 1
	end
end

--标记开启指引
function MissionGuide:openGuideByMission(mission_tab, guide_key, guide_map, is_by_green_word)
	local portData = getGameData():getPortData()
	local portId  = portData:getPortId() -- 当前港口	
	local misPort = mission_tab.guide
	local mid = mission_tab.id
	
	-- ---一个任务拥有多个完成条件时，当某个条件完成时，需要指向其它完成条件
	-- if guide_key == nil then
	-- 	if type(misPort) == "table" then
	-- 		for i = #misPort, 1, -1 do
	-- 			local guidePortId = misPort[i]
	-- 			if not self:judgeMissionFinishByPort(mission_tab, guidePortId) then
	-- 				guide_key = i
	-- 				if guidePortId == portId then
	-- 					break
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- 条件取消
	
	guide_key = guide_key or 1
	local jumpNum = -1
	local guideMap = guide_map or self:getGuideMap(mission_tab, guide_key)
	if guideMap == nil then return end

	if panelGuideMap[mid] then
		resetMissionGuide(mid)
	end

	--若玩家当前在主场景且不在目的港口，则默认指向码头
	local portLayer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(portLayer) and misPort and portId ~= misPort[guide_key] then
		local isAddGuide = true
		for k, v in pairs(guideMap) do
			--如果当前任务是出海，则不加强制出海指引
			if v == ui_word.GOTO_SEA_MATE or v == ui_word.GOTO_WORLD_MAP or v == on_off_info.GREENWORD.name then
				isAddGuide = false
				break
			end
		end
		if is_by_green_word then
			isAddGuide = false
		end
		if isAddGuide then
			local goSeaMap = {
				on_off_info.PORT_QUAY_EXPLORE,
				}
			--此功能在等级达到5级（暂定）后去除
			local playerData = getGameData():getPlayerData()
			if playerData:getLevel() >= 5 then
				goSeaMap = {}
			end
			for k, v in pairs(goSeaMap) do
				if k == 1 then
					self:openGuide(v.value, nil, mid)
				end
				-- table.insert(self.guideList, v)
			end
			return
		end
	end
	
	local guideList = {}
	for k, v in pairs(guideMap) do
		local noFind = true
		for kn, vt in pairs(on_off_info) do
			if vt.name == v then
				table.insert(guideList, vt)
				noFind = false
				break
			end
		end
		if noFind then
			jumpNum = tonumber(v)
		end
	end

	if is_by_green_word then
		self:cleanGuide(mid)
		self:addGuide(mid, guideList, true)
	end
	local onOffMap = guideList[1]
	if onOffMap and onOffMap.value then
		self:openGuide(onOffMap.value, nil, mid)
	end

	if jumpNum == 1 then
		EventTrigger(EVENT_GUIDE_UPDATE_MARKET)
		EventTrigger(EVENT_GUIDE_UPDATE_HOTEL)
		EventTrigger(EVENT_GUIDE_UPDATE_SHIPYARD)
		EventTrigger(EVENT_GUIDE_UPDATE_EQUIPENHANCE)
		EventTrigger(EVENT_GUIDE_UPDATE_PVEUI)
		EventTrigger(EVENT_GUIDE_UPDATE_EXPLOREUI)
		EventTrigger(EVENT_GUIDE_UPDATE_SAILORRECUI)
	end
end

--一个任务对应多个港口的进度完成条件
--判断该任务的相应港口的部分进度是否已完成(某个任务info，港口ID)
function MissionGuide:judgeMissionFinishByPort(missionBase, portId)
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

--打开上一个任务的指引(完成无后续任务时)
function MissionGuide:openLastMissionGuide(missionInfo)
end

function MissionGuide:clearAllGuide()
	self.guideList = {}
	curGuideKey = nil
	curGuideRect.origin.x = -2
	curGuideRect.origin.y = -2
	curGuideRect.size.width = 0
	curGuideRect.size.height = 0

	local portLayer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(portLayer) and not tolua.isnull(portLayer.guangquan) then
		portLayer.guangquan:removeFromParentAndCleanup(true)
		portLayer.guangquan = nil
	end
end

function MissionGuide:pushGuideBtn(key, btnInfo)
	-- if not key then
	-- 	return
	-- end
	-- guideBtns[key] = btnInfo

	-- local mid = self:isHasGuide(key)
	-- if mid then
	-- 	self:tryGuide(key, mid)
	-- end

	-- --程序测试用的
	-- if key == on_off_info.ACTIVITY_ORGANIZEXUANSHANG.value then
	-- 	self:tryGuide(key, mid)
	-- end
end

function MissionGuide:pullGuideBtn(key)
	local info = guideBtns[key]
	return info
end

--根据按钮开关表中对应按钮的value值设置按钮指引状态
function MissionGuide:openGuide(key, noTry, mid)
	if not noTry then
		self:tryGuide(key, mid)
	end
end

function MissionGuide:closeGuide(key)
end

function MissionGuide:isHasGuide(guide_key)
	local missionDataHandler = getGameData():getMissionData()
	local doingMissionInfo = missionDataHandler:getMissionAndDailyMissionInfo()
	if guide_key ~= on_off_info.GREENWORD.value then
		local missionId
		for _, missionInfo in ipairs(doingMissionInfo) do
			local guide_info = panelGuideMap[missionInfo.id]
			if guide_info and guide_info.guideList then
				local guideIndex = guide_info.curGuide
				if guide_info.guideList[guideIndex] then
					local _key = guide_info.guideList[guideIndex].value
					if _key == guide_key then
						missionId = missionInfo.id
						break
					end
				end
			end
		end
		return missionId
	end
end

function MissionGuide:jumpFirstGuide(mid)
	if panelGuideMap[mid] then
		if not tolua.isnull(panelGuideMap[mid].guideLayer) then
			panelGuideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		end
		if panelGuideMap[mid].hasGreen then
			panelGuideMap[mid].hasGreen = nil
		end
		panelGuideMap[mid].curGuide = 2
	end
end

function MissionGuide:isHadGreen(mid)
	if not panelGuideMap[mid] then return end
	if panelGuideMap[mid].hasGreen and tolua.isnull(panelGuideMap[mid].guideLayer) then
		if panelGuideMap[mid].curGuide == 1 then
			return true
		end
	end
end

function MissionGuide:tryGuide(key, missionId)
	-- if key == on_off_info.GREENWORD.value then
	-- 	local isExsit, preMissionId = self:isGuideLayerExsit(key)
	-- 	local mission_panel = element_mgr:get_element("ClsTeamMissionPortUI")
	-- 	if not tolua.isnull(mission_panel) then
	-- 		if isExsit then
	-- 			local missionInfo = getMissionInfo()[missionId]
	-- 			if missionInfo.type == ui_word.MAIN_TASK and missionId ~= preMissionId then
	-- 				self:jumpFirstGuide(preMissionId)
	-- 				mission_panel:addSkipMissionGuide(missionId)
	-- 			end
	-- 		else
	-- 			mission_panel:addSkipMissionGuide(missionId)
	-- 		end
	-- 	end
	-- 	return
	-- end

	-- local guideBtnInfo = self:pullGuideBtn(key)
	-- if not guideBtnInfo then
	-- 	return
	-- end
	-- if tolua.isnull(guideBtnInfo.guideLayer) then
	-- 	return
	-- end
	
	-- local btnX, btnY = 0,0
	-- local btnZorder = 0
	-- local btnRadius = 45

	-- if not tolua.isnull(guideBtnInfo.guideBtn) then
	-- 	local btnPositionX, btnPositionY = 0,0
	-- 	--TODO:isUIWidget和btn_type应该去掉一个，这里为了兼容
	-- 	local btn_type = tolua.type(guideBtnInfo.guideBtn)
	-- 	local prefix = string.sub(btn_type, 1, 2) 
	-- 	if not guideBtnInfo.x then
	-- 		if guideBtnInfo.isUIWidget or prefix == "UI" then -- cocostudio UI
	-- 			local tmp_pos = guideBtnInfo.guideBtn:getPosition()
	-- 			btnPositionX =  tmp_pos.x
	-- 		else
	-- 			btnPositionX,_ = guideBtnInfo.guideBtn:getPosition()
	-- 		end
	-- 	end
 
	-- 	if not guideBtnInfo.y then
	-- 		if guideBtnInfo.isUIWidget or prefix == "UI" then
	-- 			local tmp_pos = guideBtnInfo.guideBtn:getPosition()
	-- 			btnPositionY =  tmp_pos.y	
	-- 		else
	-- 			_, btnPositionY = guideBtnInfo.guideBtn:getPosition()
	-- 		end
	-- 	end

	-- 	btnX = btnPositionX
	-- 	btnY = btnPositionY

	-- 	btnRadius = guideBtnInfo.guideBtn:getContentSize().width * 0.5
	-- 	btnZorder = guideBtnInfo.guideBtn:getZOrder()
	-- end
	
	-- if guideBtnInfo.rect then
	-- 	btnX = guideBtnInfo.rect.origin.x + guideBtnInfo.rect.size.width / 2
	-- 	btnY = guideBtnInfo.rect.origin.y + guideBtnInfo.rect.size.height / 2
	-- end

	-- if guideBtnInfo.x then
	-- 	btnX = guideBtnInfo.x
	-- end
	-- if guideBtnInfo.y then
	-- 	btnY = guideBtnInfo.y
	-- end

	-- if guideBtnInfo.zorder then
	-- 	btnZorder = guideBtnInfo.zorder
	-- else
	-- 	btnZorder = btnZorder + 10
	-- end

	-- if guideBtnInfo.radius then
	-- 	btnRadius = guideBtnInfo.radius
	-- end

	-- if guideBtnInfo.auto_set then
	-- 	--读取系统开关表
	-- end

	-- self:addGuideLayer(key, {rect = guideBtnInfo.rect, radius = btnRadius, pos = {x = btnX, y = btnY}, needRefresh = guideBtnInfo.needRefresh, callBack = guideBtnInfo.callBack, baseView = guideBtnInfo.base_view,},
 --        {layer = guideBtnInfo.guideLayer, zorder = btnZorder}, missionId)
end

function MissionGuide:enableAllGuide()
	for _, guideInfo in pairs(panelGuideMap) do
		local guideLayer = guideInfo.guideLayer
		local skipMenu = guideInfo.skipMenu
		if not tolua.isnull(guideLayer) then
			guideLayer:setVisible(true)
		end
		if not tolua.isnull(skipMenu) then
			skipMenu:setTouchEnabled(true)
			skipMenu:setVisible(true)
		end
	end	
end

function MissionGuide:disableAllGuide()
	for _, guideInfo in pairs(panelGuideMap) do
		local guideLayer = guideInfo.guideLayer
		local skipMenu = guideInfo.skipMenu
		if not tolua.isnull(guideLayer) then
			guideLayer:setVisible(false)
		end
		if not tolua.isnull(skipMenu) then
			skipMenu:setTouchEnabled(false)
			skipMenu:setVisible(false)
		end		
	end	
end

function MissionGuide:disableGuideByPanel(panel)
	for _, guideInfo in pairs(panelGuideMap) do
		local guideLayer = guideInfo.guideLayer
		local skipMenu = guideInfo.skipMenu
		local parent
		if not tolua.isnull(guideLayer) then
			parent = guideLayer:getParent()
		end
		if parent == panel then
			if not tolua.isnull(guideLayer) then
				guideLayer:setVisible(false)
			end
			if not tolua.isnull(skipMenu) then
				skipMenu:setTouchEnabled(false)
			end		
		end
	end	
end

function MissionGuide:resetGuide()
	self:cleanAllGuide()
end

------------------------------------------------------------------------------------
function MissionGuide:setGreenGuide(mid)
	if not panelGuideMap[mid] then return end
	panelGuideMap[mid].hasGreen = true
end

function MissionGuide:changeMissionGuide(mid)
	if panelGuideMap[mid] and panelGuideMap[mid].isByGreen then return end

	local mission_conf = getMissionInfo()[mid]
	if not mission_conf or not mission_conf.super_mission_guide_1 or #(mission_conf.super_mission_guide_1[1]) <= 1 then return end

	self:cleanGuide(mid)
	local guideList = {}
	local guideMap = self:getSuperGuideMap(mission_conf)
	for k, v in pairs(guideMap) do
		for _, vt in pairs(on_off_info) do
			if vt.name == v then
				table.insert(guideList, vt)
				break
			end
		end
	end
	self:addGuide(mid, guideList, true, true)
	if panelGuideMap[mid] then
		panelGuideMap[mid].curGuide = 2
	end
end

function MissionGuide:cleanGuide(mid)
	if panelGuideMap[mid] then
		if not tolua.isnull(panelGuideMap[mid].guideLayer) then
			panelGuideMap[mid].guideLayer:removeFromParentAndCleanup(true)
		end
		if not tolua.isnull(panelGuideMap[mid].skipMenu) then
			panelGuideMap[mid].skipMenu:removeFromParentAndCleanup(true)
		end
		panelGuideMap[mid] = nil
	end
end

function MissionGuide:cleanAllGuide()
	for mid, _ in pairs(panelGuideMap) do
		self:cleanGuide(mid)
	end
	panelGuideMap = {}
end

function MissionGuide:addGuide(mid, list, isByGreen, not_need_fast_guide)
	local mission = getMissionInfo()[mid]
	local guideList = list
	if not guideList then
		guideList = {}
		local _guideMap = self:getGuideMap(mission, 1)
		if not _guideMap then return end
		for k, v in pairs(_guideMap) do
			for kn, vt in pairs(on_off_info) do
				if vt.name == v then
					table.insert(guideList, vt)
					break
				end
			end
		end
	end

	panelGuideMap[mid] = {
		["curGuide"] = 1,
		["guideType"] = mission.guide_parameter,
		["guideList"] = guideList,
		["isByGreen"] = isByGreen,
	}

	if isByGreen then 
		self:setGreenGuide(mid)
	end

	if mission.dialog_guide and tonumber(mission.dialog_guide) > 0 and not not_need_fast_guide then
		local guide_key = self:getMissionGuideKey(mid)
		self:openGuide(guide_key, nil, mid)
	end
end

function MissionGuide:cleanGuideMaskLayer()
	for _, mask_layer in ipairs(guideMaskLayer) do
		if not tolua.isnull(mask_layer) then
			mask_layer:removeFromParentAndCleanup(true)
		end
	end
	guideMaskLayer = {}
end

function MissionGuide:addMaskLayer()
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then return end

	for i = 1, 2 do
		local guide_mask_layer = CCLayer:create()

		guide_mask_layer:registerScriptTouchHandler(function(eventType, x, y)
			if eventType =="began" then
				return true
			elseif eventType =="ended" then
				return
			end
		end, false, TOUCH_PRIORITY_MISSION - 100, true)
		guide_mask_layer:setTouchEnabled(true)

		local array = CCArray:create()
		array:addObject(CCDelayTime:create(1))
		array:addObject(CCCallFunc:create(function()
			if not tolua.isnull(guide_mask_layer) then
				guide_mask_layer:removeFromParentAndCleanup(true)
			end
		end))
		local guide_action = CCSequence:create(array)
		guide_mask_layer:runAction(guide_action)

		if not tolua.isnull(guide_mask_layer) then
			table.insert(guideMaskLayer, guide_mask_layer)
			running_scene:addChild(guide_mask_layer, ZORDER_MISSION)
		end
	end
end

function MissionGuide:judgeAddGuideMask(mid)
	-- local mission_data_hanle = getGameData():getMissionData()
	-- local role_id = getGameData():getPlayerData():getRoleId()
	-- local mission_name_map = mission_data_hanle:get_name_to_id_map_by_role(role_id)
	-- local pre_mission_conf = getMissionInfo()[mid]
	-- if not pre_mission_conf.next_mission then return end
	-- local next_mission_id = mission_name_map[pre_mission_conf.next_mission]
	-- local next_mission_conf = getMissionInfo()[next_mission_id]
	-- if next_mission_conf and next_mission_conf.guide_parameter and next_mission_conf.guide_parameter > 0 then
	-- 	self:addMaskLayer()
	-- end
end

MissionGuide:init()

return MissionGuide