local tool=require("module/dataHandle/dataTools")
local news=require("game_config/news")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")

local guildData = class("guildData")

guildData.ctor = function(self)
	self.guildId = nil
	self.guildInfo = nil
	self.guildApplyList = nil
	self.guildInfoMembersUidAsKey = nil
	self.guildInfoMembersNumAsKey = nil
	self.guildName = nil
	self.guildNotice = nil
	self.guildMembersNum = nil
	self.guildMaxMembersNum = nil
	self.isInitSucess = nil
	self.curExp = 0
	self.guildGrade = 0
	self.maxExp = 0
	self.portId = 0 --公会占据据点id
	self.badge_id = nil  --徽章id
	self.prestige = 0  --声望
	self.win_amount = 0  --赢的战绩数据
	self.battle_amount = 0  --总体参战数据
	self.mail_times = 0  ---商会邮件个数
	self.call_times = 0  ---商会召集个数
	self.invest_info = nil
	self.m_other_guild_data = nil
	self.m_my_rank = nil --我的商会排名数据
end

-- --等待服务端初始化公会信息
-- guildData.receiveShowGuildButton = function(self)
-- 	self.isInitSucess = true
-- 	-- EventTrigger(EVENT_GUILD_SHOW_BUTTON,self.isInitSucess)
-- end

-- guildData.isShowGuildButton = function(self)
-- 	return self.isInitSucess
-- end

--请求公会信息 有就下发 没有不下发默认  登陆有自带下发
guildData.askGuildInfo = function(self)
	SERVER_FUNC["rpc_server_group_info"]()
end

--请求商会投资信息
guildData.askGuildInvestInfo = function(self)
	GameUtil.callRpc("rpc_server_group_invest", {})
end

guildData.setInvestInfo = function(self, invest_info)
	self.invest_info = invest_info
end

guildData.getInvestInfo = function(self)
	return self.invest_info
end

guildData.createGuildSuccessful = function(self)
	local music_info = require("game_config/music_info")
	audioExt.playEffect(music_info.COMMON_CASH.res)

	--对应EVENT_GUILD_CLOSE_CREATE_DIALOG_VIEW事件派发，GuildCreateDlg界面中的操作
	local guild_badge_ui = getUIManager():get("ClsGuildBadgePanel")
	if not tolua.isnull(guild_badge_ui) then
		guild_badge_ui:closeEffect()
	end

	local ClsDialogLayer = require("ui/dialogLayer").hideDialog()

	Alert:warning({msg = ui_word.STR_GUILD_CREATE_SUCCESS, size = 32})
	-- EventTrigger(EVENT_GUILD_OPEN_TAB_SELECT_VIEW)
	--TODO  派发事件调用回到港口了，看下怎么修改
end

guildData.getGuildInfo = function(self)
	return self.guildInfo
end

guildData.receiveGuildInfo = function(self, info)
	self.guildInfo = info

	local members = {}
	members = info.members
	if #members ~= 0 then
		self:setGuildInfoMembers(members)
		--self:sequenceListByLoginTime(1,true)
	end

	if info.id then
		self:setGuildId(info.id)
	else
		cclog("guild id is nil")
	end

	if info.name then
		self:setGuildName(info.name)
	else
		cclog("guild name is nil")
	end

	if info.maxMembers then
		self:setGuildMaxMembersNum(info.maxMembers)
	else
		cclog("guild maxMembers is nil")
	end

	if info.notice then
		self:setGuildNotice(info.notice)
	else
		cclog("guild notice is nil")
	end

	if info.grade then
		self:setGuildGrade(info.grade)
	end

	if info.curExp then --当前商会经验
		self:setCurExp(info.curExp)
	end

	if info.maxExp then --升级所需的经验总值
		self:setMaxExp(info.maxExp)
	end

	if info.portId then
		self:setGuildPortId(info.portId)
	end

	if info.icon then
		self:setBadgeId(info.icon)
	end

	if info.group_prestige then
		self:setPrestige(info.group_prestige)
	end

	if info.win_amount then
		self:setWinAmount(info.win_amount)
	end

	if info.battle_amount then
		self:setBattleAmount(info.battle_amount)
	end

	if info.mail_times then
		self:setMailTimes(info.mail_times)
	end

	if info.group_openid then
		self:setGuildGroupOpenID(info.group_openid)
	end
	if info.recruit_times then
		self:setCallTimes(info.recruit_times)
	end

	if info.rank then
		self:setMyGuildRank(info.rank)
	end

	self:setGuildViceChairmanAndDeaconNum(members)


	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui)then
		guild_main_ui:updateGuildHallView()
	end

	local clsGuildNoTicePanel = getUIManager():get("ClsGuildNoTicePanel")
	if not tolua.isnull(clsGuildNoTicePanel) then
		clsGuildNoTicePanel:updataMailTimes()
	end
