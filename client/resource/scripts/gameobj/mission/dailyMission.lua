---日常任务
local music_info = require("game_config/music_info")
local CompositeEffect = require("gameobj/composite_effect")
local ui_word = require("game_config/ui_word")
local daily_mission = require("game_config/mission/daily_mission")
local goods_info = require("game_config/port/goods_info")
local port_info = require("game_config/port/port_info")
local tool = require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local ClsMissionUI = require("gameobj/mission/clsMissionUI")
local sailor_info = require("game_config/sailor/sailor_info")

local DailyMission = {}

local GuestsMission = class("GuestsMission", function()return CCLayer:create() end)
local DailyComplete = class("DailyComplete", function()return CCLayer:create() end)
local CoolingCDLayer = class("CoolingCDLayer", function()return CCLayer:create() end)

local SHOPPING = "shopping"
local PORT = "port"
local BUSINESS = "business"
local BATTLE = "battle"
local PLUNDER = "plunder"
local UPGRADE = "upgrade"
local SELLGOODS = "sellgoods"
local UPSAILOR = "sailor"
local UPBOAT = "boat"
local GETSAILOR = "enlistsailors"
local PORTSHOP = "portshop"
local STRONGHOLD = "stronghold"
local PVE = "pve"
local EXPLORE_WRECK  = "explore_wreck"
local S_LEVEL_ID = 5

-- local DELAY_TIME_CONFIG = {
-- 	[UPBOAT] = {level = 0, time = 1},
-- 	[UPGRADE] = {level = 0, time = 1},
-- 	[PORTSHOP] = {level = 0, time = 1},
-- }

local DELAY_TIME_CONFIG = {
	[PVE] = {level = 0, time = 1},
	[PORT] = {level = 0, time = 1},
	[EXPLORE_WRECK] = {level = 0, time = 1},
}

local ResPlist = {
		["ui/mission.plist"] = 1,
	}
	
local function loadRes()
	LoadPlist(ResPlist)
end

local function unLoadRes()
	UnLoadPlist(ResPlist)
end

--创建是否接受日常任务界面
function DailyMission:createGuestsMissionLayer(missionId, id, amount, reward)
	if missionId == 0 then return nil end
	local missionInfo = daily_mission[missionId]
	local count = #missionInfo.head
	local index = math.random(1, count)
	local sailorName = missionInfo.name[index]
	local sailorImage = string.format("ui/seaman/seaman_%s.png", missionInfo.head[index])
	missionInfo.id = id
	missionInfo.amount = amount
	local transformTable = self:transformMissionInfo(missionInfo)
	if transformTable == nil then return nil end
	local sailorTxt = transformTable.sailorTxt
	---头像图名，水手名，描述，daily_mission表里的每日任务ID，(物品ID，港口ID，战役ID，没有则为0)，钱数量，奖励
	local layer = GuestsMission.new({headRes = sailorImage, name = sailorName, txt = sailorTxt,
						missionId = missionId, id = id, amount = amount, reward = reward})
	return layer
end

