-- 商会商店礼包弹出界面
local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsBaseView = require("ui/view/clsBaseView")

local group_gift_reason = require("game_config/guild/group_gift_reason")
local CompositeEffect = require("gameobj/composite_effect")

local panel_info = {
	[1] = {name = "get_gift_panel", kind = GUILD_GIFT_GIVE},
	[2] = {name = "collect_panel", kind = GUILD_GIFT_GRAB_INFO},
}

local collect_panel_widget_info = {
	[1] = {name = "have_collected", child = {[1] = {name = "collect_amount"}}, condition = {["is_have"] = true}},
	[2] = {name = "total_collect", child = {[1] = {name = "total_text"}, [2] = {name = "total_diamount_amount"}}, condition = {["is_have"] = false}},
	[3] = {name = "best_text", condition = {["my_best"] = true}},
	[4] = {name = "owner_head"},
	[5] = {name = "owner_name"},
	[6] = {name = "collect_tips"},
	[7] = {name = "over_text", condition = {["my_get"] = false}},
	[8] = {name = "best_diamond_amount", condition = {["my_get"] = true}},
	[9] = {name = "best_diamond_icon", condition = {["my_get"] = true}},
	[10] = {name = "title_pic_empty", condition = {["my_get"] = false}},
	[11] = {name = "get_award_text", condition = {["my_get"] = true, ["my_best"] = false}},
	[12] = {name = "title_pic_full", condition = {["current_get"] = false, ["my_get"] = true}},
}

local get_panel_widget_info = {
	[1] = {name = "btn_send_now"},
	[2] = {name = "btn_cancel"},
	[3] = {name = "get_tips"},
	[4] = {name = "diamond_amount"},
	[5] = {name = "gift_amount"},
}

local cell_widget_info = {
	[1] = {name = "player_head"},
	[2] = {name = "player_name"},
	[3] = {name = "get_day"},
	[4] = {name = "get_time"},
	[5] = {name = "diamond_amount"},
	[6] = {name = "best_text"},
	[7] = {name = "player_name_my"},
}

local ClsListCell = class("ClsListCell", ClsScrollViewItem)
function ClsListCell:updateUI(data, panel)
    
    for k, v in ipairs(cell_widget_info) do
    	self[v.name] = getConvertChildByName(panel, v.name)
    end
    local is_best = false
   
    local popup_ui = getUIManager():get("ClsGuildGiftPopupUI")
    if popup_ui.best_people then
    	if data.uid == popup_ui.best_people.uid then
    		is_best = true
    	end
    end

    local player_data = getGameData():getPlayerData()
    local player_uid = player_data:getUid()
    self.best_text:setVisible(is_best)
    self.player_name:setText(data.name)
    self.diamond_amount:setText(data.gold)
    self.player_name_my:setVisible(player_uid == data.uid)

    self.get_day:setText(os.date("%Y-%m-%d", data.get_time))
    self.get_time:setText(os.date("%H:%M", data.get_time))

    local res = string.format("ui/seaman/seaman_%s.png", data.icon)
    self.player_head:changeTexture(res, UI_TEX_TYPE_LOCAL)
end

local ClsGuildGiftPopupUI = class("ClsGuildGiftPopupUI", ClsBaseView)


function ClsGuildGiftPopupUI:getViewConfig(...)
    return {type =  UI_TYPE.TOP}
end

function ClsGuildGiftPopupUI:onEnter(parameter)
	self.parameter = parameter
	self.kind = parameter.kind
	self.gift_info = parameter.gift_info

	self.res_plist = {
        ["ui/guild_ui.plist"] = 1,
    }
    LoadPlist(self.res_plist)
    self:configUI()
end

