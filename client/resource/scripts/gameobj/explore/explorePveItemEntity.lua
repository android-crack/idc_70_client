-- 探索PVE事件

local explore_event = require("game_config/explore/explore_event")
local exploreAttrs = require("module/explore/exploreAttrs")
local progressTimer = require("ui/tools/ProgressTimer")
local exploreProp = require("gameobj/explore/exploreProp")
local commonBase = require("gameobj/commonFuns")
local explore_skill = require("game_config/explore/explore_skill")
local missionGuide = require("gameobj/mission/missionGuide")
local dataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")
local UI = require ("base/ui/ui")

local ITEM_VALID_DISTANCE = 2 * display.width    -- 离船的最远有效距离
local scheduler = CCDirector:sharedDirector():getScheduler()

local ExplorePveItem = class("ExplorePveItem", function() return CCLayer:create() end)

function ExplorePveItem:ctor(player_ship)
	
	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)
	
	-- init
	self.is_pause = false
	self.player_ship = player_ship
	self.item_pool = {}

	self:regFuns()
end 

function ExplorePveItem:removeItem3D()
	for k, v in pairs(self.item_pool) do
		if v.cdTimerHandler ~= nil then
			scheduler:unscheduleScriptEntry(v.cdTimerHandler)
			v.cdTimerHandler = nil
		end
		v.spItem:release()
		v = nil
	end 
	self.item_pool = nil
	self.player_ship = nil
end 

--创建实体
function ExplorePveItem:mkExploreItem(item_type, item_status)
	local fd = {}

	fd.gen_id = 0
	if item_type == EX_PVE_TYPE_PORT then
		fd.res = EX_PVE_PORT_RES[item_status]
	else
		fd.res = EX_PVE_SH_RES[item_status]
	end
	fd.hit_radius = 1
	fd.show_radius = ITEM_VALID_DISTANCE
	fd.hit = 1

	item = exploreProp.new(fd)
	item:setSpeedRate(0)

	local index = #self.item_pool + 1
	item.node:setTag("explorePveItem", tostring(index))
	
	local item_data = {
		baseData = fd,
		spItem = item,
		isStart = false,
		isOver = true,
		outOfDistance = false,
		isBroken = false,
		item_id = 0,
		item_type = item_type,
		item_status = item_status,
		cd = 0,
	}
	return item_data
end

