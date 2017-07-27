
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert") 
local CompositeEffect = require("gameobj/composite_effect")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local recruit_item_effect = require("scripts/game_config/recruit_item_effect")
local sailor_info = require("game_config/sailor/sailor_info")
local voice_info = getLangVoiceInfo()
local scheduler = CCDirector:sharedDirector():getScheduler()
local ClsBaseView = require("ui/view/clsBaseView")


local clsSailorRecruitView = class("clsSailorRecruitView", ClsBaseView)

local HONOUR_RECRUIT = 1
local GOLD_RECRUIT  = 2
local HONOUR_RECRUIT_ONCE_COST = 50
local GOLD_RECRUIT_FIVE_COST  = 888
local CARD_NUM = 5
local SAILOR_C_STAR = 3
local SAILOR_B_STAR = 4
local SAILOR_A_STAR = 5
local SAILOR_S_STAR = 7

local widget_name ={
	"all_open_btn",
	"treat_more_btn",
	"close_btn",
	"more_diamond_icon",
	"more_diamond_num",
	"more_wine_icon",
	"more_wine_num",
	"cost_txt",
	"all_open_btn_panel",
	"treat_more_btn_panel",
}

local card_name = {
	"card_panel",
	"card_back",
	"card_sailor",
	"card_item",
	"card_reward",
}

local sailor_widget = {
	"sailor_pic",
	"sailor_lv",
	"sailor_job",
	"sailor_name",
	"star_1",
	"star_2",
	"star_3",
	"star_4",
	"star_5",
}

local item_info = {
	"item_icon",
	"item_name",
}

local full_reward = {
	"item_icon1",
	"item_icon2",
	"item_name1",
	"item_name2",
}

local pos = {
	[1] = {ccp(480,750),ccp(114,300)},
	[2] = {ccp(480,750),ccp(297,300)},
	[3] = {ccp(480,750),ccp(480,300)},
	[4] = {ccp(480,750),ccp(663,300)},
	[5] = {ccp(480,750),ccp(846,300)},
}


local move_x_pos = {
	[1] = 114,
	[2] = 297,
	[3] = 480,
	[4] = 663,
	[5] = 846,
}

---type：荣誉招募和金币招募

