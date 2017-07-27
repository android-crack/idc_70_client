-- 对话框
local tips = require("game_config/tips")
local news = require("game_config/news")
local tool = require("module/dataHandle/dataTools")
local UiCommon = require("ui/tools/UiCommon")
local music_info=require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local mall_info = require("game_config/shop/mall_info")
local CompositeEffect = require("gameobj/composite_effect")
local jump_info = require("game_config/jump/jump_info")
local ClsUiWord = require("game_config/ui_word")

require("ui/tools/richlabel/richlabel")
require("gameobj/ui_utils")

local exploreBuyPowerCallBack = nil

local OPEN_SHOP_TYPE = {
	VIEW_NORMAL_TYPE = 1,
	VIEW_3D_TYPE = 2,
}

local jumpViewStatck = {}
local currentJumpIndex = 0

local Alert = {}

local bgRes = "common_9_tips2.png"
Alert.delAttention = function(self, funs, name, m_ui_manager)
	if name then
		if m_ui_manager then
			m_ui_manager:close(name)
		else
			getUIManager():close(name)
		end
	end
	RemoveTextureForKey(bgRes)

	if type(funs) == "table" then
		for k,fun in pairs(funs) do
			if type(fun) == "function" then fun() end
		end
	elseif type(funs) == "function" then
		funs()
	end
end

Alert.showFriendPk = function(self, kind, name, attacker, end_time)
	getUIManager():create("gameobj/friend/clsFriendPkTip", nil, {kind = kind, name = name, attacker = attacker, end_time = end_time})
end

------------------------------公用弹框提示界面-------------------------------------------------
--提供了各种类型弹框提示界面，包含一个按钮，两个按钮，或者特殊的按钮界面，或者是含有富文本的提示界面

--[[下面函数的封装
params:
	is_hide_close_btn, is_hide_cancel_btn, 隐藏按钮
	ok_text, cancel_text  按钮文本
	touch_priority 触摸优先级
	on_off_key 开关
	is_use_orange_btn 按钮变黄
	is_rich_label 是否富文本
--]]

--可以改变按钮文字内容
--params中参数包含：ok_text，hide_close_btn，hide_cancel_btn，cancel_text，on_off_key，use_orange_btn
--                	is_rich_label, destroy_callback, hide_middle_btn

Alert.showAttention = function(self, str, ok_func, close_func, cancel_func, params, view_param)
	--print("--------------------------tips_common---------------------------")
	params = params or {}
	local name_str = params.name_str or "AlertShowAttention"
	local is_add_touch_close_bg = nil
	if params.is_add_touch_close_bg ~= nil then is_add_touch_close_bg = params.is_add_touch_close_bg end
	local view, ui_layer, panel, m_ui_manager = self:createBaseLayer("json/tips_common.json", "panel", name_str, close_func, view_param, params.is_notification, is_add_touch_close_bg)

	if view then
		view:setIgnoreClosePanel(panel)
	end
	ui_layer.onTipsExit = function(self)
		if type(params.destroy_callback) == "function" then
			params.destroy_callback()
		end
	end

	local ok_funs_list = {}
	ok_funs_list[#ok_funs_list + 1] = ok_func

	--内容文本
	local single_text = getConvertChildByName(panel, "text_1")
	single_text:setVisible(false)
	local multi_text = getConvertChildByName(panel, "text_2")
	local btn_middle = getConvertChildByName(panel, "btn_middle")
	local btn_confirm = getConvertChildByName(panel, "btn_confirm")
	local btn_cancel = getConvertChildByName(panel, "btn_cancel")
	local btn_text_confirm = getConvertChildByName(panel, "btn_text_confirm")
	local btn_text_cancel = getConvertChildByName(panel, "btn_text_cancel")
	local btn_text_middle = getConvertChildByName(panel, "btn_text_middle")
	local btn_sail = getConvertChildByName(panel, "btn_sail")--不同颜色的按钮
	local btn_text_sail = getConvertChildByName(panel, "btn_text_sail")

	if params.is_rich_label then
		local size = multi_text:getContentSize()
		local pos = multi_text:getPosition()
		local panel_pos = panel:getPosition()
		multi_text:setVisible(false)
		local rich_text = createRichLabel("$(c:COLOR_CAMEL)".. str, size.width, size.height, 16, 2, true, true)
		if rich_text:getContentSize().width > size.width then
			rich_text = createRichLabel("$(c:COLOR_CAMEL)".. str, size.width, size.height, 16, 2, nil, false)
		end
		rich_text:setAnchorPoint(ccp(0.5, 0.5))
		rich_text:setPosition(ccp(pos.x + panel_pos.x, pos.y + panel_pos.y))
		ui_layer:addCCNode(rich_text)
		ui_layer.content_label = rich_text
	else
		multi_text:setText(str)
		ui_layer.content_label = multi_text
		if multi_text.getStringNumLines and multi_text:getStringNumLines() > 1 then
			multi_text:setTextHorizontalAlignment(kCCTextAlignmentLeft)
		end
	end

	if params.hide_close_btn then
		ui_layer.btn_close:setVisible(false)
	end

	if params.ok_text then
		btn_text_confirm:setText(params.ok_text)
		btn_text_middle:setText(params.ok_text)
		btn_text_sail:setText(params.ok_text)
	end

	if params.cancel_text then
		btn_text_cancel:setText(params.cancel_text)
	end

	local guide_btn = btn_confirm
	if params.hide_cancel_btn then
		btn_confirm:setVisible(false)
		btn_cancel:setVisible(false)
		btn_middle:setVisible(true)
		guide_btn = btn_middle
	elseif params.use_orange_btn then
		btn_confirm:setVisible(false)
		btn_sail:setVisible(true)
		guide_btn = btn_sail
	end

	if params.hide_middle_btn then
		btn_middle:setVisible(false)
		btn_middle:setTouchEnabled(false)
	end

	btn_sail:setPressedActionEnabled(true)
	btn_sail:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(ok_funs_list, name_str, m_ui_manager)
	end, TOUCH_EVENT_ENDED)

	btn_middle:setPressedActionEnabled(true)
	btn_middle:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(ok_funs_list, name_str, m_ui_manager)
	end, TOUCH_EVENT_ENDED)

	btn_confirm:setPressedActionEnabled(true)
	btn_confirm:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(ok_funs_list, name_str, m_ui_manager)
	end, TOUCH_EVENT_ENDED)

	btn_cancel:setPressedActionEnabled(true)
	btn_cancel:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(cancel_func or close_func, name_str, m_ui_manager)
	end, TOUCH_EVENT_ENDED)
	--通用二次确认框需要加指引
	if params.need_check_guide then
		view.guide = btn_confirm
		local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
		ClsGuideMgr:tryGuide(params.name_str)
	end

	ui_layer.guide_btn = guide_btn

	return view, ui_layer, ui_layer.content_label, panel
end