end


guildData.setGuildGroupOpenID = function(self, open_id)
	self.guild_group_open_id = open_id
end

guildData.getGuildGroupOpenID = function(self)
	return self.guild_group_open_id
end

guildData.setIsJoinGroup = function(self, status)
	self.is_jion_guild_group = status
end

guildData.getIsJionGroup = function(self)
	return self.is_jion_guild_group
end
---计算副会长和执事的个数
guildData.setGuildViceChairmanAndDeaconNum = function(self, members)
	local vice_chairman_num = 0
	local deacon_num = 0
	for k,v in pairs(members) do
		if v.authority == GROUP_MEMBER_LEVEL_VICE_CHAIRMAN then
			vice_chairman_num = vice_chairman_num + 1
		elseif v.authority == GROUP_MEMBER_LEVEL_DEACONRY then
			deacon_num = deacon_num + 1
		end
	end
	self.vice_chairman_num = vice_chairman_num
	self.deacon_num = deacon_num
end

---获取副会长和执事的个数
guildData.getGuildViceChairmanAndDeaconNum = function(self)
	return self.vice_chairman_num ,self.deacon_num
end

--职位优先
guildData.getSortByPost = function(self, a,b,isHightToLow)
	if isHightToLow then
		return a.authority == b.authority, a.authority > b.authority
	else
		return a.authority == b.authority, a.authority < b.authority
	end
end

--等级优先
guildData.getSortByLevel = function(self, a,b,isHightToLow)
	if isHightToLow then
		return a.level == b.level, a.level > b.level
	else
		return a.level == b.level, a.level < b.level
	end
end

--贡献值优先
guildData.getSortByContribution = function(self, a,b,isHightToLow)
	if isHightToLow then
		return a.maxContribute == b.maxContribute, a.maxContribute > b.maxContribute
	else
		return a.maxContribute == b.maxContribute, a.maxContribute < b.maxContribute
	end
end

--登录时间
guildData.sortByLoginTime = function(self, a,b,isHightToLow)
	if isHightToLow then
		if a.login == 1 or b.login == 1 then
			return a.login == b.login, a.login > b.login
		end
		return a.lastLoginTime == b.lastLoginTime, a.lastLoginTime < b.lastLoginTime
	else
		if a.login == 1 or b.login == 1 then
			return a.login == b.login, a.login < b.login
		end
		return a.lastLoginTime == b.lastLoginTime, a.lastLoginTime > b.lastLoginTime
	end
end

-- guildData.sortByLoginTime = function(self, a,b,isHightToLow)
-- 	if isHightToLow then
-- 		return a.login == b.login, a.login > b.login
-- 	else
-- 		return a.login == b.login, a.login < b.login
-- 	end
-- end

--战斗力
guildData.sortByPower = function(self, a,b,isHightToLow)
	if isHightToLow then
		return a.zhandouli == b.zhandouli, a.zhandouli > b.zhandouli
	else
		return a.zhandouli == b.zhandouli, a.zhandouli < b.zhandouli
	end
end


