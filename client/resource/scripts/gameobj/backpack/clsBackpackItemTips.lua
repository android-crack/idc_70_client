-- 背包通用tips
-- Author: chenlurong
-- Date: 2016-07-19 10:35:36
--
local music_info=require("scripts/game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local item_info = require("game_config/propItem/item_info")
local error_info = require("game_config/error_info")
local on_off_info = require("game_config/on_off_info")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local nobility_data = require("game_config/nobility_data")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

local ClsBackpackItemTips = class("ClsBackpackItemTips", ClsBaseTipsView)

function ClsBackpackItemTips:getViewConfig(name_str, params, item_type, item_data)
	return ClsBackpackItemTips.super.getViewConfig(self, name_str, params, item_type, item_data)
end

function ClsBackpackItemTips:onEnter(name_str, params, item_type, item_data, sailor_id, boat_key)
	self.boat_key = boat_key
	self.item_data = item_data
	self.item_type = item_type
	self.sailor_id = sailor_id or -1 
	self:showTips(name_str, params)
end

--显示数据
function ClsBackpackItemTips:showTips(name_str, params)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_tips.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	ClsBackpackItemTips.super.onEnter(self, name_str, params, self.panel, true)

	self.panel:setPosition(ccp(260, 70))

	self.item_icon = getConvertChildByName(self.panel, "box_icon")
	self.item_bg = getConvertChildByName(self.panel, "box_bg")
	self.item_name = getConvertChildByName(self.panel, "box_name")
	self.item_num = getConvertChildByName(self.panel, "box_tips_num")
	self.item_intro = getConvertChildByName(self.panel, "box_introduce")

	self.btn_use = getConvertChildByName(self.panel, "btn_use")

	self.btn_use_right = getConvertChildByName(self.panel, "btn_use_right")
	self.btn_compound_right = getConvertChildByName(self.panel, "btn_compound_right")

	self.btn_cost = getConvertChildByName(self.panel, "btn_cost")
	self.btn_cost_left = getConvertChildByName(self.panel, "btn_cost_left")
	self.btn_cost_right = getConvertChildByName(self.panel, "btn_cost_right")

	local item_config = self.item_data.baseData
	local quality = item_config.quality or item_config.level
	setUILabelColor(self.item_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	self.item_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)

	self.item_icon:changeTexture(convertResources(item_config.res), UI_TEX_TYPE_PLIST)
	self.item_name:setText(item_config.name)
	self.item_num:setText(self.item_data.count)
	self.item_intro:setText(item_config.desc)
	self.item_acount = self.item_data.count
	
	self.btn_sell = getConvertChildByName(self.panel, "btn_sell")
	self.btn_compound = getConvertChildByName(self.panel, "btn_compound")

	if item_config.consume and #item_config.consume > 0 then
		self:showComsumeCommonBtn(item_config.consume)
		return
	end
	self:showCommonBtn()

end

function ClsBackpackItemTips:updateCostTextColor(consume_type, consume_amount, ui_text)
	local cur_num = 0
	if consume_type == ITEM_INDEX_CONTRIBUTE then
		local guild_shop_data = getGameData():getGuildShopData()
		cur_num = guild_shop_data:getContribute()
	elseif consume_type == ITEM_INDEX_CASH then
		local player_data = getGameData():getPlayerData()
		cur_num = player_data:getCash()
	elseif consume_type == ITEM_INDEX_GOLD then
		local player_data = getGameData():getPlayerData()
		cur_num = player_data:getGold()
	end
	if cur_num < consume_amount then
		setUILabelColor(ui_text, ccc3(dexToColor3B(COLOR_RED)))
	end
end

--sailor_id --这个是船舶皮肤的传入的字段 -1是主角，或者为水手id
function ClsBackpackItemTips:useSelectCostItem(cost_type, sailor_id)
	local prop_item = self.item_data.baseData
	local collectDataHandle = getGameData():getCollectData()
	collectDataHandle:sendUseItemMessage(self.item_data.id, nil, sailor_id, cost_type)
	if self.item_acount == 1 or prop_item.uselimit == ITEM_USE_LIMIT_STATE then
		self:close()
	end
end

function ClsBackpackItemTips:showComsumeCommonBtn(consume_list)
	self.btn_use:setVisible(false)


	local player_data = getGameData():getPlayerData()
	local player_level = player_data:getLevel()
	local item_use_cost = require("game_config/propItem/item_use_cost")
	self.update_text_list = {}

	local consume_len = #consume_list
	if consume_len > 1 then
		self.btn_cost_left:setVisible(true)
		self.btn_cost_right:setVisible(true)
		local consume_pic_left = getConvertChildByName(self.btn_cost_left, "cost_icon_left")
		local consume_num_txt_left = getConvertChildByName(self.btn_cost_left, "cost_num_left")
		self.update_text_list[1] = {btn = self.btn_cost_left, pic = consume_pic_left, ui_text = consume_num_txt_left}
		local consume_pic_right = getConvertChildByName(self.btn_cost_right, "cost_icon_right")
		local consume_num_txt_right = getConvertChildByName(self.btn_cost_right, "cost_num_right")
		self.update_text_list[2] = {btn = self.btn_cost_right, pic = consume_pic_right, ui_text = consume_num_txt_right}
	else
		self.btn_cost:setVisible(true)
		local consume_pic = getConvertChildByName(self.btn_cost, "consume_pic")
		local consume_num_txt = getConvertChildByName(self.btn_cost, "consume_num")
		self.update_text_list[1] = {btn = self.btn_cost, pic = consume_pic, ui_text = consume_num_txt}
	end

	for i,v in ipairs(consume_list) do
		local item_use_cost_config = item_use_cost[player_level]
		local consume_amount = item_use_cost_config[v[2]]
		local consume_type = ITEM_TYPE_MAP[v[1]]
		local update_item = self.update_text_list[i]
		if update_item then
			update_item.ui_text:setText(consume_amount)
			local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon({["key"] = consume_type, ["value"] = consume_amount})
			update_item.pic:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
			
			self.update_text_list[i].consume_type = consume_type
			self.update_text_list[i].consume_amount = consume_amount
			self:updateCostTextColor(consume_type, consume_amount, update_item.ui_text)
			self:addUseBtnEvent(update_item.btn, function()
				self:useSelectCostItem(consume_type)
			end)
		end
	end
end

function ClsBackpackItemTips:showCommonBtn()
	local btn_use = nil
	local btn_compound = nil
	local btn_sell = nil

	local item_config = self.item_data.baseData
	if item_config.canSell and item_config.canSell == 1 then
		--可以卖的话
		self.btn_use:setVisible(false)
		self.btn_sell:setVisible(true)
		self.btn_compound:setVisible(false)
		btn_sell = self.btn_sell
		
		if (item_config.flag and item_config.flag == 1) --消耗物品的话，有合成和使用按钮
			or (item_config.cansynthetic and item_config.cansynthetic == 1) then--消耗道具的话，有合成时候
			self.btn_compound_right:setVisible(true)
			btn_compound = self.btn_compound_right
		else
			self.btn_use_right:setVisible(true)
			btn_use = self.btn_use_right
		end
	elseif (item_config.flag and item_config.flag == 1) --消耗物品的话，有合成和使用按钮
		or (item_config.cansynthetic and item_config.cansynthetic == 1) then--消耗道具的话，有合成时候
		self.btn_use:setVisible(false)
		self.btn_compound:setVisible(true)
		self.btn_use_right:setVisible(true)
		btn_use = self.btn_use_right
		btn_compound = self.btn_compound
	else
		self.btn_use:setVisible(true)
		btn_use = self.btn_use
	end

	if btn_use then
		self:addUseBtnEvent(btn_use)
	end

	if btn_compound then
		btn_compound:setPressedActionEnabled(true)
		btn_compound:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:close()
			self:compoundItemOperate()
		end,TOUCH_EVENT_ENDED)  
	end

	if btn_sell then
		btn_sell:setPressedActionEnabled(true)
		btn_sell:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local sell_get = item_config.sell_get
			local total_get
			local get_type
			for k,v in pairs(sell_get) do
				if not get_type then
					get_type = ITEM_TYPE_MAP[k]
					total_get = v * self.item_data.count
				end
			end

			local str = string.format(ui_word.BACKPACK_SELL_CONFIRM_TIPS, self.item_data.count, item_config.name)

			Alert:showCostDetailTips(str, nil, get_type, nil, total_get, ui_word.BACKPACK_SELL_CONFIRM_GET_STR, function()
				local collectDataHandle = getGameData():getCollectData()
				collectDataHandle:askSellItem(self.item_type, self.item_data.id, self.item_data.count)
				self:close()
			end)
		end,TOUCH_EVENT_ENDED)   
	end