------------------------------公用含有购买图标按钮的弹框提示界面-------------------------------------------------
--cost_type对应为：
--ITEM_INDEX_CASH为金币，币类
--ITEM_INDEX_GOLD为钻石，币类
Alert.showBuyAttention = function(self, str, cost_num, cost_type, ok_funs, close_funs, str_other, is_btn_pic, is_item_desc,item_str,item_desc)
	local name_str = "AlertShowBuyAttention"
	local view, ui_layer, panel = self:createBaseLayer("json/tips_buy.json", "panel", name_str, close_func)

	if view then
		view:setIgnoreClosePanel(panel)
	end
	--内容文本
	local content_text = getConvertChildByName(panel, "text_1")
	local content_text_other = getConvertChildByName(panel, "text_2")
	local btn_confirm = getConvertChildByName(panel, "btn_confirm")
	local btn_icon = getConvertChildByName(panel, "btn_icon")
	local btn_num = getConvertChildByName(panel, "btn_num")
	local btn_text = getConvertChildByName(panel, "btn_text")


	local content_item = getConvertChildByName(panel, "text_3")
	local content_item_desc = getConvertChildByName(panel, "text_4")
	
	if is_item_desc then
		content_item:setVisible(true)
		content_item_desc:setVisible(true)
		content_item:setText(item_str)
		content_item_desc:setText(item_desc)
	end


	if str_other and string.len(str_other) > 0 then
		content_text_other:setVisible(true)
		content_text_other:setText(str_other)
	end

	if is_btn_pic then
		btn_icon:setVisible(false)
		btn_num:setVisible(false)
		btn_text:setVisible(true)
	end

	cost_type = cost_type or ITEM_INDEX_GOLD
	if cost_type ~= ITEM_INDEX_GOLD then
		--TODO
		-- btn_icon:changeTexture()
	else
		local player_info = getGameData():getPlayerData()
		if player_info:getGold() < cost_num then
			setUILabelColor(btn_num, ccc3(dexToColor3B(COLOR_RED)))
		end
	end

	btn_num:setText(cost_num)
	if str then
		content_text:setVisible(true)
		content_text:setText(str)
	else
		content_text:setVisible(false)
	end

	btn_confirm:setPressedActionEnabled(true)
	btn_confirm:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(ok_funs, name_str)
	end, TOUCH_EVENT_ENDED)

	return view
end
-----------------------------------------------------------------------------------------------

--出海弹出的补给框
Alert.explorerSupplyAttention = function(self, str, close_funs)
	local del_flag_b = false --提示框删除标记

	local name_str = "AlertExplorerSupplyAttention"
	local closeBack
	closeBack = function()
		if not del_flag_b then
			del_flag_b = true
			self:delAttention(close_funs, name_str)
		end
	end

	local view, ui_layer, panel = self:createBaseLayer("json/tips_auto.json", "panel", name_str, closeBack)

	audioExt.playEffect(music_info.COMMON_CASH.res)

	local content_text = getConvertChildByName(panel, "text_2")
	content_text:setText(str)

	--2秒后（无需点击）即自动跳过并出
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(2))
	array:addObject(CCCallFunc:create(function()
		closeBack()
	end))
	ui_layer:runAction(CCSequence:create(array))
end

--提示文字 参数 {msg, size, x, y, color}（其实同这个：Alert:warning，不过这个新出来的话会把之前那个ko掉）
Alert.tipsWithCover = function(self, item)
	self:warning(item)
end

Alert.battleWarning = function(self, item)
	if not getGameData():getBattleDataMt():GetBattleSwitch() then return end

	local warning_data_handle = getGameData():getWarningData()
	warning_data_handle:addItem(item, 1, display.top/2)
end

Alert.warning = function(self, item)
	local warning_data_handle = getGameData():getWarningData()
	warning_data_handle:addItem(item, nil, 250)
end

Alert.getParent = function(self)
	local portLayer = getUIManager():get("ClsPortLayer")
	if tolua.isnull(portLayer) then
		local scene=GameUtil.getRunningScene()
		scene.addItem=function(self,child)
			scene:addChild(child)
		end
		return scene
	elseif not tolua.isnull(portLayer.portItem) then
		portLayer.portItem:removeFromParentAndCleanup(true)
		portLayer.portItem=nil
	end
	return portLayer
end

--探索购买体力成功提示
Alert.alertBuyResult = function(self)
	if self.buyShopItem then
		local curShopName = ui_word.SHOP_GOTO_BUY_TiTleName_3
		local accountResult = 100
		Alert:warning({msg = string.format(ui_word.SHOP_GOTO_BUY_ALERT_4, accountResult, curShopName)})
		self.buyShopItem = nil
	end
end

Alert.getOpenShopType = function(self)
	return OPEN_SHOP_TYPE
end

Alert.openShopView = function(self, parent, viewType, viewName, shop_type)
	local index = 1
	if shop_type == ITEM_TYPE_GOLD then
		index = 2
	end
	local mall_main = getUIManager():get("ClsMallMain")
	if not tolua.isnull(mall_main) then
		mall_main:selectTab(index)
	else

		getUIManager():create("gameobj/mall/clsMallMain", nil, index)
	end
end

Alert.pop3DView = function(self)
	local viewName = jumpViewStatck[currentJumpIndex]
	if viewName then
		local skipToLayer = require("gameobj/mission/missionSkipLayer")
		local skipMissLayer = skipToLayer:skipLayerByName(viewName)

		jumpViewStatck[currentJumpIndex] = nil
		currentJumpIndex = currentJumpIndex - 1
		if currentJumpIndex < 0 then
			currentJumpIndex = 0
		end
	end
end

Alert.showCommonReward = function(self, rewards, end_call, delay_time)
	if not rewards or #rewards == 0 then return end
	local bg_layer = UIWidget:create()
	local name_str = "AlertShowCommonReward"..SHOW_COMMON_REWARD_TAG
	SHOW_COMMON_REWARD_TAG = SHOW_COMMON_REWARD_TAG + 1

	if getUIManager():isLive(name_str) then
		getUIManager():close(name_str)
	end

	local base_view = getUIManager():create("ui/view/clsBaseTipsView", nil, name_str, {effect = false, is_back_bg = false, is_swallow = false}, bg_layer)

	local uiTools = require("gameobj/uiTools")
	local array = CCArray:create()
	delay_time = delay_time or 0.2
	if delay_time <= 0 then
		delay_time = 0.2
	end
	local endCallBack
	endCallBack = function()
		getUIManager():close(name_str)
	end

	base_view.onFinish = function (base_view)
		if type(end_call) == "function" then
			end_call()
		end
	end

	for k, v in ipairs(rewards) do
		local para_call = nil

		if k == #rewards then
			para_call = endCallBack
		end

		local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(v)
		local default_color = 1

		local msg = nil
		if amount > 0 then
			-- 如果amount不小于0，表示获取物品，播放特效
			msg = string.format(ui_word.REWARD_TIP,RICHTEXT_COLOR_NORMAL[color]..name,RICHTEXT_COLOR_NORMAL[default_color]..amount)
			array:addObject(CCDelayTime:create(k * delay_time))
			array:addObject(CCCallFunc:create(function()
				uiTools:showGetRewardEfffect(bg_layer, para_call, item_res, nil,
					ccp(display.cx, display.cy), nil, name, true)
			end))
		elseif amount < 0 then
			-- 否则只有提示文字，不播放特效
			msg = string.format(ui_word.LOSE_STH_TIP,RICHTEXT_COLOR_NORMAL[color]..name,RICHTEXT_COLOR_NORMAL[default_color]..(amount * -1))
		end

		array:addObject(CCCallFunc:create(function()
			local item = {
				["msg"] = msg,
			}
			if(msg)then self:warning(item)end	
		end))
	end
	if array:count() > 0 then
		bg_layer:runAction(CCSequence:create(array))
	end
	audioExt.playEffect(music_info.SHIPYARD_DISMANTLE_AWARD.res)