function clsSailorRecruitView:onEnter(type)
	self.is_open_sailor_mission_view= {}
	self.plist = {
		 ["ui/hotel_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.is_have_card = false
	self.type = type
	self:initBgView()
end

function clsSailorRecruitView:initBgView()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_treat_scene.json")
 	self:addWidget(self.panel)

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)	
	end

	self:initView()
end

function clsSailorRecruitView:initView()

	if self.is_have_card then
		return 
	end

	for i=1,CARD_NUM do
		self["card_"..i] = GUIReader:shareReader():widgetFromJsonFile("json/hotel_card.json")	
		self["card_"..i]:setZOrder(10)
		self:addWidget(self["card_"..i])
		for k,v in pairs(card_name) do
			self[v..i] = getConvertChildByName(self["card_"..i], v)
			self[v..i]:setScale(0.55)
		end
	end	
	self.is_have_card = true
	self.treat_more_btn:setTouchEnabled(false)
	self.all_open_btn:setTouchEnabled(false)
	self:setPanelVisible(true)
	self:setBtnZOrder()
	missionGuide:pushGuideBtn(on_off_info.TOKEN_ALLOPEN.value, {guideBtn=self.all_open_btn, guideLayer=self, x=345, y=110})
	-- self.more_wine_num:setVisible(false)
	-- self.more_diamond_num:setVisible(false)
	-- self.more_diamond_icon:setVisible(false)
	-- self.more_wine_icon:setVisible(false)

	self.num_list = {}
	self:createBackCard()
	self:createFrontCard()
	self:btnCallBack()
	self:updataItemNum()
end

function clsSailorRecruitView:setPanelVisible(enable)
	self.all_open_btn_panel:setVisible(enable)
	self.treat_more_btn_panel:setVisible(not enable)
end


function clsSailorRecruitView:setBtnZOrder()
	self.treat_more_btn:setZOrder(10)
	self.all_open_btn:setZOrder(10)
	self.close_btn:setZOrder(10)
	self.more_diamond_icon:setZOrder(10)
	self.more_wine_icon:setZOrder(10)
	self.cost_txt:setZOrder(10)	
end

---金币是否足够
function clsSailorRecruitView:isGoldEnough(cost)
	local playerData = getGameData():getPlayerData()
	if playerData:getGold() >= cost then
		return true
	else
		return false
	end	
end

---荣誉是否足够
function clsSailorRecruitView:isHonourEnough(cost)
	local playerData = getGameData():getPlayerData()
	if playerData:getHonour() >= cost then
		return true
	else
		return false
	end	
end

function clsSailorRecruitView:cleanView()
	for i=1,CARD_NUM do
		if self["card_"..i] and not tolua.isnull(self["card_"..i]) then
			self["card_"..i]:removeFromParentAndCleanup(true)
			self["card_"..i] = nil 
		end

		if self["backCard_"..i] and not tolua.isnull(self["backCard_"..i]) then
			self["backCard_"..i]:removeFromParentAndCleanup(true)
			self["backCard_"..i] = nil 			
		end
	end
	self.is_have_card = false
	local sailorData = getGameData():getSailorData()
	sailorData:clearRecruitSailorReward()
end

function clsSailorRecruitView:btnCallBack()
	----全翻
	self.all_open_btn:setPressedActionEnabled(true)
	self.all_open_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self.all_open_btn:setTouchEnabled(false)
        self.treat_more_btn:setTouchEnabled(false)
        self.is_more_treat = false
        self:turnTheCard(1,true)
	end,TOUCH_EVENT_ENDED)

	----再来一次
	self.treat_more_btn:setPressedActionEnabled(true)
	self.treat_more_btn:addEventListener(function ()
		self.treat_more_btn:setTouchEnabled(false)
	end,TOUCH_EVENT_BEGAN)

	self.treat_more_btn:addEventListener(function ()
		self.treat_more_btn:setTouchEnabled(true)
	end,TOUCH_EVENT_CANCELED)

	self.treat_more_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)		
		self.treat_more_btn:setTouchEnabled(false)
		self.close_btn:setTouchEnabled(false)
		self.all_open_btn:setTouchEnabled(false)
		self.is_more_treat = true
		if self:isFullTurn() and self.is_more_treat then
			self:moreTreatCallBack()
		else
			self:turnTheCard(1,true)				
		end
	end,TOUCH_EVENT_ENDED)

	----关闭
	self.close_btn:setVisible(false)
	self.close_btn:setPressedActionEnabled(true)
	self.close_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		local clsSailorRecruit = getUIManager():get("clsSailorRecruit") 
		if not tolua.isnull(clsSailorRecruit) then				
			clsSailorRecruit:setBtnTouch(true)
		end
		self:close()
		local is_first = getGameData():getSailorData():isFristASailor()
		if is_first then
			getUIManager():create("gameobj/sailor/clsSailorFristTips")
		end
	end,TOUCH_EVENT_ENDED)
end

function clsSailorRecruitView:moreTreatCallBack()

	self.close_btn:setVisible(false)	
	if self.type == HONOUR_RECRUIT then
		local isfull = self:isHonourEnough(HONOUR_RECRUIT_ONCE_COST)
		if not isfull then
			local alertType = Alert:getOpenShopType()
			Alert:showJumpWindow(HONOUR_NOT_ENOUGH, self)

			self.close_btn:setVisible(true)
			self.close_btn:setTouchEnabled(true)
			return
		end
	else
		local isfull = self:isGoldEnough(GOLD_RECRUIT_FIVE_COST)
		if not isfull then
			local alertType = Alert:getOpenShopType()
			Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self, {need_gold = GOLD_RECRUIT_FIVE_COST, come_type = alertType.VIEW_NORMAL_TYPE})
			self.treat_more_btn:setTouchEnabled(true)
			self.close_btn:setVisible(true)
			self.close_btn:setTouchEnabled(true)
			return
		end
	end

	local function cleanViewCB()
		self:cleanView()
	end
	local array = CCArray:create()
	array:addObject(CCCallFunc:create(cleanViewCB))
	local function recruitCB()
		local sailorData = getGameData():getSailorData()				
        if self.type == HONOUR_RECRUIT then
        	sailorData:sailorHonourRecruit() ---荣誉招募
		else
			sailorData:sailorDiamondRecruit() ---钻石招募
    	end
    	sailorData:getSailorFreeRecruitInfo()			
	end
	array:addObject(CCDelayTime:create(1.0))
	array:addObject(CCCallFunc:create(recruitCB))
    self:runAction(CCSequence:create(array))
