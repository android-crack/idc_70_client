
---fmy0570
---交易所结算界面

local UiCommon = require("ui/tools/UiCommon")
local CompositeEffect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word=require("game_config/ui_word")
local LoadingAction = require("gameobj/LoadingBarAction")
local voice_info = getLangVoiceInfo()
local ClsPortMarketAccountView = class("ClsPortMarketAccountView", ClsBaseView)

function ClsPortMarketAccountView:getViewConfig()
    return {         
		is_back_bg = true ,
		effect = UI_EFFECT.SCALE, 
    }
end

local widget_name = {
	"gold_num",
	"exp_num",
	"letter_num",
	"letter_icon",
	"man_pic",
	"title_icon",
	"art_txt",
	"tips_panel",
	"profit_next",
	"letter_next",
	"right_panel",
	"bar",
	"profit_num",
	"bar_bg",
	--"friend_profit",
	"hotsell_icon",
	"hotsell_num",

	"additional_profit_title",
	"additional_profit_1",
	"additional_profit_2",
	"additional_profit_3",
	"additional_profit_4",
}

local PROFIT_LEVEL_ZERO = 0
local PROFIT_LEVEL_ONE = 1
local PROFIT_LEVEL_TEO = 2
local PROFIT_LEVEL_THREE = 3