end

Alert.showZhanDouLiEffect = function(self, value,start_num, show_time, call_back)
	local back_bg = true
	local is_touch_remove = true
	local off_y = 0
	if getUIManager():isLive("ClsExploreFindPortPanel") then
		off_y = -110
		back_bg = false
		is_touch_remove = false
	end

	local layer = UIWidget:create()
	local effect_layer = UIWidget:create()
	local start_number = start_num or 0
	local label_zhandouli = createBMFont({text = start_number, size = 20, color = ccc3(dexToColor3B(COLOR_YELLOW_STROKE)), fontFile = FONT_NUM_COMBAT})
	audioExt.playEffect(music_info.PRESTIGE_RAISE.res)

	local label_pic
	if start_num then
		label_pic = display.newSprite("ui/txt/txt_prestige_total_1.png")
	else
		label_pic = getChangeFormatSprite("ui/txt/txt_get_force.png")
	end

	label_pic:setScale(0.6)
	layer:addChild(effect_layer)

	label_zhandouli:setVisible(false)
	label_pic:setVisible(false)

	layer:addCCNode(label_zhandouli)
	layer:addCCNode(label_pic)


	local pos_x,pos_y = display.cx ,display.cy + off_y
	local effect_node = CompositeEffect.new("tx_0184", pos_x,  pos_y, effect_layer, nil, nil, nil, nil, true)


	local array_action = CCArray:create()
	array_action:addObject(CCDelayTime:create(0.6))
	array_action:addObject(CCCallFunc:create(function (  )
		label_zhandouli:setVisible(true)
		label_zhandouli:setPosition(ccp(pos_x+480, pos_y-25))
	end) )

	array_action:addObject(CCMoveTo:create(0.3, ccp(500,pos_y-25)))
	array_action:addObject(CCDelayTime:create(0.2))
	array_action:addObject(CCCallFunc:create(function ()
		UiCommon:numberEffect(label_zhandouli, start_number or 0, value, 20)
	end) )
	array_action:addObject(CCDelayTime:create(0.8))
	array_action:addObject(CCMoveTo:create(0.2, ccp(-20,pos_y-25)))
	array_action:addObject(CCFadeOut:create(0.2))
	label_zhandouli:runAction(CCSequence:create(array_action))


	local array_action_pic = CCArray:create()
	array_action_pic:addObject(CCDelayTime:create(0.6))
	array_action_pic:addObject(CCCallFunc:create(function (  )
		label_pic:setVisible(true)
		label_pic:setPosition(ccp(pos_x-370, 288 + off_y))
	end) )

	array_action_pic:addObject(CCMoveTo:create(0.3, ccp(402, 288 + off_y)))

	array_action_pic:addObject(CCDelayTime:create(0.8))
	array_action_pic:addObject(CCMoveTo:create(0.25, ccp(1000,288 + off_y)))
	array_action:addObject(CCFadeOut:create(0.25))
	label_pic:runAction(CCSequence:create(array_action_pic))

	local name_str = "AlertShowZhanDouLiEffect"
	getUIManager():create("ui/view/clsBaseTipsView", nil, name_str, {effect = false, is_back_bg = back_bg}, layer, is_touch_remove)

	--local scheduler = CCDirector:sharedDirector():getScheduler()
	local callBack
	callBack = function()
		self:delAttention(call_back, name_str)
	end


	local array = CCArray:create()
	array:addObject(CCDelayTime:create(show_time or 3))
	array:addObject(CCCallFunc:create(function (  )
		callBack()
	end))

	layer:runAction(CCSequence:create(array))
	-- layer.scheduleHandler = scheduler:scheduleScriptFunc(callBack, show_time or 3, false)
	-- layer.touchCallBack = function()
	-- 	callBack()
	-- end

	layer.close = call_back
	
	return layer
end

Alert.showDialogTips = function(self, sailor, rich_str, btn_name, data, btn_fun, sail_fun, color, call_back, set_time_close)
	local ui_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/market_hotsell.json")
	convertUIType(panel)
	ui_layer:addChild(panel)
	local name_str = "AlertShowDialogTips"

	ui_layer.accountant_head = getConvertChildByName(panel, "accountant_head")
	ui_layer.accountant_name = getConvertChildByName(panel, "accountant_name")
	ui_layer.btn_tell_guild = getConvertChildByName(panel, "btn_tell_guild")
	ui_layer.btn_text = getConvertChildByName(panel, "btn_text")
	ui_layer.talk_content = getConvertChildByName(panel, "talk_content")
	ui_layer.talk_content:setVisible(false)
	ui_layer.btn_sail = getConvertChildByName(panel, "btn_sail")
	ui_layer.btn_market = getConvertChildByName(panel, "btn_market")

	local sailor_res = nil
	local sailor_name = nil
	if sailor then
		sailor_res = sailor.res
		sailor_name = sailor.name
		ui_layer.accountant_head:changeTexture(sailor_res)
	else
		local player_data = getGameData():getPlayerData()
		local icon = player_data:getIcon()
		sailor_name = player_data:getName() or ""
		icon = string.format("ui/seaman/seaman_%s.png", icon)
		ui_layer.accountant_head:changeTexture(icon, UI_TEX_TYPE_LOCAL)
	end

	local btnSize = ui_layer.accountant_head:getContentSize()
	local headSize = ui_layer.accountant_head:getContentSize()
	ui_layer.accountant_head:setScale(math.min(btnSize.height, 190) / headSize.height)

	ui_layer.accountant_name:setText(sailor_name .. ":")

	if btn_name then
		ui_layer.btn_text:setText(btn_name)
		ui_layer.btn_tell_guild:setVisible(true)
	elseif sail_fun then
		ui_layer.btn_market:setVisible(true)
		ui_layer.btn_sail:setVisible(true)
		ui_layer.btn_tell_guild:setVisible(false)
	else
		ui_layer.btn_tell_guild:setVisible(false)
  --   	ui_layer.touchCallBack = function()
		-- 	self:delAttention()
		-- 	if type(call_back) == "function" then
		-- 		call_back()
		-- 	end
		-- end
	end

	ui_layer.btn_tell_guild:setPressedActionEnabled(true)
	ui_layer.btn_tell_guild:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if btn_fun then
				btn_fun(data)
			end
			self:delAttention(call_back, name_str)
		end,TOUCH_EVENT_ENDED)

	ui_layer.btn_sail:setPressedActionEnabled(true)
	ui_layer.btn_sail:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:delAttention(call_back, name_str)
			if sail_fun then
				sail_fun()
			end
		end,TOUCH_EVENT_ENDED)

	ui_layer.btn_market:setPressedActionEnabled(true)
	ui_layer.btn_market:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if getGameData():getTeamData():isLock(true) then return end
			--前往交易所
			local port_map_ui = getUIManager():get("PortMap")
			if not tolua.isnull(port_map_ui) then
				port_map_ui:btnCloseListener()
			end
			getUIManager():create("gameobj/port/portMarket")
			self:delAttention(nil, name_str)
		end,TOUCH_EVENT_ENDED)

	ui_layer.content_lable = createRichLabel(rich_str, 526, 70, 16)
	ui_layer.content_lable:ignoreAnchorPointForPosition(false)
	ui_layer.content_lable:setAnchorPoint(ccp(0, 0.5))
	ui_layer.content_lable:setPosition(ccp(216, 60))
	ui_layer:addCCNode(ui_layer.content_lable)

	if set_time_close then
		local delay_act = CCDelayTime:create(set_time_close)
		local callback_act = CCCallFunc:create(function()
			self:delAttention(call_back, name_str)
		end)
		ui_layer:runAction(CCSequence:createWithTwoActions(delay_act, callback_act))
	end

	ui_layer.close = function (self)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if type(call_back) == "function" then
			call_back()
		end
	end
	

	local is_back_bg = (color ~= nil)
	getUIManager():create("ui/view/clsBaseTipsView", nil, name_str, {effect = false, is_back_bg = is_back_bg}, ui_layer, true)


