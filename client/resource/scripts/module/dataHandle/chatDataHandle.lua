local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local dataTools = require("module/dataHandle/dataTools")
local on_off_info = require("game_config/on_off_info")
require("ui/tools/QSpeechMgr")
local scheduler = CCDirector:sharedDirector():getScheduler()

local BLACK_LIMIT_NUM = 20
local GUILD_MSG_SYSTEM_LIMIT = 50 --商会系统信息上限
local GUILD_MSG_PLAYER_LIMIT = 50 --商会聊天信息上限
local WORLD_MSG_LIMIT = 50 --世界聊天信息上限
local NOW_MSG_LIMIT = 50 --当前聊天信息上限
local TEAM_MSG_LIMIT = 50 --队伍聊天信息上限
local SYSTEM_MSG_LIMIT = 50 --系统信息上限

--数据类型
-- DATA_WORLD = 1
-- DATA_GUILD = 2
-- DATA_PRIVATE = 3
-- DATA_SYSTEM = 4
-- DATA_TEAM = 5
-- DATA_NOW = 6

local ClsChatDataHandler = class("ClsChatDataHandler")

function ClsChatDataHandler:ctor()
	self.total_list = {}          --总的信息列表
	self.world_list = {}	      --世界信息列表
	self.guild_list = {}	      --公会信息列表
	self.team_list = {}           --队伍信息列表
	self.team_invite_list = {}    --组队邀请信息列表
	self.system_list = {}         --系统消息列表
	self.now_list = {}            --当前消息列表
	self.private_list = {}        --私聊消息列表新消息靠前
	self.not_send_message = nil   --还未发送的消息
	self.black_list = {} 		  --黑名单
	self.checking_obj = nil       --正在查询信息的对象
	self.loading_black = false    --正在载入黑名单
	self.loading_msg = false      --正在载入私聊信息
	self.end_time = nil           --世界聊天时间戳
	self.chat_end_times = {}      --各个频道聊天时间戳
	self.cur_world_info = {}      --世界频道信息
	self.pre_select_channel = nil --上一次选择的频道

	-- local list = {
	-- [1] = {
	--     ["icon"] = "101",
	--     ["level"] = 10.000000,
	--     ["list"] = {
	--         [1] = {
	--             ["area"] = "cn",
	--             ["areaId"] = 0.000000,
	--             ["areaType"] = 0.000000,
	--             ["color"] = 11423486.000000,
	--             ["id"] = 37.000000,
	--             ["message"] = "胜多负少",
	--             ["not_read"] = true,
	--             ["receiver"] = 10035.000000,
	--             ["receiverIcon"] = "102",
	--             ["receiverLevel"] = 10.000000,
	--             ["receiverName"] = "长孙凝蝶",
	--             ["receiverRole"] = 2.000000,
	--             ["sender"] = 10039.000000,
	--             ["senderIcon"] = "101",
	--             ["senderLevel"] = 10.000000,
	--             ["senderName"] = "巨浪艾林",
	--             ["senderRole"] = 1.000000,
	--             ["time"] = 1479531301.000000,
	--             ["type"] = 3.000000,
	--             },
	--         },
	--     ["name"] = "巨浪艾林",
	--     ["role"] = 1.000000,
	--     ["uid"] = 10039.000000,
	--     },
	-- [2] = {
	--     ["icon"] = "103",
	--     ["level"] = 13.000000,
	--     ["list"] = {
	--         [1] = {
	--             ["area"] = "cn",
	--             ["areaId"] = 0.000000,
	--             ["areaType"] = 0.000000,
	--             ["color"] = 11423486.000000,
	--             ["id"] = 38.000000,
	--             ["message"] = "胜多负少",
	--             ["not_read"] = true,
	--             ["receiver"] = 10035.000000,
	--             ["receiverIcon"] = "102",
	--             ["receiverLevel"] = 10.000000,
	--             ["receiverName"] = "长孙凝蝶",
	--             ["receiverRole"] = 2.000000,
	--             ["sender"] = 10027.000000,
	--             ["senderIcon"] = "103",
	--             ["senderLevel"] = 13.000000,
	--             ["senderName"] = "欧阳天瑜",
	--             ["senderRole"] = 2.000000,
	--             ["time"] = 1479531309.000000,
	--             ["type"] = 3.000000,
	--             },
	--         },
	--     ["name"] = "欧阳天瑜",
	--     ["role"] = 2.000000,
	--     ["uid"] = 10027.000000,
	--     },
	-- }

	--私聊测试数据
	-- local msg = {
	-- 	["area"] = "cn",
 --        ["areaId"] = 0.000000,
 --        ["areaType"] = 0.000000,
 --        ["color"] = 11423486.000000,
 --        ["id"] = 37.000000,
 --        ["message"] = "胜多负少",
 --        ["not_read"] = true,
 --        ["receiver"] = 10035.000000,
 --        ["receiverIcon"] = "102",
 --        ["receiverLevel"] = 10.000000,
 --        ["receiverName"] = "长孙凝蝶",
 --        ["receiverRole"] = 2.000000,
 --        ["sender"] = 10039.000000,
 --        ["senderIcon"] = "101",
 --        ["senderLevel"] = 10.000000,
 --        ["senderName"] = "巨浪艾林",
 --        ["senderRole"] = 1.000000,
 --        ["time"] = 1479531301.000000,
 --        ["type"] = 3.000000,
	-- }
	-- self:insertToPrivate(msg)
end

function ClsChatDataHandler:setPreSelectChannel(channel)
    if channel == INDEX_PLAYER then
        channel = INDEX_PRIVATE
    end
	self.pre_select_channel = channel
end

function ClsChatDataHandler:getCurWorldList()
	return self.world_list[self.cur_world_info.channel] or {}
end

