
---fmy0570
---朗姆酒招募界面
local ClsRelicPanelView = require("gameobj/relic/relicInfoPanel")
local CompositeEffect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local sailor_info = require("game_config/sailor/sailor_info")
local music_info = require("game_config/music_info")
local voice_info = getLangVoiceInfo()

local ClsSailorWineRecruit = class("ClsSailorWineRecruit", ClsBaseView)

local SAILOR_B_STAR = 4
local SAILOR_A_STAR = 5
local SAILOR_S_STAR = 7
function ClsSailorWineRecruit:getViewConfig()
    return {
        is_back_bg = true, 
    }
end

local widget_name = {
	"accountant_head",
	"accountant_name",
	"talk_content",
}

local card_name = {
	"card_panel",
	"card_back",
	"card_sailor",
	"card_item",
	"card_reward",	
}

local sailor_name_info = {
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

function ClsSailorWineRecruit:onEnter(sailor_id,is_no_sailor,end_call_back,is_update_welfare_view)

	self.data = sailor_id
	self.is_no_sailor = is_no_sailor
	self.end_call_back = end_call_back
	self.is_update_welfare_view = is_update_welfare_view

	self.plist = {
		["ui/hotel_ui.plist"] = 1,
		["ui/port_cargo.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/market_hotsell.json")
	self.cards_panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_card.json")
	self.panel:setVisible(false)
	self:addWidget(self.panel)

	self.cards_panel:setPosition(ccp(display.cx - 175, display.cy - 183))
	self:addWidget(self.cards_panel)

	self:initView()	
end


function ClsSailorWineRecruit:getSailorData(data)
    local sailorData = getGameData():getSailorData()
    local ownSailors = sailorData:getOwnSailors()
    return ownSailors[data]   
end

function ClsSailorWineRecruit:initView()

	for k,v in pairs(card_name) do
		self[v] = getConvertChildByName(self.cards_panel, v)
		self[v]:setScale(0.55)
		self[v]:setVisible(false)
	end

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self:updateView()
	self:showView()
end

local effect_tab = {
	"tx_0133_green", -- e
	"tx_0133_green", -- d
	"tx_0133_blue",  --c
	"tx_0133_purple", --b
	"tx_0133_orange",  --a
	"tx_0133_orange",  --s
	"tx_0133_orange",  --s
}

function ClsSailorWineRecruit:showView() 
	local array = CCArray:create()
	local sailorData = getGameData():getSailorData()

	if not self.is_no_sailor then
		array:addObject(CCDelayTime:create(0.1))
		array:addObject(CCCallFunc:create(function()
			self:showCardAnimation()	
		end))
		array:addObject(CCDelayTime:create(1.5))		
	end

	array:addObject(CCCallFunc:create(function()
		local reward_list = sailorData:getRecruitSailorReward()
		if reward_list and not reward_list[self.data] then
			self.panel:setVisible(true)
			self:sailorTalkAnimation()			
		end
	end))

	array:addObject(CCCallFunc:create(function ()
		--sailorData:delRecruitSailorReward(self.data)
		self:regTouchEvent(self, function(event, x, y)
			return self:onTouch(event, x, y) end)		
	end))
	self:runAction(CCSequence:create(array))
end


function ClsSailorWineRecruit:showCardAnimation()
	local sailorData = getGameData():getSailorData()
	local reward_list = sailorData:getRecruitSailorReward()

	local effect_tx 
	local array = CCArray:create()

	array:addObject(CCCallFunc:create(function ()
		self.card_back:setScale(0.55)
		self.card_back:setVisible(true)
	end))

	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCCallFunc:create(function (  )
		self.card_back:runAction(CCFadeOut:create(0.1))
		self.card_back:setVisible(false)
		local sailor_star = sailor_info[self.data].star
		local effect_res = effect_tab[sailor_star] 
		local effect = CompositeEffect.new(effect_res, display.cx - 8, display.cy + 38, self, nil, nil, nil, nil)	
		effect:setScale(0.9)
	end))
	array:addObject(CCCallFunc:create(function()
		audioExt.playEffect(music_info.HOTEL_CARD_FLOP.res)
		self.card_sailor:setVisible(true)
		self.card_sailor:runAction(CCScaleTo:create(0.2, 0.55, 0.55))
		self.card_sailor:setTouchEnabled(true)
		--local sailor_data = self:getSailorData(self.data)
		local sailor_data = sailor_info[self.data]
		if sailor_data.star == SAILOR_B_STAR then
			effect_tx = "tx_0138purple"
		elseif sailor_data.star >= SAILOR_A_STAR then
			effect_tx = "tx_0138orange"
		else
		end
	end))

	if reward_list and reward_list[self.data] then
		array:addObject(CCDelayTime:create(2))
		local function sailorFadeOutCB()
			self.card_sailor:setTouchEnabled(false)
			self.card_sailor:runAction(CCFadeOut:create(0.1))
			self.card_sailor:setVisible(false)		    		    		
		end
		array:addObject(CCCallFunc:create(sailorFadeOutCB))
		array:addObject(CCDelayTime:create(0.05)) 
		local function itemFadeInCB()
			self:createRewardCard()	--reward_list
			self.card_item:setVisible(true)
			self.card_item:runAction(CCFadeIn:create(0.1))    		
		end

		array:addObject(CCCallFunc:create(itemFadeInCB))
		array:addObject(CCCallFunc:create(function ()
			local effect = "tx_0137"
			local effect = CompositeEffect.new(effect, 0, 0, self.card_item, nil, nil, nil, nil,true)
			effect:setScale(1.5)
		end))
	end

	array:addObject(CCCallFunc:create(function (  )
		if effect_tx then
			local effect_bg = CompositeEffect.new(effect_tx, 0, 0, self.card_sailor, nil, nil, nil, nil, true)
			effect_bg:setScale(1.5)
		end
	end))

	self:runAction(CCSequence:create(array))
end

function ClsSailorWineRecruit:createRewardCard( )--reward_list
	local sailorData = getGameData():getSailorData()
	local reward_list = sailorData:getRecruitSailorReward()

	for k,v in pairs(item_info) do
		self[v]= getConvertChildByName(self.card_item, v)
	end
	self.card_item:setScale(0.55)
	local icon_str, amount, scale, name = getCommonRewardIcon(reward_list[self.data][1])
	self.item_icon:changeTexture(convertResources(icon_str), UI_TEX_TYPE_PLIST)
	self.item_name:setText(name.."*"..amount)
end

function ClsSailorWineRecruit:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsSailorWineRecruit:onTouchBegan(x , y)

	local pos_x,pos_y = 384,192
	local size_width = 175
	local size_height = 235
	if x > pos_x and x < pos_x + size_width and y > pos_y and y < pos_y + size_height then
		return true
	else
		self:close()
		local clsSailorRecruit = getUIManager():get("clsSailorRecruit") 
		if not tolua.isnull(clsSailorRecruit) then				
			clsSailorRecruit:setBtnTouch(true)
		end
		if self.end_call_back ~= nil then
			self.end_call_back()
		end	
		local sailorData = getGameData():getSailorData()
		sailorData:delRecruitSailorReward(self.data)

		if self.is_update_welfare_view then
			local ClsWefareMain = getUIManager():get("ClsWefareMain")
			if not tolua.isnull(ClsWefareMain) then
				ClsWefareMain:updateMkUI()
			end		
		end

		local is_first = sailorData:isFristASailor()
		if is_first and not self.is_no_sailor then
			getUIManager():create("gameobj/sailor/clsSailorFristTips")
		end
		return false
	end
end

function ClsSailorWineRecruit:updateView()

	self:updateSailorCard()
	self:updateSailorTalk()
end


function ClsSailorWineRecruit:updateSailorCard( )
	self.card_sailor:setScaleX(0)
	self.card_sailor:setScaleY(0.55)

	for k,v in pairs(sailor_name_info) do
		self[v] = getConvertChildByName(self.cards_panel, v)
	end

	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()

	local sailor_id = self.data
	local sailor_data = sailor_info[sailor_id]

	self.sailor_data = sailor_data 

	self.sailor_name:setText(sailor_data.name)
	self.sailor_pic:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.sailor_job:changeTexture(JOB_RES[sailor_data.job[1]], UI_TEX_TYPE_PLIST)
	local sailor_star = sailor_info[sailor_id].star
	if sailor_star > SAILOR_A_STAR then
		self.sailor_pic:setScale(0.8)
	end
	self.sailor_lv:changeTexture(STAR_SPRITE_RES[sailor_star].big, UI_TEX_TYPE_PLIST)

	for i=1,5 do
		if i > 1 then
			self["star_"..i]:setVisible(false)
		end
	end

	local effect_tx = "tx_0024" 
	local effect_bg = CompositeEffect.new(effect_tx, 0, 0, self["star_1"], nil, nil, nil, nil, true)
	effect_bg:setScale(0.4)
	
	self.card_sailor:addEventListener(function ()
		local sailor = sailor_info[self.data]
		if sailor.sex == SEX_F then
			audioExt.playEffect(voice_info["VOICE_PLOT_1008"].res, false)
		else
			audioExt.playEffect(voice_info["VOICE_PLOT_1006"].res, false)
		end
	
		local sailor_data_info = ownSailors[sailor_id]
		if sailor_data_info then
			getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor_data_info, nil, nil, true)
		end
	end, TOUCH_EVENT_ENDED)
