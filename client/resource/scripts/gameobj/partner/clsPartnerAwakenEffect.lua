
---觉醒特效

local music_info = require("game_config/music_info")
local sailor_info = require("game_config/sailor/sailor_info")
local ClsBaseView = require("ui/view/clsBaseView")
local sailor_op_config = require("game_config/sailor/sailor_op_config")
local CompositeEffect = require("gameobj/composite_effect")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local ClsRelicPanelView = require("gameobj/relic/relicInfoPanel")


local ClsPartnerAwakenEffect = class("ClsPartnerAwakenEffect", ClsBaseView)

local card_name = {
	"card_panel",
	"card_back",
	"card_sailor",
	"card_item",
	"card_reward",	
}

local widget_name = {
	"accountant_head",
	"accountant_name",
	"talk_content",
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

function ClsPartnerAwakenEffect:onEnter(sailor_id, reward)
	
    self.plist = {
        ["ui/skill_icon.plist"] = 1,
        ["ui/hotel_ui.plist"] = 1,
    }
    LoadPlist(self.plist)
    self.sailor_id = sailor_id
    if reward then
    	self.reward = reward
    end
	self:initUI()
end

function ClsPartnerAwakenEffect:initUI()
	local black_bg_spr = CCLayerColor:create(ccc4(0, 0, 0, 230))
	self:addChild(black_bg_spr,-1)

	self.cards_panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_card.json")
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/market_hotsell.json")
	self.panel:setVisible(false)
	self:addWidget(self.panel)
	self.cards_panel:setPosition(ccp(display.cx - 160, display.cy - 230))
	self:addWidget(self.cards_panel)

	for k,v in pairs(card_name) do
		self[v] = getConvertChildByName(self.cards_panel, v)
		self[v]:setScale(0.55)
		self[v]:setVisible(false)
	end

	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	local effect = CompositeEffect.new("tx_sailor_awake_success", display.cx, display.cy, self,0.6, function( ... )
		self:regTouchEvent(self, function(event, x, y)
			return self:onTouch(event, x, y) end)
		--effect:setVisible(false)
		CompositeEffect.new("tx_0133_orange", display.cx, display.cy, self)
		--self:updateSailorCard()


		local array = CCArray:create()
		array:addObject(CCCallFunc:create(function()
			self:updateSailorCard()
			self:updateSailorTalk()
		end)) 
		array:addObject(CCCallFunc:create(function ()
			self.panel:setVisible(true)
			self:sailorTalkAnimation()
		end))
        self:runAction(CCSequence:create(array))
	end)		

end

function ClsPartnerAwakenEffect:updateSailorTalk( )
	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()

	local sailor_id = self.sailor_id
	local sailor_data = sailor_info[sailor_id]
	self.sailor_data = sailor_data
	self.accountant_head:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.accountant_head:setScale(1)
	local size = self.accountant_head:getContentSize()
	self.accountant_head:setScale(140/size.width)
	self.accountant_name:setText(sailor_data.name)
	local talk_des = sailor_info[sailor_data.id].talk
	self.talk_content:setText("")	
end

function ClsPartnerAwakenEffect:sailorTalkAnimation( )
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


function ClsPartnerAwakenEffect:updateSailorCard( )
	self.card_sailor:setScaleX(0.55)
	self.card_sailor:setScaleY(0.55)

	self.card_sailor:setVisible(true)
	local effect = CompositeEffect.new("tx_0138orange", 0, 0, self.card_sailor, nil, nil, nil, nil, true)
	effect:setScale(1.5)
	for k,v in pairs(sailor_name_info) do
		self[v] = getConvertChildByName(self.cards_panel, v)
	end

	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()

	local sailor_id = self.sailor_id
	local sailor_data = ownSailors[sailor_id]

	self.sailor_name:setText(sailor_data.name)
	self.sailor_pic:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.sailor_job:changeTexture(JOB_RES[sailor_data.job[1]], UI_TEX_TYPE_PLIST)
	self.sailor_lv:changeTexture(STAR_SPRITE_RES[sailor_data.star].big, UI_TEX_TYPE_PLIST)

	for i=1,5 do
		if i >sailor_data.starLevel then
			self["star_"..i]:setVisible(false)
		end
	end

	local effect_tx = "tx_0024" 
	local effect_bg = CompositeEffect.new(effect_tx, 0, 0, self["star_"..sailor_data.starLevel], nil, nil, nil, nil, true)
	effect_bg:setScale(0.4)
end

function ClsPartnerAwakenEffect:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsPartnerAwakenEffect:onTouchBegan(x , y)

	if self.reward then
		Alert:showCommonReward(self.reward)
	end
	self:close()

	local ClsPartnerInfoView  = getUIManager():get("ClsPartnerInfoView")
	if not tolua.isnull(ClsPartnerInfoView) then
		ClsPartnerInfoView:closeView()
	end

	return false
end



function ClsPartnerAwakenEffect:onExit()
    UnLoadPlist(self.plist)
end

return ClsPartnerAwakenEffect