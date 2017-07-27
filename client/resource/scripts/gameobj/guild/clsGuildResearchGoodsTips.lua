

---商会研究所商品弹框

local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word") 
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local goods_info = require("game_config/port/goods_info")
local port_info = require("game_config/port/port_info")
local ClsGuildResearchGoodsTips = class("ClsGuildResearchGoodsTips",ClsBaseView)


local GOODS_NUM = 100


local tips_name = {
	"btn_close",
	"btn_diamond",
	"btn_handin",
	"handin_txt",
	"item_icon",
	"cost_num",
	"diamond_num",
	"panel_2",
	"panel_1",
	"goods_info",
	"need_num",
	"fly_choose",
	"tips_3",
	"tips_2",
	"txt_2",

	"goods_num_info",
	"btn_contribute",
	"cost_num",
	"goods_port_info",
}

ClsGuildResearchGoodsTips.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.SCALE,
	}
end

ClsGuildResearchGoodsTips.onEnter = function(self, data,type)
	self.res_plist ={
		["ui/item_box.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self.data = data
	self.type = type
	---res,name ,have_amount,need_amount,id
	---商会
	-- 钻石消耗，货物港口

	---交易所
	-- 货物量，金币消耗

	self:initUI(data)
	self:btnCallBack()
	self:initEvent()
end

ClsGuildResearchGoodsTips.initEvent = function(self)
	RegTrigger(CASH_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateCash()
	end)

	RegTrigger(GOLD_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateDiamound()
	end)

end

ClsGuildResearchGoodsTips.updateCash = function(self)
	local player_data = getGameData():getPlayerData()
	if self.data.cost_cash >  player_data:getCash() then
		setUILabelColor(self.cost_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.cost_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end	
end

ClsGuildResearchGoodsTips.updateDiamound = function(self)
	local player_data = getGameData():getPlayerData()
	if self.data.cost_diamound >  player_data:getGold() then
		setUILabelColor(self.diamond_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.diamond_num, ccc3(dexToColor3B(COLOR_WHITE)))
	end
end

ClsGuildResearchGoodsTips.initUI = function(self, data)
	self.ui_layer = UIWidget:create()
	self.tips_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_institute_tips.json")
	convertUIType(self.tips_panel)
	self.ui_layer:addChild(self.tips_panel)
	self:addWidget(self.ui_layer)

	local bg_size = self.tips_panel:getContentSize()
	self:setPosition(ccp(display.cx - bg_size.width/2 , display.cy - bg_size.height/2))

	for k,v in pairs(tips_name) do
		self[v] = getConvertChildByName(self.tips_panel, v)
	end

	self.panel_1:setVisible(self.type == 1)
	self.panel_2:setVisible(self.type == 2)

	self:updateUI(data)
end

ClsGuildResearchGoodsTips.updateUI = function(self, data)
	self.data = data
	getGameData():getGuildResearchData():setResearchSelectSkillInfo(data)

	self.item_icon:changeTexture(convertResources(self.data.res), UI_TEX_TYPE_PLIST)
	self.goods_info:setText(self.data.name)

	self.need_num:setText(string.format("%s/%s",self.data.have_amount,self.data.need_amount))
	local have_goods_num = 0 
	local marketData = getGameData():getMarketData()
	local good_num = marketData:getGoodsInfoById(self.data.id)
	if good_num then
		have_goods_num = good_num
	end

	if self.type == 1 then
		self:updatePanel1()
	else
		self:updatePanel2()
	end

	self.txt_2:setText(string.format(ui_word.GUILD_RESEARCH_TIPS_LAB_1,self.data.get_exp))
	local marketData = getGameData():getMarketData()
	local all_goods,all_goods1 = marketData:getAllGoods()

	self.have_goods_num = have_goods_num
	self.need_goods_num = self.data.need_amount
end

---商会内容
ClsGuildResearchGoodsTips.updatePanel1 = function(self)
	self.diamond_num:setText(self.data.cost_diamound)
	local player_data = getGameData():getPlayerData()
	if self.data.cost_diamound > player_data:getGold() then
		setUILabelColor(self.diamond_num, ccc3(dexToColor3B(COLOR_RED)))
	end

	local port_id_list = goods_info[self.data.id].buy_port

	local port_name = ""
	for k,v in pairs(port_id_list) do
		port_name = port_name..port_info[v].name.." "
	end
	self.goods_port_info:setText(port_name)

	---判断本港口交易所有没有该商品 
	if not self:isGoodPort() then
		self.handin_txt:setText(ui_word.GUILD_RESEARCH_GO_TO_GOODS_PORT)
	end
	self.tips_3:setVisible(not self:isGoodPort())
	self.tips_2:setVisible(self:isGoodPort())
	self.fly_choose:setVisible(not self:isGoodPort())
	local is_fly = getGameData():getGuildResearchData():getFlyStatus()
	self.fly_choose:setSelectedState(is_fly)
end

ClsGuildResearchGoodsTips.isGoodPort = function(self)
	local port_id_list = goods_info[self.data.id].buy_port
	local port_id = getGameData():getPortData():getPortId()
	local is_good_port = false
	for k,v in pairs(port_id_list) do
		if v == port_id then
			is_good_port = true
		end
	end
	return is_good_port
end

----交易所内容
ClsGuildResearchGoodsTips.updatePanel2 = function(self)
	self.cost_num:setText(self.data.cost_cash)
	local player_data = getGameData():getPlayerData()
	if self.data.cost_cash >  player_data:getCash() then
		setUILabelColor(self.cost_num, ccc3(dexToColor3B(COLOR_RED)))
	end
	local marketData = getGameData():getMarketData()
	local market_goods_num = marketData:getGoodsInfoById(self.data.id)
	self.goods_num_info:setText(market_goods_num)
end

----研究技能完刷新界面
ClsGuildResearchGoodsTips.updateGoodsLab = function(self, data)
	if data.key ~= self.data.skill_key then return end 
	local have_amount = 0
	local need_amount = 0
	local is_port_goods = false
	for k,v in pairs(data.list) do
		if v.mate_id == self.data.id then
			have_amount = v.mate_curr
			need_amount = v.mate_need
			is_port_goods = true
		end
	end

	local marketData = getGameData():getMarketData()
	local market_goods_num = marketData:getGoodsInfoById(self.data.id)
	self.goods_num_info:setText(market_goods_num)

	if not is_port_goods then
		need_amount = self.data.need_amount
		have_amount = self.data.need_amount
	end
	self.need_num:setText(string.format("%s/%s",have_amount,need_amount))
	self.data.have_amount = have_amount
	self.data.need_amount = need_amount
end

---商品数量发生变化刷新界面
ClsGuildResearchGoodsTips.updateGoodsInfo = function(self)
	local marketData = getGameData():getMarketData()
	local good_num  = marketData:getGoodsInfoById(self.data.id)
	self.have_goods_num = good_num
end

ClsGuildResearchGoodsTips.btnCallBack = function(self)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end,TOUCH_EVENT_ENDED)

	self.btn_diamond:setPressedActionEnabled(true)
	self.btn_diamond:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.data.have_amount >= self.data.need_amount then
			Alert:warning({msg = ui_word.GUILD_RESEARCH_GOODS_FULL, size = 26})
			return 
		end

		---钻石不足
		local cost = self.data.cost_diamound 
		local playerData = getGameData():getPlayerData()
		if playerData:getGold() >= cost then
			local skill_id = self.data.skill_key
			local mate_id = self.data.id
			local guild_research_data = getGameData():getGuildResearchData()
			local researchByDiamound
			researchByDiamound = function(  )
				guild_research_data:askResearchByDiamound(skill_id, mate_id)
			end

			local tips_open_status = guild_research_data:getResearchTipsStatus()
			if tips_open_status then
				researchByDiamound()
			else
				getUIManager():create("gameobj/guild/clsGuildSkillGoodsDiamoundTips",nil,researchByDiamound,self.data.cost_diamound)
			end
		else
			Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self)
		end
	end,TOUCH_EVENT_ENDED)

	self.btn_handin:setPressedActionEnabled(true)
	self.btn_handin:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		--判断该物品交易所中不存在 导航去有该商品的港口
		if self.data.have_amount >= self.data.need_amount then
			Alert:warning({msg = ui_word.GUILD_RESEARCH_GOODS_FULL, size = 26})
			self:close()
			return 
		end

		local open_portmarket_good_tips = 2
		if not self:isGoodPort() then
			local portData = getGameData():getPortData()
			local port_id_list = goods_info[self.data.id].buy_port
			local goal_port_id = port_id_list[1]

			portData:setEnterPortCallBack(function() 
				if getGameData():getPortData():getPortId() == goal_port_id then
					getUIManager():create("gameobj/port/portMarket",{}, nil, open_portmarket_good_tips)
				end
			end)

			local is_fly = getGameData():getGuildResearchData():getFlyStatus()
			if is_fly then
				local type_n = EXPLORE_TRANSFER_TYPE.PORT
				getGameData():getExploreData():askExploreTransfer(type_n, goal_port_id)
				return
			end

			local supplyData = getGameData():getSupplyData()
			supplyData:askSupplyInfo(true, function()
				local mapAttrs = getGameData():getWorldMapAttrsData()
				mapAttrs:goOutPort(goal_port_id, EXPLORE_NAV_TYPE_PORT)
			end)
		else
			self:close()
			getUIManager():create("gameobj/port/portMarket",{}, nil, open_portmarket_good_tips)
		end
	end,TOUCH_EVENT_ENDED)

	----捐献
	self.btn_contribute:setPressedActionEnabled(true)
	self.btn_contribute:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.data.have_amount >= self.data.need_amount then
			Alert:warning({msg = ui_word.GUILD_RESEARCH_GOODS_FULL, size = 26})
			return 
		end

		local cost = self.data.cost_cash 
		local playerData = getGameData():getPlayerData()
		if self.have_goods_num < GOODS_NUM then
			Alert:warning({msg = ui_word.GUILD_RESEARCH_GOODS_NUM_NOT_EN, size = 26})
		else
			if playerData:getCash() < cost then
				Alert:showJumpWindow(CASH_NOT_ENOUGH, self, {need_cash = cost})
				return 
			end
			local skill_id = self.data.skill_key
			local mate_id = self.data.id
			local guild_research_data = getGameData():getGuildResearchData()
			guild_research_data:askResearchByMate(skill_id, mate_id)
		end
	end,TOUCH_EVENT_ENDED)


	self.fly_choose:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local guild_research_data = getGameData():getGuildResearchData()
		guild_research_data:setFlyStatus(true)
	end,CHECKBOX_STATE_EVENT_SELECTED)

	self.fly_choose:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local guild_research_data = getGameData():getGuildResearchData()
		guild_research_data:setFlyStatus(false)
	end,CHECKBOX_STATE_EVENT_UNSELECTED)
end

ClsGuildResearchGoodsTips.goodsIsMarket = function(self, good_id)
	local marketData = getGameData():getMarketData()
	local market_goods_list = marketData:getGuildNeedGoods()
	if #market_goods_list < 1 then return false end
	for k,v in pairs(market_goods_list) do
		if v.id == good_id then
			return true
		end
	end
	return false
end

ClsGuildResearchGoodsTips.onExit = function(self)
	UnRegTrigger(GOLD_UPDATE_EVENT)
	UnRegTrigger(CASH_UPDATE_EVENT)
	UnLoadPlist(self.res_plist)
end

return ClsGuildResearchGoodsTips