end

local setBtnShow
setBtnShow = function(target, kind, label, ui_name_str)
	target.active_text = label
	target.disable_text = label .. ui_word.FUNC_NOT_OPEN_TIPS

	local on_off_data = getGameData():getOnOffData()

	on_off_data:pushOpenBtn(kind, {openBtn = target, openEnable = true, name = target.name,
		addLock = true, labelOpacity = 255 * 0.75, parent = ui_name_str,
		btnRes = "#common_btn_blue_long1.png"})
end

--初始化资源不足的基本数据
Alert.createBaseLayer = function(self, json_file, bg, name_str, nTouchCb, view_param, is_notification, is_add_touch_close_bg)
	local ui_layer = UIWidget:create()

	local panel = GUIReader:shareReader():widgetFromJsonFile(json_file)
	convertUIType(panel)
	ui_layer:addChild(panel)

	local bg = getConvertChildByName(panel, bg)
	local bg_size = bg:getContentSize()
	panel:setPosition(ccp(display.cx - bg_size.width / 2, display.cy - bg_size.height / 2))

	ui_layer.close = nTouchCb

	ui_layer.btn_close = getConvertChildByName(panel, "btn_close")
	if ui_layer.btn_close then
		ui_layer.btn_close:setPressedActionEnabled(true)
		ui_layer.btn_close:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_CLOSE.res)
			self:delAttention(nTouchCb, name_str)
		end, TOUCH_EVENT_ENDED)
	end

	local m_ui_manager = getUIManager()
	view_param = view_param or {}
	if is_notification then
		view_param = view_param or {}
		view_param.type = UI_TYPE.TOP
	end
	if is_add_touch_close_bg == nil or (not view_param.not_add_touch_close_bg) then
		is_add_touch_close_bg = true
	end
	local view = m_ui_manager:create("ui/view/clsBaseTipsView", nil, name_str, view_param, ui_layer, is_add_touch_close_bg)
	return view, ui_layer, panel, m_ui_manager
end

--金币银币荣誉立即购买
Alert.reallyBuy = function(self, parent, info, cancel_cb)
	if not info then return end
	local good_info = mall_info[info.shop_id]
	local item_res, amount, scale = getCommonRewardIcon({key = ITEM_TYPE_MAP[good_info.goods_type], id = good_info.goods_id, value = 1})
	local icon_zoom = 0.3
	local show_num = info.num
	local player_data = getGameData():getPlayerData()
	if player_data:getGold() < info.value then
		Alert:warning({msg = ui_word.TIP_NONENOUGH_DIAMOD_STR})
		return
	else
		local diamond_str = string.format("$(img:#common_icon_diamond.png|%s)$(c:COLOR_GREEN)%s$(c:COLOR_CAMEL)", icon_zoom, info.value)
		local cost_str = string.format("$(img:%s|%s)$(c:COLOR_GREEN)%s", item_res, icon_zoom, show_num)
		local show_tips = string.format(ui_word.TIP_CONFIRM_DIAMOD_BUY_STR, diamond_str, cost_str)
		Alert:showAttention(show_tips, function()
			local updateParentView
			updateParentView = function()
				if not tolua.isnull(parent) and type(parent.updateLabelCallBack) == "function" then
					parent:updateLabelCallBack()
				end
			end
			local shop_data = getGameData():getShopData()
			shop_data:askBuyShopItem(info.shop_id, 1, updateParentView)
		end, cancel_cb, nil, {is_rich_label = true})
	end
end

Alert.showBayInvite = function(self, parent, accept_callback, refuse_callback, time_callback, is_common, back_time, content, accept_text, refuse_text, is_disable_op, show_tips_text, str_waiting_text, is_show_level_tip)
	local back_time = back_time or 15

	local name_str = "AlertShowBayInvite"
	local view, ui_layer, panel = self:createBaseLayer("json/explore_copy_invite.json", "explore_invite", name_str, refuse_callback, {not_add_touch_close_bg = true}, nil, false)

	if view then
		view:setIgnoreClosePanel(panel)
	end

	local invite = getConvertChildByName(panel, "initiative_panel")
	local passivity = getConvertChildByName(panel, "passivity_panel")
	local lbl_wait = getConvertChildByName(panel, "countdown_num")
	local waiting_text_label = getConvertChildByName(panel, "waiting_text")
	local tips_god_1 = getConvertChildByName(panel, "tips_god_1")
	local tips_god_2 = getConvertChildByName(panel, "tips_god_2")
	if str_waiting_text then
		waiting_text_label:setText(str_waiting_text)
	end
	invite:setVisible(true)
	passivity:setVisible(false)

	local showBtnView
	showBtnView = function()
		passivity:setVisible(true)
		if is_show_level_tip then
			tips_god_2:setVisible(true)
		end
		invite:setVisible(false)
		local invite_text = getConvertChildByName(panel, "invite_text")
		local tips_text = getConvertChildByName(panel, "tips_text")
		local btn_accept = getConvertChildByName(panel, "btn_accept")
		local btn_text_accept = getConvertChildByName(panel, "btn_text_accept")
		local btn_refuse = getConvertChildByName(panel, "btn_refuse")
		local btn_text_refuse = getConvertChildByName(panel, "btn_text_refuse")
		tips_text:setVisible(show_tips_text)

		if content then
			invite_text:setText(content)
		end
		if accept_text then
			btn_text_accept:setText(accept_text)
		end
		if refuse_text then
			btn_text_refuse:setText(refuse_text)
		end

		if is_disable_op then
			btn_accept:setVisible(false)
			btn_refuse:setVisible(false)
			ui_layer.btn_close:setVisible(false)
		else
			btn_accept:setPressedActionEnabled(true)
			btn_accept:addEventListener(function()
				if is_common then
					self:delAttention(accept_callback, name_str)
				else
					accept_callback()
					invite:setVisible(true)
					passivity:setVisible(false)
				end
			end, TOUCH_EVENT_ENDED)

			btn_refuse:setPressedActionEnabled(true)
			btn_refuse:addEventListener(function()
				self:delAttention(refuse_callback, name_str)
			end, TOUCH_EVENT_ENDED)
		end
	end
	if is_common then
		showBtnView()
	else
		print("content", content)
		local invite_text = getConvertChildByName(panel, "invite_text")
		if content then
			invite_text:setText(content)
		end
		if is_show_level_tip then
			tips_god_1:setVisible(true)
		end
		local bay_data = getGameData():getBayData()
		local team_data = getGameData():getTeamData()
		if not team_data:isTeamLeader() then
			showBtnView()
		end
		bay_data:setResponseCallback(function()
			self:delAttention(nil, name_str)
		end)
	end

	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		back_time = back_time - 1
		lbl_wait:setText(back_time)
		local bay_data = getGameData():getBayData()
		if back_time == 0 then
			if not is_common then
				bay_data:setResponseCallback(nil)
			end
			self:delAttention(time_callback, name_str)
		end
	end))
	arr_action:addObject(CCDelayTime:create(1))
	lbl_wait:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

