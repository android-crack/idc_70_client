-- 宝物洗练界面
-- Author: chenlurong
-- Date: 2016-07-04 17:40:09
--

local music_info=require("scripts/game_config/music_info")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local base_attr_info = require("game_config/base_attr_info")
local base_info = require("game_config/base_info")
local sailor_info = require("game_config/sailor/sailor_info")
local baozang_info = require("game_config/collect/baozang_info")
local on_off_info = require("game_config/on_off_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local dataTools = require("module/dataHandle/dataTools")
local composite_effect = require("gameobj/composite_effect")

local default_baowu_key
local star_total = 4
--------------------------------------宝物洗练伙伴元件----------------------------------
local clsBaowuRefineItem = class("clsBaowuRefineItem", require("ui/view/clsScrollViewItem"))

clsBaowuRefineItem.initUI = function(self, cell_data)
	self.call_back = cell_data.call_back
	self.list_index = cell_data.index
	self.sailor_id = cell_data.sailor_id
	self.cell_num = 3

	self.item_list = {}
	self.bounding_list = {}
	local item_width = 113
	for i=1,self.cell_num do
		local item_size = CCSize(84, 84)
		local bounding_layer = display.newLayer()
		bounding_layer:setContentSize(CCSize(item_size.width, item_size.height))
		bounding_layer:setPosition(ccp(item_width * (i - 1), 0))
		self:addCCNode(bounding_layer)
		self.bounding_list[i] = bounding_layer
	end
	self:mkUi()
end

clsBaowuRefineItem.mkUi = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_list.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	self.partner_text = getConvertChildByName(self.panel, "partner_text")
	self.player_name = getConvertChildByName(self.panel, "player_name")

	if self.sailor_id ~= 0 then
		local partner_data = getGameData():getPartnerData()
		self.select_bag_equip = partner_data:getBagEquipInfo(self.list_index)

		if self.select_bag_equip.id == -1 then
			self.partner_text:setText(ui_word.BACKPCAK_ROLE_TAB_STR)
			local player_data = getGameData():getPlayerData()
			self.player_name:setText(player_data:getName())
		else
			local sailor = sailor_info[self.select_bag_equip.id]
			self.player_name:setText(sailor.name)
		end
		self.partner_baowu = self.select_bag_equip.partnerBaowu
	else
		self.player_name:setText("")
	end

	local baowu_data = getGameData():getBaowuData()
	self.baowu_list = {}
	for i=1,self.cell_num do
		local baowu_res = {}
		baowu_res.btn = getConvertChildByName(self.panel, "btn_baowu_" .. i)
		baowu_res.icon = getConvertChildByName(self.panel, "baowu_icon_" .. i)
		baowu_res.select = getConvertChildByName(self.panel, "btn_baowu_selected_" .. i)
		self.baowu_list[i] = baowu_res
		self.baowu_list[i].baowu_star = {}
		for star_index=1,star_total do
			self.baowu_list[i].baowu_star[star_index] = getConvertChildByName(self.panel, string.format("star_%s_%s", i, star_index))
		end

		if self.partner_baowu and string.len(self.partner_baowu[i]) > 0 then
			local baowu_key = self.partner_baowu[i]
			
			local baowu_item_data = baowu_data:getInfoById(baowu_key)
			local baowu_config = baozang_info[baowu_item_data.baowuId]
			local item_res = baowu_config.res
			baowu_res.icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
			baowu_res.id = baowu_key

			local quality = baowu_item_data.color
			local btn_res = string.format("item_box_%s.png", quality)
			baowu_res.btn:changeTexture(btn_res, UI_TEX_TYPE_PLIST)

			if not default_baowu_key then 
				self.call_back(self, i, baowu_key)
				default_baowu_key = baowu_key
			elseif baowu_key == default_baowu_key then
				self.call_back(self, i, baowu_key)
			end

		else
			baowu_res.select:setVisible(false)
			baowu_res.icon:setVisible(false)
		end
	end
	self:updateStarLevel()
end

clsBaowuRefineItem.updateStarLevel = function(self)
	if not self.baowu_list then
		return
	end
	local partner_data = getGameData():getPartnerData()
	self.select_bag_equip = partner_data:getBagEquipInfo(self.list_index)
	local baowu_data = getGameData():getBaowuData()
	for cell_pos=1,self.cell_num do
		local star_icon_list = self.baowu_list[cell_pos].baowu_star
		local refine_attr
		local baowu_config
		if self.partner_baowu and string.len(self.partner_baowu[cell_pos]) > 0 then
			local baowu_key = self.partner_baowu[cell_pos]
			local baowu_item_data = baowu_data:getInfoById(baowu_key)
			baowu_config = baozang_info[baowu_item_data.baowuId]
			for i,v in ipairs(self.select_bag_equip.refineAttr) do
				if v and v.index == cell_pos then
					refine_attr = v.refine
				end
			end
		end
		local star_level = 0
		if refine_attr then
			star_level = dataTools:calBaowuStarLevel(refine_attr, baowu_config)
		end
		for star_index = 1, star_total do
			local star_icon = star_icon_list[star_index]
			if star_level > (star_index - 1) * 2 then
				star_icon:setVisible(true)
				local star_res = "common_star3.png"
				if (star_level - (star_index * 2)) >= 0 then
					star_res = "common_star1.png"
				end
				star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
			else
				star_icon:setVisible(false)
			end
		end
	end
end

clsBaowuRefineItem.onTap = function(self, x, y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)
	for k, button in pairs (self.bounding_list) do
		if button:boundingBox():containsPoint(node_pos) then
			local select_item = self.baowu_list[k]
			if select_item.id and not select_item.is_selected then
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				self.call_back(self, k, select_item.id)
			end
		end
	end
end

clsBaowuRefineItem.getListIndex = function(self)
	return self.list_index
end

clsBaowuRefineItem.changeSelectState = function(self, pos, state)
	local baowu_item = self.baowu_list[pos]
	if baowu_item.is_selected ~= state then
		baowu_item.select:setVisible(state)
	end
	baowu_item.is_selected = state
end

------------------------------------------------------------------------------------------

local ClsBaowuRefineUI = class("ClsBaowuRefineUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
ClsBaowuRefineUI.getViewConfig = function(self)
	return {
		name = "ClsBaowuRefineUI",       --(选填）默认 class的名字
		type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
		-- is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
		effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
	}
end

ClsBaowuRefineUI.onEnter = function(self, index, baowu_key)
	self.plist_tab = {
		["ui/backpack.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.plist_tab)

	self.select_index = index
	default_baowu_key = baowu_key
	self.attr_num = 4
	self.ask_refine_check = false
	self.lock_list = {
		[1] = 0,
		[2] = 1,
		[3] = 1,
		[4] = 2,
	}

	self:initUI()
	self:initEvent()

	if index == nil and baowu_key == nil then
		local partner_data = getGameData():getPartnerData()	
		partner_data:askBagEquipInfo()
	else
		self:showpartnerInfo()
	end
	
end

ClsBaowuRefineUI.initUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.baowu_icon = getConvertChildByName(self.panel, "baowu_icon")
	self.baowu_icon_new = getConvertChildByName(self.panel, "baowu_icon_d")
	self.baowu_icon:setVisible(false)
	self.baowu_icon_new:setVisible(false)

	self.old_attr_list = {}
	self.new_attr_list = {}
	local old_bar_light_pos
	local new_bar_light_pos
	for i=1,self.attr_num do
		old_attr_list = {}
		old_attr_list.attr = getConvertChildByName(self.panel, string.format("property_%s", i))
		old_attr_list.default = getConvertChildByName(self.panel, string.format("property_txt%s", i))
		old_attr_list.lock = getConvertChildByName(self.panel, string.format("lock_icon_%s", i))
		old_attr_list.bar_bg = getConvertChildByName(self.panel, string.format("bar_bg_%s", i))
		old_attr_list.bar = getConvertChildByName(self.panel, string.format("bar_%s", i))
		old_attr_list.bar_light = getConvertChildByName(self.panel, string.format("bar_light_%s", i))
		old_attr_list.property_num = getConvertChildByName(self.panel, string.format("property_num_%s", i))
		old_attr_list.damage_icon = getConvertChildByName(self.panel, string.format("damage_icon_%s", i))
		old_attr_list.bar_full = getConvertChildByName(self.panel, string.format("bar_full_%s", i))
		old_bar_light_pos = old_attr_list.bar_light:getPosition()
		old_attr_list.bar_light_pos = ccp(old_bar_light_pos.x, old_bar_light_pos.y)
		self.old_attr_list[i] = old_attr_list
		old_attr_list.lock:setVisible(false)
		old_attr_list.default:setVisible(true)
		old_attr_list.default:setText("")
		old_attr_list.bar_bg:setVisible(false)

		new_attr_list = {}
		new_attr_list.attr = getConvertChildByName(self.panel, string.format("property_%s_d", i))
		new_attr_list.default = getConvertChildByName(self.panel, string.format("property_txt_d%s", i))
		new_attr_list.bar_bg = getConvertChildByName(self.panel, string.format("bar_bg_%s_d", i))
		new_attr_list.bar = getConvertChildByName(self.panel, string.format("bar_%s_d", i))
		new_attr_list.bar_light = getConvertChildByName(self.panel, string.format("bar_light_%s_d", i))
		new_attr_list.property_num = getConvertChildByName(self.panel, string.format("property_num_%s_d", i))
		new_attr_list.damage_icon = getConvertChildByName(self.panel, string.format("damage_icon_%s_d", i))
		new_attr_list.arrow = getConvertChildByName(self.panel, string.format("arrow_%s", i))
		new_attr_list.bar_full = getConvertChildByName(self.panel, string.format("bar_full_%s_d", i))
		new_bar_light_pos = new_attr_list.bar_light:getPosition()
		new_attr_list.bar_light_pos = ccp(new_bar_light_pos.x, new_bar_light_pos.y)
		self.new_attr_list[i] = new_attr_list
		new_attr_list.default:setVisible(true)
		new_attr_list.default:setText("")
		new_attr_list.bar_bg:setVisible(false)
		new_attr_list.arrow:setVisible(false)
	end

	self.baowu_star = {}
	self.baowu_star_new = {}
	for i=1,4 do
		self.baowu_star[i] = getConvertChildByName(self.panel, string.format("star_%s", i))
		self.baowu_star_new[i] = getConvertChildByName(self.panel, string.format("star_%s_d", i))
	end

	self.consume_num = getConvertChildByName(self.panel, "consume_num")
	self.btn_save = getConvertChildByName(self.panel, "btn_save")
	self.btn_refine = getConvertChildByName(self.panel, "btn_xilian")
	self.diamond_cost = getConvertChildByName(self.panel, "diamond_cost")
	self.diamond_icon = getConvertChildByName(self.panel, "xilian_diamond")
	self.btn_xilian_text = getConvertChildByName(self.panel, "btn_xilian_text")
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.btn_breakthrough = getConvertChildByName(self.panel,"btn_breakthrough")
	self.btn_tips = getConvertChildByName(self.panel,"btn_tips")
	self.wash_panel = getConvertChildByName(self.panel,"wash_panel")
	self.prestige_num_d = getConvertChildByName(self.panel,"prestige_num_d")
	self.prestige_num = getConvertChildByName(self.panel,"prestige_num")
	self.tips_text = getConvertChildByName(self.panel,"tips_text")
	self.consume_num:setText("")
	self.btn_save:disable()
	self.btn_save:setTouchEnabled(false)
	self.btn_refine:disable()
	self.btn_refine:setTouchEnabled(false)

	ClsGuideMgr:tryGuide("ClsBaowuRefineUI")
	self.btn_refine.last_time = 0
end

ClsBaowuRefineUI.initEvent = function(self)
	for i=1,self.attr_num do
		self.old_attr_list[i].lock:addEventListener(function()
			local cur_lock = self.old_attr_list[i].lock
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if cur_lock.is_select then
				self.lock_cur_num = self.lock_cur_num - 1
				cur_lock.is_select = false
				cur_lock:setGray(true)
				self:updateRefineEssenceInfo()
				self.old_attr_statue[i].lock = false
			elseif self.lock_cur_num < self.lock_max_num then
				self.lock_cur_num = self.lock_cur_num + 1
				cur_lock.is_select = true
				cur_lock:setGray(false)
				self:updateRefineEssenceInfo()
				self.old_attr_statue[i].lock = true
			else
				Alert:warning({msg = string.format(ui_word.BAOWU_ATTR_LOCK_NUM_TIPS, self.lock_max_num)})

			end
		end, TOUCH_EVENT_ENDED)
	end

	self.btn_save:setPressedActionEnabled(true)
	self.btn_save:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local need_confirm_str = self:getSaveConfirmTips()
			if need_confirm_str then
				Alert:showAttention(ui_word.BACKPACK_REFINE_SAVE_CONFIRM_TIPS, function()
					self:setTouch(false)
					local baowu_data_handler = getGameData():getBaowuData()
					baowu_data_handler:askRefiningSave(self.select_index, self.select_baowu_pos)
				end, nil, nil, {hide_close_btn = true})
			else
				self:setTouch(false)
				local baowu_data_handler = getGameData():getBaowuData()
				baowu_data_handler:askRefiningSave(self.select_index, self.select_baowu_pos)
			end
		end,TOUCH_EVENT_ENDED)

	self.btn_refine:setPressedActionEnabled(true)
	self.btn_refine:addEventListener(function()
			if CCTime:getmillistimeofCocos2d() - self.btn_refine.last_time < 800 then return end
			self.btn_refine.last_time = CCTime:getmillistimeofCocos2d()

			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local player_date = getGameData():getPlayerData()
			if self.essence > self.essence_sum then
				Alert:showJumpWindow(BAOWU_JINGHUA_NOT_ENOUGH, self, {come_type = Alert:getOpenShopType().VIEW_3D_TYPE})
			elseif self.diamond_num > player_date:getGold() then
				Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self, {come_type = Alert:getOpenShopType().VIEW_3D_TYPE})
			else
				local star_list, need_confirm_str = self:getLockAttrData()
				if need_confirm_str then
					Alert:showAttention(need_confirm_str, function()
						self.btn_refine:setTouchEnabled(false)
						self:setTouch(false)
						local baowu_data_handler = getGameData():getBaowuData()
						baowu_data_handler:askRefining(self.select_index, self.select_baowu_pos, star_list)
					end, nil, nil, {hide_close_btn = true, is_add_touch_close_bg = false})
				else
					self.btn_refine:setTouchEnabled(false)
					self:setTouch(false)
					local baowu_data_handler = getGameData():getBaowuData()
					baowu_data_handler:askRefining(self.select_index, self.select_baowu_pos, star_list)
				end
			end	
		end,TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self.btn_close:setTouchEnabled(false)
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()	
	end,TOUCH_EVENT_ENDED)

	self.btn_tips:addEventListener(function()
		local tip = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_explain.json")
		getUIManager():create("ui/view/clsBaseTipsView", nil, "BaowuRefineTip", {is_back_bg = true},tip, true)
	end,TOUCH_EVENT_ENDED)

	self.btn_breakthrough:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local baowu_data_handler = getGameData():getBaowuData()
		baowu_data_handler:askBaowuBreak(self.select_index, self.select_baowu_pos, self.m_baowuKey)	
	end,TOUCH_EVENT_ENDED)
end

ClsBaowuRefineUI.updatePerfetRefineBack = function(self)
	self.btn_refine:setTouchEnabled(true)
end

ClsBaowuRefineUI.showpartnerInfo = function(self)
	if self.list_view ~= nil then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end	

	self.cell_list = {}
	self.select_baowu_item = nil
	self.select_baowu_pos = nil
	local row = 3

	local width = 335
	local height = 444
	local list_cell_size = CCSize(width, 118)

	self.list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(29, 38))
	self:addWidget(self.list_view)

	local partner_data = getGameData():getPartnerData()	
	local partner_ids = partner_data:getBagEquipIds()

	for i,sailor_id in ipairs(partner_ids) do
		local cell_spr = clsBaowuRefineItem.new(list_cell_size, {index = i, sailor_id = sailor_id, call_back = function(item, pos, id)
			self:selectItem(item, pos, id)
		end})
		self.cell_list[#self.cell_list + 1] = cell_spr
	end
	self.list_view:addCells(self.cell_list)

	-- self.list_view:setCurrentIndex(1)
	self.list_view:setTouch(self.touch_enable)
end

ClsBaowuRefineUI.selectItem = function(self, item, pos, key)
	if self.select_baowu_item then
		self.select_baowu_item:changeSelectState(self.select_baowu_pos, false)
	end
	self:resetAttrShow()
	item:changeSelectState(pos, true)
	self.select_index = item:getListIndex()
	self.select_baowu_item = item
	self.select_baowu_pos = pos
	self:showRefineInfo(key)

	local baowu_data_handler = getGameData():getBaowuData()
	self.ask_refine_check = true
	baowu_data_handler:askRefiningCheck(self.select_index, self.select_baowu_pos)

	self.btn_refine:active()
	self.btn_refine:setTouchEnabled(true)
end

ClsBaowuRefineUI.showRefineInfo = function(self, baowu_key)
	self.select_baowu_key = baowu_key
	default_baowu_key = baowu_key

	local player_data = getGameData():getPlayerData()
	local player_level = player_data:getLevel()
	self.refine_max_num = base_info[player_level].sailor_baowu_attr_num
	self.lock_max_num = self.lock_list[self.refine_max_num]
	self.lock_cur_num = 0
	self.essence = 0
	self.diamond_num = 0
	local baowu_data = getGameData():getBaowuData()
	local baowu_item_data = baowu_data:getInfoById(baowu_key)
	self.select_data_config = baozang_info[baowu_item_data.baowuId]
	self.baowu_icon:changeTexture(convertResources(self.select_data_config.res), UI_TEX_TYPE_PLIST)
	self.baowu_icon_new:changeTexture(convertResources(self.select_data_config.res), UI_TEX_TYPE_PLIST)
	self.baowu_icon:setVisible(true)
	self.baowu_icon_new:setVisible(true)
	self:updateRefineBaowuInfo()
	self:updateRefineEssenceInfo()
end
	
ClsBaowuRefineUI.updateRefineBaowuInfo = function(self, need_num_effect)
	self.btn_save:disable()
	self.btn_save:setTouchEnabled(false)

	local partner_data = getGameData():getPartnerData()
	local select_bag_equip = partner_data:getBagEquipInfo(self.select_index)
	local refine_attr = {}
	local is_surmount = 0
	for i,v in ipairs(select_bag_equip.refineAttr) do
		if v and v.index == self.select_baowu_pos then
			refine_attr = v.refine
			is_surmount = v.isSurmount or 0
		end
	end

	self.lock_cur_num = 0
	self.old_attr_statue = {}
	self.temp_attr_list = {}
	self.last_old_attr_statue = {}
	local need_effect_list = {}
	for i=1,self.attr_num do
		local old_attr_list = self.old_attr_list[i]
		local attr_info = refine_attr[i]
		if attr_info then
			old_attr_list.attr:setText(base_attr_info[attr_info.attr].name)
			setUILabelColor(old_attr_list.attr, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[attr_info.color])))
			self:showAttrPer(old_attr_list, attr_info, false)
			old_attr_list.lock.is_select = false
			old_attr_list.lock:setGray(true)
			old_attr_list.lock:setVisible(true)
			old_attr_list.lock:setTouchEnabled(true)
			if not self.old_attr_statue[i] or self.old_attr_statue[i].attr ~= attr_info.attr then
				local effect_pos = old_attr_list.attr:convertToWorldSpace(ccp(0, 0))
				need_effect_list[#need_effect_list + 1] = {x = effect_pos.x, y = effect_pos.y}
			end
			self.old_attr_statue[i] = {attr = attr_info.attr}
		else
			if i <= self.refine_max_num then
				old_attr_list.default:setText(ui_word.BACKPACK_BOAT_SPACE_STR)
				setUILabelColor(old_attr_list.attr, ccc3(dexToColor3B(COLOR_CAMEL)))
			else
				old_attr_list.default:setText("")
			end
			self.old_attr_statue[i] = nil
			old_attr_list.lock:setVisible(false)
			old_attr_list.lock:setTouchEnabled(false)
		end
	end

	local star_level = dataTools:calBaowuStarLevel(refine_attr, self.select_data_config)
	for i=1,star_total do
		local star_icon = self.baowu_star[i]
		if star_level > (i - 1) * 2 then
			star_icon:setVisible(true)
			local star_res = "common_star3.png"
			if (star_level - (i * 2)) >= 0 then
				star_res = "common_star1.png"
			end
			star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
		else
			star_icon:setVisible(false)
		end
	end
	self.prestige_num:setText(select_bag_equip.baowuPower[self.select_baowu_pos])
	self.prestige_num_d:setText("")
	self.wash_panel:setVisible(is_surmount == 0)
	self.btn_breakthrough:setVisible(is_surmount == 1)
	self.tips_text:setVisible(is_surmount ~= 1)
	self:setTouch(true)
	-- if need_num_effect then
	-- 	self:showAttrUpdateEffect(need_effect_list)
	-- end
	self.m_baowuKey = select_bag_equip.partnerBaowu[self.select_baowu_pos]
end

ClsBaowuRefineUI.updateRefineEssenceInfo = function(self)
	local baowu_data_handler = getGameData():getBaowuData()
	local refining_data = baowu_data_handler:getRefiningEssenceById()
	self.essence = refining_data["essence"]
	self.diamond_num = 0
	if self.lock_cur_num > 0 then
		self.diamond_num = refining_data["refining_" .. self.lock_cur_num]
		self.essence = self.essence + refining_data[string.format("refining_essence_%s", self.lock_cur_num)]
	end
	self.diamond_cost:setVisible(self.diamond_num > 0)
	self.diamond_icon:setVisible(self.diamond_num > 0)
	self.btn_xilian_text:setVisible(self.diamond_num == 0)
	self.essence_sum = baowu_data_handler:getEssence() or 0
	if self.essence > self.essence_sum then
		setUILabelColor(self.consume_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	else
		setUILabelColor(self.consume_num, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	end
	self.consume_num:setText(string.format("%s/%s", self.essence_sum, self.essence))

	local player_date = getGameData():getPlayerData()
	if self.diamond_num > player_date:getGold() then
		setUILabelColor(self.diamond_cost, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	else
		setUILabelColor(self.diamond_cost, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	end
	self.diamond_cost:setText(self.diamond_num)
end

--属性增幅显示设置
ClsBaowuRefineUI.showAttrPer = function(self, per_obj, attr_info, show_effect)
	if not self.select_data_config then return end
	per_obj.bar_bg:setVisible(true)
	local attr_change_per = 0
	local cur_attr = attr_info.attr or attr_info.name
	if attr_info and attr_info.value and cur_attr then
		local attr_limit = self.select_data_config[cur_attr.."_limit"]
		if attr_limit then
			attr_change_per = math.floor(attr_info.value / attr_limit* 100 + 0.0000000000001)
		end
	end
	per_obj.bar_full:setVisible(attr_change_per >= 100)
	per_obj.bar_light:setVisible(attr_change_per < 100)
	per_obj.bar:setVisible(attr_change_per < 100)

	per_obj.bar:setPercent(attr_change_per)
	per_obj.bar_light:setPosition(ccp(per_obj.bar_light_pos.x + 106 * attr_change_per/100 - 4, per_obj.bar_light_pos.y))
	per_obj.property_num:setText(dataTools:getBaowuSpecialAttr(cur_attr, attr_info.value))
	local icon_res
	if cur_attr == "damageIncrease" then
		icon_res = "backpack_treasure_up.png"
	elseif cur_attr == "damageReduction" then
		icon_res = "backpack_treasure_down.png"
	end
	per_obj.damage_icon:setVisible(false)
	if not tolua.isnull(per_obj.attr_effect) then
		per_obj.attr_effect:removeFromParentAndCleanup(true)
		per_obj.attr_effect = nil
	end
	if icon_res then
		per_obj.damage_icon:setVisible(true)
		per_obj.damage_icon:changeTexture(icon_res, UI_TEX_TYPE_PLIST)
		if show_effect then
			per_obj.attr_effect = composite_effect.new("tx_treasure_fire", -150, 0, per_obj.bar_bg, nil, nil, nil, nil)
		end
	end
end

ClsBaowuRefineUI.resetAttrShow = function(self)
	for i=1,self.attr_num do
		local new_attr_list = self.new_attr_list[i]
		new_attr_list.bar_bg:setVisible(false)
		new_attr_list.arrow:setVisible(false)
		new_attr_list.default:setText("")

		local old_attr_list = self.old_attr_list[i]
		old_attr_list.bar_bg:setVisible(false)
		old_attr_list.default:setText("")
	end
	for i=1, 4 do
		self.baowu_star[i]:setVisible(false)
		self.baowu_star_new[i]:setVisible(false)
	end
end

ClsBaowuRefineUI.showRefineTempData = function(self, index, pos, attr_data, power)
	if self.select_index == (index + 1) and self.select_baowu_pos == pos then
		if attr_data and #attr_data > 0 then
			local need_effect_list = {}
			self.last_old_attr_statue = table.clone(self.old_attr_statue)
			self.temp_attr_list = {}

			for i=1,self.attr_num do
				local new_attr_list = self.new_attr_list[i]
				local attr_info = attr_data[i]
				if attr_info then
					new_attr_list.attr:setText(base_attr_info[attr_info.name].name)-- .. dataTools:getBaowuSpecialAttr(attr_info.name, attr_info.value)
					setUILabelColor(new_attr_list.attr, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[attr_info.color])))
					local is_same = false
					if not self.last_old_attr_statue[i] or self.last_old_attr_statue[i].attr ~= attr_info.attr then
						local effect_pos = new_attr_list.attr:convertToWorldSpace(ccp(0, 0))
						need_effect_list[#need_effect_list + 1] = {x = effect_pos.x, y = effect_pos.y}
							
					end
					if self.last_old_attr_statue[i] and self.last_old_attr_statue[i].attr == attr_info.name then
						is_same = true
					end
					local can_show_effect = false
					if not self.ask_refine_check then
						can_show_effect = not is_same
					end
					self:showAttrPer(new_attr_list, attr_info, can_show_effect)
					self.temp_attr_list[i] = {attr = attr_info.name, is_same = is_same}
				else
					if i <= self.refine_max_num then
						new_attr_list.default:setText(ui_word.BACKPACK_BOAT_SPACE_STR)
						setUILabelColor(new_attr_list.attr, ccc3(dexToColor3B(COLOR_CAMEL)))
					else
						new_attr_list.default:setText("")
					end
				end
			end
			self.prestige_num_d:setText(power)
			-- if is_op then
			-- 	self:showAttrUpdateEffect(need_effect_list)
			-- else
			-- end
			self:updateRefineEssenceInfo()
			self.btn_save:active()
			self.btn_save:setTouchEnabled(true)

			local star_level = dataTools:calBaowuStarLevel(attr_data, self.select_data_config)
			for i=1,star_total do
				local star_icon = self.baowu_star_new[i]
				if star_level > (i - 1) * 2 then
					star_icon:setVisible(true)
					local star_res = "common_star3.png"
					if (star_level - (i * 2)) >= 0 then
						star_res = "common_star1.png"
					end
					star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
				else
					star_icon:setVisible(false)
				end
			end
		end
		self.ask_refine_check = false
		self:setTouch(true)
	end
end

ClsBaowuRefineUI.reqRefineBack = function(self, errno)
	if errno ~= 0 then
		self:setTouch(true)
		return
	end
	if not tolua.isnull(self.refine_effect) then
		self.refine_effect:removeFromParentAndCleanup(true)
		self.refine_effect = nil
	end

	self.refine_effect = composite_effect.new("tx_treasure_light", 512, 198, self, nil, nil, nil, nil)
	audioExt.playEffect(music_info.BOAT_UP.res)
end

--洗练保存返回
ClsBaowuRefineUI.refiningSaveBack = function(self, errno)
	if errno ~= 0 then
		self:setTouch(true)
		return
	end

	self:resetAttrShow()
	self.cell_list[self.select_index]:updateStarLevel()
	self:updateRefineBaowuInfo(true)
	self:updateRefineEssenceInfo()
end

ClsBaowuRefineUI.getLockAttrData = function(self)
	local lock_list = {}
	local need_confirm_str = nil
	local special_attrs = self.select_data_config.special_attrs
	for i=1,4 do
		local cur_old_attr_statue = self.old_attr_statue[i]
		if cur_old_attr_statue then
			if cur_old_attr_statue.lock then
				lock_list[#lock_list + 1] = i - 1
			end
		end
		local temp_attr = self.temp_attr_list[i]
		if temp_attr then
			for k,v in ipairs(special_attrs) do
				if not need_confirm_str and not temp_attr.is_same and v == temp_attr.attr then
					need_confirm_str = ui_word.BACKPACK_REFINE_CONFIRM_TIPS
				end
			end
		end
	end
	return lock_list, need_confirm_str
end

ClsBaowuRefineUI.getSaveConfirmTips = function(self)
	local need_confirm_str = nil
	local special_attrs = self.select_data_config.special_attrs
	local old_special_attr_num = 0
	local new_special_attr_num = 0
	for i=1,4 do
		for k,v in ipairs(special_attrs) do
			if self.temp_attr_list[i] and v == self.temp_attr_list[i].attr then
				new_special_attr_num = new_special_attr_num + 1
			end
			local cur_old_attr_statue = self.old_attr_statue[i]
			if cur_old_attr_statue and cur_old_attr_statue.attr == v then
				old_special_attr_num = old_special_attr_num + 1
			end
		end
	end
	return (old_special_attr_num > 0 and new_special_attr_num == 0)
end

ClsBaowuRefineUI.updateLabelCallBack = function(self)
	self:updateRefineEssenceInfo()
end

ClsBaowuRefineUI.setTouch = function(self, enable)
	if not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enable)
	end
end

ClsBaowuRefineUI.onExit = function(self)
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
end

return ClsBaowuRefineUI