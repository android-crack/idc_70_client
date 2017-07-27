
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert") 
local DataTool = require("module/dataHandle/dataTools")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local CompositeEffect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word")
local lmjzm_reward_expbook = require("game_config/lmjzm_reward_expbook")
local zszm_reward_expbook = require("game_config/zszm_reward_expbook")
local item_info = require("game_config/propItem/item_info")

local clsSailorRecruit = class("clsSailorRecruit", ClsBaseView)

local HONOUR_RECRUIT_ONCE_COST = 50 --cost 100 per time to use honour recruit
local GOLD_RECRUIT_FIVE_COST = 888

local FIVE_DIAMOND_RECRUIT_TIMES = 50

local LIMIT_ACTIVIT_TEN_TIMES = 10
local LIMIT_ACTIVIT_FIVTY_TIMES = 50

local MAX_FREE_TIMES = 11

local HONOUR_RECRUIT = 1
local GOLD_RECRUIT   = 2
local widget_name = {
	"cost_wine_num",
	"cost_diamond_num",
	"wine_treat_btn",
	"diamond_treat_btn",
	"cost_free_txt",
	"cost_free_txt_2",
	"cost_wine_icon",
	"cost_diamond_icon",
	"big_wine_iocn",
	"wine_iocn",
	"book_icon",
	"slogan_1",

	"num_1",
	"award_icon_1",
	"award_num_1",
	"award_icon_2",
	"award_num_2",

	"slogan_2",
	"num_2",
	"last_time_num",
	"diamond_treat_1",
	"diamond_treat_2",
}

local rewards_sailor_id = {
	[1] = 45,
	[2] = 71,
	[3] = 83,
}

clsSailorRecruit.getViewConfig = function(self)
	return {
		is_swallow = false,        
		--effect = UI_EFFECT.FADE,   
	}
end

clsSailorRecruit.initView = function(self)
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)	
	end

	local task_data = getGameData():getTaskData()
	local honour_keys = {
		on_off_info.WINE_ENLIST.value,
	}
	task_data:regTask(self.wine_treat_btn, honour_keys, KIND_RECTANGLE, honour_keys[1], 90, 27, true)
	
	missionGuide:pushGuideBtn(on_off_info.RECRUIT_DIAMOND.value, {guideBtn=self.diamond_treat_btn, guideLayer=self, x=635, y=135})
	missionGuide:pushGuideBtn(on_off_info.WINE_ENLIST.value, {guideBtn=self.wine_treat_btn, guideLayer=self, x=322, y=135})

	self.panel:setVisible(false)
	local sailorData = getGameData():getSailorData()
	sailorData:askLimitRecruitActivity()     ---请求限时招募活动	
	sailorData:getSailorFreeRecruitInfo()    ---招募航海士免费协议

	self:updateExpRewards()
end

clsSailorRecruit.updateExpRewards = function(self)
	local exp_book_id_1 = lmjzm_reward_expbook["1"].id
	local exp_book_icon_1 = item_info[exp_book_id_1].res
	local exp_book_num_1 = lmjzm_reward_expbook["1"].cnt

	self.award_icon_1:changeTexture(convertResources(exp_book_icon_1), UI_TEX_TYPE_PLIST)
	self.award_num_1:setText(exp_book_num_1)

	local exp_book_id_2 = zszm_reward_expbook["1"].id
	local exp_book_icon_2 = item_info[exp_book_id_2].res
	local exp_book_num_2 = zszm_reward_expbook["1"].cnt

	self.award_icon_2:changeTexture(convertResources(exp_book_icon_2), UI_TEX_TYPE_PLIST)
	self.award_num_2:setText(exp_book_num_2)		
end

---金币是否足够
clsSailorRecruit.isGoldEnough = function(self, cost)
	local playerData = getGameData():getPlayerData()
	if playerData:getGold() >= cost then
		return true
	else
		return false
	end	
end

---荣誉是否足够
clsSailorRecruit.isHonourEnough = function(self, cost)
	local playerData = getGameData():getPlayerData()
	if playerData:getHonour() >= cost then
		return true
	else
		return false
	end	
end