function ClsGuildGiftPopupUI:configGetGiftPanelUI()
	for k, v in ipairs(get_panel_widget_info) do
		local item = getConvertChildByName(self.get_gift_panel, v.name)
		item.name = v.name
		self.get_gift_panel[v.name] = item
	end
	
	local gift_info = self.gift_info

	local panel = self.get_gift_panel
	panel.btn_send_now:setTouchEnabled(true)
	panel.btn_send_now:setPressedActionEnabled(true)

	panel.btn_cancel:setTouchEnabled(true)
	panel.btn_cancel:setPressedActionEnabled(true)

	panel.btn_send_now:addEventListener(function()
		local guild_shop_data = getGameData():getGuildShopData()
       	guild_shop_data:askGiveOutGuildGif(gift_info.giftId)
       	self:closeView()
	end, TOUCH_EVENT_ENDED)

	panel.btn_cancel:addEventListener(function() 
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	panel.diamond_amount:setText(gift_info.gold)
	panel.gift_amount:setText(gift_info.cnt)

	local effect_layer = getConvertChildByName(self.panel, "effect_layer")
	local show_txt = string.format(ui_word.GUILD_GET_FUNCTION_TIP, group_gift_reason[gift_info.reason].title)
	self.get_gift_panel.get_tips:setText(show_txt)
	--创建特效
	local put_effect_layer = display.newLayer()
	effect_layer:addCCNode(put_effect_layer)
	local box_effect = CompositeEffect.new("tx_0168", 480, 390, put_effect_layer, nil, function() end)
	audioExt.playEffect(music_info.GUILD_WAREHOUSE_GIFT.res)
end

function ClsGuildGiftPopupUI:configCollectPanelUI()
	local player_data = getGameData():getPlayerData()
	local player_uid = player_data:getUid()

	local gift_info = self.gift_info
	local my_get = false--默认自己没有抢到红包（实际的意思是抢到了，不论是否之前就抢到了，还是现在这时抢到的）
	local my_best = false --默认自己不是最佳
	local current_get = false
	local my_gift_info = nil
	local reward_list = gift_info.rewardlist
	for k, v in pairs(reward_list) do
		if v.uid == player_uid then
			my_get = true
			my_gift_info = v
			break
		end
	end

	local is_have = true--是否还有？
	local current_get_num = 0
	for k, v in pairs(reward_list) do
		current_get_num = current_get_num + 1
	end
	
	if current_get_num == gift_info.cnt then
		is_have = false
	end

	if not is_have then
		self.best_people = reward_list[1]
		for k, v in pairs(reward_list) do
			if reward_list[k].gold > self.best_people.gold then
				self.best_people = v
			end
		end
		if self.best_people.uid == player_uid then
			my_best = true
		end
	end

	local guild_shop_data = getGameData():getGuildShopData()
	local gift_status = guild_shop_data:getGiftStatus(gift_info.giftId)

	local current_results = {
		["is_have"] = is_have,
		["my_best"] = my_best,
		["my_get"] = my_get,
		["current_get"] = (gift_status == GIFT_GET),
	}

	print("+++++++++++++++++++++++", is_have, my_best, my_get, (gift_status == GIFT_GET))
	for k, v in ipairs(collect_panel_widget_info) do
		local item = getConvertChildByName(self.collect_panel, v.name)
		item.condition = v.condition
		if v.child then
			for i, j in ipairs(v.child) do
				local children = getConvertChildByName(item, j.name)
				item[j.name] = children
			end
		end
		self.collect_panel[v.name] = item
		local is_available = true
		if v.condition then
			for g, h in pairs(v.condition) do
				print("g#######################", g, current_results[g], h)
				if current_results[g] ~= h then
					is_available = false
					break
				end
			end 
		end
		item:setVisible(is_available)
	end

	local panel = self.collect_panel

	if gift_info.icon and gift_info.icon ~= "" then
		local res = string.format("ui/seaman/seaman_%s.png", gift_info.icon)
	    panel.owner_head:changeTexture(res, UI_TEX_TYPE_LOCAL)
	else
		panel.owner_head:changeTexture("common_icon_guild.png", UI_TEX_TYPE_PLIST)
		local pos = panel.owner_head:getPosition()
		panel.owner_head:setPosition(ccp(pos.x, pos.y - 5))
		panel.owner_head:setScale(0.65)
	end

	local show_txt = string.format("%d/%d", current_get_num, gift_info.cnt)
	panel.have_collected.collect_amount:setText(show_txt)

	show_txt = string.format(ui_word.GUILD_SHOP_GIFT_ALL_TIP, gift_info.cnt)
	panel.total_collect.total_text:setText(show_txt)

	panel.total_collect.total_diamount_amount:setText(gift_info.gold)
	local name = gift_info.name == '' and ui_word.GUILD_NAME or gift_info.name 
	show_txt = string.format(ui_word.GUILD_SHOP_GIFT_NAME, name)
	panel.owner_name:setText(show_txt)

	show_txt = string.format(ui_word.GUILD_SHOP_GET_GIFT_DEC, group_gift_reason[gift_info.reason].title)
	panel.collect_tips:setText(show_txt)

	if my_gift_info then
		panel.best_diamond_amount:setText(my_gift_info.gold)
	end

	if #reward_list < 1 then return end

	--排序最新的排最前
	table.sort(reward_list, function(a, b)
		return a.get_time > b.get_time
	end)

	local my_reward = nil
	for k, v in ipairs(reward_list) do
		if v.uid == player_uid then
			my_reward = v
			table.remove(reward_list, k)
			break
		end
	end

	if my_reward then
		table.insert(reward_list, 1, my_reward)
	end

    self.list_view = ClsScrollView.new(413, 120, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_gift_list.json")
        return cell_ui
   	end, {is_fit_bottom = true})
   	
    self.list_view:setPosition(ccp(264, 66))
    self:addWidget(self.list_view)

    local current_cells = {}
	for k, v in ipairs(reward_list) do
        local current_cell = ClsListCell.new(CCSize(413, 60), v)
       	current_cells[#current_cells + 1] = current_cell
    end
    self.list_view:addCells(current_cells)
    
    local title_text_empty = getConvertChildByName(self.panel, "title_text_empty")
    if gift_status == GIFT_GET then
    	guild_shop_data:setGiftStatus(gift_info.giftId, GIFT_GETTED)
		local effect_layer = getConvertChildByName(self.panel, "effect_layer")
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCCallFunc:create(function ()
			title_text_empty:setVisible(true)
		end))
		self:runAction(CCSequence:create(array))
		--创建特效
		local put_effect_layer = display.newLayer()
		effect_layer:addCCNode(put_effect_layer)
		local box_effect = CompositeEffect.new("tx_0168", 480, 390, put_effect_layer, nil, function() end)
		audioExt.playEffect(music_info.GUILD_WAREHOUSE_GIFT.res)
	else
		title_text_empty:setVisible(true)
	end
end

local show_by_kind = {
	[GUILD_GIFT_GIVE] = ClsGuildGiftPopupUI.configGetGiftPanelUI,
	[GUILD_GIFT_GRAB_INFO] = ClsGuildGiftPopupUI.configCollectPanelUI
}

function ClsGuildGiftPopupUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_gift_popup.json")
    self:addWidget(self.panel)
	for k, v in ipairs(panel_info) do
		self[v.name] = getConvertChildByName(self.panel, v.name)
		self[v.name].name = v.name
		self[v.name].kind = v.kind
		self[v.name]:setVisible(v.kind == self.kind)
	end
	show_by_kind[self.kind](self)
    self.not_touch_rect = CCRect(263, 57, 440, 274)

    self:regTouchEvent(self, function(eventType, x, y)
    	local touch_point = ccp(x, y)
    	local is_in = self.not_touch_rect:containsPoint(touch_point)
    	if not is_in then
    		self:closeView()
    	end
	end)
end

function ClsGuildGiftPopupUI:closeView()
	self:close()
	local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
	if tolua.isnull(guild_shop_ui) then return end
	guild_shop_ui:setTouch(true)
end

function ClsGuildGiftPopupUI:onExit()
	UnLoadPlist(self.res_plist)
end



return ClsGuildGiftPopupUI