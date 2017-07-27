local element_mgr = require("base/element_mgr")
local ui_word = require("game_config/ui_word")

local action_tab = {}

local showTip
showTip = function(msg, x, y, color)
	x = x or 264
	y = y or 290
	color = color or ccc3(dexToColor3B(COLOR_RED))
	local Alert = require("ui/tools/alert")
	Alert:warning({msg = msg, x = x, y = y, color = color})
end

local skipGuildTaskViewAction
skipGuildTaskViewAction = function(chat_id)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	missionSkipLayer:skipLayerByName("guild_detail_multi", nil)
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		action_tab[chat_id] = nil
	end
end

local shareEvent
shareEvent = function(...)
	local key = arg[1]
	local market_data = getGameData():getMarketData()
	market_data:askPortHotSellShareGet(key)
end

local exploreEvent
exploreEvent = function(...)
	local key = arg[1]
	--探索事件分享
	local sceneLayer = element_mgr:get_element("ClsGuildOpenLayer")
	local copy_scene = getUIManager():get("ClsCopySceneLayer")

	if not tolua.isnull(sceneLayer) or (not tolua.isnull(copy_scene)) then
		local tips = require("game_config/tips")
		showTip(tips[168].msg)
		return
	end
end

local skipGuildTaskViewEvent
skipGuildTaskViewEvent = function(...)
	local chat_id = arg[1]
	if getGameData():getTeamData():isTeamLock(true) then return end
	action_tab[tonumber(chat_id)] = skipGuildTaskViewAction
	
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		GameUtil.callRpc("rpc_server_chat_check", {tonumber(chat_id)})
	else
		showTip(ui_word.EXPLORE_CLICK_ENTER_BOSS)
	end
end

local enterBossViewEvent
enterBossViewEvent = function(...)
	if getGameData():getTeamData():isTeamLock(true) then return end
	local GuildBossData = getGameData():getGuildBossData()
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		local guild_info_data = getGameData():getGuildInfoData()
		if guild_info_data:hasGuild() then
			--添加停止触摸的方法，防止在消息还没到的时候点到聊天页面
			GuildBossData:setSkipTag(1)
			GuildBossData:askGuildBossInfo()
		else
			showTip(ui_word.STR_GUILD_ADD_TIPS)
		end
	else
		showTip(ui_word.EXPLORE_CLICK_ENTER_BOSS)
	end
end

local enterBossWithGetRewardEvent
enterBossWithGetRewardEvent = function(...)
	local GuildBossData = getGameData():getGuildBossData()
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		local guild_info_data = getGameData():getGuildInfoData()
		if guild_info_data:hasGuild() then
			GuildBossData:setSkipTag(1)
			GuildBossData:askGuildBossInfo()
		else
			showTip(ui_word.STR_GUILD_ADD_TIPS)
		end
	else
		showTip(ui_word.EXPLORE_CLICK_ENTER_BOSS)
	end
end

local enterGuildShopGiftEvent
enterGuildShopGiftEvent = function(...)
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local skip_layer = missionSkipLayer:skipLayerByName("guild_gift", nil)
		local port_layer = getUIManager():get("ClsPortLayer")
		port_layer:addItem(skip_layer)
	else
		showTip(ui_word.EXPLORE_CLICK_ENTER_BOSS)
	end
end

local enterGuildTeamEvent
enterGuildTeamEvent = function(...)
	local chat_id = arg[1]
	local port_id = tonumber(arg[2])
	getGameData():getTeamData():handleChatEvent(1, chat_id, port_id)
end

local enterWorldTeamEvent
enterWorldTeamEvent = function(...)
	local team_id = arg[1]
	local address_id = tonumber(arg[2])
	getGameData():getTeamData():handleChatEvent(2, team_id, address_id)
end

local grabRedPackageEvent
grabRedPackageEvent = function(...)
	local gift_id = tonumber(arg[1])
	local guild_shop_data = getGameData():getGuildShopData()
	local tip_ui = getUIManager():get("ClsGuildGiftTip")
	if not tolua.isnull(tip_ui) then
		local data = tip_ui:getData()
		if data.giftId == gift_id then
			tip_ui:closeView()
		end
	end
	guild_shop_data:askGrabGuildGif(gift_id)