end

function clsSailorRecruitView:createBackCard()
	for i=1,CARD_NUM do  	   
		self["backCard_"..i] = self["card_back"..i]
		self["backCard_"..i]:setPosition(pos[i][1]) 
		self["backCard_"..i].isfull = false
		self["backCard_"..i]:addEventListener(function()
			self["backCard_"..i]:setScale(0.55)
			self["backCard_"..i]:setTouchEnabled(false)
			self:turnTheCard(i,false)
		end, TOUCH_EVENT_ENDED)   
	end

	self:createMoveCard(1)	
end

function clsSailorRecruitView:createFrontCard()

	for i=1,CARD_NUM do
		self["card_item"..i]:setPosition(pos[i][2])
		self["card_item"..i]:setVisible(false)
	end

	for i=1,CARD_NUM do   ---满星奖励
		self["card_reward"..i]:setPosition(pos[i][2])
		self["card_reward"..i]:setVisible(false)
	end

	for i=1,CARD_NUM do   ----航海士
		self["card_sailor"..i]:setPosition(pos[i][2])
		self["card_sailor"..i]:setVisible(false)
		self["card_sailor"..i]:addEventListener(function ()
			self.all_open_btn:setTouchEnabled(false)
			self.treat_more_btn:setTouchEnabled(false)
			local sailorData = getGameData():getSailorData()
			local ownSailors = sailorData:getOwnSailors()
			local rewardInfo = sailorData:getRecruitSailorInfo()
			local sailor = ownSailors[rewardInfo[i].id]
			if sailor.sex == SEX_F then
				audioExt.playEffect(voice_info["VOICE_PLOT_1008"].res, false)
			else
				audioExt.playEffect(voice_info["VOICE_PLOT_1006"].res, false)
			end
		
			--getUIManager():create("gameobj/sailor/clsShowSailorInfoView", {}, rewardInfo[i].id)
			getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor,nil,nil,true)
		end, TOUCH_EVENT_ENDED)
	end		
end