Alert.openMarketView = function(self, parent, viewType, viewName)
	viewType = viewType or OPEN_SHOP_TYPE.VIEW_NORMAL_TYPE
	if not tolua.isnull(parent) then
		getUIManager():create("gameobj/port/portMarket", nil, viewType == OPEN_SHOP_TYPE.VIEW_3D_TYPE)
	else
		getUIManager():create("gameobj/port/portMarket")
	end
end

Alert.goGetMonthCard = function(self)
	local enter_call = self.parameter.enter_call--之前需要进行的操作
	if type(enter_call) == "function" then
		enter_call()
	end
	local welfare_main = getUIManager():get("ClsWefareMain")
	if not tolua.isnull(welfare_main) then
		welfare_main:close()
	end
	return getUIManager():create("gameobj/welfare/clsWelfareMain",nil,1)
end

Alert.goShop = function(self, type,name)
	local come_type
	local come_name
	if self.parameter then
		come_type = self.parameter.come_type
		come_name = self.parameter.come_name
	else
		come_type = type
		come_name = type
	end

	self:openShopView(self.parent, come_type, come_name, ITEM_TYPE_GOLD)
end

Alert.goFindBaowu = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("team_treasure")
end

Alert.goGetCashNow = function(self)
	local shop_date = getGameData():getShopData()
	local info = shop_date:getNearestShopItem(ITEM_TYPE_CASH, 0)
	self:reallyBuy(self.parent, info, function() end)
end

Alert.goGetJinghuaNow = function(self)
	local shop_date = getGameData():getShopData()
	local info = shop_date:getNearestShopItem(ITEM_TYPE_TIEM, PROP_BAOWU_ESSENCE)
	self:reallyBuy(self.parent, info, function() end)
end

Alert.goGetPowerNow = function(self)
	local shop_date = getGameData():getShopData()
	local info = shop_date:getNearestShopItem(ITEM_TYPE_TILI)
	self:reallyBuy(self.parent,info, function() end)
end

Alert.goGuildWarehouse = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("guild_shop")
end

Alert.goRecruit = function(self)
	local hotel_main_ui = getUIManager():get("ClsHotelMain")
	if tolua.isnull(hotel_main_ui) then
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local goal_layer = missionSkipLayer:skipLayerByName("hotelRecruit")
	else
		local current_index = hotel_main_ui:getCurrentTabIndex()
		if current_index ~= HOTEL_RECRUIT then
			local recruit_btn = hotel_main_ui:getSailorRecruitBtn()
			recruit_btn:executeEvent(TOUCH_EVENT_ENDED)
			if not tolua.isnull(hotel_main_ui) then
				hotel_main_ui:setTouch(true)
			end
		end
	end
end

Alert.gojingyingFight = function(self)
	loadZhanyi()
end

Alert.goGuildTask = function(self)
	local parent = self.parent
	local guild_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_ui) then
		local ClsGuildShopUI = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(ClsGuildShopUI) then
			ClsGuildShopUI:close()
		end
		guild_ui:createGuildTask()
	else
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local goal_layer = missionSkipLayer:skipLayerByName("guild_task")
	end
end

Alert.goToContribute = function(self)
	local parent = self.parent
	local guild_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_ui) then
		local ClsGuildShopUI = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(ClsGuildShopUI) then
			ClsGuildShopUI:close()
		end

		guild_ui:btnDonateClick()
	else
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local goal_layer = missionSkipLayer:skipLayerByName("guild_donate")
	end
end

Alert.goArena = function(self)
	if getGameData():getTeamData():isLock(true) then return end
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("arena")
end

Alert.goShipyardStore = function(self)
	local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
	if not tolua.isnull(shipyard_ui) then
		shipyard_ui:enterAssignTab(TAB_SHOP)
		return
	end

	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("shipyard_shop")
end

Alert.goMarket = function(self)
	local come_type = self.parameter.come_type
	local come_name = self.parameter.come_name
	local enter_call = self.parameter.enter_call--之前需要进行的操作

	if getGameData():getTeamData():isLock(true) then return end

	local go
	go = function()
		self:openMarketView(self.parent, come_type, come_name)
	end

	if type(enter_call) == "function" then
		enter_call(go)
		return
	end
	go()
end

Alert.goCangbaoTu = function(self)
	if getGameData():getTeamData():isLock(true) then return end
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("backpack_other")
end

Alert.goFire = function(self)
	local hotel_main_ui = getUIManager():get("ClsHotelMain")
	if tolua.isnull(hotel_main_ui) then
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local goal_layer = missionSkipLayer:skipLayerByName("foster")
	else
		local partner_info_view = getUIManager():get("ClsPartnerInfoView")
		local sailor_list_view = getUIManager():get("ClsSailorListView")
		if not tolua.isnull(partner_info_view) then
			getUIManager():close("ClsPartnerInfoView")
			local close_btn = partner_info_view:getCloseBtn()

			if not tolua.isnull(sailor_list_view) then
				sailor_list_view:closeSailorViewCB()
			end
		end

		local current_tab_index = hotel_main_ui:getCurrentTabIndex()
		if current_tab_index ~= HOTEL_REWARD then
			local sailor_list_btn = hotel_main_ui:getSailorListBtn()
			sailor_list_btn:executeEvent(TOUCH_EVENT_ENDED)
		end
	end
	local sailor_list_view = getUIManager():get("ClsSailorListView")
	if not tolua.isnull(sailor_list_view) then
		local fire_btn = sailor_list_view:getFireBtn()
		fire_btn:executeEvent(TOUCH_EVENT_ENDED)
	end
end

Alert.goPeerage = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("peerages")
end

Alert.goAutoTrade = function(self)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = missionSkipLayer:skipLayerByName("auto_trade")
end