end


local showShareRelic
showShareRelic = function(...)
	local relic_id = tonumber(arg[1])
	local chat_id = tonumber(arg[2])
	local task_cash = 100000
	local relic_info = require("game_config/collect/relic_info")
	local cur_info = relic_info[relic_id]
	if cur_info then
		local show_txt = string.format(ui_word.BUY_SHARE_RELIC_TIP, task_cash, cur_info.name)
		local Alert = require("ui/tools/alert")
		Alert:showAttention(show_txt, function()
			local collect_data = getGameData():getCollectData()
			if not collect_data:isDiscoveryRelic(relic_id) then 
				local playerData = getGameData():getPlayerData()
				local cur_cash = playerData:getCash()
				if cur_cash >= task_cash then
					collect_data:askBuyShareRelic(relic_id, chat_id)
				else
					showTip(ui_word.BUY_RELIC_FAIL)
				end
			else
				local show_txt = string.format(ui_word.RELIC_ALREADY_EXIST, cur_info.name)
				showTip(show_txt)
			end
		end)
	end
end

local clickJoinGuild
clickJoinGuild = function(...)
	local guild_id = tonumber(arg[1])
	local guild_icon_id = tonumber(arg[2])
	local guild_name = arg[3]
	local guild_level = arg[4]

	local data = {
		res = guild_icon_id,
		name = guild_name,
		id = guild_id,
		level = guild_level,
	}

	getUIManager():create("gameobj/guild/clsCreateGuildTips.lua",nil,data,nil,true)
end

--获得船舶
local showBoatTips
showBoatTips = function(parameter)
	getUIManager():create("gameobj/chat/clsChatToShowBoat", nil, parameter)
end

--获得船舶宝物
local showBoatBaowuTips
showBoatBaowuTips = function(parameter)
	getUIManager():create("gameobj/chat/clsChatToShipEquip", nil, parameter)
end

--获得宝物
local showBaowuTips
showBaowuTips = function(parameter)
	getUIManager():create("gameobj/chat/clsChatToBaowu", nil, parameter)
end

--获得道具
local showItemTips
showItemTips = function(parameter)
	-- {
	--     ["id"] = 34.000000,
	--     ["name"] = "高级阿拉伯桨帆船图纸",
	-- }
end

--获得水手
local showSailorTips
showSailorTips = function(parameter)
	local playerData = getGameData():getPlayerData()
	local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
	mission_skip_layer:skipSailorCollectUI(nil, playerData:getUid(), nil, parameter.id)
end

local useCoating
useCoating = function(...)
	print("使用幻彩涂装")
end

local buySeaBaozang
buySeaBaozang = function(...)
	getUIManager():close("clsNewShipEffectUI")
	local ship_effect_ui = getUIManager():get("clsNewShipEffectUI")
	if not tolua.isnull(ship_effect_ui) then
		ship_effect_ui:closeView()
	end
	getUIManager():close("ClsBackpackItemTips")
	getUIManager():create("gameobj/welfare/clsWelfareMain",nil,1)
end

local DIAMOND_NUM = 40
local helpFinishMission
helpFinishMission = function(...)
	local mission_data_handler = getGameData():getMissionData()
	local info = mission_data_handler:getAssistInfo()

	local Alert = require("ui/tools/alert")

	local chat_id, port_id = ...

	if info.used_count == info.total_count then
		Alert:showAttention(ui_word.MISSION_HELP_NONE_TIMES, function()
			enterGuildTeamEvent(chat_id, port_id)
		end, nil, nil, {hide_cancel_btn = true, ok_text = ui_word.MAIN_CONTINUE})
		return
	end

	local _, _, _, panel = Alert:showAttention(ui_word.MISSION_HELP_TIP, function()
		enterGuildTeamEvent(chat_id, port_id)
	end, nil, nil, {hide_cancel_btn = true})

	local widgets = {}
	local widget_info = {
		[1] = {name = "questionnaire_panel"},
		[2] = {name = "text_times"},
		[3] = {name = "text_num"},
	}

	for k, v in ipairs(widget_info) do
		local item = getConvertChildByName(panel, v.name)
		item:setVisible(true)
		widgets[v.name] = item
	end

	local coin_num = getConvertChildByName(widgets.questionnaire_panel, "coin_num")
	coin_num:setText(tostring(DIAMOND_NUM))
	widgets.text_num:setText(string.format("%d/%d", info.used_count, info.total_count))
