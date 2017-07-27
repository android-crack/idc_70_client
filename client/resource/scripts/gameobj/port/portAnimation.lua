
require("gameobj/port/portFunc")
--港口的小人 和各种装饰
local PeopleSprite=require("gameobj/port/peopleSprite")
local relic_info = require("game_config/collect/relic_info")
local tool=require("module/dataHandle/dataTools")
local CompositeEffect=require("gameobj/composite_effect")
local effect_info=require("game_config/port/portEffect")
local CompositeEffect=require("gameobj/composite_effect")
local ui_word=require("scripts/game_config/ui_word")
local music_info=require("scripts/game_config/music_info")
local element_mgr = require("base/element_mgr")
local on_off_info = require("game_config/on_off_info")
local porAnimation={}

local auto_del_action = 1
local delay_time = 0.2

function porAnimation:mkPeople(target, portConfig, openInfo)   --小人和黑市商人
	target.peoples = {}
	target.manSprite = nil

	local portData = getGameData():getPortData()
	local peopleIds = portData:getPortPeople()

	local pointLen = #portConfig.people--配置表中小人数量
	local peopleLen = #peopleIds

	local gap = pointLen - peopleLen  --坐标点与小人数量的差异
	if gap > 0 then
		local peopleIds_= table.clone(peopleIds)
		for i = 1, gap do
			table.insert(peopleIds, peopleIds_[math.random(1, #peopleIds_)])
		end
	elseif gap < 0 then
		for i = 1, -gap do
			table.remove(peopleIds, math.random(1, #peopleIds))
		end
	end

	local key = 1
	local flipX = portData:getPortFlipX()

	for kP, id in ipairs(peopleIds) do
		local points = table.clone(portConfig.people[key])

		for i = 1, #points do
			if flipX == 1 then
				points[i][1] = display.right - points[i][1]
			end
		end

		local pLen = #points

		local x1, y1 = nil, nil   --起始点
		local x2, y2 = points[1][1], points[1][2]
		local direct = 0             --正方向
		local index = 1              --点索引
		local delay = nil            --暂停多久
        local people = PeopleSprite.new(tool:getPeople(id), points[1], points[2])
		people.firstFade = true

		target.spriteBg:addChild(people)
		
        local function turn(pos1,pos2)
            local oldX,oldY,newX,newY = x1,y1,x2,y2

            if pos1 and pos2 then 
                oldX, oldY, newX, newY = pos1[1], pos1[2], pos2[1], pos2[2]
            end
            
            if oldY < newY then
                people:runAction(people.reverseAnimation)
                if oldX < newX then
                    people:setFlipX(true)
                else
                    people:setFlipX(false)
                end
            else
                people:runAction(people.frontAnimation)
                if oldX < newX then
                    people:setFlipX(false)
                else
                    people:setFlipX(true)
                end
            end
            
        end
        
		local changePoint=nil
		changePoint = function()
			people:stopAllActions()

			delay = points[index][3]
			if direct == 0 then           --正向 反向 遍历
				local boolValue = (index == pLen)
				if boolValue then
					direct = 1
					index = pLen - 1
				else
					index = index + 1
				end
			else
				if index == 1 then
					direct = 0
					index = 2
				else
					index = index - 1
				end
			end
			x1,y1 = x2, y2
			x2,y2 = points[index][1], points[index][2]
            
			local function move()
				if y1 < y2 then
					people:runAction(people.reverseAnimation)
					if x1 < x2 then
						people:setFlipX(true)
					else
						people:setFlipX(false)
					end
				else
					people:runAction(people.frontAnimation)
					if x1 < x2 then
						people:setFlipX(false)
					else
						people:setFlipX(true)
					end
				end
				local moveTo = CCMoveTo:create(getTime(x1, y1, x2, y2), ccp(x2, y2))
				local callFunc = CCCallFuncN:create(changePoint)
				people:runAction(CCSequence:createWithTwoActions(moveTo,callFunc))
			end

			if delay then
				local arr = {}
				if delay == 0 and not people.firstFade then
					local function fadeOut()
						people:runAction(CCFadeOut:create(0.5))
						if not tolua.isnull(people.mark) then
							people.mark:runAction(CCFadeOut:create(0.5))
						end

						if not tolua.isnull(people.bubble) then
							people.bubble:runAction(CCFadeOut:create(0.5))
						end

						if not tolua.isnull(people.relic_button) then
							people.relic_button:setVisible(false)
							people.relic_button:setEnabled(false)
						end

						if not tolua.isnull(people.button) then
							people.button:setEnabled(false)
						end

						people.shade:runAction(CCFadeOut:create(0.5))
					end
					table.insert(arr, CCCallFuncN:create(fadeOut))
					table.insert(arr, CCDelayTime:create(5))
					local function fadeIn()
						if not tolua.isnull(people.mark) then
							people.mark:runAction(CCFadeIn:create(0.5))
						end

						if not tolua.isnull(people.bubble) then
							people.bubble:runAction(CCFadeIn:create(0.5))
						end

						if not tolua.isnull(people.relic_button) then
							people.relic_button:setVisible(target:getIsEnable())
							people.relic_button:setEnabled(target:getIsEnable())
						end

						if not tolua.isnull(people.button) then
							people.button:setEnabled(target:getIsEnable())
						end

						people.shade:runAction(CCFadeIn:create(0.5))
						people:runAction(CCFadeIn:create(0.5))
					end
					table.insert(arr, CCCallFuncN:create(fadeIn))
				else
					if people.firstFade then 
					    people.firstFade = false 
					end
					table.insert(arr, CCDelayTime:create(delay))
				end
				table.insert(arr, CCCallFuncN:create(move))
				people:runAction(transition.sequence(arr))
			else
				move()	
			end
		end
		
		local arr = {}
		if target.showEffect then
            if not tolua.isnull(people.mark) then
                people.mark:setOpacity(0)
                people.mark:runAction(CCFadeIn:create(0.5))
            end
			people.shade:setOpacity(0)
            people.shade:runAction(CCFadeIn:create(0.5))

			people:setOpacity(0)
			table.insert(arr, CCFadeIn:create(0.5))
		end
		table.insert(arr, CCCallFuncN:create(changePoint))
		people:runAction(transition.sequence(arr))

		table.insert(target.peoples, people)
		key = key + 1
	end
end

local armatureManager = CCArmatureDataManager:sharedArmatureDataManager()

function porAnimation:mkEffect(target,portConfig,openInfo)
	--target.effectArmature={}
	if self.effects then
		for k,v in pairs(self.effects) do
			if not tolua.isnull(v) then v:removeFromParentAndCleanup(true) end
		end
	end
	target.effects={}

	if portConfig.effect then
		for k,v in pairs(portConfig.effect) do
			local effect=effect_info[v.effectId]
			local sprite=nil
			if effect.effect then
				local armatureRes="effects/"..effect.effect..".ExportJson"
				table.insert(target.effectArmature,armatureRes)
				
				LoadArmature({armatureRes,})
				sprite=CCArmature:create(effect.effect)
				sprite:setPosition(ccp(getX(v.pos[1]),v.pos[2]))
				local armatureAnimation=sprite:getAnimation()
        		armatureAnimation:playByIndex(0)
        		target.spriteBg:addChild(sprite)
			elseif effect.anim then
				sprite=display.newSprite(nil,getX(v.pos[1]),v.pos[2])
				target.spriteBg:addChild(sprite)
				sprite:runAction(CCRepeatForever:create(getAnimate(effect.anim.res,effect.anim.count,0.1)))
			end
			sprite:setZOrder(0)
			sprite:setScale(portConfig.scale/100)
			target.effects[#target.effects+1]=sprite
		end
	end
end

local function showDialogIcon()
	--print(debug.traceback())
	local sp = display.newSprite("#common_dialog.png")

    local portData = getGameData():getPortData()
    local port_id = portData:getPortId()

	local boatData = getGameData():getBoatData()
	local black_shop_status = boatData:getAllBlackShopStatus()
	--local black_shop_list = boatData:getBlackShopIdList()

	local is_black_shop_port = boatData:isInBlackPort()

	local onOffData = getGameData():getOnOffData()
	local open = onOffData:isOpen(on_off_info.PORT_SHIPYARD.value)
	local ClsStoreList = getUIManager():get("ClsStoreList")

	if black_shop_status ~= 0 and is_black_shop_port and open and tolua.isnull(ClsStoreList) then--
		local port_layer = getUIManager():get("ClsPortLayer")
		local black_shop_btn = port_layer:createButton({sound = music_info.COMMON_CLOSE.res,image = "#common_icon_coin.png", imageSelected = "#common_icon_coin.png", x = 24, y = 30,unSelectScale = 0.4, selectScale = 0.4})
		black_shop_btn:setScale(0.4)
		black_shop_btn:regCallBack( function()
			--black_shop_btn:setScale(0.3)
			black_shop_btn:setEnabled(false)
			local player_data = getGameData():getPlayerData()
			if( player_data:getLevel() < OPEN_BLACK_STORE_LEVEL)then
				require("ui/tools/alert"):showAttention(ui_word.BLACKMARKET_NEED_LEVEL_TIP, nil, nil, nil, {ok_text = ui_word.MAIN_OK, hide_cancel_btn = true})
			else
				local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
				missionSkipLayer:skipLayerByName("shipyard_shop")
			end
		end)
		local sp_size = sp:getContentSize()
		black_shop_btn:setPosition(ccp(sp_size.width / 2,sp_size.height / 2))

		local effect_tx = "tx_qipao_faguang"
		local effect_light = nil 
		if not effect_light and tolua.isnull(effect_light) then
			effect_light = CompositeEffect.new(effect_tx, 25, 24, black_shop_btn)
		end		
		sp:addChild(black_shop_btn,1)

		sp:setCascadeColorEnabled(true)
		sp:setCascadeOpacityEnabled(true)
		local actions = CCArray:create()
		actions:addObject(CCCallFunc:create(function() 
			local ClsStoreList = getUIManager():get("ClsStoreList")
			if not tolua.isnull(ClsStoreList) then
				black_shop_btn:setVisible(false)
				--effect_light:setVisible(false)
			else
				black_shop_btn:setVisible(true)
				--effect_light:setVisible(true)	
			end

		end))
		local action = CCSequence:create(actions)
		sp:runAction(CCRepeatForever:create(action))

	else
		local p1 = display.newSprite("#common_dialog_point.png", 14, 30)
		local p2 = display.newSprite("#common_dialog_point.png", 24, 30)
		local p3 = display.newSprite("#common_dialog_point.png", 34, 30)
		sp:setCascadeColorEnabled(true)
		sp:setCascadeOpacityEnabled(true)
		sp:addChild(p1)
		sp:addChild(p2)
		sp:addChild(p3)
		
		local ani_tick = 0.4
		local actions = CCArray:create()
		actions:addObject(CCCallFunc:create(function() 
			p1:setVisible(true)
			p2:setVisible(true)
			p3:setVisible(true)
		end))
		actions:addObject(CCDelayTime:create(ani_tick))
		actions:addObject(CCCallFunc:create(function() 
			p1:setVisible(false)
			p2:setVisible(false)
			p3:setVisible(false)
		end))
		actions:addObject(CCDelayTime:create(ani_tick))
		actions:addObject(CCCallFunc:create(function()
			p1:setVisible(true)
		end))
		actions:addObject(CCDelayTime:create(ani_tick))
		actions:addObject(CCCallFunc:create(function()
			p2:setVisible(true)
		end))
		actions:addObject(CCDelayTime:create(ani_tick))
		local action = CCSequence:create(actions)
		sp:runAction(CCRepeatForever:create(action))	
	end

	return sp
end

--与小人的对话
function porAnimation:mkNPCBubble(target, portConfig)
	self.index_people = 0 --当前有气泡的小人索引
	self.talk_mark = false  --当前是否有对话内容显示
	local last_people = 0

	local peoplers = #portConfig.people
	local bubble_node = nil
	local array = CCArray:create() --每过5秒,随机到一个小人, 显示气泡
	array:addObject(CCDelayTime:create(0.01)) --为了一开始进入港口时，等待小人的“出现”
	array:addObject(CCCallFunc:create(function() --创建气泡
		if not tolua.isnull(bubble_node) then
			bubble_node:removeFromParentAndCleanup(true)
		end

		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		last_people = self.index_people
		if self.relic_people_index then
			self.index_people = math.random(peoplers)
			while(self.index_people == self.relic_people_index)
			do
				self.index_people = math.random(peoplers)
			end
		else
			self.index_people = math.random(peoplers)
		end
		
		if tolua.isnull(target.peoples[self.index_people]) then return end
		if (target.peoples[self.index_people]:getOpacity() ~= 255) then --解决小人还没出来，但气泡已经冒出来了
			self.index_people = last_people 
			return
		end

		if not tolua.isnull(target.spriteBg.talk_node) then --解决有弹出提示内容，还会有气泡冒出他本人
			if target.spriteBg.talk_node:getTag() == self.index_people then
				self.index_people = last_people
				return
			end
		end

		local size_peopler = target.peoples[self.index_people]:getContentSize() 
		bubble_node = showDialogIcon()
		bubble_node:setPosition(ccp(0, size_peopler.height + 10))
		if (target.peoples[self.index_people]:getOpacity() ~= 255) then --解决小人还没出来，但气泡已经冒出来了
			self.index_people = last_people
			return
		end

		target.peoples[self.index_people]:addChild(bubble_node)
		target.peoples[self.index_people].bubble = bubble_node

		if last_people ~= 0 then --解决小人已有气泡的时候，有其它小人会踩到那气泡
			if last_people == self.index_people then return end
			local last_ZOrder = target.peoples[last_people]:getZOrder()
			local current_ZOrder = target.peoples[self.index_people]:getZOrder()
			target.peoples[last_people]:setZOrder(current_ZOrder)
			target.peoples[self.index_people]:setZOrder(last_ZOrder)
		else
			local current_ZOrder = target.peoples[self.index_people]:getZOrder()
			target.peoples[self.index_people]:setZOrder(current_ZOrder + 1)
		end
	end))
	array:addObject(CCDelayTime:create(5))
	local action = CCRepeatForever:create(CCSequence:create(array))
	-- action:setTag(bubble_action)
	target:runAction(action)

	local array = CCArray:create() --每过40秒，若无人为显示对话内容，则自动显示
	array:addObject(CCDelayTime:create(40))
	array:addObject(CCCallFunc:create(function()
		if not target:getIsEnable() then
			self.talk_mark = false
			return
		end
		if not self.talk_mark then
			self:mkTalkContent(target, portConfig, self.index_people)
		end
		self.talk_mark = false
	end))
	local action = CCRepeatForever:create(CCSequence:create(array))
	target:runAction(action)
end

function porAnimation:mkRelicMissionIcon(target, port_config)
	if self.relic_people_index then return end
	local people_num = #port_config.people
	self.relic_people_index = math.random(people_num)
	while(self.relic_people_index == self.index_people)
	do
		self.relic_people_index = math.random(people_num)
	end
	if not target.peoples then cclog("小人没了") return end
	
	local select_people = target.peoples[self.relic_people_index]
	local people_size = select_people:getContentSize()
	local port_layer = getUIManager():get("ClsPortLayer")
	local relic_tip_sp = port_layer:createButton({image = "#main_ruins.png"})
	relic_tip_sp:regCallBack(function()
		select_people.relic_button:setEnabled(false)
		if target:getIsEnable() then
			local collect_data = getGameData():getCollectData()
			local port_data = getGameData():getPortData()
		    local port_id = port_data:getPortId() --当前港口id
		    local mission_relic_id = collect_data:getRelicIdByPortId(port_id)
			collect_data:askAcceptRelicMission(mission_relic_id)
		else
			select_people.relic_button:setEnabled(true)
		end
	end)
	select_people:addChild(relic_tip_sp)
	relic_tip_sp:setPosition(ccp(people_size.width / 2, people_size.height + 10))
	select_people.relic_button = relic_tip_sp
end

function porAnimation:delRelicMissionIcon(target)
	if self.relic_people_index then
		local have_icon_people = target.peoples[self.relic_people_index]
		self.relic_people_index = nil
		if not tolua.isnull(have_icon_people) and not tolua.isnull(have_icon_people.relic_button) then
			have_icon_people.relic_button:removeFromParentAndCleanup(true)
		end
	end
end

function porAnimation:mkNPCTalk(target, portConfig)
	for index, people in pairs(target.peoples) do
		local port_layer = getUIManager():get("ClsPortLayer")
		local btn_node = port_layer:createButton({image = "#common_9_white.png", isNeedVoiceEffect = false})
		btn_node:setScale(3)
		people:addChild(btn_node)
		people.button = btn_node
		btn_node:setButtonOpacity(0)
		local size_people = people:getContentSize()
		btn_node:setPosition(ccp(size_people.width / 2, size_people.height / 2))
		btn_node:regCallBack(function()
			people.button:setEnabled(false)
			if target:getIsEnable() then
				audioExt.playEffect(music_info.NPC_TIPS_CLOSED.res)
				if self.relic_people_index then
					local have_icon_people = target.peoples[self.relic_people_index]
					if not tolua.isnull(have_icon_people.relic_button) then
						have_icon_people.relic_button:setEnabled(false)
					end
				end
				self:mkTalkContent(target, portConfig, index)
			else
				people.button:setEnabled(true)
			end
		end)
	end
end

local tab_talk = {}

function porAnimation:mkTalkContent(target, portConfig, index)
	if tolua.isnull(target.peoples[index]) then return end
	local people = target.peoples[index]
	local z_people = people:getZOrder()
	if people:getOpacity() == 0 then
		return
	end

	self.talk_mark =  true
	
	local actionMgr = CCDirector:sharedDirector():getActionManager()

	local delContent = function()
		if self.relic_people_index then
			local have_icon_people = target.peoples[self.relic_people_index]
			if not tolua.isnull(have_icon_people) and not tolua.isnull(have_icon_people.relic_button) then
				have_icon_people.relic_button:setEnabled(target:getIsEnable())
			end
		end
		for i, spr in pairs(tab_talk) do
			if not tolua.isnull(spr) then
				local array = CCArray:create()
				array:addObject(CCEaseBackIn:create(CCScaleTo:create(delay_time, 0)))
				array:addObject(CCDelayTime:create(delay_time + 0.1))
				array:addObject(CCCallFunc:create(function()
					target.spriteBg.talk_node:removeFromParentAndCleanup(true)
					actionMgr:resumeTarget(target.peoples[i])
					for _, people in pairs(target.peoples) do
						people.button:setEnabled(target:getIsEnable())
					end
				end))
				spr:runAction(CCSequence:create(array))
				actionMgr:removeActionByTag(auto_del_action, target)
				return
			end
		end
	end

	local showContent = function()
		for i, spr in pairs(tab_talk) do
			if not tolua.isnull(spr) then 
				audioExt.playEffect(music_info.NPC_TIPS_CLOSED.res)
				local array = CCArray:create()
				array:addObject(CCEaseBackIn:create(CCScaleTo:create(delay_time, 0)))
				array:addObject(CCDelayTime:create(delay_time + 0.1))
				array:addObject(CCCallFunc:create(function()
					target.spriteBg.talk_node:removeFromParentAndCleanup(true)
					actionMgr:resumeTarget(target.peoples[i])
					for _, people in pairs(target.peoples) do
						people.button:setEnabled(target:getIsEnable())
					end
				end))
				spr:runAction(CCSequence:create(array))
				actionMgr:removeActionByTag(auto_del_action, target)
				return
			end
		end

		if not tolua.isnull(people.bubble) then
			people.bubble:setVisible(false)
		end
	
		local spr_talk_bg = display.newSprite("#common_npc_tips.png")
		spr_talk_bg:setOpacity(200)
		
		local size_talk_bg = spr_talk_bg:getContentSize()
		
		local port_info = require("game_config/port/port_info")
		local portData = getGameData():getPortData()
		local portId = portData:getPortId()
		if portId == nil then
			return 
		end
		local tab_talk_content = port_info[portId]["chat" .. index]
		local str_talk_content = ui_word.PORT_NO_TALK
		if type(tab_talk_content) == "table" then
			str_talk_content = tab_talk_content[math.random(#tab_talk_content)]
		end

		local lbl_talk_content = createBMFont({text = str_talk_content, width = size_talk_bg.width - 20,
								fontFile = FONT_COMMON,color = ccc3(dexToColor3B(COLOR_BROWN)), size = 14, x = size_talk_bg.width / 2, y = 10 + (size_talk_bg.height - 10) / 2})
 		
		local layer = CCLayer:create()
		layer:setTouchEnabled(false) 
		local port_layer = getUIManager():get("ClsPortLayer")
		port_layer:regTouchEvent(layer, function(event, x, y)
			if event == "began" then
				layer:setTouchEnabled(false)  
				for _, people in pairs(target.peoples) do
					people.button:setEnabled(false)
				end
				audioExt.playEffect(music_info.NPC_TIPS_CLOSED.res) 
				delContent()
				return false
			end
		end)
		layer:addChild(spr_talk_bg)
		target.spriteBg:addChild(layer, 2)
		target.spriteBg.talk_node = layer
		target.spriteBg.talk_node:setTag(index)


		local size_people = people:getContentSize()
		
		local pos_people = ccp(people:getPositionX(), people:getPositionY())
		local baselineY = display.height - 200

		if pos_people.x <= display.cx and pos_people.y <= baselineY then --控制文本框的方向以及坐标 左下
			spr_talk_bg:setAnchorPoint(ccp(0, 0))
			spr_talk_bg:setPosition(ccp(pos_people.x - 20, pos_people.y + 10))
		elseif pos_people.x <= display.cx and pos_people.y > baselineY then --左上
			spr_talk_bg:setFlipY(true)
			spr_talk_bg:setAnchorPoint(ccp(0, 1))
			spr_talk_bg:setPosition(ccp(pos_people.x - 20, pos_people.y - 10))
			lbl_talk_content:setPosition(ccp(size_talk_bg.width / 2, (size_talk_bg.height - 10) / 2))
		elseif pos_people.x > display.cx and pos_people.y <= baselineY then  --右下
			spr_talk_bg:setFlipX(true)
			spr_talk_bg:setAnchorPoint(ccp(1, 0))
			spr_talk_bg:setPosition(ccp(pos_people.x + 20,pos_people.y + 10))
		elseif pos_people.x > display.cx and pos_people.y > baselineY then --右上
			spr_talk_bg:setFlipX(true)
			spr_talk_bg:setFlipY(true)
			spr_talk_bg:setAnchorPoint(ccp(1, 1))
			lbl_talk_content:setPosition(ccp(size_talk_bg.width / 2, (size_talk_bg.height - 10) / 2))
			spr_talk_bg:setPosition(ccp(pos_people.x + 20, pos_people.y - 10))
		end

		spr_talk_bg:addChild(lbl_talk_content)
		tab_talk[index] = spr_talk_bg

		actionMgr:pauseTarget(people)
		spr_talk_bg:setScale(0)
		local action = CCArray:create()
		action:addObject(CCEaseBackOut:create(CCScaleTo:create(delay_time, 1)))
		action:addObject(CCDelayTime:create(delay_time + 0.1))
		action:addObject(CCCallFunc:create(function()
			people.button:setEnabled(target:getIsEnable())
			layer:setTouchEnabled(target:getIsEnable())
		end))
		spr_talk_bg:runAction(CCSequence:create(action))
	end

	local array = CCArray:create() --5秒之后，自动消失对话框
	array:addObject(CCCallFunc:create(function()
		showContent()
	end))

	array:addObject(CCDelayTime:create(5))  
	array:addObject(CCCallFunc:create(function()
		delContent()
	end))

	local actions = CCSequence:create(array)
	actions:setTag(auto_del_action)
	if not target:getActionByTag(auto_del_action) then
		target:runAction(actions) 
	else
		delContent()
	end
end	

return porAnimation