Alert.goShopDiamond = function(self)
	local enter_call = self.parameter.enter_call--之前需要进行的操作
	if type(enter_call) == "function" then
		enter_call()
	end

	local mall_ui = getUIManager():get("ClsMallMain")
	if tolua.isnull(mall_ui) then
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local goal_layer = missionSkipLayer:skipLayerByName("mall_charge")
	else
		local ClsMallBuyTips = getUIManager():get("ClsMallBuyTips")
		if not tolua.isnull(ClsMallBuyTips) then
			ClsMallBuyTips:closeView()
		end

		mall_ui:selectTab(3)
	end
end

Alert.goActivity = function(self)
	local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = mission_skip_layer:skipLayerByName("activity")
end

Alert.toWorldMap = function(self)
	local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
	local goal_layer = mission_skip_layer:skipLayerByName("world_mission")
end

Alert.goMunicipalWork = function(self, target_ui)
	local player_data = getGameData():getPlayerData()
	local on_off_data = getGameData():getOnOffData()
	local municipal_work_data = getGameData():getMunicipalWorkData()
	local task_list = municipal_work_data:getTaskList()
	if #task_list == 0 then
		return
	end
	if player_data:getPower() >= 1000 and on_off_data:isOpen(on_off_info.TOWN_WORK.value) then
		self:showAttention(ClsUiWord.STR_MUNICIPAL_WORK_GO_TIPS, function()
			target_ui:close()
			local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
			mission_skip_layer:skipLayerByName("municipal_work")
		end, nil, nil, {hide_cancel_btn = true, ok_text = ClsUiWord.STR_GO})
	end
end

Alert.goShipyard = function(self)
	getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_BUILD)
end

Alert.goWelfareGift = function(self)
	getUIManager():create("gameobj/welfare/clsWelfareMain", nil, 4)
end

--按钮对应的事件
local event_by_kind = {
	["goGetMonthCard"] = Alert.goGetMonthCard,	    --购买VIP特权
	["goShop"] = Alert.goShop,						--去商城
	["goFindBaowu"] = Alert.goFindBaowu,			--组队寻宝
	["goMarket"] = Alert.goMarket,					--去交易所
	["goGetCashNow"] = Alert.goGetCashNow,			--立即获得银币
	["goGetJinghuaNow"] = Alert.goGetJinghuaNow,	--立即获取精华
	["goGuildWarehouse"] = Alert.goGuildWarehouse,	--公会仓库
	["goRecruit"] = Alert.goRecruit,				--招募
	["gojingyingFight"] = Alert.gojingyingFight,	--去精英战役
	["goGuildTask"] = Alert.goGuildTask,			--公会任务
	["goToContribute"] = Alert.goToContribute,		--公会捐献
	["goCangbaoTu"] = Alert.goCangbaoTu,			--藏宝图
	["goArena"] = Alert.goArena,					--竞技场
	["goShipyardStore"] = Alert.goShipyardStore,	--船厂商店
	["goFire"] = Alert.goFire,                      --解雇
	["goGetPowerNow"] = Alert.goGetPowerNow,		--立即获得体力
	["goPeerage"] = Alert.goPeerage,			    --爵位升级
	["goAutoTrade"] = Alert.goAutoTrade,            --委任经商界面
	["goShopDiamond"] = Alert.goShopDiamond,        --商城购买钻石
	["goActivityEveryday"] = Alert.goActivity,      --活动的日常任务
	["goWorldMission"] = Alert.toWorldMap,          --世界任务大地图
	["goShipyard"] = Alert.goShipyard,               --去造船厂
	["goWelfareGift"] = Alert.goWelfareGift         --每日礼包
}

Alert.updateGetCashNowShow = function(self, btn)
	local value = getConvertChildByName(btn, "btn_num")
	value:setVisible(false)
	local icon = getConvertChildByName(btn, "btn_icon")
	icon:changeTexture("common_icon_coin.png", UI_TEX_TYPE_PLIST)
	local text_sale = btn.text_sale
	text_sale:setVisible(false)
	local cash = self.parameter.need_cash

	local shop_date = getGameData():getShopData()

	if tolua.isnull(value) then return end
	local player_data = getGameData():getPlayerData()
	--local cur_cash = cash - player_data:getCash()

	local info = shop_date:getNearestShopItem(ITEM_TYPE_CASH, 0)
	value:setText(info.num)
	value:setVisible(true)

	if info.discount then
		text_sale:setText(string.format(ui_word.TIP_NEXT_SALE, tostring(info.discount)))
		text_sale:setVisible(true)
	else
		text_sale:setVisible(false)
	end
end

Alert.updateGetJinghuaNowShow = function(self, btn)
	local value = getConvertChildByName(btn, "btn_num")
	value:setVisible(false)
	local icon = getConvertChildByName(btn, "btn_icon")
	local text_sale = btn.text_sale
	text_sale:setVisible(false)

	icon:changeTexture("common_item_essence.png", UI_TEX_TYPE_PLIST)
	local shop_date = getGameData():getShopData()
	if tolua.isnull(value) then return end
	local info = shop_date:getNearestShopItem(ITEM_TYPE_TIEM, PROP_BAOWU_ESSENCE)
	value:setText(info.num)
	value:setVisible(true)
	if info.discount then
		text_sale:setText(string.format(ui_word.TIP_NEXT_SALE, tostring(info.discount)))
		text_sale:setVisible(true)
	else
		text_sale:setVisible(false)
	end
end

Alert.updateMarketBtnShow = function(self, btn)
	local market_ui = getUIManager():get("ClsPortMarket")
	if not tolua.isnull(market_ui) then
		btn:disable()
		return
	end

	if isExplore then
		btn:disable()
		return
	end

	local relic_discover_ui = getUIManager():get("ClsRelicDiscoverUI")
	if not tolua.isnull(relic_discover_ui) then
		btn:disable()
		return
	end
end

Alert.updateMonthCardBtnShow = function(self, btn)
	local player_data = getGameData():getPlayerData()
	local remain_day = player_data:getVipRemainDay()
	if remain_day and remain_day > 0 then--是VIP
		btn:disable()
		return
	end
end

Alert.updateGetPowerNowShow = function(self, btn)
	local value = getConvertChildByName(btn, "btn_num")
	value:setVisible(false)
	local icon = getConvertChildByName(btn, "btn_icon")
	local text_sale = btn.text_sale
	text_sale:setVisible(false)

	icon:changeTexture("common_icon_power.png", UI_TEX_TYPE_PLIST)
	local shop_date = getGameData():getShopData()

	if tolua.isnull(value) then return end
	local info = shop_date:getNearestShopItem(ITEM_TYPE_TILI)
	value:setText(info.num)
	value:setVisible(true)

	if info.discount then
		text_sale:setText(string.format(ui_word.TIP_NEXT_SALE, tostring(info.discount)))
		text_sale:setVisible(true)
	else
		text_sale:setVisible(false)
	end
end

Alert.updateGoShop = function(self, btn)
	if isExplore then
		btn:disable()
		return
	end
end

--按钮对应界面更新
local update_by_kind = {
	["goGetCashNow"] = Alert.updateGetCashNowShow,
	["goGetJinghuaNow"] = Alert.updateGetJinghuaNowShow,
	["goMarket"] = Alert.updateMarketBtnShow,
	["goGetMonthCard"] = Alert.updateMonthCardBtnShow,
	["goGetPowerNow"] = Alert.updateGetPowerNowShow,
	["goShop"] = Alert.updateGoShop,
}