end

function ClsBackpackItemTips:addUseBtnEvent(btn_use, use_fun)
	local prop_item = self.item_data.baseData

	btn_use.last_time = 0
	btn_use:setPressedActionEnabled(true)
	btn_use:addEventListener(function()
		if CCTime:getmillistimeofCocos2d() - btn_use.last_time > 500 then 
			audioExt.playEffect(music_info.COMMON_BUTTON.res)

			local is_scence = getGameData():getSceneDataHandler():isInCopyScene()
			if prop_item.sceneuse == 1 and is_scence then
				Alert:warning({msg = ui_word.BACKPCAK_ITEM_NO_USE})
				self:close()
				return 
			end

			if use_fun then
				use_fun()
			else
				self:useItemOperate()	
			end
			btn_use.last_time = CCTime:getmillistimeofCocos2d()
		end
	end,TOUCH_EVENT_ENDED)

	if (not getGameData():getSceneDataHandler():isInPortScene()) and prop_item.is_sea_use_hidden > 0 then
		btn_use:setEnabled(false)
	end
end

function ClsBackpackItemTips:useItemOperate()
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local prop_item = self.item_data.baseData
	local teamData = getGameData():getTeamData()

	local function useBaoWuBox()
		local baowu_data = getGameData():getBaowuData()
		baowu_data:askUseBaowuBox(self.item_data.id)
		if self.item_acount == 1 or prop_item.uselimit == ITEM_USE_LIMIT_STATE then
			self:close()
		end
	end
	local function usePaper()
		if prop_item.uselimit == ITEM_USE_LIMIT_STATE then
			if ClsSceneManage:doLogic("checkAlert") then return end
		end

		if prop_item.cantips == ITEM_USE_TIPS then
			--使用高级藏宝图
			local status = getGameData():getOnOffData():isOpen(on_off_info.ORGANIZETEAM.value)
			if not status then
				Alert:warning({msg = ui_word.NO_TEAM_TO_MAP})
				return
			end

			local scene_data_handle = getGameData():getSceneDataHandler()
			if scene_data_handle:isInCopyScene() then
				Alert:warning({msg = ui_word.STR_LEAVE_ACITITY})
				return 
			end
			
			Alert:showTipWindow(TIP_WIN_LONG_BTN, function()
				self:useSelectCostItem()
			end)
			return 
		elseif prop_item.cantips == ITEM_USE_HOTSELL_TIPS then
			Alert:showAttention(news.PORT_MARKET_HOT_SELL_CONFIRM.msg, function()
				self:useSelectCostItem()
			end)
			return
		elseif prop_item.backpack_type == PROP_ITEM_BACKPACK_SKIN then

			 local partner_data = getGameData():getPartnerData()
			local skin_data = partner_data:getBagEquipSkinByBoatKey(self.boat_key)
			if skin_data then
				Alert:showAttention(news.PORT_MARKET_HOT_SELL_CONFIRM.msg, function()
				self:useSelectCostItem(nil, self.sailor_id)
				end)
			else
				self:useSelectCostItem(nil, self.sailor_id)
			end
			
			return
		else
			self:useSelectCostItem()
		end
	end
	local function useOtherItem()
		self:close()
		local skip_ui = prop_item.skipUI
		if skip_ui and skip_ui ~= "" then
			local switch = prop_item.switch
			if switch and switch ~= "" then
				local onOffData = getGameData():getOnOffData()
				if not onOffData:isOpen(on_off_info[switch].value) then 
					Alert:warning({msg = news.WAREHOUSE_USE_LOCK.msg})
					return
				end
			end
			if string.sub(skip_ui, 1, 5) == "guild" then --跳转到商会
				local guild_info_data = getGameData():getGuildInfoData()
				if not guild_info_data:hasGuild() then --没有商会，就提示
					Alert:warning({msg = ui_word.STR_GUILD_ADD_TIPS})
				end
			end

			if skip_ui == "ports" then
				local mapAttrs = getGameData():getWorldMapAttrsData()
				local portData = getGameData():getPortData()
				local port_id = portData:getPortId() -- 当前港口id
				mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE)
				return
			end
			local skip_layer = missionSkipLayer:skipLayerByName(skip_ui, nil)
		end
	end
	local event_by_item_type = {
		[ITEM_USE_BAOWU_BOX] = useBaoWuBox,
		[ITEM_USE_TYPE] = usePaper,
	}
	local function useItem()
		if prop_item.use_item_type and event_by_item_type[prop_item.use_item_type] then
			event_by_item_type[prop_item.use_item_type]()
		else
			useOtherItem()
		end
	end
	local function goBackPort()
		if ClsSceneManage:doLogic("checkAlert") then return end

		local port_info = require("game_config/port/port_info")
		local portData = getGameData():getPortData()
		local portName = port_info[portData:getPortId()].name
		local tips = require("game_config/tips")
		local str = string.format(tips[77].msg, portName)
		Alert:showAttention(str, function()
				if teamData:isLock() then
					Alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_ACCEPT_TIP})
					return
				end
				self:close()          
				portData:setEnterPortCallBack(function() 
					getUIManager():create("gameobj/backpack/clsBackpackMainUI")
				end)
				portData:askBackEnterPort()
		end, nil, nil, {hide_cancel_btn = true})
	end

	--队伍锁
	if prop_item.is_team_use_lock > 0 and teamData:isLock() then
		Alert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
		return
	end
	--海上也锁
	if prop_item.is_sea_use_lock > 0 and (not getGameData():getSceneDataHandler():isInPortScene()) then 
		goBackPort()
		return
	end
	
	useItem()