function clsSailorRecruitView:createMoveCard(num)
	if not self.black_layer and tolua.isnull(self.black_layer) then
		self.black_layer = CCLayerColor:create(ccc4(0,0,0,120))
		self.black_layer:setContentSize(CCSize(display.width,display.height))
		self.black_layer:setZOrder(1)
		self.panel:addCCNode(self.black_layer)
	end

	if num > CARD_NUM then
		for i=1,CARD_NUM do
			self["backCard_"..i]:setTouchEnabled(true)
		end
		self.all_open_btn:setTouchEnabled(true)
		self.treat_more_btn:setTouchEnabled(true)
		self.close_btn:setTouchEnabled(true)
		return
	end
	if num <= CARD_NUM then
	 	audioExt.playEffect(music_info.HOTEL_CARD_DEAL.res)
		local move = CCMoveTo:create(0.15,pos[num][2])
		local rotate = CCRotateBy:create(0.1,20)
		local array = CCArray:create()
		array:addObject(CCSpawn:createWithTwoActions(move,rotate))
		array:addObject(CCRotateBy:create(0.1,-20))

		array:addObject(CCCallFunc:create(function (  )
			local sailorData = getGameData():getSailorData()
			local ownSailors = sailorData:getOwnSailors()
			local reward_list = sailorData:getRecruitSailorInfo()
			local effect_tx
			if reward_list and reward_list[num] then
				if reward_list[num]["type"] == ITEM_INDEX_SAILOR then
					local sailor_id = reward_list[num].id
					local sailor_star = sailor_info[sailor_id].star
					if sailor_star == SAILOR_B_STAR then
						 effect_tx = "tx_0138purple"
					elseif sailor_star >= SAILOR_A_STAR then
						 effect_tx = "tx_0138orange"
					else
					end
				else
					local item_count = reward_list[num].amount
					local item_id = reward_list[num].id 
					if recruit_item_effect[item_id] and item_count == recruit_item_effect[item_id].count then
						effect_tx = recruit_item_effect[item_id].effect_id					
					end
				end
			end

			if effect_tx then
				local effect_bg = CompositeEffect.new(effect_tx, 0, 0, self["card_panel"..num], nil, nil, nil, nil, true)
				effect_bg:setScale(1.5)
				self["card_panel"..num]:setPosition(pos[num][2])
				self["card_panel"..num]:setVisible(true)
			end

			if not tolua.isnull(self["backCard_"..num]) then 
				self["backCard_"..num]:setPosition(pos[num][2])
			end

		end))

		local function animationCB()
			num = num + 1
			self:createMoveCard(num)	
		end

		array:addObject(CCCallFunc:create(animationCB))	    
		self["backCard_"..num]:runAction(CCSequence:create(array))   
		self.close_btn:setTouchEnabled(false)   
	end
end

local effect_tab = {
	"tx_0133_green", -- e
	"tx_0133_green", -- d
	"tx_0133_blue",  --c
	"tx_0133_purple", --b
	"tx_0133_orange",  --a
	"tx_0133_orange",  --s
	"tx_0133_orange",
}

function clsSailorRecruitView:shakeScene()

	local runScene = GameUtil.getRunningScene()	
	local array = CCArray:create()
	array:addObject(CCMoveBy:create(0.05, ccp(0,3)))
	array:addObject(CCMoveBy:create(0.05, ccp(-3,0)))
	array:addObject(CCMoveBy:create(0.05, ccp(0,-3)))
	array:addObject(CCMoveBy:create(0.05, ccp(3,0)))
	array:addObject(CCCallFunc:create(function ()
		runScene:setPosition(ccp(0,0))
	end))
	local actionc = CCRepeat:create(CCSequence:create(array), 3)
	runScene:runAction(actionc) 
end