function ClsChatDataHandler:setWorldChannel(channel)
	--初始化频道信息
	self.cur_world_info.channel = channel or 1
	
	--初始化列表
	if not self.world_list[channel] then
		self.world_list[channel] = {}
	end

	--更新界面
	local obj = self:getPanelByName("ClsWorldChatPanelUI")
	if not tolua.isnull(obj) then
		obj:enterCall()
	end
end

function ClsChatDataHandler:getCurWorldInfo()
	return self.cur_world_info
end

function ClsChatDataHandler:getWorldChannelInfo()
	return self.cur_world_info
end

function ClsChatDataHandler:getChatEndTime(kind)
	return self.chat_end_times[kind]
end

function ClsChatDataHandler:isExistFile(file_name)
	return CCFileUtils:sharedFileUtils():isFileExist(file_name)
end

--尽可能用最简便的格式保存数据
--黑名单和保存的聊天信息
local BLACK_FILE_ROOT = "player_%d_black"
local format_str = "{%d,'%s',%s,%d,%d},\n" --1.uid 2.名字 3.头像 4.等级 5.角色

function ClsChatDataHandler:initBlackFile()
	local player_data = getGameData():getPlayerData()
    local black_file_name = string.format(BLACK_FILE_ROOT, player_data:getUid())--黑名单文件名
    local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
    local black_path = string.format("%sdhh.game.qtz.com", write_path)
    self.m_black_file_path = string.format("%s/%s.lua", black_path, black_file_name)
end

function ClsChatDataHandler:putInBlackList(data)
	if #self.black_list >= BLACK_LIMIT_NUM then
		Alert:warning({msg = ui_word.BLACK_ARRIVE_LIMET, x = 264, y = 290})
		return
	end

	local temp = {}
	temp.uid = data.sender or 0
	temp.name = data.senderName or ui_word.DEFAULT_NAME_TIPS
	temp.icon = data.senderIcon or "10"
	temp.level = data.senderLevel or 1
	temp.role = data.senderRole or 1
	table.insert(self.black_list, temp)
	self:writeOneBlackFile(temp)
end

function ClsChatDataHandler:deleteBlack(uid)
	if not self.black_list then return end
	for k, v in ipairs(self.black_list) do
		if v.uid == uid then
			table.remove(self.black_list, k)
			local black_ui = self:getBlackUI()
			if not tolua.isnull(black_ui) then
				black_ui:deleteCell(uid)
			end
			break
		end 
	end
	self:writeManyBlackFile()
end

function ClsChatDataHandler:writeManyBlackFile()
	if GTab.IS_VERIFY then return end
	self:initBlackFile()
    local black_file = nil
    xpcall(function()
        black_file = io.open(self.m_black_file_path, "w")
        if not black_file then
            return
        end
        for k, v in ipairs(self.black_list) do
       		black_file:write(string.format(format_str, v.uid, self:msgEncode(v.name), v.icon, v.level, v.role))
       	end
       	if #self.black_list < 1 then
       		self:removeBlackFile()
       	end
        black_file:close()
        black_file = nil
    end, function(error_msg)
        if black_file then
            black_file:close()
        end
        self:removeBlackFile()
        __G__TRACKBACK__(error_msg)
    end)
end

function ClsChatDataHandler:writeOneBlackFile(temp)
	if GTab.IS_VERIFY then return end
	self:initBlackFile()
    local black_file = nil
    xpcall(function()
        black_file = io.open(self.m_black_file_path, "a")--追加
        if not black_file then
            return
        end
        black_file:write(string.format(format_str, temp.uid, self:msgEncode(temp.name), temp.icon, temp.level, temp.role))
        black_file:close()
        black_file = nil
    end, function(error_msg)
        if black_file then
            black_file:close()
            self:removeBlackFile()
        end
        __G__TRACKBACK__(error_msg)
    end)
end

