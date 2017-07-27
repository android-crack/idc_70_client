-- 小伙伴经验升级tips
local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ui_word = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsUpExpTip= class("ClsUpExpTip", ClsBaseView)
local scheduler = CCDirector:sharedDirector():getScheduler()

local EXP_BOOK_1 = 68  ---经验书id
local EXP_BOOK_2 = 1
local EXP_BOOK_3 = 69

function ClsUpExpTip:getViewConfig()
    return {
        is_swallow = true,          
        --effect = UI_EFFECT.FADE,   
    }
end

function ClsUpExpTip:onEnter(parent, sailor_id, pos)

	self.parent = parent
	self.pos = pos

	local sailor_data = getGameData():getSailorData()
	self.own_sailors = sailor_data:getOwnSailors()
	self.sailor = self.own_sailors[sailor_id]


   	local btn_panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_equip_tips.json")
   	self:addWidget(btn_panel)
   	self:setPosition(pos)
	self.panel = btn_panel


	self.size_width = 300
	self.size_height = 120

	self.exp_book = {EXP_BOOK_1, EXP_BOOK_2, EXP_BOOK_3}

	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)

	self:initUI()	
end


function ClsUpExpTip:onExit()  
	if self.scheduler_upLevel then
		scheduler:unscheduleScriptEntry(self.scheduler_upLevel)
		self.scheduler_upLevel = nil
	end
end

function ClsUpExpTip:initUI()
	self.book_btn_list = {}
	for i = 1, 3 do
		local propDataHandle = getGameData():getPropDataHandler()
	    local item = propDataHandle:hasPropItem(self.exp_book[i])    

	    local count = 0
	    if item then count = item.count end


		local btn_book = getConvertChildByName(self.panel, string.format("btn_equip_%s", i))
		self.book_btn_list[i] = btn_book

		local book_num = getConvertChildByName(self.panel, string.format("equip_num_%s", i))
		self.book_btn_list[i].book_num = book_num
		book_num:setText(count)

		btn_book:setTouchEnabled(true)

		btn_book:addEventListener(function()

			for k,v in pairs(self.book_btn_list) do
				v:setTouchEnabled(false)
			end

			local function upLevelSailor(  )
				self:addExp(btn_book, i)
			end

			self.scheduler_upLevel = scheduler:scheduleScriptFunc(upLevelSailor, 0.15, false)
			self:addExp(btn_book, i)
		end, TOUCH_EVENT_BEGAN)

		btn_book:addEventListener(function()
			if self.scheduler_upLevel then
				scheduler:unscheduleScriptEntry(self.scheduler_upLevel)
				self.scheduler_upLevel = nil
			end
			for k,v in pairs(self.book_btn_list) do
				v:setTouchEnabled(true)
			end

		end, TOUCH_EVENT_CANCELED)


		btn_book:addEventListener(function()
			if self.scheduler_upLevel then
				scheduler:unscheduleScriptEntry(self.scheduler_upLevel)
				self.scheduler_upLevel = nil
			end
			for k,v in pairs(self.book_btn_list) do
				v:setTouchEnabled(true)
			end

		end, TOUCH_EVENT_ENDED)



		if i == 1 then
			self.btn_book = btn_book 
		end
	end
	ClsGuideMgr:tryGuide("ClsUpExpTip")
	missionGuide:pushGuideBtn(on_off_info.BOOK_SELECT.value, {rect = CCRect(25, 17, 79, 82), guideLayer = self})
end


function ClsUpExpTip:updateUI( )
	for i = 1, 3 do
		local propDataHandle = getGameData():getPropDataHandler()
	    local item = propDataHandle:hasPropItem(self.exp_book[i])    

	    local count = 0
	    if item then count = item.count end
	    local book_num = self.book_btn_list[i].book_num
		book_num:setText(count)
	end	
end

function ClsUpExpTip:addExp(item, num)
	--item:setTouchEnabled(false)
	local player_data = getGameData():getPlayerData()
    local max_level = player_data:getMaxLevel()

    if self.sailor.level >= max_level then
        Alert:warning({msg = ui_word.SAILOR_USE_GOODS_ADD_EXP_MAX})
        --item:setTouchEnabled(true)
        return
    end

    local propDataHandle = getGameData():getPropDataHandler()
    local prop_item = propDataHandle:hasPropItem(self.exp_book[num]) ----航海士经验书

    --经验书不足
    if not prop_item or (prop_item and prop_item.count == 0) then
    	self.parent:clearTips()
        Alert:showJumpWindow(EXP_BOOK_NOT_ENOUGH, self.parent)
        --item:setTouchEnabled(true)
		if self.scheduler_upLevel then
			scheduler:unscheduleScriptEntry(self.scheduler_upLevel)
			self.scheduler_upLevel = nil
		end
        return
    end

    local needBookCnt = 1
    local collect_data = getGameData():getCollectData()
    collect_data:sendUseItemMessage(self.exp_book[num], needBookCnt, self.sailor.id)
end


function ClsUpExpTip:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsUpExpTip:onTouchBegan(x , y)

	if x > self.pos.x and x < self.pos.x + self.size_width and y > self.pos.y and y < self.pos.y + self.size_height then
		return true
	else

		self:close()		
		self.parent:clearTips()
		return false
	end
end


return ClsUpExpTip