--在线时间优先
guildData.sequenceListByLoginTime = function(self, func_key,isHightToLow)
	--if isHightToLow then
		--print("===============================降序")
	--else
		--print("=================================升序")
	--end

	local sort_func_list = {
		{ func = guildData.sortByLoginTime, func_tag = 1},   ---在线时间
		{ func = guildData.getSortByPost, func_tag = 2}, 	---职位
		{ func = guildData.getSortByLevel, func_tag = 3}, ---等级
		{ func = guildData.sortByPower, func_tag = 4}, ---声望
		{ func = guildData.getSortByContribution, func_tag = 5}, ---贡献
	}
	local members = self:getGuildInfoMembersNumAsKey()
	if not members then return end
	local unselect_sort_func = {}
	for k,v in ipairs(sort_func_list) do
		if k ~= func_key then
			unselect_sort_func[#unselect_sort_func + 1] = v
		end
	end

	table.sort(unselect_sort_func, function (a,b)
		return a.func_tag < b.func_tag
	end)

	local temp = {}
	for k, v in pairs(members) do
		temp[#temp + 1] = v
	end

	table.sort(temp, function(a, b)
		local flag, result = sort_func_list[func_key]["func"](self, a, b, isHightToLow)
		if flag ~= true then return result end
		flag, result = unselect_sort_func[1]["func"](self, a, b, true)
		if flag ~= true then return result end
		flag, result = unselect_sort_func[2]["func"](self, a, b, true)
		if flag ~= true then return result end
		flag, result = unselect_sort_func[3]["func"](self, a, b, true)
		if flag ~= true then return result end
		flag, result = unselect_sort_func[4]["func"](self, a, b, true)
		if flag ~= true then return result end
		return result
	end)

	self:reSetOrder()
	return temp
end


guildData.reSetOrder = function(self)
	for k,v in ipairs(self.guildInfoMembersNumAsKey) do
		self.guildInfoMembersUidAsKey[v.uid].order = k
	end
end

guildData.getGuildGrade = function(self)
	return self.guildGrade or 0
end

guildData.setGuildGrade = function(self, value)
	self.guildGrade = value
end

--商会升级所需经验
guildData.getCurExp = function(self)
	return self.curExp or 0
end

--商会当前经验
guildData.setCurExp = function(self, value)
	self.curExp = value
end

guildData.getMaxExp = function(self)
	return self.maxExp or 0
end

guildData.setMaxExp = function(self, value)
	self.maxExp = value
end

guildData.askExitGuild = function(self)
	if self:hasGuild() then
		GameUtil.callRpc("rpc_server_group_quit", {},"rpc_client_group_quit")
	end
end

guildData.askExitGuildTimesTips = function(self)
	if self:hasGuild() then
		GameUtil.callRpc("rpc_server_to_quit_group", {})
	end	
end

guildData.getGuildState = function(self, cdofusg)
	if not cdofusg then cdofusg = self.guildInfo.cdofusg end

	if not cdofusg then cdofusg = 0 end

	if cdofusg < 3 then return ui_word.STR_GUILD_STATE_GOOD end
	if cdofusg < 6 then return ui_word.STR_GUILD_STATE_NORMAL end
	return ui_word.STR_GUILD_STATE_BAD
end

guildData.receiveExitGuild = function(self)
	self:setGuildId(nil)
	self:setGuildInfoMembers(nil)
	self:setBadgeId(nil)
	self.guildInfo = nil
	local guildSearchData = getGameData():getGuildSearchData()
	guildSearchData:clearSearchData()
	Alert:warning({msg = ui_word.STR_GUILD_EXIT, size = 26})
	-- self:setPortBattleInfo(0, 0)

	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:initDonate()

	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui)then
		guild_main_ui:close()
	end
end

guildData.getGuildInfoMembersNumAsKey = function(self)
	return self.guildInfoMembersNumAsKey
end

guildData.getGuildInfoMembersUidAsKey = function(self)
	return self.guildInfoMembersUidAsKey
end

guildData.isGuildMember = function(self, uid)
	if not self.guildInfoMembersUidAsKey then return false end
	if not self.guildInfoMembersUidAsKey[uid] then
		return false
	end
	return true
end

guildData.getGuildInfoMemberByUid = function(self, uid)
	if not self.guildInfoMembersUidAsKey then return end
	return self.guildInfoMembersUidAsKey[uid]
end

guildData.removeGuildInfoMember = function(self, uid)
	if not self.guildInfoMembersUidAsKey or not self.guildInfoMembersNumAsKey then return end
	self.guildInfoMembersUidAsKey[uid] = nil
	for k,v in ipairs(self.guildInfoMembersNumAsKey) do
		if v.uid == uid then
			self.guildInfoMembersNumAsKey[k] = nil
		end
	end
end

guildData.setGuildInfoMembers = function(self, members)
	if members then
		self.guildMembersNum = #members
		self.guildInfoMembersNumAsKey = members
		self.guildInfoMembersUidAsKey = {}
		for k,v in ipairs(members) do
			self.guildInfoMembersUidAsKey[v.uid] = v
		end
		self:setGuildViceChairmanAndDeaconNum(members)
	else
		self.guildInfoMembersNumAsKey = nil
		self.guildInfoMembersUidAsKey = nil
		self.guildMembersNum = 0
	end
end

guildData.getCaptionName = function(self, members)
	members = members or self.guildInfoMembersUidAsKey

	if not members then return "" end

	for k, v in pairs(members) do
		if v.authority == GROUP_MEMBER_LEVEL_CHAIRMAN  then
			return v.name
		end
	end
	return ""
end

guildData.getGuildName = function(self)
	return self.guildName
end

guildData.setGuildName = function(self, name)
	self.guildName = name
end

--更新notice
guildData.updateNotice = function(self, strNotice)
	GameUtil.callRpc("rpc_server_group_edit_notice", {strNotice}, "rpc_client_group_edit_notice")
end

guildData.getGuildNotice = function(self)
	return self.guildNotice
end

guildData.setGuildNotice = function(self, notice)
	--self.guildNotice = notice
	-- 屏蔽敏感字
	self.guildNotice = replaceValidText(notice)
end

guildData.getGuildMembersNum = function(self)
	return self.guildMembersNum
end

guildData.setGuildMembersNum = function(self, membersNum)
	self.guildMembersNum = membersNum
end

guildData.getGuildMaxMembersNum = function(self)
	return self.guildMaxMembersNum
end

guildData.setGuildMaxMembersNum = function(self, num)
	self.guildMaxMembersNum = num
end

guildData.getGuildInfoMembers = function(self)
	return self.guildInfoMembers
end

guildData.setGuildId = function(self, id)
	self.guildId = id
	EventTrigger(JOIN_EXIT_GUILD_EVENT)
end

guildData.getGuildId = function(self)
	return self.guildId
end

--判断
guildData.hasGuild = function(self)
	return self.guildId ~= nil and self.guildId ~= 0
end

guildData.receiveGuildApplyReply = function(self)

	   -- EventTrigger(EVENT_GUILD_UPDATE_REQUEST_VIEW_REMOVECELL)
	--TODO 申请加入不用同意了，看下是不是不用了
end

guildData.receiveUpdateNotice = function(self, notice)
	self:setGuildNotice(notice)

	local main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(main_ui) then
		main_ui:updateGuildNotice()
	end
end

guildData.receiveChangeAuthority = function(self)
	--local guild_info_ui = getUIManager():get("ClsGuildInfoPanel")
	--if not tolua.isnull(guild_info_ui) then
	self:askGuildInfo()
	--end
end

guildData.changeAuthority = function(self, uid, authority)
	GameUtil.callRpc("rpc_server_group_change_authority", {uid, authority})
end

guildData.captainKickGuildMember = function(self, uid)

	if tonumber(uid) > 0 then
		GameUtil.callRpc("rpc_server_group_kick", {uid})
	else
		cclog("uid is 0")
	end

end

guildData.isCaptain = function(self)
	local authority = self:playerAuthority()
	if authority == GROUP_MEMBER_LEVEL_CHAIRMAN then
		return true
	end
	return false
end

guildData.isEidtNotice = function(self)
	local authority = self:playerAuthority()
	if authority > GROUP_MEMBER_LEVEL_DEACONRY then
		return true
	end
	return false
end

guildData.isNormalMember = function(self)
	local authority = self:playerAuthority()
	if authority == GROUP_MEMBER_LEVEL_MEMBER then
		return true
	end
	return false
end

guildData.receiveGuildKickMember = function(self, member)
	self:removeGuildInfoMember(member)
	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
	Alert:warning({msg = ui_word.STR_GUILD_KICK_OUT, size = 26})
end

--申请列表,批准和拒绝按钮功能
guildData.guildApplyReply = function(self, userId, reply)
	local guildId = self:getGuildId()
	GameUtil.callRpc("rpc_server_group_apply_reply", {guildId, userId, reply})
end

guildData.askGuildApplyList = function(self)
	if self:hasGuild() then
		GameUtil.callRpc("rpc_server_group_apply_list", {})
	end
end

--请求改变申请公会类型
guildData.changeJoinType = function(self, type)
	if self:hasGuild() then
		GameUtil.callRpc("rpc_server_group_join_type", {type}, "rpc_client_group_join_type")
	end
end

guildData.playerAuthority = function(self)
	local playerData = getGameData():getPlayerData()
	local goalUid = playerData:getUid()
	if self.guildInfoMembersUidAsKey and self.guildInfoMembersUidAsKey[goalUid] then
		return self.guildInfoMembersUidAsKey[goalUid].authority
	end
	return 0
end

guildData.receiveGuildApplyList = function(self, applyList, join_type)
	self.guildApplyList = applyList
	--print("=============申请列表============================")
	--table.print(applyList)
	local guild_apply_ui = getUIManager():get("ClsGuildApplyManagerUI")
	if not tolua.isnull(guild_apply_ui) then
		guild_apply_ui:updateJoinType(join_type)
		guild_apply_ui:updateApplyList(applyList)
	end
end

----设置公会据点港口id
guildData.setGuildPortId = function(self, id)
	self.portId = id
end

guildData.getGuildPortId = function(self)
	return self.portId
end

--商会徽章id
guildData.setBadgeId = function(self, id)
	self.badge_id = id
end

guildData.getBadgeId = function(self)
	if not self.badge_id or tonumber(self.badge_id ) < 1 then
		return 1
	end
	return tonumber(self.badge_id)
end

--商会声望
guildData.setPrestige = function(self, num)
	self.prestige = num
end

guildData.getPrestige = function(self)
	return self.prestige
end

--商会据点战赢数据
guildData.setWinAmount = function(self, num)
	self.win_amount = num
end

guildData.getWinAmount = function(self)
	return self.win_amount
end

--商会据点战总参战次数
guildData.setBattleAmount = function(self, num)
	self.battle_amount = num
end

guildData.getBattleAmount = function(self)
	return self.battle_amount
end

---商会召集次数
guildData.setCallTimes = function(self, times)
	self.call_times = times
end

guildData.getCallTimes = function(self)
	return self.call_times
end

----商会邮件条数
guildData.setMailTimes = function(self, times)
	self.mail_times = times
end

guildData.getMailTimes = function(self)
	return self.mail_times
end

guildData.askEditIcon = function(self, icon)
	GameUtil.callRpc("rpc_server_group_edit_icon", {tostring(icon)})
end

guildData.askGroupMail = function(self, text)
	GameUtil.callRpc("rpc_server_group_member_mail", {text}, "rpc_client_group_member_mail")
end

guildData.askGroupCall = function(self, text)
	GameUtil.callRpc("rpc_server_group_recruit", {text}, "rpc_client_group_recruit")
end

--是否有商会战场系统开放
guildData.hasOpenGuildBossBtn = function(self)
	if not self:hasGuild() then
		return false
	end
	local guild_level = self:getGuildGrade()
	local open_level = GUILD_SYSTEM_GRADE[GUILD_SYSTEM_TAB.GUILD_BOSS]
	if guild_level < open_level then
		return false
	end
	return true
end

-- 查询其它商会信息 返回 rpc_client_group_info
guildData.requestOtherGuildInfo = function(self, guild_id)
	GameUtil.callRpc("rpc_server_show_group_info",{guild_id})
end

guildData.setOtherGuildData = function(self, data)
	self.m_other_guild_data = data
end

guildData.getOtherGuildData = function(self)
	return self.m_other_guild_data
end

guildData.askCreateGroup = function(self)
	GameUtil.callRpc("rpc_server_guild_bind_group", {})
end

guildData.askJoinGroup = function(self)
	GameUtil.callRpc("rpc_server_guild_join_group", {})
end

guildData.askUnbindGroup = function(self)
	GameUtil.callRpc("rpc_server_guild_unbind_group", {})
end

guildData.setMyGuildRank = function(self, rank)
	self.m_my_rank = rank
end

guildData.getMyGuildRank = function(self)
	return self.m_my_rank
end

return guildData