function ClsChatDataHandler:loadBlackFile()
	if GTab.IS_VERIFY then return end
	if self.loading_black then return cclog("正在载入") end
	self.loading_black = true

    self:initBlackFile()
    if self:isExistFile(self.m_black_file_path) then
        xpcall(function()
        	local file = io.open(self.m_black_file_path, "r")
        	if not file then
        		return
        	end
            local str = string.format("return {%s}", file:read("*a"))
            for k, v in ipairs(loadstring(str)()) do
            	local temp = {}
            	temp.uid = v[1]
            	temp.name = self:msgDecode(v[2])
            	temp.icon = v[3]
            	temp.level = v[4]
            	temp.role = v[5]
            	self.black_list[#self.black_list + 1] = temp
            end
        end, function(error_msg)
        	self:removeBlackFile()
            __G__TRACKBACK__(error_msg)
        end)
    end
end

function ClsChatDataHandler:removeBlackFile()
	if self:isExistFile(self.m_black_file_path) then
        os.remove(self.m_black_file_path)
    end
end

function ClsChatDataHandler:isInBlack(uid)
	for k, v in ipairs(self.black_list) do
		if v.uid == uid then
			return true
		end
	end
	return false
end

--缓存私聊数据
--%d表示我和所有玩家的
local MSG_FILE_ROOT = "player_%d_private_msg"
local PEOPLE_LIMIT = 20
local MSG_LIMIT = 20

function ClsChatDataHandler:initMsgFile()
	local player_data = getGameData():getPlayerData()
    self.msg_file_name = string.format(MSG_FILE_ROOT, player_data:getUid())--黑名单文件名
    local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
    local msg_path = string.format("%sdhh.game.qtz.com", write_path)
    self.m_msg_file_path = string.format("%s/%s.lua", msg_path, self.msg_file_name)
end

function ClsChatDataHandler:saveMsgToLocal()
	if GTab.IS_VERIFY then return end
	self:initMsgFile()
	self:removeMsgFile()
    local msg_file = nil
    xpcall(function()
        msg_file = io.open(self.m_msg_file_path, "a")--追加
        if not msg_file then
            return
        end
        
        --保存信息
        for k, v in ipairs(self.private_list) do
        	if k > PEOPLE_LIMIT then break end--只保存最近聊天的PEOPLE_LIMIT个人信息
        	if #v.list < 1 then cclog("没有消息") end
        	msg_file:write(self:getMsgStr(k, v))
        end

        msg_file:close()
        msg_file = nil
    end, function(error_msg)
        if msg_file then
            msg_file:close()
            self:removeMsgFile()
        end
        __G__TRACKBACK__(error_msg)
    end)
end

function ClsChatDataHandler:loadMsgFile()
	if GTab.IS_VERIFY then return end
	if self.loading_msg then return cclog("正在载入") end
	self.loading_msg = true

    self:initMsgFile()
    if self:isExistFile(self.m_msg_file_path) then
        xpcall(function()
        	local file = io.open(self.m_msg_file_path, "r")
        	if not file then
        		return
        	end
          	local str = string.format("return {%s}", file:read("*a"))
          	self.private_list = {}
            for k, v in ipairs(loadstring(str)()) do
            	for i, j in ipairs(v.list) do
            		j.senderName = self:msgDecode(j.senderName)
            		j.receiverName = self:msgDecode(j.receiverName)
            	end
            	v.name = self:msgDecode(v.name) 
            	self.private_list[#self.private_list + 1] = v
            end
            self:tryDispatchRedPoint()
        end, function(error_msg)
        	self:removeMsgFile()
            __G__TRACKBACK__(error_msg)
        end)
    end
end

--判断一条消息是否是语音
function ClsChatDataHandler:isAudio(msg)
	return string.sub(msg, 3, 8) == "button"
end

local msg_format = "[%d]={['area']='%s',['areaId']=%d,['areaType']=%d,['id']=%d,['message']='%s',['not_read']=%s,['receiver']=%d,['receiverIcon']='%s',['receiverLevel']=%d,['receiverName']='%s',['receiverRole']=%d,['sender']=%d,['senderIcon']='%s',['senderLevel']=%d,['senderName']='%s',['senderRole']=%d,['time']=%d,['type']=%d,},"
function ClsChatDataHandler:getMsgStr(index, item)
	local list_str = ""
	local new_info = nil
	local temp_list = {}
	local length = #item.list
	local cur_index = length
	local count = 0
	for k = 1, MSG_LIMIT do
		local v = item.list[cur_index]
		if not v then cclog("没消息了") break end
		if k == 1 then
			new_info = v
		end
		temp_list[#temp_list + 1] = v--这时最新的在第一个
		cur_index = cur_index - 1
	end

	local msg_index = 0
	for k = #temp_list, 1, -1 do--让最新的在后面
		msg_index = msg_index + 1	
		--拼接和某个玩家的所有聊天消息
		local v = temp_list[k]
		local temp_str = string.format(msg_format, msg_index, v.area, v.areaId, v.areaType, v.id, v.message, tostring(v.not_read), 
			v.receiver, v.receiverIcon, v.receiverLevel, self:msgEncode(v.receiverName), v.receiverRole, 
			v.sender, v.senderIcon, v.senderLevel, self:msgEncode(v.senderName), v.senderRole, v.time, v.type)
		list_str = string.format("%s%s", list_str, temp_str)
		cur_index = cur_index - 1
	end

	if new_info then
		local player_info = self:getPlayerInfo(new_info)
		local write_str = string.format("[%d]={['uid']=%d,['name']='%s',['icon']='%s',['level']=%d,['role']=%d,['list']={%s},},\n", index, player_info.uid, self:msgEncode(player_info.name), player_info.icon, player_info.level, player_info.role, list_str)
		return write_str
	end
end

function ClsChatDataHandler:removeMsgFile()
	if self:isExistFile(self.m_msg_file_path) then
        os.remove(self.m_msg_file_path)
    end
end

function ClsChatDataHandler:deleteMsgRecord(uid)
	local is_update_samll_panel = false
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			for i, j in ipairs(v.list) do
				if self:isFindMsg(j) then
					is_update_samll_panel = true
				end
			end
			table.remove(self.private_list, k)
			break
		end
	end
	self:saveMsgToLocal()
	self:deleteMsgFromTotalByUid(uid, DATA_PRIVATE)

	local private_list_ui = self:getPrivateListUI()
	if not tolua.isnull(private_list_ui) then
		private_list_ui:deleteListView()
	end

	local private_obj_ui = self:getPanelByName("ClsPrivateObjUI")
	if not tolua.isnull(private_obj_ui) then
		private_obj_ui:deleteCell(uid)
	end

	--更新聊天小框和聊天主面板
	if is_update_samll_panel then
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
			local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
			if not tolua.isnull(panel_ui) then
				panel_ui:updateShowMessage()
			end
		end
	end
end

function ClsChatDataHandler:cleanTeamMsg()
	self.team_list = {}
	self:deleteMsgFromTotalByKind(DATA_TEAM)
end

function ClsChatDataHandler:cleanGuildMsg()
	self.guild_list = {}
	self:deleteMsgFromTotalByKind(DATA_GUILD)
end

function ClsChatDataHandler:cleanPrivateMsg(uid)
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			table.remove(self.private_list, k)
			break
		end
	end
end

function ClsChatDataHandler:getBlackUI()
	local component_ui = getUIManager():get("ClsChatComponent")
	if tolua.isnull(component_ui) then return end
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	if tolua.isnull(main_ui) then return end
	local player_ui = main_ui:getPanelByName("ClsPlayerPanelUI")
	if tolua.isnull(player_ui) then return end
	local black_ui = player_ui:getPanelByName("ClsBlackListUI")
	if tolua.isnull(black_ui) then return end
	return black_ui
end

function ClsChatDataHandler:getPrivateListUI()
	local component_ui = getUIManager():get("ClsChatComponent")
	if tolua.isnull(component_ui) then return end
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	if tolua.isnull(main_ui) then return end
	local player_ui = main_ui:getPanelByName("ClsPlayerPanelUI")
	if tolua.isnull(player_ui) then return end
	local private_list = player_ui:getPanelByName("ClsPrivateListUI")
	if tolua.isnull(private_list) then return end
	return private_list
end

function ClsChatDataHandler:cleanCheckingObj()
	self.checking_obj = nil
end

function ClsChatDataHandler:isChecking()
	return not tolua.isnull(self.checking_obj) 
end

function ClsChatDataHandler:setCheckObj(obj)
	self.checking_obj = obj
end

function ClsChatDataHandler:getCheckObj()
	return self.checking_obj
end

function ClsChatDataHandler:getBlackList()
	return self.black_list
end

function ClsChatDataHandler:setNotSendMsg(msg)
	self.not_send_message = msg
end

function ClsChatDataHandler:getNotSendMsg()
	return self.not_send_message
end

function ClsChatDataHandler:cleanNotSendMsg()
	self.not_send_message = nil
end

--通过uid获得未读信息数量
function ClsChatDataHandler:getNotReadByUid(uid)
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			local num = 0
			for i, j in ipairs(v.list) do
				if j.not_read then
					num = num + 1
				end
			end
			return num
		end
	end
	return 0
end

function ClsChatDataHandler:isHaveNotReadMsg()
	for k, v in ipairs(self.private_list) do
		for i, j in ipairs(v.list) do
			if j.not_read then
				return true
			end
		end
	end
	return false
end

--获得单个私聊的所有信息
function ClsChatDataHandler:getOneTotalPrivateMsg(uid)
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			return v
		end
	end
end

--获得单个私聊信息
function ClsChatDataHandler:getOnePrivateMsg(uid)
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			return v.list
		end
	end
end

--设置信息已读
function ClsChatDataHandler:setMsgRead(uid)
	for k, v in ipairs(self.private_list) do
		if v.uid == uid then
			for i, j in ipairs(v.list) do
				j.not_read = false
			end
			break
		end
	end
	self:saveMsgToLocal()
	self:tryDispatchRedPoint()
end

-------------------------------------------插入数据到对应的列表 start-------------------------------------------

function ClsChatDataHandler:getPanelByName(name)
	local component_ui = getUIManager():get("ClsChatComponent")
	if tolua.isnull(component_ui) then return end
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	if tolua.isnull(main_ui) then return end
	local obj = main_ui:getPanelByName(name)
	return obj
end

function ClsChatDataHandler:insertToWorld(msg)
	local temp = self:getCurWorldList()
	if #temp == WORLD_MSG_LIMIT then
		table.remove(temp, 1)
	end
	temp[#temp + 1] = msg

	local obj = self:getPanelByName("ClsWorldChatPanelUI")
	if not tolua.isnull(obj) then
		obj:addCell(msg)
	end
end

function ClsChatDataHandler:insertToNow(msg)
	if #self.now_list == NOW_MSG_LIMIT then
		table.remove(self.now_list, 1)
	end
	self.now_list[#self.now_list + 1] = msg

	local obj = self:getPanelByName("ClsNowChatPanelUI")
	if not tolua.isnull(obj) then
		obj:addCell(msg)
	end
end

function ClsChatDataHandler:insertToGuild(msg)
	if msg.sender == GAME_SYSTEM_ID then
		local num = 0
		local first_index = 0
		local find_one = false
		for k, v in ipairs(self.guild_list) do
			if v.sender == GAME_SYSTEM_ID then
				if not find_one then
					find_one = true
					first_index = k
				end
				num = num + 1
			end
		end
		if num == GUILD_MSG_SYSTEM_LIMIT then
			table.remove(self.guild_list, first_index)
		end
		table.insert(self.guild_list, msg)
	else
		local num = 0
		local first_index = 0
		local find_one = false
		for k, v in ipairs(self.guild_list) do
			if v.sender ~= GAME_SYSTEM_ID then
				if not find_one then
					find_one = true
					first_index = k
				end
				num = num + 1
			end
		end
		if num == GUILD_MSG_PLAYER_LIMIT then
			table.remove(self.guild_list, first_index)
		end
		table.insert(self.guild_list, msg)
	end

	local obj = self:getPanelByName("ClsGuildChatPanelUI")
	if not tolua.isnull(obj) then
		obj:addCell(msg)
	end
end

function ClsChatDataHandler:insertToTeam(msg)
	if #self.team_list == TEAM_MSG_LIMIT then
		table.remove(self.team_list, 1)
	end
	self.team_list[#self.team_list + 1] = msg
	local obj = self:getPanelByName("ClsTeamChatPanelUI")
	if not tolua.isnull(obj) then
		obj:addCell(msg)
	end
end

function ClsChatDataHandler:insertToSystem(msg)
	if #self.system_list == SYSTEM_MSG_LIMIT then
		table.remove(self.system_list, 1)
	end

	self.system_list[#self.system_list + 1] = msg
	local obj = self:getPanelByName("ClsSystemChatPanelUI")
	if not tolua.isnull(obj) then
		obj:addCell(msg)
	end
end

function ClsChatDataHandler:insertToTotal(msg)
	local is_update = false
	if msg.id > 0 then
		for k, v in ipairs(self.total_list) do
			if v.id == msg.id then
				self.total_list[k] = msg
				is_update = true
			end
		end
	end
	if not is_update then
		self.total_list[#self.total_list + 1] = msg
	end
end

function ClsChatDataHandler:movePrivateByIndex(item, index)
	local temp = {}
	for k, v in ipairs(self.private_list) do
		if v ~= item then
			temp[#temp + 1] = v
		end
	end
	table.insert(temp, index, item)
	self.private_list = temp
end

--这是私聊总的数据
--最近私聊的在前面
function ClsChatDataHandler:insertToPrivate(msg)
	if not self:isMySendMsg(msg) then--如果该私聊信息不是我发的
		msg.not_read = true--默认是未读信息
	else
		msg.not_read = false--自己发的默认已经读了
	end

	local player_info = self:getPlayerInfo(msg)
	local is_recorded = false--默认没有记录过
	for k, v in ipairs(self.private_list) do
		if v.uid == player_info.uid then
			is_recorded = true
			v.name = player_info.name
			v.icon = player_info.icon
			v.level = player_info.level
			v.role = player_info.role
			v.icon = player_info.icon
			v.list[#v.list + 1] = msg
			self:movePrivateByIndex(v, 1)
		end
	end
	if not is_recorded then--初始化一个插入
		local temp = {}
		temp.uid = player_info.uid
		temp.name = player_info.name
		temp.level = player_info.level
		temp.role = player_info.role
		temp.icon = player_info.icon
		temp.list = {msg}
		table.insert(self.private_list, 1, temp)
	end

	--实时将最新数据保存到本地
	self:saveMsgToLocal()
	self:tryDispatchRedPoint()
	local private_list = self:getPrivateListUI()
	if not tolua.isnull(private_list) then
		--这时候处在与某人私聊的界面
		private_list:addCell(player_info, msg)
	end

	local component_ui = getUIManager():get("ClsChatComponent")
	if tolua.isnull(component_ui) then return end

	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	if not tolua.isnull(main_ui) then
		local private_obj_ui = main_ui:getPanelByName("ClsPrivateObjUI")
		if tolua.isnull(private_obj_ui) then return end
		local cell_info = self:getOneTotalPrivateMsg(player_info.uid)
		if is_recorded then
			private_obj_ui:updateCell(cell_info)
		else
			private_obj_ui:addCell(cell_info)
		end
	end
end

local insert_msg_to_list = {
	[DATA_WORLD] = ClsChatDataHandler.insertToWorld,
	[DATA_GUILD] = ClsChatDataHandler.insertToGuild,
	[DATA_TEAM] = ClsChatDataHandler.insertToTeam,
	[DATA_PRIVATE] = ClsChatDataHandler.insertToPrivate,
	[DATA_BLACK] = ClsChatDataHandler.insertToBlack,
	[DATA_NOW] = ClsChatDataHandler.insertToNow,
	[DATA_SYSTEM] = ClsChatDataHandler.insertToSystem,
}

function ClsChatDataHandler:insertList(msg)
	if not msg then cclog("要插入的数据不能为空") return end
	local kind = msg.type

	msg.message = replaceValidText(msg.message)
	if type(insert_msg_to_list[kind]) == "function" then
		insert_msg_to_list[kind](self, msg)
	end

	self:insertToTotal(msg)

	if self:isUserDefaultShow(msg) then
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
		    local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
			if not tolua.isnull(panel_ui) then
				panel_ui:updateShowMessage()
			end
		end
	end
end
-------------------------------------------插入数据到对应的列表 end-------------------------------------------

-------------------------------------------设置列表 start-------------------------------------------
function ClsChatDataHandler:setNowList(list)
	self.now_list = list
end

function ClsChatDataHandler:setGuildList(list)
	self.guild_list = list
end
 
function ClsChatDataHandler:setTeamList(list)
	self.team_list = list
end

function ClsChatDataHandler:setPrivateList(list)
	self.private_list = list
end

function ClsChatDataHandler:setTotalList(list)
	self.total_list = list
end

local set_list_by_kind = {
	[DATA_GUILD] = ClsChatDataHandler.setGuildList,
	[DATA_TEAM] = ClsChatDataHandler.setTeamList,
}

--设置List
function ClsChatDataHandler:setList(list)
	--统一取第一个cell的数据用来判断list的类型
	if not list or #list < 1 then cclog("要设置的列表不能为空") return end
	--按时间排序
	table.sort(list, function(a, b)
		return a.time < b.time
	end)

	--设置到对应的list
	local cell = list[1]
	local kind = cell.type
	if type(set_list_by_kind[kind]) == "function" then
		set_list_by_kind[kind](self, list)
	end

	--插入到总列表
	for k, v in ipairs(list) do	
		self:insertToTotal(v)
	end
end
-------------------------------------------设置列表 end-------------------------------------------

-------------------------------------------获得列表 start-------------------------------------------
function ClsChatDataHandler:getTotalList()
	table.sort(self.total_list, function(a, b)
		return a.time < b.time
	end)
	return self.total_list
end

function ClsChatDataHandler:getWorldList()
	local temp = self:getCurWorldList()
	table.sort(temp, function(a, b)
		return a.time < b.time
	end)
	return temp
end

function ClsChatDataHandler:getGuildList()
	table.sort(self.guild_list, function(a, b)
		return a.time < b.time
	end)
	return self.guild_list
end

function ClsChatDataHandler:getTeamList()
	table.sort(self.team_list, function(a, b)
		return a.time < b.time
	end)
	return self.team_list
end

function ClsChatDataHandler:getTotalNowList()
	return self.now_list
end

--从所有的当前消息中获取当前消息
--如果提供源数据，那么就从提供的源数据当中获取当前的信息
function ClsChatDataHandler:getNowList()
    local explore_layer = getUIManager():get("ExploreLayer")
    local port_layer = getUIManager():get("ClsPortLayer")
    local copy_layer = getUIManager():get("ClsCopySceneLayer")

    local need_content = {}
    if not tolua.isnull(explore_layer) then
        for k, v in ipairs(self.now_list) do
            if v.areaType == CHAT_SEA_AREA and v.areaId == self.cur_area_id then
                need_content[#need_content + 1] = v
            end
        end
    elseif not tolua.isnull(port_layer) then
        local port_data = getGameData():getPortData()
        local port_id = port_data:getPortId()
        for k, v in ipairs(self.now_list) do
            if v.areaType == CHAT_PORT_AREA and v.areaId == port_id then
                need_content[#need_content + 1] = v
            end
        end
    elseif not tolua.isnull(copy_layer) then
        local sceneDataHander = getGameData():getSceneDataHandler()
        local scene_id = sceneDataHander:getSceneId()
        for k, v in ipairs(self.now_list) do
            if  v.areaType == CHAT_SEA_AREA and v.areaId == scene_id then
                need_content[#need_content + 1] = v
            end
        end
    end
    return need_content
end

--获得聊天小面板显示内容
function ClsChatDataHandler:getSmallPanelList()
    --先过滤掉设置中不让显示的
	local show_list = {}
	for k, v in ipairs(self.total_list) do
		if self:isUserDefaultShow(v) and not v.not_show_small then
            show_list[#show_list + 1] = v
		end
	end

	--再过滤掉不是当前的
	local explore_layer = getUIManager():get("ExploreLayer")
    local port_layer = getUIManager():get("ClsPortLayer")
    local copy_layer = getUIManager():get("ClsCopySceneLayer")
	local real_show_list = {}
    if not tolua.isnull(explore_layer) then
        local sea_id = self:getCurAreaID()
        for k, v in ipairs(show_list) do
            if (v.areaType == CHAT_SEA_AREA and v.areaId == sea_id) or v.areaType == 0 then
                real_show_list[#real_show_list + 1] = v
            end
        end
    elseif not tolua.isnull(port_layer) then
        local port_data = getGameData():getPortData()
        local port_id = port_data:getPortId()
        for k, v in ipairs(show_list) do
            if (v.areaType == CHAT_PORT_AREA and v.areaId == port_id) or v.areaType == 0 then
                real_show_list[#real_show_list + 1] = v
            end
        end
    elseif not tolua.isnull(copy_layer) then
        local sceneDataHander = getGameData():getSceneDataHandler()
        local scene_id = sceneDataHander:getSceneId()
        for k, v in ipairs(show_list) do
            if  (v.areaType == CHAT_SEA_AREA and v.areaId == scene_id) or v.areaType == 0 then
                real_show_list[#real_show_list + 1] = v
            end
        end
    end
    return real_show_list
end

local type_key = {
	[KIND_WORLD] = "NO_SHOW_WORLD",
	[KIND_GUILD] = "NO_SHOW_GUILD",
	[KIND_TEAM] = "NO_SHOW_TEAM",
	[KIND_NOW] = "NO_SHOW_NOW",
	[KIND_SYSTEM] = "NO_SHOW_SYSTEM",
	[KIND_PRIVATE] = "NO_SHOW_PRIVATE",
}

--判断消息是否用户设置显示
function ClsChatDataHandler:isUserDefaultShow(msg)
	local user_chat_set = CCUserDefault:sharedUserDefault()
	if user_chat_set and not user_chat_set:getBoolForKey(type_key[msg.type]) then
		return true
	else
		return false
	end
end

function ClsChatDataHandler:isFindMsg(msg)
	local component_ui = getUIManager():get("ClsChatComponent")
	if not tolua.isnull(component_ui) then
		local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
		if not tolua.isnull(panel_ui) then
			return panel_ui:isFindMsg(msg)
		end
	end
end

function ClsChatDataHandler:getSystemList()
	return self.system_list
end

function ClsChatDataHandler:getPrivateList()
	return self.private_list
end

local get_list_by_kind = {
	[DATA_WORLD] = ClsChatDataHandler.getWorldList,
	[DATA_NOW] = ClsChatDataHandler.getNowList,
	[DATA_GUILD] = ClsChatDataHandler.getGuildList,
	[DATA_TEAM] = ClsChatDataHandler.getTeamList,
	[DATA_SYSTEM] = ClsChatDataHandler.getSystemList,
	[DATA_PRIVATE] = ClsChatDataHandler.getPrivateList,
}

function ClsChatDataHandler:getList(kind)
	if not kind then return cclog("类型不能为空") end

	if type(get_list_by_kind[kind]) == "function" then
		return get_list_by_kind[kind](self)
	end
end

function ClsChatDataHandler:getChannel()
	if self.pre_select_channel then
		return self.pre_select_channel
	else
		if #self.guild_list > 0 then
			return INDEX_GUILD
		elseif #self.team_list > 0 then
			return INDEX_TEAM
		elseif #self.world_list > 0 then
			return INDEX_WORLD
		elseif #self.now_list > 0 then
			return INDEX_NOW
		else
			return INDEX_WORLD
		end
	end
end

-------------------------------------------获得列表 end-------------------------------------------

function ClsChatDataHandler:deleteMsgFromTotalByKind(data_type)
	local temp = {}
	local is_update_samll_panel = false
	for k, v in ipairs(self.total_list) do
		if v.type ~= data_type then
			temp[#temp + 1] = v
		else
			if self:isFindMsg(v) then
				is_update_samll_panel = true
			end
		end
	end
	self.total_list = temp

	--更新聊天小框和聊天主面板
	if is_update_samll_panel then
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
			local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
			if not tolua.isnull(panel_ui) then
				panel_ui:updateShowMessage()
			end
		end
	end
end

function ClsChatDataHandler:deleteMsgFromTotalByMsgId(msg_id)
	if not self.total_list then return end
	local is_update_samll_panel = false
	for k, v in ipairs(self.total_list) do
		if tonumber(v.id) == msg_id then
			if self:isFindMsg(v) then
				is_update_samll_panel = true
			end
			table.remove(self.total_list, k)
			break
		end
	end

	if is_update_samll_panel then
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
			local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
			if not tolua.isnull(panel_ui) then
				panel_ui:updateShowMessage()
			end
		end
	end
end

function ClsChatDataHandler:deleteMsgFromTotalByUid(uid, data_type)
	local temp = {}
	for k, v in ipairs(self.total_list) do
		local player_info = self:getPlayerInfo(v)
		if (player_info.uid ~= uid) or (v.type ~= data_type) then
			temp[#temp + 1] = v
		end
	end
	self.total_list = temp
end

function ClsChatDataHandler:deletePrivate(msg_id)
	if not self.private_list then return end
	for k, v in ipairs(self.private_list) do
		for i, j in ipairs(v.list) do
			if j.id == msg_id then
				table.remove(v.list, i)
				break
			end
		end
	end
end

function ClsChatDataHandler:deleteGuild(msg_id)
	if not self.guild_list then return end
	for k, v in ipairs(self.guild_list) do
		if tonumber(v.id) == msg_id then
			table.remove(self.guild_list, k)
			break
		end
	end
	local guild_ui = self:getPanelByName("ClsGuildChatPanelUI")
	if not tolua.isnull(guild_ui) then
		guild_ui:deleteCell(msg_id)
	end
end

local remove_msg_by_kind = {
	[DATA_GUILD] = ClsChatDataHandler.deleteGuild,
	[DATA_PRIVATE] = ClsChatDataHandler.deletePrivate,
}

-------------------------------------------删除指定ID的消息 start-------------------------------------------
function ClsChatDataHandler:deleteMsgByKind(kind, msg_id)
	--id可以是消息id也可以是uid
	if not kind or not msg_id then cclog("删除消息要指定删除消息的类型和ID") return end
	remove_msg_by_kind[kind](self, msg_id)
	self:deleteMsgFromTotalByMsgId(msg_id)
end

--外部接口统一，里面不要统一，你永远不知道策划要做什么特殊处理
function ClsChatDataHandler:cleanMsgAppointUid(uid)
	local clean_list = {
		[1] = {set = self.setGuildList, get = self.getGuildList, ui = "ClsGuildChatPanelUI"},
		[2] = {set = self.setNowList, get = self.getTotalNowList, ui = "ClsNowChatPanelUI"},
		[3] = {set = self.setTeamList, get = self.getTeamList, ui = "ClsTeamChatPanelUI"},
		[4] = {set = self.setPrivateList, get = self.getPrivateList, ui = "ClsPrivateListUI"},
		[5] = {set = self.setTotalList, get = self.getTotalList},
	}

	local is_update_samll_panel = false
	for k, v in ipairs(clean_list) do
		local remain_list = {}
		for i, j in ipairs(v.get(self)) do
			if j.sender ~= uid then
				table.insert(remain_list, j)
			else
				if self:isFindMsg(j) then
					is_update_samll_panel = true
				end
			end
		end
		v.set(self, remain_list)
		if v.ui then
			local ui_obj = self:getPanelByName(v.ui)
			if not tolua.isnull(ui_obj) then
				ui_obj:updateView()
			end
		end
	end

	local is_update = false
	for k, v in pairs(self.world_list) do
		if k == self.cur_world_info.channel then
			is_update = true
		end

		local remain_list = {}
		for i, j in ipairs(v) do
			if j.sender ~= uid then
				table.insert(remain_list, j)
			end
		end
		self.world_list[k] = remain_list
		if is_update then
			local world_ui = self:getPanelByName("ClsWorldChatPanelUI")
			if not tolua.isnull(world_ui) then
				world_ui:updateView()
			end
		end
	end

	--更新聊天小框和聊天主面板
	if is_update_samll_panel then
		local component_ui = getUIManager():get("ClsChatComponent")
		if not tolua.isnull(component_ui) then
			local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
			if not tolua.isnull(panel_ui) then
				panel_ui:updateShowMessage()
			end
		end
	end
end

--该条信息是否是我发出的
function ClsChatDataHandler:isMySendMsg(msg)
	local playerData = getGameData():getPlayerData()
	if playerData:getUid() == msg.sender then
		return true
	end
	return false
end

--获取玩家信息
function ClsChatDataHandler:getPlayerInfo(msg)
	local playerData = getGameData():getPlayerData()
	if playerData:getUid() == msg.sender then
		return {uid = msg.receiver, name = msg.receiverName, level = msg.receiverLevel, role = msg.receiverRole, icon = msg.receiverIcon}
	else
		return {uid = msg.sender, name = msg.senderName, level = msg.senderLevel, role = msg.senderRole, icon = msg.senderIcon}
	end
end

--通过聊天内容获取和你聊天的对象的uid
function ClsChatDataHandler:getPlayerUid(msg)
	local playerData = getGameData():getPlayerData()
	if playerData:getUid() == msg.sender then
		return msg.receiver
	else
		return msg.sender
	end
end

function ClsChatDataHandler:setCurAreaID(value)
	self.cur_area_id = value or 1
end

function ClsChatDataHandler:getCurAreaID()
	return self.cur_area_id
end

--将语音转为文字
function ClsChatDataHandler:convertMsg(msg)
	local new_msg = msg
	local _, end_index = string.find(new_msg, AUDIO_CHAT_FLAG)
	if end_index then
		local start_index = string.find(new_msg, ")")
		new_msg = string.sub(new_msg, start_index + 1) 
	end
	return new_msg
end

----------------------------协议----------------------------
--发送消息
function ClsChatDataHandler:askSendPublicMsg(chatType, chatContent)
	GameUtil.callRpc("rpc_server_chat_send", {chatType, chatContent})
end

function ClsChatDataHandler:askSendPrivateMsg(friendId, chatContent)
	GameUtil.callRpc("rpc_server_chat_private", {friendId, chatContent})
end

function ClsChatDataHandler:askPlayerInfo(id)
	GameUtil.callRpc("rpc_server_chat_player_info", {id})
end

function ClsChatDataHandler:askJoinBlackList(uid, key)
	GameUtil.callRpc("rpc_server_set_black_list", {uid, key})
end

function ClsChatDataHandler:askConvertChannel(num)
	GameUtil.callRpc("rpc_server_chat_channel", {num})
end

----------------------------更新 UI ---------------------------
--显示聊天气泡
function ClsChatDataHandler:updateExploreChat(chat)
    if chat.type ~= KIND_TEAM and chat.type ~= KIND_NOW then return end
    local message_txt = getRichLabelText(chat.message)
    if message_txt == "" then return end
    
    local message = self:convertMsg(chat.message)
    
    local userDefault = CCUserDefault:sharedUserDefault()
    local NO_SHOW_NOW = userDefault:getBoolForKey("NO_SHOW_NOW")
    local NO_SHOW_TEAM = userDefault:getBoolForKey("NO_SHOW_TEAM")

    if chat.type == KIND_NOW and not NO_SHOW_NOW then
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local shipLayerBase = explore_layer:getShipsLayer()
            if not tolua.isnull(shipLayerBase) then 
                shipLayerBase:showShipChatBubble({direction = DIRECTION_RIGHT, 
                    sender = chat.sender, show_msg = message})
            end
        end
    end

    if chat.type == KIND_TEAM and not NO_SHOW_TEAM then
        local TMPUI = getUIManager():get("ClsTeamMissionPortUI")
        if not tolua.isnull(TMPUI) then
            TMPUI:showChatBubble({show_msg = message, sender = chat.sender})
        end
    end
end

function ClsChatDataHandler:msgDecode(str)
	return string.gsub(str, '%%(%x%x)', function(c) return string.char(tonumber(c, 16)) end)
end

--%28%40%5F%40%29
function ClsChatDataHandler:msgEncode(str)
	return string.gsub(str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
end

----------------------------录音以及发送聊天消息接口----------------------------
--这个信息原本就有颜色
-- chat.message = $(button:#chat_play_btn.png|0.8,@@2@@101301472729565)喂喂

function ClsChatDataHandler:isColorStart(msg)
	local start_index, end_index, match = string.find(msg, "$%(c:COLOR_(.-)%)")
	if start_index == 1 then
		return true
	else
		return false
	end
end

function ClsChatDataHandler:isHaveColor(msg)
	local match_str = string.find(msg, "$%(c:COLOR_(.-)%)")
	return match_str ~= nil
end

-- $(button:#chat_play_btn.png|0.8,@@2@@101301472729565)
function ClsChatDataHandler:getAudioBtn(msg)
	local _, _, match_str = string.find(msg, "(.+%))")
	return match_str
end

function ClsChatDataHandler:isAudio(msg)
	local match_str = string.find(msg, "$%(button:(.-)%)")
	return match_str ~= nil
end

function ClsChatDataHandler:isLegal(msg)
	msg = getRichLabelText(msg)
	local commonBase  = require("gameobj/commonFuns")
    msg = commonBase:returnUTF_8CharValid(msg)

	local has = check_string_has_invisible_char(msg)
    if has or commonBase:checkAllCharacterIsNul(msg) then
        return false
    end

    if not checkChatTextValid(msg, true) then
        return false
    end

    return true
end

function ClsChatDataHandler:parseAudio(msg)
	if self:isAudio(msg) then
		local is_legal = self:isLegal(msg)
		if not is_legal then
			return self:getAudioBtn(msg)
		end
	end
	return msg
end

local NOW_LEVEL_LIMIT = 10
local WORLD_LEVEL_LIMIT = 20
local WORLD_CHAT_TAKE_GOLD = 10
--录音
function ClsChatDataHandler:recordMessage(channel)
    local speech = getSpeechInstance()
    speech:showSpeechView(function(text, vid)
        if not text then return end
        local info = string.format("$(button:#chat_play_btn.png|0.8,%s)%s", tostring(vid), tostring(text))
        self:askRpc(info, channel)
    end)
end

function ClsChatDataHandler:cancelRecord()
    local speech = getSpeechInstance()
    speech:cancelRecogn()
end

function ClsChatDataHandler:stopRecord()
    local speech = getSpeechInstance()
    speech:stopRecogn()
end

function ClsChatDataHandler:sendWorldMsg(msg, channel)
	local player_data = getGameData():getPlayerData()
    local current_level = player_data:getLevel()
    if current_level < WORLD_LEVEL_LIMIT then
        Alert:warning({msg = ui_word.WORLD_LEVEL_NOT_ENOUGH, x = 264, y = 290})
        return
    end
    local chat_data_handler = getGameData():getChatData()
    chat_data_handler:askSendPublicMsg(channel, msg)
end

function ClsChatDataHandler:sendNowMsg(msg, channel)
	local player_data = getGameData():getPlayerData()
    local current_level = player_data:getLevel()
    if current_level < NOW_LEVEL_LIMIT then
        Alert:warning({msg = ui_word.NOW_LEVEL_NOT_ENOUGH, x = 264, y = 290})
        return
    end
    self:askSendPublicMsg(channel, msg)
end

function ClsChatDataHandler:sendGuildMsg(msg, channel)
	self:askSendPublicMsg(channel, msg)
end

function ClsChatDataHandler:sendTeamMsg(msg, channel)
	self:askSendPublicMsg(channel, msg)
end

--私聊
function ClsChatDataHandler:sendPrivateMsg(msg, channel)
	local component_ui = getUIManager():get("ClsChatComponent")
	if not tolua.isnull(component_ui) then
	    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	    local data = main_ui:getPlayerBtnPara()
	    self:askSendPrivateMsg(data.uid, msg)
	end
end

local send_msg_by_channel = {
	[KIND_WORLD] = ClsChatDataHandler.sendWorldMsg,
	[KIND_NOW] = ClsChatDataHandler.sendNowMsg,
	[KIND_GUILD] = ClsChatDataHandler.sendGuildMsg,
	[KIND_TEAM] = ClsChatDataHandler.sendTeamMsg,
	[KIND_PRIVATE] = ClsChatDataHandler.sendPrivateMsg,
}

--将信息发给服务端
function ClsChatDataHandler:askRpc(msg, channel)
	--发送的话清空缓存了的发送消息
	send_msg_by_channel[channel](self, msg, channel)
end

--尝试给红点
function ClsChatDataHandler:tryDispatchRedPoint()
	local taskData = getGameData():getTaskData()
	if self:isHaveNotReadMsg() then
		taskData:setTask(on_off_info.CHAT_FRIEND.value, true)
	else
		taskData:setTask(on_off_info.CHAT_FRIEND.value, false)
	end
end  

return ClsChatDataHandler