end

local gotoOtherPort
gotoOtherPort = function(...)
	local port_id = tonumber(arg[1])
	local port_info = require("game_config/port/port_info")
	local Alert = require("ui/tools/alert")
	local cur_port_id = getGameData():getPortData():getPortId()
	local portLayer = getUIManager():get("ClsPortLayer")
	if cur_port_id == port_id and not tolua.isnull(portLayer) then
		Alert:warning({msg = string.format(ui_word.BLACKMARKET_PORT_LBL, port_info[port_id].name) , size = 26})
		return 
	end
	getGameData():getTeamData():toEnterOtherTeam(port_id, function()
		local boatData = getGameData():getBoatData()
		boatData:gotoOtherPort(port_id)
	end)
end


--['msg'] = T('$(touch:["SHARE_TAG","%s"])$(c:COLOR_GREEN)%s$(c:COLOR_CREAM_STROKE)的商品正在热销！前3位$(c:COLOR_GREEN)点击这条消息$(c:COLOR_CREAM_STROKE)的小伙伴即可共享热销状态~'),
--['msg'] = T('%s分享了探索副本事件$(touch:["EXPLORE_TAG","%s"])$(c:COLOR_GREEN)【点击查看】'),
--['msg'] = T('$(touch:["GUILD_TASK_TAG","%s"])%s发布了多人任务《%s》，当前参与人数%s/3$(c:COLOR_GREEN)【点击查看】'),
--['msg'] = T('$(touch:["BOSS_TAG"])商会已开启对大海盗的讨伐$(c:COLOR_GREEN)【点击查看】'),
--['msg'] = T('$(touch:["BOSS_REWARD_TAG"])商会已击垮大海盗，并搜获大量宝箱$(c:COLOR_GREEN)【点击查看】'),

--函数调用参数的意义和服务端协商
local touchEvent = {
	--策划配表的事件
	["SHARE_TAG"] = shareEvent,
	["EXPLORE_TAG"] = exploreEvent,
	["GUILD_TASK_TAG"] = skipGuildTaskViewEvent,         --商会多人任务
	["BOSS_TAG"] = enterBossViewEvent,                   --商会战场
	["BOSS_REWARD_TAG"] = enterBossWithGetRewardEvent,
	["GUILD_GIFT_TAG"] = enterGuildShopGiftEvent,        --商会礼包
	["TEAM_INVITATION"] = enterGuildTeamEvent,           --商会组队邀请
	["GUILD_GIFT_TIP_TAG"] = grabRedPackageEvent,        --商会礼包
	["WORLD_TEAM_INVITATION"] = enterWorldTeamEvent,     --世界组队邀请
	["SHARE_RELIC"] = showShareRelic,                    --分享遗迹信息
	["CLICK_JOIN_GUILD"] = clickJoinGuild,               --入会
	["GO_USE_COATING"] = useCoating,                     --使用幻彩涂装
	["GO_BUT_SEA_BAOZANG"] = buySeaBaozang,              --购买海神宝藏
	["HELP_FINISH_MISSION"] = helpFinishMission,         --帮助完成主线战斗
	["GO_PORT"] = gotoOtherPort,                         ---跳转其他港口

	--服务端下发的事件
	["boatTips"] = showBoatTips,                         --显示船舶信息
	["boatBaowuTips"] = showBoatBaowuTips,               --船舶宝物
	["baowuTips"] = showBaowuTips,                       --宝物提示
	["itemTips"] = showItemTips,                         --道具提示
	["sailorTips"] = showSailorTips                      --水手提示
}

return {touchEvent = touchEvent, action_tab = action_tab}