clsSailorRecruit.initBtn = function(self)

	----荣誉招募
	self["wine_treat_btn"]:setPressedActionEnabled(true)
	self["wine_treat_btn"]:addEventListener(function ()
		self:setBtnTouch(false)
	end,TOUCH_EVENT_BEGAN)

	self["wine_treat_btn"]:addEventListener(function ()
		self:setBtnTouch(true)
	end,TOUCH_EVENT_CANCELED)

	self["wine_treat_btn"]:addEventListener(function()
		
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local isfull = self:isHonourEnough(self.needHonour)
		if isfull or self.honour_free == true then
			local sailorData = getGameData():getSailorData()
			sailorData:saveOldSailors()
			local callBackHonourRecruit
			callBackHonourRecruit = function()
				local sailorData = getGameData():getSailorData()
				sailorData:sailorHonourRecruit()
				sailorData:getSailorFreeRecruitInfo()    ---招募航海士免费协议				
			end
			local array = CCArray:create()
			array:addObject(CCCallFunc:create(function (  )
				local effect_tx = "tx_zhaowu"
				self.effect_wine = CompositeEffect.new(effect_tx, 0,0, self.wine_iocn, nil, nil, nil, nil,true)
			end))
			array:addObject(CCCallFunc:create(callBackHonourRecruit))
			array:addObject(CCDelayTime:create(1.0))
			local callBackRecruitView
			callBackRecruitView = function()
				if self.effect_wine then
					self.effect_wine:removeFromParentAndCleanup(true)
					self.effect_wine = nil 
				end
			end
			array:addObject(CCCallFunc:create(callBackRecruitView))
			self:runAction(CCSequence:create(array))
		else
			local alertType = Alert:getOpenShopType()
			Alert:showJumpWindow(HONOUR_NOT_ENOUGH, self:getParent())
			self:setBtnTouch(true)
		end
	end, TOUCH_EVENT_ENDED)

	local on_off_data = getGameData():getOnOffData()
	on_off_data:pushOpenBtn(on_off_info.WINE_ENLIST.value, {openBtn = self["wine_treat_btn"], openEnable = true, addLock = true, 
		labelOpacity = 255 * 0.75, btnRes = "#common_btn_blue1.png", parent = "clsSailorRecruit"})

	on_off_data:pushOpenBtn(on_off_info.RECRUIT_DIAMOND.value, {openBtn = self["diamond_treat_btn"], openEnable = true, addLock = true, 
		labelOpacity = 255 * 0.75, btnRes = "#common_btn_orange3.png", parent = "clsSailorRecruit"})
	
	self["diamond_treat_btn"]:setPressedActionEnabled(true)
	self["diamond_treat_btn"]:addEventListener(function ()
		self:setBtnTouch(false)
	end,TOUCH_EVENT_BEGAN)

	self["diamond_treat_btn"]:addEventListener(function()
		self:setBtnTouch(true)
	end, TOUCH_EVENT_CANCELED)

	self["diamond_treat_btn"]:addEventListener(function()
		
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local isfull = self:isGoldEnough(GOLD_RECRUIT_FIVE_COST)
		if isfull then  -----钻石充足
		   
			local sailorData = getGameData():getSailorData()
			sailorData:saveOldSailors()
			local callBackGoldRecruit
			callBackGoldRecruit = function()
				local sailorData = getGameData():getSailorData()
				sailorData:sailorDiamondRecruit()
				sailorData:getSailorFreeRecruitInfo()    ---招募航海士免费协议          		
			end
			local array = CCArray:create()	
			array:addObject(CCCallFunc:create(function (  )
				local effect_tx = "tx_zhaowu02"
				self.effect = CompositeEffect.new(effect_tx, 0,0, self.big_wine_iocn, nil, nil, nil, nil,true)
			end))
			array:addObject(CCDelayTime:create(1.0))
			array:addObject(CCCallFunc:create(callBackGoldRecruit))
			
			local callBackRecruitView
			callBackRecruitView = function()
				if self.effect then
					self.effect:removeFromParentAndCleanup(true)
					self.effect = nil 
				end

				--getUIManager():create("gameobj/sailor/clsSailorRecruitView", {}, GOLD_RECRUIT)
			end
			array:addObject(CCCallFunc:create(callBackRecruitView))
			self:runAction(CCSequence:create(array))				
		else
			local alertType = Alert:getOpenShopType()
			Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self:getParent(), {need_gold = GOLD_RECRUIT_FIVE_COST, come_type = alertType.VIEW_NORMAL_TYPE})

			self:setBtnTouch(true)
		end
	end, TOUCH_EVENT_ENDED)


	self.book_icon:setTouchEnabled(true)
	self.book_icon:addEventListener(function (  )
		local playerData = getGameData():getPlayerData()
		local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
		mission_skip_layer:skipSailorCollectUI(nil, playerData:getUid())
	end,TOUCH_EVENT_ENDED)	
end

clsSailorRecruit.refreshView = function(self)
	self.cost_free_txt:setVisible(self.honour_free)
	self.cost_wine_num:setVisible(not self.honour_free) 
	self.cost_wine_num:setText(self.needHonour)
	self.cost_wine_icon:setVisible(not self.honour_free)
	self:setWineColor()

	self.cost_diamond_num:setText(GOLD_RECRUIT_FIVE_COST)
	self:setDiamondColor()	
end