end

--装配材料面板-------------------------------
local function getMaterialSynthetiseInfo( config )
	local equip_material_info = require("game_config/boat/equip_material_info")
	for k,v in pairs(equip_material_info) do
		if v.type == config.type and v.level == (config.level + 1) then
			return v
		end
	end
	return nil
end

function ClsBackpackItemTips:compoundItemOperate()
	local item_config = self.item_data.baseData

	--爵位够才显示
	local current_level = getGameData():getNobilityData():getCurrentNobilityData().level
	local nobility_config = nobility_data[item_config.noblelimit]
	if nobility_config then -- 有爵位才判断
		if current_level < nobility_config.level then
			Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_NOBILITY_STR, nobility_config.title)})
			return
		end
	end

	local baowu_data = getGameData():getBaowuData()
	if item_config.cansynthetic and item_config.cansynthetic == 1 then--直接可以合成
		local have_count = self.item_data.count
		local cell_num = item_config.synthetic_num
		local synthetic_item = item_info[item_config.synthetic_item]
		local player_info = getGameData():getPlayerData()
		if player_info:getLevel() < item_config.levellimit then
			Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_LEVEL_STR, item_config.levellimit)})	
		elseif have_count >= cell_num then
			local num = math.floor(have_count / cell_num)
			local need_total = num * cell_num
			local alert_text = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_ALERT, need_total, item_config.name)
			local get_str = string.format("%s %s", synthetic_item.name, num)
			Alert:showCostDetailTips(alert_text, nil, ITEM_INDEX_PROP, item_config.synthetic_item, get_str, nil, function()
				baowu_data:askBaowuSynthetise(self.item_data.id)
			end)

		else
			Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_NEED_STR, cell_num)})
		end	
	elseif item_config.flag and item_config.flag == 1 then
		if item_config.level >= 6 then--最高级
			Alert:warning({msg = error_info[371].message})
		else
			local material_count = self.item_data.count
			if material_count >= item_config.need then
				local num = math.floor(material_count/item_config.need)
				local need_total = num * item_config.need
				local synthetise_config = getMaterialSynthetiseInfo(item_config)
				local alert_text = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_ALERT, need_total, item_config.name)
				local get_str = string.format("%s %s", synthetic_item.name, num)
				Alert:showCostDetailTips(alert_text, nil, ITEM_INDEX_MATERIAL, item_config.synthetic_item, get_str, nil, function()
					baowu_data:askMaterialSynthetise(self.item_data.id)
				end)
			else
				Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_NEED_STR, item_config.need)})
			end
		end
	else
		Alert:warning({msg = error_info[370].message})
	end
end

--更新tips中的数量数据
function ClsBackpackItemTips:updateTipsItemNums(item_id, amount)
	if self.item_data.id == item_id then
		local prop_data_dandler = getGameData():getPropDataHandler()
		local prop_item = prop_data_dandler:get_propItem_by_id(item_id)
		if not prop_item then
			self:close()
			return
		end
		self.item_acount = prop_item.count
		self.item_num:setText(self.item_acount)

		if self.update_text_list then
			for i,v in ipairs(self.update_text_list) do
				table.print(v)
				self:updateCostTextColor(v.consume_type, v.consume_amount, v.ui_text)
			end
		end
	end
end

return ClsBackpackItemTips