Alert.portMarketPowerNoEnoughTips = function(self, cell_back)
	local name_str = "AlertPortMarketPowerNoEnoughTips"
	local view, ui_layer, panel = self:createBaseLayer("json/tips_res_2.json", "panel", name_str, cell_back)

	if view then
		view:setIgnoreClosePanel(panel)
	end
	local child_panel_1 = getConvertChildByName(panel, "child_panel_1")
	local child_panel_2 = getConvertChildByName(panel, "child_panel_2")
	local child_panel_3 = getConvertChildByName(panel, "child_panel_3")
	local btn_blue = getConvertChildByName(child_panel_3,"btn_blue_panel")
	btn_blue:setVisible(false)
	local btn_orange = getConvertChildByName(child_panel_3,"btn_orange_panel")
	btn_orange:setVisible(true)

	local btn_get = getConvertChildByName(btn_orange, "btn_3")
	btn_get:setPressedActionEnabled(true)
	btn_get:setVisible(true)
	btn_get:setTouchEnabled(true)
	btn_get:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(cell_back, name_str)
		event_by_kind["goGetPowerNow"](self)
	end, TOUCH_EVENT_ENDED)

	---商店
	local btn_mall = getConvertChildByName(panel, "btn_2")
	btn_mall:setPressedActionEnabled(true)
	btn_mall:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(cell_back, name_str)
		local come_type = self:getOpenShopType().VIEW_3D_TYPE
		local come_name = 'port_market_power_consume'
		event_by_kind["goShop"](self,come_type,come_name)
	end, TOUCH_EVENT_ENDED)

	----继续交易
	local btn_continue = getConvertChildByName(panel, "btn_1")
	btn_continue:setPressedActionEnabled(true)
	btn_continue:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(cell_back, name_str)
		local ClsPortMarket = getUIManager():get("ClsPortMarket")
		if not tolua.isnull(ClsPortMarket) then
			ClsPortMarket:gotoAccount()
		end
	end, TOUCH_EVENT_ENDED)

	-- btn text
	local cfg = jump_info["POWER_NOT_ENOUGH_MARKET"]
	local btn_text_1 = getConvertChildByName(child_panel_1,"btn_text")
	btn_text_1:setText(cfg["btn_info"][1].text)
	local btn_text_2 = getConvertChildByName(child_panel_2,"btn_text")
	btn_text_2:setText(cfg["btn_info"][2].text)
	local btn_text_3 = getConvertChildByName(btn_orange,"btn_text")
	btn_text_2:setText(cfg["btn_info"][3].text)
	local desc = getConvertChildByName(panel,"desc")
	desc:setText(cfg.description)
	local title = getConvertChildByName(panel,"title")
	title:setText(cfg.title)

end

----close_view_name:关闭不足弹框的上级界面name
Alert.showJumpWindow = function(self, kind, parent, parameter, close_view_name)
	local name_str = "AlertShowJumpWindow"
	parameter = parameter or {}
	if isExplore and parameter and not parameter.ignore_sea then
		local show_txt = string.format(ui_word.RES_NOT_ENOUGH_TIP, jump_info[kind].title)
		Alert:warning({msg = show_txt})
		return
	end
	parameter = parameter or {}
	self.kind = kind
	self.parent = parent
	self.parameter = parameter
	local n_touch_call = parameter.close_call

	local windown_info = jump_info[kind]
	local main_panel_index =  windown_info.main_panel_index
	local view, ui_layer, panel

	if getUIManager():isLive("AlertShowJumpWindow") then
		getUIManager():close("AlertShowJumpWindow")
	end
	if main_panel_index == 3 then
		view, ui_layer, panel = self:createBaseLayer("json/tips_res_2.json", "panel", name_str, n_touch_call)
	else
		view, ui_layer, panel = self:createBaseLayer("json/tips_res_1.json", "panel", name_str, n_touch_call)
	end
	ui_layer.onTipsExit = function()
		if type(parameter.destroy_callback) == "function" then 
			parameter.destroy_callback()
		end
	end

	local title = getConvertChildByName(panel, "title")
	title:setText(windown_info.title)

	local desc = getConvertChildByName(panel, "desc")
	desc:setText(windown_info.description)


	local mian_panel_name = string.format("btn_panel_%s", main_panel_index)

	local main_panel = getConvertChildByName(panel, mian_panel_name)
	main_panel:setVisible(true)

	for k = 1, main_panel_index do
		local child_panel_name = string.format("child_panel_%s", k)
		local btn_info = windown_info.btn_info[k]
		local child_panel = getConvertChildByName(main_panel, child_panel_name)

		local btn_type = btn_info.type or "blue"--默认使用蓝色按钮
		local btn_panel_name = string.format("btn_%s_panel", btn_type)
		local btn_panel = getConvertChildByName(child_panel, btn_panel_name)
		btn_panel:setVisible(true)

		local btn_name = string.format("btn_%s", k)
		local btn = getConvertChildByName(btn_panel, btn_name)
		btn.name = btn_name--用于功能开关的有关逻辑
		local btn_text = getConvertChildByName(btn, "btn_text")
		if btn_type == "orange" then
			local text_sale = getConvertChildByName(btn_panel, "text_sale")
			btn.text_sale = text_sale
		end
		btn:setTouchEnabled(true)
		btn:setPressedActionEnabled(true)
		btn_text:setText(btn_info.text)

		if type(update_by_kind[btn_info.event]) == "function" then
			update_by_kind[btn_info.event](self, btn)
		end

		if btn:isEnabled() and btn_info.key then--再考虑功能开关
			setBtnShow(btn, on_off_info[btn_info.key].value, btn_info.text, name_str)
		end

		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:delAttention(nil, name_str)
			if close_view_name and not tolua.isnull(getUIManager():get(close_view_name)) then
				getUIManager():get(close_view_name):close()
			end

			event_by_kind[btn_info.event](self)
		end, TOUCH_EVENT_ENDED)
	end
	return view
end

local alignLabel
alignLabel = function(obj_1, obj_2, aim_obj)
	local obj_1_pos = obj_1:convertToWorldSpace(ccp(0,0))
	local obj_2_pos = obj_2:convertToWorldSpace(ccp(0,0))
	local dis_x = obj_2_pos.x - obj_1_pos.x
	local total_width = obj_2:getSize().width + obj_1:getSize().width*obj_1:getScale()/2
	if total_width > dis_x then
		local old_pos = aim_obj:getPosition()
		aim_obj:setPosition(ccp(old_pos.x + total_width - dis_x, old_pos.y))
	end
end

