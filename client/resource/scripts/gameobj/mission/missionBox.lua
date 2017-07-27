----  任务框

local MissionEvent = require("gameobj/mission/missionEvent")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local UiCommon = require("ui/tools/UiCommon")
local CompositeEffect = require("gameobj/composite_effect")
local commonBase = require("gameobj/commonFuns")
local scheduler = CCDirector:sharedDirector():getScheduler()

local MissionBox = {}
local explain_size = 33
local cd_scheduler_handler = nil
local cd = 2
MissionBox.isOpen = nil
--创建任务框层
function MissionBox:createDialogLayer()
	self.resPlist = {
		["ui/material_icon.plist"] = 1, 
		["ui/mission.plist"] = 1,
	}
	local layer = display.newLayer()

	return layer
end

------- 新任务
function MissionBox:newMisssion(item)   
    self.isOpen = true   
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then return end
	if tolua.isnull(self.layer) then
		self.layer = self:createDialogLayer()
		self.layer:setTag(9595)
		running_scene:addChild(self.layer, ZORDER_MISSION)
	end 

	LoadPlist(self.resPlist)

	self.call_back = item.call_back
	
	local mission_bg = display.newSprite("#mission_bg.png", display.cx, display.cy)
	self.layer:addChild(mission_bg)
	local backgrSize = mission_bg:getContentSize()
	
	local desc = ""
	for k, v in ipairs(item.desc) do
		local str = v
		local index = string.find(v, "#", 0)
		if index then
			str = string.sub(v, index + 1)
		else
			index = string.find(v, "@", 0)
			if index then
				str = string.sub(v, index + 1)
			end
		end
		desc = desc .. str
	end
	
	local explainText = desc
	explain = createBMFont({text = explainText,align = ui.TEXT_ALIGN_CENTER, fontFile=FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 18, x = backgrSize.width/2, y = 80 })
	explain:setAnchorPoint(ccp(0.5,0.5))
	explain:setString(explainText)
	mission_bg:addChild(explain)
    if explain:getContentSize().width > 550 then
       explain:removeFromParentAndCleanup(true)
       explain = createBMFont({text = explainText,width = 550,align = ui.TEXT_ALIGN_LEFT, fontFile=FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 18, x = backgrSize.width*0.42-217, y = 80 })
	   explain:setAnchorPoint(ccp(0,0.5))
	   mission_bg:addChild(explain)
    end
	local collectCommon = require("ui/collectCommon")
	local rewardItem = {}
	rewardItem.bgNode = mission_bg
	rewardItem.data = item
	rewardItem.posX = 0
	rewardItem.posY = 35
	rewardItem.direction = DIRECTION_HORIZONTAL
	rewardItem.picType = 2
	rewardItem.rowDetal = 250
	rewardItem.gapDx = 30
	rewardItem.fontSet = {numSize=22, numColor=COLOR_CREAM_STROKE}

	local rewPosX
	local rewardNode
	local widthCount
	rewPosX, rewardNode, widthCount = collectCommon:createReward(rewardItem)

	rewardNode:setAnchorPoint(ccp(0.5,0.5))
	rewardNode:setPositionX(mission_bg:getContentSize().width/2 - widthCount/2 - (#rewardNode.label-1)*rewardItem.rowDetal/2 + 20)
	rewardNode:setAnchorPoint(ccp(0.5,0.5))

	if rewardNode.label then
		if #rewardNode.label == 1 then
			rewardNode:setPositionX(rewardNode:getPositionX()-50)
		end
		for k,v in ipairs(rewardNode.label) do
			local numBgFrame = display.newSpriteFrame("mission_numBg.png")
		    local numBgSprite = CCScale9Sprite:createWithSpriteFrame(numBgFrame)
		    numBgSprite:setContentSize(CCSize(135, 40))
		    numBgSprite:setPosition(v:getPositionX()+45,v:getPositionY())
		    rewardNode:addChild(numBgSprite, -1)
		end
	end


	local newMissionPosY = 142
	
	local linePosY = 120
	mission_bg:addChild(display.newSprite("#mission_line1.png", backgrSize.width * 0.5, linePosY))
	local mission_text_task = display.newSprite("ui/txt/txt_mission_task.png", 85, linePosY)
	mission_text_task:setScale(0.6)
	mission_bg:addChild(mission_text_task)
	-- mission_bg:addChild(display.newSprite("#mission_name2.png", 101, linePosY))

	self:addMissionTitle(item, mission_bg, {posY = newMissionPosY, boxType = 1})	

	local function clickCallFunc()
		if tolua.isnull(self.layer) then
			return
		end
		if item.event then self:missionEvent(item.event) end
		local onOffData = getGameData():getOnOffData()	
		self:openMissionGuide(item)
		onOffData:openNewButton()
		self:hideDialog()
	end

	local acceptBtn = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected="#common_btn_blue2.png", imageDisabled="", x=850, y=60,
        text = ui_word.TASK_ACCEPT, fsize = 18, scale= SMALL_BUTTON_SCALE, fontFile = FONT_BUTTON, fcolor = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	acceptBtn:regCallBack(function()
				clickCallFunc()
			end)
	mission_bg:addChild(MyMenu.new(acceptBtn, TOUCH_PRIORITY_MISSION - 2))

	mission_bg:setOpacity(0)
	local act = CCCallFunc:create(function()
		--local new_mission = CompositeEffect.bollow("tx_1007", 190, newMissionPosY, mission_bg)	
		--self:addFinger()
	end)
	mission_bg:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.3), act))

	self.layer:registerScriptTouchHandler(function(event, x, y)
        if event =="began" then 
        	clickCallFunc()		
			return true 
		end
	end, false, TOUCH_PRIORITY_MISSION - 1, true)
	self.layer:setTouchEnabled(true)
	
	-- 播放接受任务音效
	audioExt.pauseMusic()
	audioExt.playEffect(music_info.MISSION_ACCEPT.res, false)

	self:initCD(clickCallFunc)