function ClsPortMarketAccountView:onEnter(data,profit_info,call_back)
	self.plistTab = {
		["ui/skill_icon.plist"] = 1,
		["ui/hotel_ui.plist"] = 1,
		["ui/market_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)	

	self.data = data 
	self.call_back = call_back
	self.profit_info = profit_info

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/market_result.json")
	self:addWidget(self.panel)

	--添加的特效层
	self.effectLayer = CCLayer:create()
	self:addChild(self.effectLayer, -1)

	self:regTouchEvent(self, function(event, x, y)
	return self:onTouch(event, x, y) end)
	self:initUI()
end

function ClsPortMarketAccountView:initUI( )
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end	

	self:updataUI()
end

function ClsPortMarketAccountView:updataUI( )
	local gold_num,exp_num,latter_num = 0,0,0

	for k,v in pairs(self.data) do
		if v.type == ITEM_INDEX_EXP then
			exp_num = v.amount
		elseif v.type == ITEM_INDEX_CASH then
			gold_num = v.amount

		elseif v.type == ITEM_INDEX_PROP then
			latter_num = v.amount
		end
	end

	UiCommon:numberEffect(self.gold_num,  0, gold_num, 30)
	UiCommon:numberEffect(self.exp_num,  0, exp_num, 30)
	UiCommon:numberEffect(self.letter_num,  0, latter_num, 30)
	UiCommon:numberEffect(self.hotsell_num,  0, self.profit_info.hotsell, 30)


	self.letter_icon:setVisible(latter_num ~= 0 )
	self.letter_num:setVisible(latter_num ~=0 )
	
	self.hotsell_num:setVisible(self.profit_info.hotsell > 0)
	self.hotsell_icon:setVisible(self.profit_info.hotsell > 0)

	local reward = self.profit_info.pNextMax
	local next_latter_num = self.profit_info.letter

	self.profit_next:setText(reward)
	self.letter_next:setText(next_latter_num)

	local pos = self.profit_next:getPosition()
	local size = self.profit_next:getContentSize()

	self.right_panel:setPosition(ccp(pos.x + size.width ,pos.y - size.height))

	CompositeEffect.new("tx_result_light", display.cx , display.cy + 105 , self.effectLayer)
	self:updateEffect()
	self:updateBarNum()
	self:updateAdditionalLab()
end

function ClsPortMarketAccountView:updateAdditionalLab(  )
	local lable_num = 0
	local str_list = {}
	if self.profit_info.port_bonus ~= 0 then
		lable_num = lable_num + 1
		str_list[lable_num] = string.format(ui_word.MARK_PORT_ADD_LAB, self.profit_info.port_bonus)
	end
	if self.profit_info.team_bonus ~= 0 then
		lable_num = lable_num + 1
		str_list[lable_num] = string.format(ui_word.MARK_TEAM_ADD_LAB, self.profit_info.team_bonus)
	end
	if self.profit_info.friend_bonus ~= 0 then
		lable_num = lable_num + 1
		str_list[lable_num] = string.format(ui_word.MARK_FRIENT_ADD_LAB, self.profit_info.friend_bonus)
	end

	if self.profit_info.skin_bonus ~= 0 then
		lable_num = lable_num + 1
		str_list[lable_num] = string.format(ui_word.MARK_SANBAO_BAOT_ADD_LAB, self.profit_info.skin_bonus)
	end


	--print("-----------self.profit_info----------------",self.profit_info.port_bonus, self.profit_info.team_bonus, self.profit_info.friend_bonus)
	self.additional_profit_title:setVisible(lable_num > 0)

	for i=1,4 do
		if i > lable_num then
			self["additional_profit_"..i]:setVisible(false)
		else
			self["additional_profit_"..i]:setText(str_list[i])
		end
	end	
end


local DURATION = 1 --进度条做满动画的时间

function ClsPortMarketAccountView:updateBarNum()
	local cur_percent = self.profit_info.pOld/self.profit_info.pMax * 100;
	self.profit_num:setText(string.format("%s/%s", self.profit_info.pOld, self.profit_info.pMax))
	self.bar:setPercent(cur_percent)

	local next_p = self.profit_info.pOld + self.profit_info.pDelta - self.profit_info.pMax

	if next_p > 0 then
		local account = 1 + math.floor(next_p / self.profit_info.pNextMax)
        local arr = CCArray:create()
        for i = 1, account do
        	local max = self.profit_info.pMax
        	local cur_num = self.profit_info.pOld
        	if i > 1 then 
        		max = self.profit_info.pNextMax
        		cur_num = 0
        	end
            arr:addObject(CCCallFunc:create(function()
                self:progressAction(self.bar, 100, DURATION) 
                UiCommon:numberEffect(self.profit_num, cur_num, max, DURATION * 120, nil,"", "/" .. max)
            end))
            arr:addObject(CCDelayTime:create(DURATION))
            arr:addObject(CCCallFunc:create(function()
                -- if self.bar_effect then
                --     self.bar_effect:removeFromParentAndCleanup(true)
                --     self.bar_effect = nil 
                -- end
                -- self.bar_effect = CompositeEffect.new("tx_arena_bar", 0, 0, self.bar_bg, 0.8, nil, nil, nil, true)
                -- self.bar_effect:setScaleX(1.7)
                self.bar:setPercent(0)
                self.profit_num:setText("0/" .. self.profit_info.pNextMax)
            end)) 
        end

        local cur_detla = next_p % self.profit_info.pNextMax
    	local cur_per = cur_detla/self.profit_info.pNextMax * 100
    	local time = DURATION * cur_per / 100
        arr:addObject(CCCallFunc:create(function()
            self:progressAction(self.bar, cur_per, time)         
            --等级
            UiCommon:numberEffect(self.profit_num, 0, cur_detla, DURATION * 120, nil,"", "/" .. self.profit_info.pNextMax)            
        end))

        local endSeq = CCSequence:create(arr)
        self.bar:runAction(endSeq)
    else
    	local cur_profit = self.profit_info.pOld + self.profit_info.pDelta
		local profit_percent = cur_profit/self.profit_info.pMax * 100
		local time = DURATION * (profit_percent - cur_percent) / 100
        self:progressAction(self.bar, profit_percent, time)
        UiCommon:numberEffect(self.profit_num, tonumber(self.profit_info.pOld), tonumber(cur_profit), DURATION * 120, nil, "", "/" .. self.profit_info.pMax)
    end
end

function ClsPortMarketAccountView:progressAction(progressBar, cur, time)
    if not tolua.isnull(progressBar) then
        local lastPercent = progressBar:getPercent()
        local runTime = (cur - lastPercent) * time / 100
        LoadingAction.new(cur, lastPercent, time, progressBar)
    end
end

function ClsPortMarketAccountView:updateEffect()

	if self.profit_info.level then
		local tx_effect
		local color = COLOR_GREEN_STROKE
		if self.profit_info.level == PROFIT_LEVEL_ONE then
			tx_effect = "tx_txt_trade_2"
			color = COLOR_BLUE_STROKE
			audioExt.playEffect(voice_info.VOICE_LOLI_2.res)
		elseif self.profit_info.level == PROFIT_LEVEL_TEO then
			tx_effect = "tx_txt_trade_3"
			color = COLOR_PURPLE_STROKE
			audioExt.playEffect(voice_info.VOICE_LOLI_3.res)
		elseif self.profit_info.level == PROFIT_LEVEL_THREE then
			tx_effect = "tx_txt_trade_4"
			color = COLOR_YELLOW_STROKE
			self.tips_panel:setVisible(false)
			audioExt.playEffect(voice_info.VOICE_LOLI_4.res)
		elseif self.profit_info.level == PROFIT_LEVEL_ZERO then
			tx_effect = "tx_txt_trade_1"
			self.man_pic:setVisible(false)
			color = COLOR_GREEN_STROKE
			audioExt.playEffect(voice_info.VOICE_LOLI_1.res)
		end	
		if tx_effect then
			CompositeEffect.new(tx_effect, 30,108, self.art_txt,nil,nil, nil, nil, true)			
		end
		setUILabelColor(self.gold_num, ccc3(dexToColor3B(color)))
	end	

	local close_array = CCArray:create()
	close_array:addObject(CCDelayTime:create(3)) 
	close_array:addObject(CCCallFunc:create(function (  )
		self:closeMySelf()
	end))
	self:runAction(CCSequence:create(close_array))
end


function ClsPortMarketAccountView:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsPortMarketAccountView:onTouchBegan(x , y)

	-- self.profit_info.level = self.profit_info.level + 1
	-- self:updateEffect()
	-- if self.profit_info.level > 3 then
	-- 	self.profit_info.level = 1
	-- end
	self:closeMySelf()
	return false
end

function ClsPortMarketAccountView:closeMySelf()
	self:close()
	if type(self.call_back) == "function" then
		self.call_back()
	end

	local ClsPortMarket = getUIManager():get("ClsPortMarket")
	if not tolua.isnull(ClsPortMarket) then
		ClsPortMarket:close()
	end	
end

function ClsPortMarketAccountView:onExit( )
	UnLoadPlist(self.plistTab)
end

return ClsPortMarketAccountView