function clsSailorRecruitView:turnTheCard(num, is_all)
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()
	local reward_list = sailorData:getRecruitSailorInfo()
	local reward_full_list = sailorData:getRecruitSailorReward()


	if is_all then
		for i=1,CARD_NUM do
			if self["backCard_"..i] then
				self["backCard_"..i]:setTouchEnabled(false)
			end
		end
	end
	local array = CCArray:create()
	if self["backCard_"..num] and not self["backCard_"..num].isfull then   ---判断是否翻牌
		audioExt.playEffect(music_info.HOTEL_CARD_FLOP.res)
		local effect_res = "tx_0153"
		if reward_list[num]["type"] == ITEM_INDEX_SAILOR then
			local sailor_id = reward_list[num].id
			effect_res = effect_tab[sailor_info[sailor_id].star]
			if sailor_info[sailor_id].star > SAILOR_C_STAR then
				self:shakeScene()
			end
		end
		array:addObject(CCCallFunc:create(function()
			self["backCard_"..num]:setVisible(false)
			self["card_panel"..num]:setVisible(true)
			local ccp = pos[num][2]
			local effect = CompositeEffect.new(effect_res, ccp.x, ccp.y, self, nil, nil, nil, nil)
		end))
		array:addObject(CCDelayTime:create(0.4))

		local function animationCB()
			if reward_list[num]["type"] == ITEM_INDEX_SAILOR  then
				self["card_sailor"..num]:setVisible(true)
				self["card_sailor"..num]:setScale(0.65)
				self["card_sailor"..num]:runAction(CCScaleTo:create(0.1, 0.55, 0.55))

				if is_all then
					self["card_sailor"..num]:setTouchEnabled(false)
				else
					self["card_sailor"..num]:setTouchEnabled(true)
				end
				self:createSailorCard(num)

			else
				self["card_item"..num]:setVisible(true)
				self["card_item"..num]:setScale(0.65)
				self["card_item"..num]:runAction(CCScaleTo:create(0.1, 0.55, 0.55))	
				self:createItemCard(num)

			end	    	
		end
		array:addObject(CCCallFunc:create(animationCB))

		if not is_all and reward_list[num]["type"] == ITEM_INDEX_SAILOR then
			local sailor_id = reward_list[num].id
			if not reward_full_list[sailor_id] then
				array:addObject(CCDelayTime:create(0.4))
				array:addObject(CCCallFunc:create(function ( )
					getUIManager():create("gameobj/sailor/clsSailorWineRecruit",{},sailor_id,true)	
								
				end))
			end
		end	

		local sailor_id = reward_list[num].id 
		if reward_list[num]["type"] == ITEM_INDEX_SAILOR and reward_full_list[sailor_id] then
			if not is_all then
				array:addObject(CCDelayTime:create(1.4))
				local function sailorFadeOutCB()
					self["card_sailor"..num]:setScale(0.55)		    	
					self["card_sailor"..num]:runAction(CCFadeOut:create(0.1))
					self["card_sailor"..num]:setVisible(false)		    		    		
				end
				array:addObject(CCCallFunc:create(sailorFadeOutCB))
				array:addObject(CCDelayTime:create(0.05)) 
				local function itemFadeInCB()
					self["card_item"..num]:setVisible(true)
					self["card_item"..num]:runAction(CCFadeIn:create(0.1))
					self:createRewardItemCard(num)	    		
				end
				array:addObject(CCCallFunc:create(itemFadeInCB))
				array:addObject(CCCallFunc:create(function ()
					local effect = "tx_0137"
					local ccp = pos[num][2]
					local effect = CompositeEffect.new(effect, ccp.x, ccp.y, self, nil, nil, nil, nil)
				end))

			else
				self.num_list[#self.num_list + 1] = num
			end
		end

		self["backCard_"..num].isfull = true
	end

	if is_all then   ----连翻
		if num < 6 then
			if reward_list[num]["type"] == ITEM_INDEX_SAILOR then
				local sailor_id = reward_list[num].id
				local is_show_view = self:isShowTaskView(sailor_id)
				if is_show_view and not self.is_open_sailor_mission_view[sailor_id] then
					array:addObject(CCDelayTime:create(0.05))
				else
					local function callBack()
						num = num+1
						self:turnTheCard(num, is_all)	
					end
					array:addObject(CCDelayTime:create(0.05))
					array:addObject(CCCallFunc:create(callBack))
				end
			else
				local function callBack()
					num = num+1
					self:turnTheCard(num, is_all)	
				end
				array:addObject(CCDelayTime:create(0.05))
				array:addObject(CCCallFunc:create(callBack))
			end
		else
			local function callBack()
				num = num+1
				self:turnTheCard(num, is_all)	
			end
			array:addObject(CCDelayTime:create(0.05))
			array:addObject(CCCallFunc:create(callBack))
		end				
	end

	if self:isFullTurn() then
		self.close_btn:setVisible(true)
		self.all_open_btn:setTouchEnabled(false)
	   	self.treat_more_btn:setTouchEnabled(not self.is_more_treat)
	   	self:setPanelVisible(false)
	end

	if num <= CARD_NUM then
		self["backCard_"..num]:runAction(CCSequence:create(array))
	else
		self:fullStarRewardCard(1)
	end

	if not is_all then
		self.treat_more_btn:setTouchEnabled(true)
	end 
end

----满星奖励
function clsSailorRecruitView:fullStarRewardCard(tag)

	if tag <= #self.num_list then
		local num = self.num_list[tag] 
		local function sailorFadeOutCB()
			self["card_sailor"..num]:setScale(0.55)		    	
			self["card_sailor"..num]:runAction(CCFadeOut:create(0.1))
			self["card_sailor"..num]:setVisible(false)		    		    		
		end
		local array_full_star = CCArray:create()
		array_full_star:addObject(CCCallFunc:create(sailorFadeOutCB))
		array_full_star:addObject(CCDelayTime:create(0.05)) 
		local function itemFadeInCB()
			self["card_item"..num]:setVisible(true)
			self["card_item"..num]:runAction(CCFadeIn:create(0.1))
			self:createRewardItemCard(num)	    		
		end
		array_full_star:addObject(CCCallFunc:create(itemFadeInCB))
		array_full_star:addObject(CCCallFunc:create(function ()
			local effect = "tx_0137"--tx_0137
			local ccp = pos[num][2]
			local effect = CompositeEffect.new(effect, ccp.x, ccp.y, self, nil, nil, nil, nil)
		end))		
		array_full_star:addObject(CCDelayTime:create(0.05))
		array_full_star:addObject(CCCallFunc:create(function ()
			tag = tag + 1
			self:fullStarRewardCard(tag)			
		end))
		
		if tag == #self.num_list then
			array_full_star:addObject(CCCallFunc:create(function ()
				self.num_list = {}
			end))			
		end

		self["card_sailor"..num]:runAction(CCSequence:create(array_full_star))	
	else
		self:onTurn()
		local sailorData = getGameData():getSailorData()
		sailorData:clearFullStarReward()

		if self.is_more_treat then
			self:moreTreatCallBack()
		end
	end
	
end

function clsSailorRecruitView:isShowTaskView(sailor_id)
	local sailor_mission = info_sailor_mission[sailor_id] -- 判断水手是否有传记任务
	if sailor_mission then 
		local mission_count = #sailor_mission
		local sailorData = getGameData():getSailorData()
		local ownSailors = sailorData:getOwnSailors()
		local sailor_data = ownSailors[sailor_id] 
		local memoirChapter = sailor_data.memoirChapter
		local memoirStatus = sailor_data.memoirStatus
		if memoirChapter <= 1 and sailor_data.starLevel == 1 then --水手是新招募，没有接传记任务
			return true
		else
			return false			
		end 
	else
		return false
	end
end

function clsSailorRecruitView:onTurn()
	local sailorData = getGameData():getSailorData()
	local reward_list = sailorData:getRecruitSailorInfo()
	for i=1,CARD_NUM do
		if reward_list[i]["type"] == 12 then
			self["card_sailor"..i]:setTouchEnabled(true)
		end
	end
end
---判断是否全部翻完
function clsSailorRecruitView:isFullTurn()
	for i=1,CARD_NUM do
		if not self["backCard_"..i].isfull  then
			return false
		end				
	end
	return true
end

function clsSailorRecruitView:createSailorCard(num)
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()
	local reward_list = sailorData:getRecruitSailorInfo()

	local sailor_id = reward_list[num].id
	local sailor_data = ownSailors[sailor_id]

	for k,v in pairs(sailor_widget) do
		self[v]= getConvertChildByName(self["card_sailor"..num], v)
	end
	self["card_sailor"..num]:setScale(0.55)
	self["sailor_name"]:setText(sailor_data.name)
	self["sailor_pic"]:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self["sailor_job"]:changeTexture(JOB_RES[sailor_data.job[1]], UI_TEX_TYPE_PLIST)
	local sailor_star = sailor_info[sailor_id].star
	if sailor_star > SAILOR_A_STAR then
		self.sailor_pic:setScale(0.8)
	end
	self["sailor_lv"]:changeTexture(STAR_SPRITE_RES[sailor_star].big, UI_TEX_TYPE_PLIST)
	for i=1,CARD_NUM do
		if i > 1 then
			self["star_"..i]:setVisible(false)
		end
	end

	local effect_tx = "tx_0024" --"tx_0024"
	local effect_bg = CompositeEffect.new(effect_tx, 0, 0, self["star_"..sailor_data.starLevel], nil, nil, nil, nil, true)
	effect_bg:setScale(0.4)
end

function clsSailorRecruitView:createItemCard(num)
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()
	local reward_list = sailorData:getRecruitSailorInfo()
	local item_id = reward_list[num].id	
	for k,v in pairs(item_info) do
		self[v]= getConvertChildByName(self["card_item"..num], v)
	end
	self["card_item"..num]:setScale(0.55)
	local icon_str, amount, scale, name = getCommonRewardIcon(reward_list[num])
	self.item_icon:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
	self.item_name:setText(name.."*"..amount)
end

function clsSailorRecruitView:createRewardItemCard(num)
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()
	local reward_list = sailorData:getRecruitSailorReward()
	local sailor_list = sailorData:getRecruitSailorInfo()
	local sailor_id = sailor_list[num].id	
	for k,v in pairs(item_info) do
		self[v]= getConvertChildByName(self["card_item"..num], v)
	end
	self["card_item"..num]:setScale(0.55)
	local icon_str, amount, scale, name = getCommonRewardIcon(reward_list[sailor_id][1])
	self.item_icon:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
	self.item_name:setText(name.."*"..amount)
end



function clsSailorRecruitView:createRewardCard(num)
	local sailorData = getGameData():getSailorData()
	local reward_list = sailorData:getRecruitSailorInfo()
	local reward_full_list = sailorData:getRecruitSailorReward()
	local sailor_id = reward_list[num].id
	for k,v in pairs(full_reward) do
		self[v]= getConvertChildByName(self["card_reward"..num], v)
		self[v]:setVisible(false)
	end
	self["card_reward"..num]:setScale(0.55)
	local reward = reward_full_list[sailor_id]
	for k,v in pairs(reward) do
		local icon_str, amount, scale, name = getCommonRewardIcon(v)
		self["item_icon"..k]:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
		self["item_name"..k]:setText(name.."*"..amount)
		self["item_name"..k]:setVisible(true)
		self["item_icon"..k]:setVisible(true)
	end
end

function clsSailorRecruitView:updataItemNum()
	self.timer = scheduler:scheduleScriptFunc(function ( )
		self:timerCB()
	end, 1, false)
end

function clsSailorRecruitView:unscheduleTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function clsSailorRecruitView:timerCB()
	if tolua.isnull(self) then
		self:unscheduleTimer()
	else
		local playerData = getGameData():getPlayerData()
		local honour_num = playerData:getHonour()
		local gold_num = playerData:getGold()
		if self.type == HONOUR_RECRUIT then
			self.more_wine_icon:setVisible(true)
			self.more_diamond_icon:setVisible(false)
			self.more_wine_num:setVisible(true)
			self.more_wine_num:setText(HONOUR_RECRUIT_ONCE_COST)
			if honour_num < HONOUR_RECRUIT_ONCE_COST then
				self.more_wine_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
			else
				self.more_wine_num:setColor(ccc3(dexToColor3B(COLOR_YELLOW)))
			end
		else
			self.more_diamond_icon:setVisible(true)
			self.more_diamond_num:setVisible(true)
			self.more_diamond_num:setText(GOLD_RECRUIT_FIVE_COST)
			self.more_wine_icon:setVisible(false)
			if gold_num < GOLD_RECRUIT_FIVE_COST then
				self.more_diamond_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
			else
				self.more_diamond_num:setColor(ccc3(dexToColor3B(COLOR_YELLOW)))
			end
		end
	end

end

function clsSailorRecruitView:onExit()
	local sailorData = getGameData():getSailorData()
	sailorData:clearFullStarReward()
	UnLoadPlist(self.plist)
end

function clsSailorRecruitView:setButtonTouch(enable)
	if self:isFullTurn() then
		self.all_open_btn:setTouchEnabled(not enable)
	else
		self.all_open_btn:setTouchEnabled(enable)
	end
	
	self.treat_more_btn:setTouchEnabled(enable)		
end

return clsSailorRecruitView