end

function ClsSailorWineRecruit:updateSailorTalk( )
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()

	local sailor_id = self.data
	local sailor_data = ownSailors[sailor_id]
	self.accountant_head:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.accountant_name:setText(sailor_data.name)
	local talk_des = sailor_info[sailor_data.id].talk
	self.talk_content:setText("")	
end

function ClsSailorWineRecruit:sailorTalkAnimation( )
	local desc_lab = self.talk_content
	local talk_des = sailor_info[self.sailor_data.id].talk

	local dec_str = talk_des or "nil"
	local dec_lab_cut_tab = ClsRelicPanelView:spliteString(dec_str, 1)
	local dec_lab_cut_count_n = 1
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.05))
	array:addObject(CCCallFunc:create(function()
		if type(dec_lab_cut_tab) == "table" then
			if dec_lab_cut_count_n > #dec_lab_cut_tab then
				desc_lab:stopAllActions()

				return
			end
		end
		if not tolua.isnull(desc_lab) then
			local str = ""
			for i = 1, dec_lab_cut_count_n do
				str = str .. dec_lab_cut_tab[i]
			end
			desc_lab:setText(str)
		else
			desc_lab:stopAllActions()
			return
		end
		dec_lab_cut_count_n = dec_lab_cut_count_n + 1
	end))
	desc_lab:runAction(CCRepeatForever:create(CCSequence:create(array)))

end

function ClsSailorWineRecruit:onExit()
	UnLoadPlist(self.plist)
end

return ClsSailorWineRecruit