---missionInfo:daily_mission 表， missionData:服务端数据
function DailyMission:transformMissionInfo(missionInfo, missionData)
	local dailyTable = {}	
	local tipTxt = missionInfo.target_tips
    local raw_target_tips = tipTxt
    if type(tipTxt) == "table" then
        raw_target_tips = ""
        local str = ""
        for k,v in ipairs(tipTxt) do
            str = str .. "|" .. v
            local find_index = string.find(v, "#", 0)
            if find_index then
                raw_target_tips = raw_target_tips .. string.sub(v, find_index + 1)
            else
                raw_target_tips = raw_target_tips .. v
            end
        end
        tipTxt = str
    end


    local progressTxt = missionInfo.mission_tip  ---任务目标描述

	local index = missionData.describe
	local mission_des = missionInfo.mission_desc[index]   ---任务描述

	local tipStr = ""
	local progressStr = ""
	local missionStr = ""
	local json_info = missionData.json_info
	dailyTable.missionTip = ""

	if missionInfo.mission_type == PORT then

		local port_id  = json_info["portId"]
		local port_name = port_info[port_id].name

		tipStr = string.format(tipTxt,port_name)
		raw_target_tips = string.format(raw_target_tips,port_name )
		progressStr = string.format(progressTxt, port_name)
		missionStr = string.format(mission_des, port_name)
	elseif missionInfo.mission_type == BUSINESS then
		tipStr = string.format(tipTxt, tostring(json_info.profit))
		raw_target_tips = string.format(raw_target_tips, tostring(json_info.profit))
		progressStr = string.format(progressTxt, tostring(json_info.profit))
		missionStr = string.format(mission_des, tostring(json_info.profit))
	elseif missionInfo.mission_type == PVE then 

		tipStr = tipTxt
		raw_target_tips = raw_target_tips
		progressStr = progressTxt 		--tostring(json_info.times),
		missionStr = mission_des

	elseif missionInfo.mission_type == EXPLORE_WRECK then ---
		tipStr = tipTxt
		raw_target_tips = raw_target_tips
		progressStr = progressTxt 		--tostring(json_info.times),
		missionStr = mission_des
	end
	
	tipStr = split(tipStr, "|")
	local completeTips = nil
	if missionData.status == 2 then
		completeTips = true--ui_word.HOTEL_REWARD_COMPELETE_TIPS
		progressStr = ui_word.HOTEL_REWARD_COMPELETE_TIPS
		tipStr = missionInfo.complete_desc
	end
	dailyTable.missionTip = tipStr
	dailyTable.progressDes = progressStr
	local missionDataHandler = getGameData():getMissionData()
	dailyTable.name = missionDataHandler:getMissionTypeName(missionInfo.mission_type)
	dailyTable.completeTips = completeTips
	dailyTable.raw_target_tips = raw_target_tips
	dailyTable.missionStr = missionStr
	return dailyTable
end

--对话用的拼接
function DailyMission:parseMissionInfo(missionInfo, missionData, sourceStr)
	local dailyTable = {}
	local tipStr = ""
	local json_info = missionData.json_info
	dailyTable.missionTip = ""

	if missionInfo.mission_type == PORT then

		local portName = port_info[json_info.portId].name
		tipStr = string.format(sourceStr, portName)
	elseif missionInfo.mission_type == BUSINESS then		
		tipStr = string.format(sourceStr, tostring(json_info.profit))
	elseif missionInfo.mission_type == PVE then
		tipStr = sourceStr
	elseif missionInfo.mission_type == EXPLORE_WRECK then
		tipStr = sourceStr
	end
	dailyTable.missionTip = tipStr
	
	return dailyTable
end