clsSailorRecruit.setWineColor = function(self)
	local playerData = getGameData():getPlayerData()
	if playerData:getHonour() < self.needHonour then
		self.cost_wine_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
	else
		self.cost_wine_num:setColor(ccc3(dexToColor3B(COLOR_WHITE)))
	end
end

clsSailorRecruit.setDiamondColor = function(self)
	local playerData = getGameData():getPlayerData()
	if playerData:getGold() < GOLD_RECRUIT_FIVE_COST then
		self.cost_diamond_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
	else
		self.cost_diamond_num:setColor(ccc3(dexToColor3B(COLOR_WHITE)))
	end
end

clsSailorRecruit.unscheduleTimer = function(self)
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end
------协议下发刷新
clsSailorRecruit.setData = function(self, needHonour, gold_free_time, limit_activit_times,activit_all_times)--time,one, five

	self.panel:setVisible(true)
	self.honour_free = false
	self.gold_free = false
	self:unscheduleTimer()

	self.needHonour = needHonour
	self.gold_free_time = gold_free_time
	self.limit_activit_times = limit_activit_times
	self.activit_all_times = activit_all_times
	--print("==============金币免费次数，总数，gold_free_time，limit_activit_times，activit_all_times",honour_free_times,honour_free_all_times,gold_free_time,limit_activit_times,activit_all_times)

	if self.needHonour == 0  then
		self.honour_free = true
	end

	if gold_free_time == 0 then
		self.gold_free = true
	end
	self:refreshView()

	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.timer = scheduler:scheduleScriptFunc(function ( )
		self:timerCB()
	end, 1, false)

	local need_times = self.activit_all_times
	self.num_1:setText(need_times - self.limit_activit_times)

	self:updateLimitActivitView()
end

clsSailorRecruit.updateLimitActivitView = function(self)
	local sailorData = getGameData():getSailorData()
	local is_limit_activi = sailorData:isLimitActivityStatus()
	local limit_activity_info = sailorData:getLimitActivityInfo()
	-- print("-------------is_limit_activi--------",is_limit_activi)
	-- table.print(limit_activity_info)

	self.slogan_1:setVisible(not is_limit_activi)
	self.slogan_2:setVisible(is_limit_activi)
	self.diamond_treat_1:setVisible(not is_limit_activi)
	self.diamond_treat_2:setVisible(is_limit_activi)

	if is_limit_activi and limit_activity_info.times then
		self.num_2:setText(limit_activity_info.times)
		local time = limit_activity_info.remainTime
		local time_str = DataTool:getTimeStr4(tonumber(time))
		self.last_time_num:setText(time_str)
	end
end

clsSailorRecruit.timerCB = function(self)
	if tolua.isnull(self) then
		self:unscheduleTimer()
	else
		if self.gold_free_time == 0 then
			self:setDiamondColor()
		end
		
		-- if self.honour_free_times >= 1 then
		-- 	self:setWineColor()
		-- end
	end
end

--关闭不足界面返回后，刷新
clsSailorRecruit.updateLabelCallBack = function(self)
	local playerData = getGameData():getPlayerData()
	if not tolua.isnull(self.cost_wine_num) and playerData:getHonour() >= self.needHonour then
		self.cost_wine_num:setColor(ccc3(dexToColor3B(COLOR_WHITE)))
	end
	if not tolua.isnull(self.cost_diamond_num) and playerData:getGold() >= GOLD_RECRUIT_FIVE_COST then
		self.cost_diamond_num:setColor(ccc3(dexToColor3B(COLOR_WHITE)))
	end
end

clsSailorRecruit.setBtnTouch = function(self, enable)
	if self.wine_treat_btn and self.diamond_treat_btn then 
		self.wine_treat_btn:setTouchEnabled(enable)
		self.diamond_treat_btn:setTouchEnabled(enable)
	end

	local ClsHotelMain = getUIManager():get("ClsHotelMain")
	if not tolua.isnull(ClsHotelMain) then
		ClsHotelMain:setBtnTouchEnable(enable)
	end
end

clsSailorRecruit.onEnter = function(self)
	self.plist = {
		["ui/hotel_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_treat_ui.json")
	self:addWidget(self.panel)
	self.needHonour = HONOUR_RECRUIT_ONCE_COST

	self:initView()	
	self:initBtn()
end

clsSailorRecruit.limitActivityWillStop = function(self)

	local sailorData = getGameData():getSailorData()
	local is_limit_activi = sailorData:isLimitActivityStatus()
	if not is_limit_activi then return end
	local is_will_stop,time = sailorData:isLimitActivityWillStop()
	if is_will_stop then
		local time_num = math.modf(time/60)+1
		local str = string.format(ui_word.SAILOR_LIMIT_ACTIVITY_TIPS,time_num)
		Alert:showAttention(str)
	end
			
end

clsSailorRecruit.onExit = function(self)
	UnLoadPlist(self.plist)
end

return clsSailorRecruit