end 

--判断是否被点击
function MissionBox:isClickRect(x, y)
	if not tolua.isnull(self.fingerClick) then
		local pos = self.layer:convertToNodeSpace(ccp(x,y))
		local touchInFinger = self.fingerRect:containsPoint(pos)
		if touchInFinger then
			return true
		end
	end
	return false
end

--添加点击特效
function MissionBox:addFinger()
	local dx, dy = display.right - 200, display.cy
	
	self.fingerClick = CompositeEffect.bollow("tx_1042_1", dx, dy, self.layer)
	self.fingerRect = CCRect(dx - 50, dy - 50, 100, 100)
end

---添加任务标题
function MissionBox:addMissionTitle(item, missionBg, taskMap)	
	local leftFigure  = display.newSprite("#mission_figure.png")
	local rightFigure = display.newSprite("#mission_figure.png")
	rightFigure:setFlipX(true)
	local figureSize = leftFigure:getContentSize()
	
	local lableName = createBMFont({text=item.name,fontFile=FONT_TITLE,size=SIZE_TITLE,align=ui.TEXT_ALIGN_CENTER,
			 x = 0, y = 0,color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
	missionBg:addChild(lableName)
	local lnw = lableName:getContentSize().width
	
	missionBg:addChild(leftFigure)
	missionBg:addChild(rightFigure)
	
	local labelPosX = 0
	local leftPosX  = 0
	local rightPosX = 0
	if taskMap.boxType == 2 then		--完成任务弹框
		leftFigure:setAnchorPoint(ccp(0.5,0.5))
		rightFigure:setAnchorPoint(ccp(0.5, 0.5))
		lableName:setAnchorPoint(ccp(0.5, 0.5))
		
		local backgrSize = missionBg:getContentSize()
		local missionTitlePosX = 425
		labelPosX = missionTitlePosX + figureSize.width + 5
		leftPosX  = missionTitlePosX
		rightPosX = labelPosX + lableName:getContentSize().width + 5
	else
		labelPosX = display.cx
		leftPosX  = labelPosX - lnw * 0.5 - figureSize.width * 0.5
		rightPosX = labelPosX + lnw * 0.5 + figureSize.width * 0.5
	end
	
	local posY = taskMap.posY
	lableName:setPosition(labelPosX, posY + 3)
	local leftFigureX = labelPosX-(lableName:getContentSize().width/2+leftFigure:getContentSize().width/2+10)
	local rightFigureX = labelPosX+(lableName:getContentSize().width/2+rightFigure:getContentSize().width/2+7)
	leftFigure:setPosition(leftFigureX, posY)
	rightFigure:setPosition(rightFigureX, posY)

end

-- 完成任务
function MissionBox:completeMission(item)  
	self.isOpen = true
	-- 播放完成任务音效
    audioExt.pauseMusic()
	audioExt.playEffect(music_info.MISSION_COMPLETE.res, false)
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then return end
	if tolua.isnull(self.layer) then
		self.layer = self:createDialogLayer()
		running_scene:addChild(self.layer, ZORDER_MISSION)
	end 

	LoadPlist(self.resPlist)

	local mission_bg = display.newSprite("#mission_bg.png", display.cx, display.cy)
	self.layer:addChild(mission_bg)
	local backgrSize = mission_bg:getContentSize()
	
	local titlePosY = 140
	self:addMissionTitle(item, mission_bg, {posY = titlePosY, boxType = 2})	
	
	local collectCommon = require("ui/collectCommon")
	local rewardItem = {}
	rewardItem.bgNode = mission_bg
	rewardItem.numLbBgInfo = {res="#mission_numBg.png", size=CCSizeMake(138, 40), isScale9Sprite=true}
	rewardItem.data = item
	rewardItem.posX = 0
	rewardItem.posY = 60
	rewardItem.gapDx = 30
	rewardItem.direction = DIRECTION_HORIZONTAL
	rewardItem.rowDetal = 250
	rewardItem.picType = 2
	rewardItem.fontSet = {numSize=22, numColor=COLOR_CREAM_STROKE}

	local rewPosX, rewardNode, widthCount = collectCommon:createReward(rewardItem)
	rewardNode:setPositionX(mission_bg:getContentSize().width/2 - widthCount/2 - (#rewardNode.label-1)*rewardItem.rowDetal/2 + 20)
	rewardNode:setAnchorPoint(ccp(0.5,0.5))

	if rewardNode.label then
		if #rewardNode.label == 1 then
			rewardNode:setPositionX(rewardNode:getPositionX()-50)
		end
		for k,v in ipairs(rewardNode.label) do
			local numBgFrame = display.newSpriteFrame("mission_numBg.png")
		    local numBgSprite = CCScale9Sprite:createWithSpriteFrame(numBgFrame)
		    numBgSprite:setContentSize(CCSize(135, 40))
		    numBgSprite:setPosition(v:getPositionX()+43,v:getPositionY())
		    rewardNode:addChild(numBgSprite, -1)
		end
	end

	local linePosY = 120
	mission_bg:addChild(display.newSprite("#mission_line1.png", backgrSize.width * 0.5, linePosY))
	local mission_text_task = display.newSprite("ui/txt/txt_mission_task.png", 85, linePosY)
	mission_text_task:setScale(0.6)
	mission_bg:addChild(mission_text_task)

	local completeSp = display.newSprite("ui/txt/txt_stamp_complete.png", 850, 60)
	mission_bg:addChild(completeSp)

	local fadeTime = 0.3
	mission_bg:setOpacity(0)
	local act = CCCallFunc:create(function()
		--local complete_mission = CompositeEffect.bollow("tx_1008", 200, backgrSize.height * 0.5, mission_bg)
		--self:addFinger()
	end)
	mission_bg:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(fadeTime), act))
	
	local function clickCallFunc()
		if not tolua.isnull(self.layer) then
			if item.gold then
				audioExt.playEffect(music_info.COMMON_GOLD.res, false)
			end
			if item.silver then
				audioExt.playEffect(music_info.COMMON_CASH.res, false)
			end
			if item.seaman or item.boat or item.equip then
				audioExt.playEffect(music_info.TOWN_CARD.res, false)
			end
			if item.exp or item.honor or item.honor then
				audioExt.playEffect(music_info.COMMON_HONOUR.res, false)
			end

			local function closeDialog()
				self.call_back = item.call_back
				self:hideDialog()
				local missionDataHandler = getGameData():getMissionData()
				missionDataHandler:askGetMissionReward(item.id)
			end
			
			-- CompositeEffect.bollow("tx_1039", 800, backgrSize.height * 0.5, mission_bg, 1.2, function()
			-- 	closeDialog()
			-- end)
			
			closeDialog()
		end
	end
	
	self.layer:registerScriptTouchHandler(function(event, x, y)
        if event =="began" then 
		       clickCallFunc()
			return true 
		end
	end, false, TOUCH_PRIORITY_MISSION - 1, true)
	self.layer:setTouchEnabled(true)

	self:initCD(clickCallFunc)
end

function MissionBox:initCD(call_back)
	cd = 2
    local function updateCdTime()
        if tolua.isnull(self.layer) then
            if cd_scheduler_handler then
                scheduler:unscheduleScriptEntry(cd_scheduler_handler)
                cd_scheduler_handler = nil
            end
            return
        end
        cd = cd - 1
        if cd <= 0 then
        	if cd_scheduler_handler then
                scheduler:unscheduleScriptEntry(cd_scheduler_handler)
                cd_scheduler_handler = nil
            end
        	if call_back ~= nil then
        		call_back()
        	end
        end
    end
    if cd_scheduler_handler then
        scheduler:unscheduleScriptEntry(cd_scheduler_handler)
        cd_scheduler_handler = nil
    end
    cd_scheduler_handler = scheduler:scheduleScriptFunc(updateCdTime, 1, false)
end

-- 任务事件触发
function MissionBox:missionEvent(item)  
	local event = item.event 
	local params = item.params
	if MissionEvent[event] then
		MissionEvent[event](params)
	end 
end 

function MissionBox:callFunc(call_back)
	if call_back and type(call_back) == "function" then  
		call_back()
	end 
end

-- 关闭对话
function MissionBox:hideDialog() 
	self.isOpen = nil
    audioExt.resumeMusic()
	self.layer:removeFromParentAndCleanup(true)
	self.layer = nil
	if cd_scheduler_handler then
        scheduler:unscheduleScriptEntry(cd_scheduler_handler)
        cd_scheduler_handler = nil
    end
	UnLoadPlist(self.resPlist)
	-- 回调
	self:callFunc(self.call_back)
end

--没有接受弹出框时调用
function MissionBox:newMissionEvent(item)
	if item.event then self:missionEvent(item.event) end
	local onOffData = getGameData():getOnOffData()
	self:openMissionGuide(item)
	onOffData:openNewButton()
	self:callFunc(item.call_back)
end

--没有完成弹出框时调用
function MissionBox:completeMissionEvent(item)
	self:callFunc(item.call_back)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:askGetMissionReward(item.id)
end

---标记显示任务指引
function MissionBox:openMissionGuide(mission_tab)
	local missionDataHandler = getGameData():getMissionData()
	cclog(T("================================标记显示任务指引 missionId=")..mission_tab.id)
	missionDataHandler:setPortSelectMisId(mission_tab.id)

	ClsGuideMgr:openGuideByMission(mission_tab)
end

return MissionBox 