--创建日常任务完成界面
function DailyMission:createCompleteLayer(missionId, reward, isEnd, missionInfo, callFunc)	
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then return end
	local missionId = missionInfo.missionId
	local missionConfig = daily_mission[tonumber(missionId)]
	local tempStr = ""
	if isEnd then
		local endStr = missionConfig.end_dialog
		local index = math.random(#endStr)
		tempStr = endStr[index]
	else
		local startStr = missionConfig.accept_dialog	
		local index = math.random(#startStr)
		tempStr = startStr[index]
	end
	local tempTable = self:parseMissionInfo(missionConfig, missionInfo, tempStr)
	local msg = tempTable.missionTip
	
	local start_callback = function()
		EventTrigger(EVENT_DELETE_ITEMS_LAYER)
	end
	local delay_callback_info = nil
	local delay_time_config_item = DELAY_TIME_CONFIG[missionConfig.mission_type]
	if  not isEnd and delay_time_config_item then--isEnd and
		delay_callback_info = {}
		delay_callback_info.time = delay_time_config_item.time
		delay_callback_info.callback = function()
			local missionDataHandler = getGameData():getMissionData()
			missionDataHandler:dailyMissionGoOn(missionInfo)
		end

	end

	local sailor_data = getGameData():getSailorData()
	local sailorId = sailor_data:getCaptain()
	
	local function endCallBack( )

		start_callback()

		if delay_callback_info then
			delay_callback_info.callback()
		end

		if isEnd then
			-- local title = ""
			-- title = missionConfig.mission_name[1]

			-- local param = {
			-- 	name = title,
			-- 	reward = reward,
			-- 	call_back = callFunc
			-- }
			callFunc()

			if isExplore then
				getUIManager():create("gameobj/guild/clsGuildTaskPanel",{},"reward_task")
			else
				local skipToLayer = require("gameobj/mission/missionSkipLayer")
				skipToLayer:skipLayerByName("guild_task", nil)
			end
			
		else
			callFunc()
		end
	end


	local sailor = sailor_info[sailor]
	local rich_str = "$(font:FONT_CFG_1)"..msg
	local call_back = endCallBack
	local close_time = 1
	Alert:showDialogTips(sailor, rich_str, nil, nil, nil, nil, nil, call_back, close_time)
end

--创建是否接受藏宝图任务界面(港口ID，藏宝图类型，花费的钱)
function DailyMission:createTreasureMissionLayer(id, consume)
	Alert:warning({msg = string.format(ui_word.BLACKMARKET_CONSUME, consume)})
	local playerData = getGameData():getPlayerData()
    local icon = playerData:getIcon()
    icon = string.format("ui/seaman/seaman_%s.png", icon)
    local sailorImage = icon
	local sailorName = playerData:getName()
	local portName = port_info[id].name
	local sailorTxt = string.format(ui_word.BLACKMARKET_ASK_ALREADYSHOW, portName)
	local missionId = 0
	
	local layer = GuestsMission.new({headRes = sailorImage, name = sailorName, txt = sailorTxt,
		missionId = missionId, id = id})
	return layer
end

--创建冷却CD时间内请客提示界面
function DailyMission:createCoolingCDLayer()
	if self.money == nil or self.money <= 0 then
		return nil
	end
	local layer = CoolingCDLayer.new(self.money)
	return layer
end

--设置冷却CD时间和金币
function DailyMission:setCDTimeData(cdTime, gold)
	self.money = gold
	self.cdTime = cdTime or 0
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.cdTimeSchedule then
		scheduler:unscheduleScriptEntry(self.cdTimeSchedule)
		self.cdTimeSchedule = nil
	end
	if self.cdTime >= 1 then
		self.cdTimeSchedule = scheduler:scheduleScriptFunc(function(dt)
			self.cdTime = self.cdTime - 1
			if self.cdTime <= 0 then
				scheduler:unscheduleScriptEntry(self.cdTimeSchedule)
				self.cdTimeSchedule = nil
			end
		end,1,false)
	end
end

function DailyMission:getCDTime()
	self.cdTime = self.cdTime or 0
	return self.cdTime
end

function DailyMission:getCDTimeNeedMoney()
	return self.money
end
--------------------------------------创建是否接受日常任务界面------------------------------------

---日常任务界面
function GuestsMission:ctor(content)	
	loadRes()
	self:showChatDialog(content)
end

--创建日常对话框
function GuestsMission:createChatDialog(content)	
	self.isDailyMission = true
	if content.missionId == 0 then
		self.isDailyMission = false
	end
	
	self.chatPlotBg = getChangeFormatSprite("ui/bg/bg_plot.png")
	self.chatPlotBg:setAnchorPoint(ccp(0.5, 1))
	self.chatPlotBgSize = self.chatPlotBg:getContentSize()
	self.chatPlotBg:setPosition(ccp(display.cx, 0))
	self:addChild(self.chatPlotBg)
	
	local seamanHead = display.newSprite(content.headRes)
	
	self.chatPlotBg:addChild(seamanHead)
	local scale = 130 / seamanHead:getContentSize().width
	seamanHead:setScale(scale)
	seamanHead:setAnchorPoint(ccp(0,0))
	seamanHead:setPosition(ccp(120, 0))
	
	local seamanName = createBMFont({text = content.name, fontFile = FONT_MICROHEI_BOLD, size = 20, 
					color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 290, y = 120 })
	seamanName:setAnchorPoint(ccp(0, 1))
	self.chatPlotBg:addChild(seamanName)
	
	local lx, ly = 290, 90
	local labelWidth = 560
	if not self.isDailyMission then
		labelWidth = 360
	end
	local labelTab = {text = content.txt, fontFile = FONT_MICROHEI_BOLD, size = 18, width = labelWidth, 
					color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),x = lx, y = ly}
	local contentLabel = createBMFont(labelTab)
	contentLabel:setAnchorPoint(ccp(0, 1))
	self.chatPlotBg:addChild(contentLabel)
	
	--奖励
	if content.reward then
		local rewardLabel = createBMFont({text = ui_word.TASK_REWARD_NAME, fontFile = FONT_MICROHEI_BOLD, size = 18, width = 560, 
						color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),x = 290, y = 50})
		rewardLabel:setAnchorPoint(ccp(0, 1))
		self.chatPlotBg:addChild(rewardLabel)
		
		local collectCommon = require("ui/collectCommon")
		local rewardTable = {}
		for k, v in pairs(content.reward) do
			local key = tonumber(v.key)
			if key == ITEM_INDEX_CASH then
				rewardTable.silver = v.value
			elseif key == ITEM_INDEX_EXP then
				rewardTable.exp = v.value
			elseif key == ITEM_INDEX_GOLD then
				rewardTable.gold = v.value
			elseif key == ITEM_INDEX_HONOUR then
				rewardTable.honor = v.value
			end
		end
		local rewardItem = {}
		rewardItem.bgNode = self.chatPlotBg
		rewardItem.data = rewardTable
		rewardItem.posX = 370
		rewardItem.posY = 30
		rewardItem.direction = DIRECTION_HORIZONTAL
		rewardItem.picType = 2
		collectCommon:createReward(rewardItem)
	end

	--接受按钮
	local acceptButton = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png", x = 850, y = 90,
        text = ui_word.STR_ACCEPT, fsize=16, scale= SMALL_BUTTON_SCALE, fontFile=FONT_BUTTON})
	acceptButton:regCallBack(function(event)
		if self.isDailyMission then	--日常任务
			GameUtil.callRpc("rpc_server_accept_daily_mission", {content.missionId, content.id, content.amount})
		else
			--藏宝图任务
			GameUtil.callRpc("rpc_server_accept_treasure_mission", {1}, "rpc_client_accept_treasure_mission")
		end
		self:closeChatDialog()
	end)
	
	--拒绝按钮
	local refuseButton = MyMenuItem.new({image = "#btn_darkred_1.png", imageSelected = "#btn_darkred_2.png", x = 850, y = 40,
        text = ui_word.STR_REFUSE,fsize=16,fontFile=FONT_BUTTON})
	refuseButton:regCallBack(function(event)
		if not self.isDailyMission then
			GameUtil.callRpc("rpc_server_accept_treasure_mission", {0}, "rpc_client_accept_treasure_mission")
		end
		self:closeChatDialog()
	end)
	
	self.chatPlotBg:addChild(MyMenu.new({acceptButton, refuseButton}))