function ExplorePveItem:getItemFromPool(itemType, itemStatus)
	for k, item_data in pairs(self.item_pool) do
		if item_data.isOver and item_data.item_type == itemType and item_data.item_status == itemStatus then
			return item_data
		end
	end
	
	local item = self:mkExploreItem(itemType, itemStatus)
	self.item_pool[#self.item_pool + 1] = item
	return item
end

function ExplorePveItem:createPortItem(portId, pos, exploreLayer)
	local portPveData = getGameData():getPortPveData()
	local pveInfo = portPveData:getPortPveInfo(portId)
	local item = self:getItemFromPool(EX_PVE_TYPE_PORT, pveInfo.status)
	if not item then return end
	
	item.item_id = portId
	item.spItem:setPos(pos.x, pos.y)
	item.spItem:setVisible(true)
	item.isOver = false
	item.outOfDistance = false
	item.isBroken = false
	self:unBrokenItem(item)
	
	return item
end 

function ExplorePveItem:createPirateIcon(item)
	--创建boss头像
	local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
	local config = pve_stronghold_info[item.item_id]
	local boss_id = config.boss_id
	if boss_id and (boss_id > 0) then
		if not tolua.isnull(item.boss_icon) then
			item.boss_icon:removeFromParentAndCleanup(true)
		end
		local boss_info = require("game_config/explore/patrol_boss_info")
		local boss_config = boss_info[boss_id]
        local sailor_info = require("game_config/sailor/sailor_info")
        local sailor_ID = tonumber(boss_config.sailor_id)
        if sailor_ID < 1 then
            sailor_ID = 1
        end
        local icon = sailor_info[sailor_ID].res
        local scale = 0.4
        if sailor_info[sailor_ID].star >= 6 then
            scale = 0.15
        end
        local icon = display.newSprite(icon)
        icon:setPosition(ccp(0, 0))
        icon:setZOrder(50)
        item.boss_icon = icon
        icon:setScale(scale)
        return icon
	end
end

function ExplorePveItem:createShItem(strongholdId, pos, exploreLayer)
	local portPveData = getGameData():getPortPveData()
	local pveInfo = portPveData:getStrongHoldPveInfo(strongholdId)
	local cpInfo = portPveData:getStrongHoldCpInfo(strongholdId)
	local item = self:getItemFromPool(EX_PVE_TYPE_STRONGHOLD, pveInfo.status)
	if not item then return end
	
	item.item_id = strongholdId
	
	if tolua.isnull(item.name_bg) then
		local name_size = 5
		local len = commonBase:utfstrlen(cpInfo.name)
		if len < name_size then 
			item.name_bg = display.newSprite("#explore_name1.png", 0, -30)
		else
			item.name_bg = display.newSprite("#explore_name2.png", 0, -30)
		end
		item.spItem.ui:addChild(item.name_bg)
	end

	local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
	local config = pve_stronghold_info[strongholdId]

	if portPveData:isStrongHoldOpen(item.item_id) then
		if tolua.isnull(item.attack_btn) then
			local n_image = "#explore_pve1.png"
			local s_image = "#explore_pve2.png"
			local pos_y = 0
			local sailor_icon = nil
			local menu_scale = 0.7
			if config.boss_id and (config.boss_id > 0) then
				sailor_icon = self:createPirateIcon(item) --创建boss头像，boss为主线战役boss表的id
				n_image = "#explore_head_bg.png"
				s_image = "#explore_head_bg.png"
				pos_y = 40
				menu_scale = 1.0
			end
			local explore_layer = getExploreLayer()
			item.attack_btn = explore_layer:createButton({sound="",image = n_image, imageSelected= s_image, imageDisabled = "",x =0, y = pos_y})
			if sailor_icon then
				item.attack_btn:addChild(sailor_icon)
			end

			item.attack_btn:regCallBack(function()
				if self.is_pause then return end
				missionGuide:clearGuideLayer()
				--print("点击了")
			    plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				--EventTrigger(EVENT_EXPLORE_SHOW_STRONGHOLD_INFO, item.item_id)
				EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = item.item_id, navType = EXPLORE_NAV_TYPE_SH})
			end )
			local menuNode = CCNode:create()
			menuNode:addChild(item.attack_btn)
			menuNode:setScale(menu_scale)
			menuNode:setPosition(ccp(0, -23))
			item.spItem.ui:addChild(menuNode)
		else
			item.attack_btn:setVisible(true)
		end
	else
		if not tolua.isnull(item.attack_btn) then
			item.attack_btn:setVisible(false)
		end
	end

	if portPveData:isStrongHoldCool(item.item_id) then
		local cd = pveInfo.coolCD - os.time()
		local cdStr = nil
		if cd > 0 then
			item.cd = cd
			cdStr = dataTools:getTimeStr2(cd)
		else
			cdStr = ui_word.PVE_CP_SH_CD
		end

		if tolua.isnull(item.cdClockNode) then
			item.cdClockNode = CCNode:create()

			item.cdClockNode.bg = display.newSprite("#explore_time_bg.png", -3, 60)
			item.cdClockNode:addChild(item.cdClockNode.bg)

			item.cdClockNode.icon = display.newSprite("#explore_time.png", -65, 60)
			item.cdClockNode:addChild(item.cdClockNode.icon)

			item.cdClockNode.lb = createBMFont({text = cdStr, size = 18, fontFile = FONT_CFG_1, color=ccc3(dexToColor3B(COLOR_GREEN)), align=ui.TEXT_VALIGN_CENTER})
			item.cdClockNode.lb:setPosition(11, 62)
			item.cdClockNode.lb:setAnchorPoint(ccp(0.5,0.5))
			item.cdClockNode:addChild(item.cdClockNode.lb)

			item.spItem.ui:addChild(item.cdClockNode)
		else
			item.cdClockNode.lb:setString(cdStr)
			item.cdClockNode:setVisible(true)
		end

		if cd > 0 then
			item.cdTimerHandler = scheduler:scheduleScriptFunc(function()
			if not item or tolua.isnull(item.cdClockNode) then
				if item and item.cdTimerHandler then
					scheduler:unscheduleScriptEntry(item.cdTimerHandler)
					item.cdTimerHandler = nil
				end
				return
			end
			item.cd = item.cd - 1
			if item.cd <= 0 then
				if item.cdTimerHandler ~= nil then
					local portPveData = getGameData():getPortPveData()
					scheduler:unscheduleScriptEntry(item.cdTimerHandler)
					item.cdTimerHandler = nil
					if portPveData:isStrongHoldCool(item.item_id) then
						item.cdClockNode.lb:setString(ui_word.PVE_CP_SH_CD)
					else
						item.cdClockNode:setVisible(false)
					end
				end
			else
				item.cdClockNode.lb:setString(dataTools:getTimeStr2(item.cd))
			end
			end,1,false)
		end
	else
		if not tolua.isnull(item.cdClockNode) then
			item.cdClockNode:setVisible(false)
		end
	end

	if tolua.isnull(item.name_label) then
		item.name_label = createBMFont({text = cpInfo.name, size = 20, fontFile = FONT_TITLE, color=ccc3(dexToColor3B(COLOR_RED)), align=ui.TEXT_ALIGN_CENTER})
		item.name_label:setPosition(0, -23)
		item.spItem.ui:addChild(item.name_label)
	else
		item.name_label:setString(cpInfo.name)
	end

	item.spItem:setPos(pos.x, pos.y)
	item.spItem:setVisible(true)
	item.isOver = false
	item.outOfDistance = false
	self:unBrokenItem(item)

	return item
