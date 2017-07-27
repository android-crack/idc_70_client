local error_info = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local element_mgr = require("base/element_mgr")
local ui_word = require("scripts/game_config/ui_word")
local parseMsg = require("module/message_parse")
local on_off_info = require("game_config/on_off_info")
local ClsChatAudioMessageBase = require("gameobj/chat/clsChatAudioMessageBase")
local rpc_down_info = require("game_config/rpc_down_info")
-- 解析系统发送的文本
local function parseSystemMessage(chat)
	chat.message = parseMsg.parse(chat.message)
	return chat
end

--公会聊天一次性下发最新50条信息
function rpc_client_chat_msg_list(list)
	if not list or #list < 0 then return end
	--解析消息
	for k, v in pairs(list) do
		list[k] = parseSystemMessage(v)
		if v.sender == GAME_SYSTEM_ID then
			if v.type == KIND_GUILD then
				list[k].senderName = ui_word.GUILD_NAME
			elseif v.type == KIND_SYSTEM then
				list[k].senderName = ui_word.SYSTEM_NAME
			end
		end 
	end
	local chat_data = getGameData():getChatData()
	chat_data:setList(list)
end

local function doBaseLogic(chat, channels)
	-- local module_start_game = require("module/login/startGame")
	-- local is_can = false
	-- if channels and #channels == 1 and channels[1] == '' then is_can = true end 
	-- if channels and #channels > 0 and not is_can then
	-- 	local current_channel_id = module_start_game.getChannelId()
	-- 	for k, v in ipairs(channels) do
	-- 		if v == current_channel_id then
	-- 			is_can = true
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- if not is_can then cclog("不能显示") return end

	local chat_data_handler = getGameData():getChatData()
	if chat.sender == GAME_SYSTEM_ID then
		if chat.type == KIND_GUILD then
			chat.senderName = ui_word.GUILD_NAME
		elseif chat.type == KIND_SYSTEM then
			chat.senderName = ui_word.SYSTEM_NAME
		end
	end

	chat_data_handler:insertList(chat)

	chat_data_handler:updateExploreChat(chat)
end