end

--展示日常对话框
function GuestsMission:showChatDialog(content)
	self:createChatDialog(content)
	self.chatPlotBg:runAction(CCMoveBy:create(0.5, ccp(0, self.chatPlotBgSize.height)))
end

--关闭日常对话框
function GuestsMission:closeChatDialog()
	if tolua.isnull(self) then return end

	local act1 = CCMoveBy:create(0.5, ccp(0, -self.chatPlotBgSize.height * 1.5))
	local act2 = CCCallFunc:create(function()
		unLoadRes()
		self:removeFromParentAndCleanup(true)
		EventTrigger(EVENT_HOTEL_SET_TOUCH, true)
	end)
	self.chatPlotBg:runAction(CCSequence:createWithTwoActions(act1, act2))
end

--------------------------------------完成日常任务界面------------------------------------

-- 完成任务
function DailyComplete:ctor(item)
	loadRes()
	
	local missionBg = display.newSprite("#mission_bg.png", display.cx, display.cy)
	self:addChild(missionBg)
	local backgrSize = missionBg:getContentSize()
	
	local titlePosY = 140
	self:addMissionTitle(item, missionBg, titlePosY)	

	local fadeTime = 0.3
	local linePosX = 0
	local tempPosY = 120
	local lineSprite1 = display.newSprite("#mission_line3.png")
	lineSprite1:setPosition(ccp(backgrSize.width / 2, tempPosY))
	missionBg:addChild(lineSprite1)
	--船长！悬赏任务已经完成，请去【酒馆】领赏。side_left7
	
	local name_sprite = display.newSprite("ui/txt/txt_mission_reward.png", 113, tempPosY)
	name_sprite:setScale(0.6)
	missionBg:addChild(name_sprite)

	local completeSp = display.newSprite("ui/txt/txt_stamp_complete.png", 850, 60)
	missionBg:addChild(completeSp)

	local tipsLabel = createBMFont({fontFile = FONT_CFG_1, text = ui_word.DAILY_FIND_TREASUREMAP_TIPS_COMPELETE, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),
                size = 20})
	tipsLabel:setPosition(ccp(backgrSize.width / 2, 85))
	missionBg:addChild(tipsLabel)
	missionBg:setOpacity(0)

	local function clickCallFunc()
		local function closeDialog()
			self:hideDialog()
		end
		closeDialog()
	end

	--跳转提示
	local go_lab = createBMFont({text = ui_word.DAILY_REWARD_GET_TIPS, fontFile=FONT_TITLE,size=SIZE_TITLE, align=ui.TEXT_ALIGN_CENTER, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), x = backgrSize.width / 2, y = 45})
	missionBg:addChild(go_lab, 1)
	
	local act = CCCallFunc:create(function()
		-- local complete_mission = CompositeEffect.bollow("tx_1008", 200, backgrSize.height * 0.5, missionBg)
		-- self:addFinger()
	end)
	missionBg:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(fadeTime), act))
	
	self.call_back = item.call_back
	
	self:registerScriptTouchHandler(function(event, x, y)
		if event == "began" then
			return true
		elseif event == "ended" then 
			local portLayer = getUIManager():get("ClsPortLayer")
			if tolua.isnull(portLayer) then
				getGameData():getExploreData():exploreOver()
				clickCallFunc()
				return
			end
			if not tolua.isnull(portLayer) and not tolua.isnull(portLayer.portItem) then 
				portLayer.portItem:removeFromParentAndCleanup(true)
				portLayer.portItem = nil
			end
			local skipToLayer = require("gameobj/mission/missionSkipLayer")
			skipToLayer:skipLayerByName("guild_task", nil)
			--portLayer:addItem(skipMissLayer)
			clickCallFunc()
		end
	end, false, -129, true)
	self:setTouchEnabled(true)
	-- 播放完成任务音效
	audioExt.playEffect(music_info.MISSION_COMPLETE.res, false)