end

function ExplorePveItem:update(dt)  --刷新
	if self.item_pool == nil then
		return
	end

	local px, py = self.player_ship:getPos()

	for k, v in pairs(self.item_pool) do
		if not v.isOver then 
			v.spItem:update(dt) 
			
			local x, y = v.spItem:getPos()
			local dis = Math.distance(px, py, x, y) 
			local showDistance = 0
			if v.baseData.show_radius > 0 then
				showDistance = v.baseData.show_radius
			else
				showDistance = ITEM_VALID_DISTANCE
			end
			local shipPos = ccp(px, py)
			v.outOfDistance = false

			if dis > showDistance then -- 超出距离，释放事件
				v.outOfDistance = true
				self:releaseItem(v)
			elseif v.baseData.hit == 1 then -- 碰撞检测 
				
			end
		end 
	end 
end

function ExplorePveItem:brokenItem(item_data)
	item_data.isBroken = true
	item_data.spItem:broken()
end

function ExplorePveItem:unBrokenItem(item_data)
	item_data.isBroken = false
	item_data.spItem:unBroken()
end

function ExplorePveItem:releaseItem(item_data)
	EventTrigger(EVENT_EXPLORE_RELEASE_EVENT_PVE_ITEM, item_data)
end

function ExplorePveItem:pause(is_pause)
	local missionGuide = require("gameobj/mission/missionGuide")
	local curGuideMission = missionGuide:getCurGuideMission()
	if curGuideMission and curGuideMission.id == 12 then
		--兼容攻击巴塞罗那海上据点指引问题
		return
	end

	self.is_pause = is_pause

	local isEnable = true
	if is_pause then
		isEnable = false
	end
	for k,v in ipairs(self.item_pool) do
		if not v.isOver and not tolua.isnull(v.attack_btn) then
			v.attack_btn:setEnabled(isEnable)
		end
	end
end 

function ExplorePveItem:onExit()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	UnRegTrigger(EVENT_EXPLORE_RELEASE_EVENT_PVE_ITEM)
	self = nil
end

function ExplorePveItem:regFuns()

	local function evReleaseExplorePveItem(item_data)   --释放事件
		if tolua.isnull(self) then return end

		if item_data.isOver then
			return 
		end

		item_data.cd = 0

		if item_data.cdTimerHandler ~= nil then
			scheduler:unscheduleScriptEntry(item_data.cdTimerHandler)
			item_data.cdTimerHandler = nil
		end

		item_data.spItem.is_pause = false

		item_data.isOver = true
		item_data.spItem:setVisible(false)
		if not tolua.isnull(item_data.hp) then
			item_data.hp:setVisible(false)
		end
		if item_data.particle and item_data.spItem.node then
			item_data.particle:Stop()
			item_data.spItem.node:removeChild(item_data.particle:GetNode())
			item_data.particle = nil
		end
		
		if type(item_data.eventFuncEnd) == "function" and item_data.is_start then 
			item_data.eventFuncEnd(item_data) 
			item_data.is_start = false
		end	

	end
	
	RegTrigger(EVENT_EXPLORE_RELEASE_EVENT_PVE_ITEM, evReleaseExplorePveItem)
end 

return ExplorePveItem