 
---fmy0570
---活动成长基金界面
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local fund_info = require("game_config/activity/fund_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word")
local ClsGrowthFundTab = class("ClsGrowthFundTab", ClsBaseView)

local CARD_NUM = 6
local NO_BUY_FUND_STATUS = 0


local BUY_FUND_KEY = "com.tencent.qmdhh.gift98"
local widget_name = {
	"get_btn",
	"btn_buy_txt",
	"btn_rmb",
	"btn_rmb_num",
	"time_online",
}

function ClsGrowthFundTab:getViewConfig()
	return {is_swallow = false}
end


function ClsGrowthFundTab:onEnter()
    self.plist = {
        ["ui/shop_ui.plist"] = 1,
        ["ui/award_ui.plist"]  = 1,
        ["ui/activity_ui.plist"] = 1,
    }
    LoadPlist(self.plist)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_growth_fund.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	--self:askData()
	self:initUI()
	self:initBtn()
end

function ClsGrowthFundTab:askData()
	local growth_fund_data = getGameData():getGrowthFundData()
	growth_fund_data:askFundInfo()
end


function ClsGrowthFundTab:initBtn()
	self.get_btn:setPressedActionEnabled(true)
	self.get_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		--print("=======================获取基金",BUY_FUND_KEY)
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.beginPay(BUY_FUND_KEY)

	end, TOUCH_EVENT_ENDED)
end


function ClsGrowthFundTab:initUI()

	local growth_fund_data = getGameData():getGrowthFundData()
	self.fund_data_info = growth_fund_data:getFundInfo()
	-- print("=================购买信息=============")
	-- table.print(self.fund_data_info)

	self.card_list = {}
	for i=1,CARD_NUM do

		local  award_card = getConvertChildByName(self.panel, "award_card_"..i)
		self.card_list[i] = award_card

		local level_num = getConvertChildByName(self.panel, "level_num_"..i)
		self.card_list[i].level_num = level_num

		local diamonds_num  = getConvertChildByName(self.panel, "diamonds_num_"..i)
		self.card_list[i].diamonds_num = diamonds_num

		local award_card_btn  = getConvertChildByName(self.panel, "award_card_btn_"..i)
		self.card_list[i].award_card_btn = award_card_btn

		local award_btn_no  = getConvertChildByName(self.panel, "award_btn_no_"..i)
		self.card_list[i].award_btn_no = award_btn_no

		local award_over_txt  = getConvertChildByName(self.panel, "award_over_txt_"..i)
		self.card_list[i].award_over_txt = award_over_txt

		local award_btn_yes  = getConvertChildByName(self.panel, "award_btn_yes_"..i)
		self.card_list[i].award_btn_yes = award_btn_yes

	end
	--self:initBtn()
	self:updateUI()
end

function ClsGrowthFundTab:updateUI()
	local fund_data = fund_info
    local player_level = getGameData():getPlayerData():getLevel()

	for i=1,CARD_NUM do
		local level = fund_data[i].level
		self.card_list[i].level_num:setText(level)
		self.card_list[i].diamonds_num:setText(fund_data[i].gold)

		if self.fund_data_info.is_buy ~= NO_BUY_FUND_STATUS then
			if player_level >= level then
				self:setBtnLableEnable(i, false, true, false)
			else
				self:setBtnLableEnable(i, true, false, false)
			end
		else
			self:setBtnLableEnable(i,true,false,false)	
		end
		
		self.card_list[i].award_card_btn:setPressedActionEnabled(true)
		self.card_list[i].award_card_btn:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if self.fund_data_info.is_buy == NO_BUY_FUND_STATUS then
				Alert:warning({msg = ui_word.NO_BUY_GROWTH_FUND , size = 26})
				return 
			end

            if player_level < fund_data[i].level then
            	Alert:warning({msg = ui_word.GROWTH_FUND_NOT_LEVEL , size = 26})
            	return 
            end
			local growth_fund_data = getGameData():getGrowthFundData()
			growth_fund_data:askFundReward(i)
        end, TOUCH_EVENT_ENDED)
	end

	if self.fund_data_info.taken_list then
		for k,v in pairs(self.fund_data_info.taken_list) do
			self:setBtnLableEnable(v, false, false, true)
			self.card_list[v].award_card_btn:setVisible(false)
		end
	end

	self:updateBtnLable(self.fund_data_info.is_buy == NO_BUY_FUND_STATUS)
end

function ClsGrowthFundTab:setBtnLableEnable(node_tag, no_enable, yes_enable, over_enable)
	self.card_list[node_tag].award_btn_no:setVisible(no_enable)
	self.card_list[node_tag].award_btn_yes:setVisible(yes_enable)
	self.card_list[node_tag].award_over_txt:setVisible(over_enable)		
end


function ClsGrowthFundTab:updateBtnLable(enable)
	self.get_btn:setTouchEnabled(enable)
	self.btn_buy_txt:setVisible(not enable)
	self.btn_rmb:setVisible(enable)
	self.btn_rmb_num:setVisible(enable)
end

function ClsGrowthFundTab:onExit()
    UnLoadPlist(self.plist)
end

return ClsGrowthFundTab