end

---添加任务标题
function DailyComplete:addMissionTitle(item, missionBg, posY)	
	local leftFigure  = display.newSprite("#mission_figure.png")
	local rightFigure = display.newSprite("#mission_figure.png")
	rightFigure:setFlipX(true)
	local figureSize = leftFigure:getContentSize()
	local lableName = createBMFont({text = item.name,fontFile=FONT_TITLE,size=SIZE_TITLE,align=ui.TEXT_ALIGN_CENTER,
			 x = 0, y = 0})
	missionBg:addChild(lableName)
	local lnw = lableName:getContentSize().width
	lnw = lnw * lableName:getScale()
	missionBg:addChild(leftFigure)
	missionBg:addChild(rightFigure)
	
	local labelPosX = 0
	local leftPosX  = 0
	local rightPosX = 0
	leftFigure:setAnchorPoint(ccp(1, 0.5))
	rightFigure:setAnchorPoint(ccp(0, 0.5))
	
	local backgrSize = missionBg:getContentSize()
	labelPosX = backgrSize.width / 2
	local dx = 2
	leftPosX  = labelPosX - lnw / 2 - dx
	rightPosX = labelPosX + lnw / 2 + dx
	
	leftFigure:setPosition(leftPosX, posY)
	rightFigure:setPosition(rightPosX, posY)
	lableName:setPosition(labelPosX, posY)