function rpc_client_chat_msg(chat, channels)
	local chat_data = getGameData():getChatData()
	if chat_data:isInBlack(chat.sender) then cclog("已经被拉入黑名单了") return end
	-- chat = {
	-- 	["area"] = "cn",
	-- 	["areaId"] = 6.000000,
	-- 	["areaType"] = 1.000000,
	-- 	["senderIcon"] = "101",
	-- 	["id"] = 0.000000,
	-- 	["message"] = "@(message:105|39,6,@(name:O%28%E2%88%A9%5F%E2%88%A9%29O),@(team:1),@(port:6))",
	-- 	["receiver"] = 0.000000,
	-- 	["receiverName"] = "{name = 我屮艸芔茻}",
	-- 	["sender"] = 10115.000000,
	-- 	["senderName"] = "O(∩_∩)O",
	-- 	["time"] = 1473068070.000000,
	-- 	["type"] = 1.000000,
	-- }

	-- chat.message = "@(message:105|39,6,O%28%E2%88%A9%5F%E2%88%A9%29O,@(team:1),@(port:6))"
	--以下注释是测试数据
	--(touch:["GUILD_GIFT_TIP_TAG","%d"])
	--chat.message = string.format('商会成员“%s”给大家发放了商会礼包，先到先得，船长们快来抢啊！$(c:COLOR_GREEN)$(msgcall:["GUILD_GIFT_TIP_TAG","%d"]|【打开礼包】)', "某某某", 134)
	-- chat.message = '$(button:#chat_play_btn.png|0.8,@@2@@101301472729565)习近平'
	chat.message = chat_data:parseAudio(chat.message)
	--船舶
	-- chat.message = '@(message:251|@(name:%28%40%5F%40%29),@(color:4),@(boatTips:{"rand_attrs":{"antiCrits":{"ba_quality":4,"ba_value":1440},"melee":{"ba_quality":2,"ba_value":668},"load":{"ba_quality":3,"ba_value":35}},"name":"高级皇家战列舰","quality":4,"rand_amount":4,"id":132,"base_attrs":{"defense":{"ba_quality":4,"ba_value":4203},"melee":{"ba_quality":4,"ba_value":2101},"range":{"ba_quality":4,"ba_value":500},"remote":{"ba_quality":4,"ba_value":6306},"speed":{"ba_quality":4,"ba_value":70},"durable":{"ba_quality":4,"ba_value":42044},"load":{"ba_quality":4,"ba_value":80}}}))'
	--道具
	-- chat.message = '@(message:229|@(name:(@~@)),@(color:4),@(itemTips:{"name":"高级阿拉伯桨帆船图纸","id":34}))'

	-- chat.message = chat_data:msgEncode(chat.message, 'name')

	-- chat.message = string.gsub(chat.message, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
 --    chat.message = string.gsub(chat.message, " ", "+")
	--水手
	-- chat.message = '@(message:85|@(name:徐亚),@(sailorTips:{"name":"克里·雷萨诺","id":34}))'
	--宝物
	-- chat.message = '@(message:251|@(name:徐亚),@(color:4),@(baowuTips:{"level":1,"name":"女爵佩剑","id":101,"color":2,"primary_attr":{"melee":{"attr_value":17,"attr_color":2},"remote":{"attr_value":17,"attr_color":2}}}))'
	--船舶宝物
	-- chat.message = '@(message:251|@(name:徐亚),@(color:4),@(boatBaowuTips:{"color":1,"level":1,"name":"人鱼船首像","primary_attr":{"speed":{"attr_color":0,"attr_value":2}},"id":401}))'
	--获得道具
	-- chat.message = '@(message:318|%E9%92%B1%E8%A2%8B,1)'

	--小聊天框屏蔽获得道具的系统消息
	local start_index, end_index = string.find(chat.message, "@%(message:318|") 
	chat.not_show_small = (type(end_index) == "number")

	chat = parseSystemMessage(chat)

	local chat_audio_message = element_mgr:get_element("ClsChatAudioMessageBase")
	if not chat_audio_message then
		chat_audio_message = ClsChatAudioMessageBase.new()
	end
	chat_audio_message:insertPlayQueue(chat)
	doBaseLogic(chat, channels)

	-- rpc_client_open_url(chat.message, "http://abcd.afsdf.com/abc.html?a=b,c=d")
end

local function rpcReturnCall(err, kind)
	local chat_data = getGameData():getChatData()
	if err ~= 0 then
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	else
		chat_data:cleanNotSendMsg()
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
			local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
			if not tolua.isnull(main_ui) then
				main_ui:cleanEidtBox()
			end
		end
	end
end

function rpc_client_chat_send(result, err, kind)
	rpcReturnCall(err, kind)
end

function rpc_client_open_url(msg, url)
	msg = string.format("$(url:%s,%s)", msg, url)
	local chat = {}
	chat.area = "cn"
	chat.message = msg
	chat.sender = GAME_SYSTEM_ID
	chat.senderName = ui_word.SYSTEM_NAME
	chat.url = url
	chat.type = KIND_SYSTEM
	doBaseLogic(chat)
end

--私聊成功与否返回协议
function rpc_client_chat_private(err)
	local kind = DATA_PRIVATE
	rpcReturnCall(err, kind)
end

--私聊数据
function rpc_client_chat_private_msg(msg)
	local chat_data = getGameData():getChatData()
	if chat_data:isInBlack(msg.sender) then cclog("已经被拉入黑名单了") return end
	msg = parseSystemMessage(msg)
	-- local chat_data = getGameData():getChatData()
	-- local msg = {
	-- 	id = 1,
	-- 	sender = 40000,
	-- 	senderName = "我叫新消息",
	-- 	senderRole = 2,
	-- 	senderIcon = "101",
	-- 	senderLevel = 80,
	-- 	receiver = 10041,
	-- 	receiverIcon = "10",
	-- 	receiverLevel = 10,
	-- 	receiverRole = 3,
	-- 	message = "更新了",
	-- 	time = 20,
	-- }
	msg.type = KIND_PRIVATE
	msg.areaType = 0
	local chat_data_handler = getGameData():getChatData()
	chat_data_handler:insertList(msg)
end

function rpc_client_chat_check(errno, chat_id)
	if errno == 0 then
		local touch_event_for_chat_message = require("gameobj/chat/touchEventForChatMessage")
		if type(touch_event_for_chat_message.action_tab[chat_id]) == "function" then
			touch_event_for_chat_message.action_tab[chat_id](chat_id)
		end
	else
		Alert:warning({msg = error_info[errno].message})
	end
end

function rpc_client_delete_chat(uid)
	local chat_data_handler = getGameData():getChatData()
	chat_data_handler:cleanMsgAppointUid(uid)
end

--删除商会聊天信息
function rpc_client_group_chat_delete(chat_id)
	local chat_data_handler = getGameData():getChatData()
	chat_data_handler:deleteMsgByKind(DATA_GUILD, chat_id)
end

--删除私聊信息
function rpc_client_friend_chat_delete(chat_id)
	local chat_data_handler = getGameData():getChatData()	
	chat_data_handler:deleteMsgByKind(DATA_PRIVATE, chat_id)
end

function rpc_client_chat_broadcast(msg)
	if msg.sender == GAME_SYSTEM_ID then
		msg.senderName = ui_word.SYSTEM_NAME
	end
	msg = parseSystemMessage(msg)
	msg.message = getRichLabelText(msg.message)
	local broadcast_data = getGameData():getBroadcastData()
	broadcast_data:insertMsgTolist(msg) 
end

function rpc_client_chat_player_info(server_info)
	if not server_info then cclog("服务端没有数据") end
	local component_ui = getUIManager():get("ClsChatComponent")
	if tolua.isnull(component_ui) then return end
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	if tolua.isnull(main_ui) then return end
	if not main_ui:isVisible() then return end
	local chat_data = getGameData():getChatData()
	local obj = chat_data:getCheckObj()
	if tolua.isnull(obj) then return end
	local chat_data = getGameData():getChatData()
	chat_data:cleanCheckingObj()
	obj:createExpandWin(server_info)
end

function rpc_client_chat_channel(channel, num)
	local chat_data = getGameData():getChatData()
	chat_data:setWorldChannel(channel)

	local num_str = ui_word.CHAT_PERSON_NUMBER_NORMAL
	if num and num > 200 then
		if num > 350 then
			num_str = ui_word.CHAT_PERSON_NUMBER_FIRE
		else
			num_str = ui_word.CHAT_PERSON_NUMBER_BUSY
		end
	end

	local chat = parseSystemMessage({
		sender = 10000,
		time = CCTime:getmillistimeofCocos2d(),
		receiverLevel = 0,
		type = 1,
		id = 0,
		message = string.format(rpc_down_info[340].msg, channel, num_str),
		areaType = 0,
		senderName = "SYSTEM"
	})

	local chat_audio_message = element_mgr:get_element("ClsChatAudioMessageBase")
	if not chat_audio_message then
		chat_audio_message = ClsChatAudioMessageBase.new()
	end
	chat_audio_message:insertPlayQueue(chat)
	doBaseLogic(chat, channels)
end