--提示可以进行分行，str_1, str_2都给与内容就代表有两行间隔提示，只有str_1就是一行文本
--red_tips, btn_name, cost_not_enough为params中的参数
Alert.showCostDetailTips = function(self, str_1, str_2, cost_type, cost_id, cost_num, cost_str, call_back, params)
	params = params or {}
	local name_str = "AlertShowCostDetailTips"
	if getUIManager():isLive("AlertShowCostDetailTips") then
		getUIManager():close("AlertShowCostDetailTips")
	end
	local view, ui_layer, panel = self:createBaseLayer("json/tips_team_port.json", "panel", name_str)
	if view then
		view:setIgnoreClosePanel(panel)
	end
	local btn_confirm = getConvertChildByName(panel, "btn_confirm")
	local btn_text_confirm = getConvertChildByName(panel, "btn_text_confirm")
	local multi_panel = getConvertChildByName(panel, "team_panel")
	local multi_txt_1 = getConvertChildByName(panel, "text_port")
	local multi_txt_2 = getConvertChildByName(panel, "text_team")

	local single_txt = getConvertChildByName(panel, "text_2")
	local red_tip_label = getConvertChildByName(panel, "text_not_enough")
	local cost_tips_txt = getConvertChildByName(panel, "text_1")
	red_tip_label:setVisible(true)

	local cost_num_txt = getConvertChildByName(panel, "coin_num")
	local cost_icon = getConvertChildByName(panel, "coin")
	local cost_bg = getConvertChildByName(panel, "text_bg")

	if params.btn_name and string.len(params.btn_name) > 0 then
		btn_text_confirm:setText(params.btn_name)
	end

	if params.red_tips and string.len(params.red_tips) > 0 then
		red_tip_label:setText(params.red_tips)
	else
		red_tip_label:setText("")
	end

	if str_2 and string.len(str_2) > 0 then
		multi_panel:setVisible(true)
		multi_txt_1:setText(str_1)
		multi_txt_2:setText(str_2)
		single_txt:setText("")
	else
		multi_panel:setVisible(false)
		single_txt:setText(str_1)
	end

	local res, _, scale, name = getCommonRewardIcon({type = cost_type, id = cost_id, amount = cost_num})
	cost_icon:changeTexture(convertResources(res), UI_TEX_TYPE_PLIST)
	cost_num_txt:setText(cost_num)
	if type(cost_num) == "number" and cost_num <= 0 then
		cost_bg:setVisible(false)
	end
	if params.cost_not_enough then
		setUILabelColor(cost_num_txt, ccc3(dexToColor3B(COLOR_RED)))
	end
	if cost_str and string.len(cost_str) > 0 then
		cost_tips_txt:setText(cost_str)
	else
		--自适应居中
		local show_panel = getConvertChildByName(panel, "Panel")
		local off_set_x = 10
		local old_pos = show_panel:getPosition()
		local total_size = cost_num_txt:getSize().width + cost_icon:getSize().width * cost_icon:getScale() - off_set_x
		show_panel:setPosition(ccp(- total_size/2, old_pos.y))
		cost_tips_txt:setText("")
	end

	btn_confirm:setPressedActionEnabled(true)
	btn_confirm:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:delAttention(call_back, name_str)
		end, TOUCH_EVENT_ENDED)
	return view
end

--造船厂购买材料提示
Alert.showBuyMaterialTip = function(self, paramter)
	local call_back = paramter.call_back
	local name_str = "AlertShowBuyMaterialTip"
	local view, ui_layer, panel = self:createBaseLayer("json/tips_shipyard_material_tips.json", "panel", name_str)
	if view then
		view:setIgnoreClosePanel(panel)
	end
	local btn_confirm = getConvertChildByName(panel, "btn_confirm")
	btn_confirm:setPressedActionEnabled(true)
	btn_confirm:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(call_back, name_str)
	end, TOUCH_EVENT_ENDED)
end

Alert.longBtnEvent = function(self, panel, name_str, ok_func)
	local btn_use = getConvertChildByName(panel, "btn_use")
	btn_use:setTouchEnabled(true)
	btn_use:setPressedActionEnabled(true)
	btn_use:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(ok_func, name_str)
	end, TOUCH_EVENT_ENDED)
end

local tips_event_by_kind = { 
	[TIP_WIN_LONG_BTN] = Alert.longBtnEvent,
}

local tips_json_res = {
	[TIP_WIN_LONG_BTN] = "json/tips_high_treasure_map.json",
}

--根据类型弹相应的提示框
Alert.showTipWindow = function(self, kind, ok_func, close_func, parameter)
	local name_str = "AlerShowTipWindow"
	local view, ui_layer, panel = self:createBaseLayer(tips_json_res[kind], "panel", name_str, close_func)
	tips_event_by_kind[kind](self, panel, name_str, ok_func, parameter)
end

--
--params = {
-- area_name 海域名字
-- port_name 港口名字
-- go_callback 导航按钮的回调
-- }
Alert.showGoToPortFight = function(self, params)
	local name_str = "AlertPortFightTip"
	local view, ui_layer, panel = self:createBaseLayer("json/tips_portfight_go.json", "panel", name_str)

	if view then
		view:setIgnoreClosePanel(panel)
	end

	local lbl_area_txt = getConvertChildByName(panel, "text_2")
	local lbl_port_txt = getConvertChildByName(panel, "text_3")
	local btn_navigate = getConvertChildByName(panel, "btn_navigate")

	local area_name = params.area_name or ""
	local port_name = params.port_name or ""

	lbl_area_txt:setText(area_name)
	lbl_port_txt:setText(port_name)

	btn_navigate:setPressedActionEnabled(true)
	btn_navigate:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:delAttention(params.go_callback, name_str)
	end, TOUCH_EVENT_ENDED)
end

--有版本更新，服务器下行弹出来的框，优先级最高处理
Alert.showVersionTips = function(self, msg)
	local login_relink_ui = require("ui/loginRelinkUI"):getCurUIObj()
	if not tolua.isnull(login_relink_ui) then
		login_relink_ui:removeFromParentAndCleanup(true)
	end
	if not tolua.isnull(Alert.vertion_ui) then
		return
	end
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_update.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = CCLayer:create()
	local ui_layer = UILayer:create()
	scene:addChild(layer)
	ui_layer:addWidget(panel)
	layer:addChild(ui_layer)

	Alert.vertion_ui = layer

	local touch_rect = CCRect(272, 144, 435, 275)
	local __onTouch
	__onTouch = function(eventType, x, y)
		if eventType == "began" then
			if touch_rect:containsPoint(ccp(x,y)) then 
				return false
			end 
			return true
		end
	end

	layer:setZOrder(TOPEST_ZORDER)
	layer:registerScriptTouchHandler(__onTouch, false, TOUCH_PRIORITY_RPCTIPS, true)
	layer:setTouchEnabled(true)
	ui_layer:setTouchEnabled(true)

	local btn_ok = getConvertChildByName(panel, "btn_middle")
	btn_ok:setPressedActionEnabled(true)
	local btn_ok_txt = getConvertChildByName(panel, "btn_text_middle")
	btn_ok_txt:setText(ui_word.OUT_GAME_TIPS)
	
	local closeGame
	closeGame = function()
		CCDirector:sharedDirector():endToLua()
	end 
	
	btn_ok:addEventListener(closeGame, TOUCH_EVENT_ENDED)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeGame, TOUCH_EVENT_ENDED)

	local txt_update = getConvertChildByName(panel, "txt_update")
	txt_update:setText(msg)
	txt_update:setVisible(true)
end

return Alert