end

--添加点击特效
function DailyComplete:addFinger()
	local dx, dy = display.right - 100, display.cy
	self.fingerClick = CompositeEffect.bollow("tx_1042_1", dx, dy, self)
	self.fingerRect = CCRect(dx - 50, dy - 50, 100, 100)
end

--判断是否被点击
function DailyComplete:isClickRect(x, y)
	if not tolua.isnull(self.fingerClick) then
		local pos = self:convertToNodeSpace(ccp(x,y))
		local touchInFinger = self.fingerRect:containsPoint(pos)
		if touchInFinger then
			return true
		end
	end
	return false
end

-- 关闭对话
function DailyComplete:hideDialog()  
	unLoadRes()
	self:removeFromParentAndCleanup(true)
	-- 回调
	self:callFunc(self.call_back)
end

function DailyComplete:callFunc(call_back)
	if type(call_back) == "function" then  
		call_back()
	end 
end

-------------------------------------请客冷却时间界面----------------------------------
function CoolingCDLayer:ctor(money)
	self:showCDTipLayer(money)
end

--创建layer
function CoolingCDLayer:createCDTip(money)	
	self.cdPlotBg = getChangeFormatSprite("ui/bg/bg_plot.png")
	self.cdPlotBg:setAnchorPoint(ccp(0.5, 1))
	self.cdPlotBgSize = self.cdPlotBg:getContentSize()
	self.cdPlotBg:setPosition(ccp(display.cx, 0))
	self:addChild(self.cdPlotBg)
	
	local sailor_data = getGameData():getSailorData()
	local roomSailor = sailor_data:getCaptain()
	if roomSailor then
		local sailor = tool:getSailor(roomSailor)	
		local seamanHead = display.newSprite(sailor.res)	
		self.cdPlotBg:addChild(seamanHead)
		local scale = 130 / seamanHead:getContentSize().width
		seamanHead:setScale(scale)
		seamanHead:setAnchorPoint(ccp(0,0))
		seamanHead:setPosition(ccp(120, 0))
	end
	
	local tipStr = string.format(ui_word.DAILY_CD_TIP, money)
	local cdTipLabel = createBMFont({text = tipStr, fontFile = FONT_MICROHEI_BOLD, size = 20, 
					color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 290, y = 90 })
	cdTipLabel:setAnchorPoint(ccp(0, 1))
	self.cdPlotBg:addChild(cdTipLabel)

	--确认按钮
	local acceptButton = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png", x = 850, y = 90,
        text = ui_word.MAIN_OK,fsize=16,fontFile=FONT_BUTTON})
	acceptButton:regCallBack(function(event)
		GameUtil.callRpc("rpc_server_cancel_daily_cd", {}, "rpc_client_cancel_daily_cd")
		self:closeChatDialog()
	end)
	
	--取消按钮
	local refuseButton = MyMenuItem.new({image = "#btn_darkred_1.png", imageSelected = "#btn_darkred_2.png", x = 850, y = 40,
        text = ui_word.MAIN_CANCEL,fsize=16,fontFile=FONT_BUTTON})
	refuseButton:regCallBack(function(event)
		self:closeChatDialog()
	end)
	
	self.cdPlotBg:addChild(MyMenu.new({acceptButton, refuseButton}))
end

--展示CD冷却时间内请客界面
function CoolingCDLayer:showCDTipLayer(money)
	self:createCDTip(money)
	self.cdPlotBg:runAction(CCMoveBy:create(0.5, ccp(0, self.cdPlotBgSize.height)))
end

--关闭日常对话框
function CoolingCDLayer:closeChatDialog()
	if tolua.isnull(self) then return end

	local act1 = CCMoveBy:create(0.5, ccp(0, -self.cdPlotBgSize.height * 1.5))
	local act2 = CCCallFunc:create(function()
		self:removeFromParentAndCleanup(true)
		EventTrigger(EVENT_HOTEL_SET_TOUCH, true)
	end)
	self.cdPlotBg:runAction(CCSequence:createWithTwoActions(act1, act2))
end

return DailyMission