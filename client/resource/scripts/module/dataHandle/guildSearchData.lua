local tool=require("module/dataHandle/dataTools")
local news=require("game_config/news")
local Alert = require("ui/tools/alert")

--申请次数
local applyNum=0
--已经申请列表    key是公会id 值是true
local applyList={}

local GuildSearchData = class("GuildSearchData")

GuildSearchData.ctor = function(self)
	self.guildBaseList = {}
	self.guild_apply_time = {} ---申请公会时间表
end

---申请公会时间
GuildSearchData.setGuildApplyTime = function(self, guild_id,time)
	self.guild_apply_time[guild_id] = time
end

GuildSearchData.getGuildApplyTime = function(self, guild_id)
	if self.guild_apply_time[guild_id] then
		return self.guild_apply_time[guild_id]		
	end
	return false
end

--搜索公会  空串默认服务端搜索
GuildSearchData.askSearchGuild = function(self, keyWord)
	keyWord=keyWord or ""
	GameUtil.callRpc("rpc_server_group_search", {keyWord})
end

--查询公会列表基本信息
GuildSearchData.askSearchBaseInfo = function(self, groupId)
	if not self:updateSearchBaseInfo( nil, groupId) then
		GameUtil.callRpc("rpc_server_base_group_info", {groupId})
	end
end

GuildSearchData.updateSearchBaseInfo = function(self, info, groupId)
	if info then
		self.guildBaseList[info.id] = info
	else
		if self.guildBaseList[groupId] == nil then
			return false
		else
			info = self.guildBaseList[groupId]
		end	
	end

	local guild_ui = getUIManager():get("ClsGuildListPanel")
	if not tolua.isnull(guild_ui) then
		guild_ui:updateGuildBaseInfo(info)
	end
	return true
end
--class group_search_t {
--	int id;
--	string name;
--	int members;
--	int maxMembers;
--	int create_time;
--}
GuildSearchData.revceiveSearchGuild = function(self, guildList)
	if #guildList==0 then
		Alert:warning({msg = news.GUILD_FIND_RESULT.msg, color = ccc3(dexToColor3B(COLOR_RED))})
	end
	
	for k,guild in pairs(guildList) do
		if applyList[guild.id] then guild.isApply=true end --已经申请过了  在当前游戏生命周期有效
	end

	table.sort(guildList, function(a,b)
        return a.grade > b.grade
    end)

	local guild_search_ui = getUIManager():get("ClsGuildListPanel")
	if not tolua.isnull(guild_search_ui) then
		guild_search_ui:updateList(guildList)
	end
end

--创建公会
GuildSearchData.askCreateGuild = function(self, guildName, badge_key)
	if type(guildName)~='string' or guildName=="" then
		Alert:warning({msg = news.GUILD_INPUT_NAME.msg, color = ccc3(dexToColor3B(COLOR_RED))})
		return
	end
	GameUtil.callRpc("rpc_server_group_create", {guildName, tostring(badge_key)},"rpc_client_group_create")
end

--申请加入公会   结果只是代表申请成功是否 不代表加入成功
GuildSearchData.askApplyGuild = function(self, guildId)
	-- if applyNum >= 10 then
	-- 	Alert:warning({msg = news.GUILD_APPLY_NUM.msg, color = ccc3(dexToColor3B(COLOR_RED)), y = 0})
	-- 	return false
	-- end
	GameUtil.callRpc("rpc_server_group_apply_request", {guildId})
	return true
end

GuildSearchData.askInvitePerson = function(self, uid)
	GameUtil.callRpc("rpc_server_group_invite", {uid})
end

---接受邀请加入商会oUser:被邀请人,groupId：商会id, inviter：邀请人
GuildSearchData.acceptInvitePerson = function(self, groupId, inviter)
	GameUtil.callRpc("rpc_server_group_accept_invite", {groupId, inviter})
end


--直接加入公会
GuildSearchData.askJoinGuild = function(self, guildId)
	GameUtil.callRpc("rpc_server_group_join", {guildId}, "rpc_client_group_info")
	return true
end

GuildSearchData.receiveApplyResult = function(self, groupId)
	applyNum=applyNum+1
	applyList[groupId]=true
end

GuildSearchData.clearSearchData = function(self)
	applyNum = 0
	applyList = {}
end

GuildSearchData.resetGuildBaseList = function(self)
	self.guildBaseList = {}
end

return GuildSearchData
