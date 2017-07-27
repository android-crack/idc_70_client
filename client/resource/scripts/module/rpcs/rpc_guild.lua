local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")--公会创建
local news = require("game_config/news")
local ClsUiWord = require("game_config/ui_word")
local battleResult = require("module/battleAttrs/battleResult")

-- ----邀请入会invitee 被邀请人 groupId 被邀请进入的商会ID inviter 邀请人
function rpc_client_group_invite(groupId, groupName, inviter_uid, name)
	local str = string.format(ClsUiWord.STR_GUILD_INVITE_MEMBER_TAB,name,groupName)
	Alert:showAttention(str,function ()
		local guild_search_data = getGameData():getGuildSearchData()
		guild_search_data:acceptInvitePerson(groupId,inviter_uid)
	end)
end

--rpc_server_group_accept_invite(object oUser, int groupId, int inviter);

function rpc_client_group_mission_update_message(erro)
	if erro ~= 0 then
		Alert:warning({msg = error_info[error].message, size = 26})
		return
	end

	Alert:warning({msg = ClsUiWord.GUILD_TASK_SEND_SUCCESS, size = 26})
	local ui = getUIManager():get("ClsGuildTaskMulDetails")
	if not tolua.isnull(ui) then
		ui:closeView()
	end
end

--多人任务，退出
function rpc_client_group_mission_cancel(result, error)
	if result ~= 1 then
		Alert:warning({msg =error_info[error].message, size = 26})
		return
	end

	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:cancelGroupTask()
end

--公会任务领奖结果返回
function rpc_client_group_mission_get_reward(result, error)
	if result ~= 1 then
		Alert:warning({msg =error_info[error].message, size = 26})
		local ui = getUIManager():get("ClsGuildTaskMain")
		if not tolua.isnull(ui) then
		   -- ui:setTouch(true)
		end
		return
	end
end

--参与公会任务
function rpc_client_group_mission_join(result, error)
	if result ~= 1 then
		Alert:warning({msg =error_info[error].message, size = 26})
		return
	end
end

--领奖成功数据返回
function rpc_client_group_mission_reward_info(data)

	local sailorData = getGameData():getSailorData()
	sailorData:saveDataBeforReward(data.sailors)

	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:receiveReward(data)
end

--单个任务info(只有聊天跳转到详情才用到)
function rpc_client_group_mission_info(data)
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:receiveCurOpenMission(data)
end

--单个任务info
function rpc_client_group_mission_list_info(data)
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:receiveGuildTask(data)
end

--多人任务详细信息
function rpc_client_group_mission_detail(data)
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:receiveMultiTaskDetail(data)
end


--任务列表，包括个人和公会
function rpc_client_group_mission_list(datas)
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:receiveGuildTasks(datas)
end


-- ---通知是否查询到公会信息了
-- function rpc_client_group_show()
-- 	local guildInfoData = getGameData():getGuildInfoData()
-- 	guildInfoData:receiveShowGuildButton()
-- end

function rpc_client_group_create(groupId,result,error)
	local guildInfoData = getGameData():getGuildInfoData()
	if result==1 then
		guildInfoData:setGuildId(groupId)
		guildInfoData:createGuildSuccessful()
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

---加入或创建成功都返回这个协议
function rpc_client_group_info(info)
	local guildInfoData = getGameData():getGuildInfoData()
	local guild_prestige_data = getGameData():getGuildPrestigeData()
	guild_prestige_data:askGuildPrestigeInfo()
	guildInfoData:receiveGuildInfo(info)

	getGameData():getRankData():resetMyGuildInfo()
	local rank_main_ui = getUIManager():get("ClsRankMainUI")
	if not tolua.isnull(rank_main_ui) then
		local guild_rank_ui = rank_main_ui:getListView(GUILD_RANK_TYPE)
		if not tolua.isnull(guild_rank_ui) then
			guild_rank_ui:updateGuildText()
		end
	end
end

function rpc_client_show_group_info(error,info)
	if error == 0 then
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:setOtherGuildData(info)
		getUIManager():create("gameobj/guild/clsOtherGuildMainUI",nil,info)	
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end

end

--申请加入公会
function rpc_client_group_apply_request(groupId, result, error)
	if result == 1 then
		local guild_search_ui = getUIManager():get("ClsGuildListPanel")
		if not tolua.isnull(guild_search_ui) then
			guild_search_ui:updateGuildApplyState(groupId)
		end
		Alert:warning({msg = ClsUiWord.STR_GUILD_APPLY_SUCCESS, size = 26})
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end
end

--公会申请回复
function rpc_client_group_apply_reply(result, error)
	if result == 1 then
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end
end

--商会申请列表数据
function rpc_client_group_apply_list(list, join_type)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:receiveGuildApplyList(list, join_type)
end

--商会申请类型要求，是否需要验证
function rpc_client_group_join_type(result, err, join_type)
	if result == 1 then
		Alert:warning({msg = ClsUiWord.STR_GUILD_EXCHANGE_TEST, size = 26})
		local guild_apply_ui = getUIManager():get("ClsGuildApplyManagerUI")
		if not tolua.isnull(guild_apply_ui) then
			guild_apply_ui:updateJoinType(join_type)
		end
	else
		Alert:warning({msg =error_info[err].message, size = 26})
	end
end

function rpc_client_group_search(result, err, list)
	if result==1 then
		local guildSearchData = getGameData():getGuildSearchData()
		guildSearchData:revceiveSearchGuild(list)
	else
		Alert:warning({msg =error_info[err].message, size = 26})
	end
end

function rpc_client_base_group_info(info)
	local guildSearchData = getGameData():getGuildSearchData()
	guildSearchData:updateSearchBaseInfo(info)
end


---退工会次数弹框协议
function rpc_client_to_quit_group(result)
	Alert:showAttention(ClsUiWord.STR_GUILD_EXIT_TIMES_TIPS, function()
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:askExitGuild()
	end)
end

--退出公会
function rpc_client_group_quit(result,error)
	if result == 1 then
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:receiveExitGuild()
		local guild_shop_data = getGameData():getGuildShopData()
		guild_shop_data:cleanGiftData()

		local guild_research_data = getGameData():getGuildResearchData()
		guild_research_data:clearResearchData()

		local tip_ui = getUIManager():get("ClsGuildGiftTip")
		if not tolua.isnull(tip_ui) then
			tip_ui:closeView()
		end

		local ClsGuildSkillResearchMain = getUIManager():get("ClsGuildSkillResearchMain")
		if not tolua.isnull(ClsGuildSkillResearchMain) then
			ClsGuildSkillResearchMain:closeMySelf()
		end

		-- local clsOtherGuildMainUI = getUIManager():get("clsOtherGuildMainUI")
		-- if not tolua.isnull(clsOtherGuildMainUI) then
		-- 	clsOtherGuildMainUI:close()
		-- 	local ClsCreateGuildTips = getUIManager():get("ClsCreateGuildTips")
		-- 	if not tolua.isnull(ClsCreateGuildTips) then
		-- 		ClsCreateGuildTips:close()
		-- 	end

		-- end

		local chat_data_handler = getGameData():getChatData()
		chat_data_handler:cleanGuildMsg()

		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:clearTaskList()

		local port_layer = getUIManager():get("ClsPortLayer")

		if not tolua.isnull(port_layer) then
			port_layer:createChatComponent()
		end

		getGameData():getRankData():resetMyGuildInfo()
		local rank_main_ui = getUIManager():get("ClsRankMainUI")
		if not tolua.isnull(rank_main_ui) then
			local guild_rank_ui = rank_main_ui:getListView(GUILD_RANK_TYPE)
			if not tolua.isnull(guild_rank_ui) then
				guild_rank_ui:updateGuildText()
			end
		end

		if getUIManager():isLive("ClsGuildMainUI") then
			getUIManager():close("ClsGuildMainUI")
		end

		local chat_panel_ui = getUIManager():get("ClsChatSystemPanel")
		if tolua.isnull(chat_panel_ui) then return end
		chat_panel_ui:updateShowMessage()
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

--公会事件
function rpc_client_group_event_list(list)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:receiveAllGuildEvents(list)
end

function rpc_client_group_add_event(event)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:receiveGuildEvent(event)
end

--捐献
function rpc_client_group_donate(result, error)
	if result then
		local guildPrestigeData = getGameData():getGuildPrestigeData()
		guildPrestigeData:receiveGuildDonateResult()
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end
end

function rpc_client_group_prestige_salute(result, error, reward)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:receiveSaluteResult(result,error, reward)
end

function rpc_client_group_salute_reward(result, error, power)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:receiveSaluteResult(result,error, power, true)
end

function rpc_client_group_update_salute_sign(salute_times, salute_limit)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:receiveSaluteLimit(salute_times, salute_limit)
end


-- class group_honour_t {
--     int star_member;
--     string star_name;
--     string star_icon;
--     int star_grade;
--     int has_salute;
--     random_reward_t* salute_reward;
--     int reward;
-- }
function rpc_client_group_honour_info(info)
	if(info == nil) then  end
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:setStarData(info)
	local guildPrestigeData = getGameData():getGuildPrestigeData()
	guildPrestigeData:setSaluteTime(info.has_salute)
	guildPrestigeData:receiveGuildStar(info.star_member)
end

--移除公会
function rpc_client_group_kick(member, result, error)
	if result == 1 then
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:receiveGuildKickMember(member)
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

--更新notice
function rpc_client_group_update_notice(notice)
	if type(notice) == "string" then
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:receiveUpdateNotice(notice)
	end
end

function rpc_client_group_edit_notice(result, error)
	if result ==  1 then
		Alert:warning({msg = ClsUiWord.STR_GUILD_EDIT_BORAD_SUCCESS, size = 26})
	else
	   local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

--职位改变
function rpc_client_group_change_authority(result, error)
	if result ==  1 then
		local guildInfoData = getGameData():getGuildInfoData()
		guildInfoData:receiveChangeAuthority()
	else
	   local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

function rpc_client_group_authority_update(member, authority)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:receiveChangeAuthority()
end

function rpc_client_group_aid_boat_list(list)
	local guildAidData = getGameData():getGuildAidData()
	guildAidData:initGuildFriendBaseInfo(list)
end

function rpc_client_group_aid_fighter_data(fighterData)
	local guildAidData = getGameData():getGuildAidData()
	guildAidData:initGuildFriendTotalInfo(fighterData)
end

function rpc_client_chat_send_chat(result,error)
	if result == 0 then
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_SEND_FAIL .." %d", error)
		end
		Alert:warning({msg = str, size = 26})
	else

	end
end

function rpc_client_group_boss_drown_ship_rewards(rewards)
	Alert:showCommonReward(rewards)
end

function  rpc_client_group_boss_info(bossInfo)
	local GuildBossData = getGameData():getGuildBossData()
	GuildBossData:initBossInfo(bossInfo)
	if bossInfo.status == 0 then
		local GuildBossData = getGameData():getGuildBossData()
		GuildBossData:bossFightCD(0)
	end

	local port_layer = getUIManager():get("ClsPortLayer")
	if tolua.isnull(port_layer) then
		return
	end
	if GuildBossData:getSkipTag() == 0 then
		GuildBossData:setSkipTag(nil)
		if bossInfo.remainTime == 0 then
			if not tolua.isnull(port_layer) then
				port_layer:setTouch(true)
			end
			Alert:warning({msg = ClsUiWord.CHAT_TIMEOUT_TIPS, size = 26})
			return
		end

		local skipToLayer = require("gameobj/mission/missionSkipLayer")
		local skipMissLayer = skipToLayer:skipLayerByName("guild_boss", nil)
	elseif GuildBossData:getSkipTag() == 1 then
		GuildBossData:setSkipTag(nil)
		if bossInfo.remainTime == 0 then
			Alert:warning({msg = ClsUiWord.CHAT_TIMEOUT_TIPS, size = 26})
			return
		end

		local skipToLayer = require("gameobj/mission/missionSkipLayer")
		local skipMissLayer = skipToLayer:skipLayerByName("guild_boss_rank", nil)
	end
end

function rpc_client_group_boss_gift(result, error, cur_times)
	if result == 1 then
		local GuildBossData = getGameData():getGuildBossData()
		GuildBossData:setInvest(cur_times)

		local ClsGuildSkillStudyTab = getUIManager():get("ClsGuildSkillStudyTab")
		if not tolua.isnull(ClsGuildSkillStudyTab) then
			ClsGuildSkillStudyTab:updateContributionLab()
		end
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_SEND_FAIL .." %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

function rpc_client_group_boss_gift_reward(rewards)
	Alert:showCommonReward(rewards)
end

function rpc_client_group_boss_open(bossInfo)
	local GuildBossData = getGameData():getGuildBossData()
	GuildBossData:initBossInfo(bossInfo)
end

function rpc_client_group_boss_fight_start(result, error)
	local ClsGuildBossUI = getUIManager():get("GuildBossUI")
	if result == 0 then
		local msg = error_info[error].message
		Alert:warning({msg = msg, size = 26})
		if not tolua.isnull(ClsGuildBossUI) then
			ClsGuildBossUI:playRight1View()
		end
		return
	end
end

function rpc_client_group_boss_fight_result(rewards, result, error)
	if result == 1 then
		-- battleResult.showBattleResult(rewards)
	else

	end
end

function rpc_client_group_boss_rank(ranks, cur_sum_point, max_sum_point)
	local GuildBossData = getGameData():getGuildBossData()
	GuildBossData:setSumPoint(cur_sum_point, max_sum_point)
	GuildBossData:GuildBossAttackRanks(ranks)
end

function rpc_client_group_boss_rank_reward(result, error, rewards)
	if result == 1 then
		local GuildBossData = getGameData():getGuildBossData()
		GuildBossData:getGuildBossRewards(rewards)
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_SEND_FAIL .." %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

function rpc_client_group_boss_hp_progress(cur, max, rank) --rank为玩家自己的排行
	local GuildBossData = getGameData():getGuildBossData()
	GuildBossData:updateBossHp(cur, max)

	if not tolua.isnull(getUIManager():get("FightUI")) then
		EventTrigger(EVENT_BATTLE_GUILD_BOSS_FLUSH_CURAMOUNT, rank)
	end
end

-------------------------------------------------------

-- 公会商店
function rpc_client_guild_shop_list(list)
	local guildShopData = getGameData():getGuildShopData()
	guildShopData:receiveShopList(list)
end

-- 单个商品信息
function rpc_client_guild_shop_info(shop_info)
	local guildShopData = getGameData():getGuildShopData()
	guildShopData:receiveShopInfo(shop_info)
end

-- 公会贡献
function rpc_client_guild_contribute(contribute)
	local guildShopData = getGameData():getGuildShopData()
	guildShopData:receiveContribute(contribute)
end

-- 购买
function rpc_client_guild_shop_buy(result, error, shopId, amount, reward)
	if result ~= 1 then
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	elseif result == 1 then
		Alert:showCommonReward(reward)

		local guild_shop_list = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(guild_shop_list) then 
			guild_shop_list:updateShopLeftNum(shopId, amount)
		end

		local clsSailorRecruit = getUIManager():get("clsSailorRecruit")
		if not tolua.isnull(clsSailorRecruit) then
			clsSailorRecruit:setWineColor()
		end
	end
end

function rpc_client_group_gifts_warehouse( status, war_reward, gifts )
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:setShopGiftData(status, war_reward, gifts)
end

function rpc_client_group_gifts( reward )
	Alert:showCommonReward(reward, function()
		--为了限制商会礼包领取个数，每次弹出奖励后才出现下一个
		local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(guild_shop_ui) then
			guild_shop_ui:updateGiftTouchState(true)
		end
	end)
end

--领取军团礼包
function rpc_client_group_get_gifts( errno )
	if errno == 0 then
	else
		local errInfo = error_info[errno]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", errno)
		end
		Alert:warning({msg = str, size = 26})
		--为了限制商会礼包领取个数，每次弹出奖励后才出现下一个
		local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(guild_shop_ui) then
			guild_shop_ui:updateGiftTouchState(true)
		end
	end
end

function rpc_client_group_boss_fight_cd_reset(result, error)
	if result == 1 then
		local GuildBossData = getGameData():getGuildBossData()
		GuildBossData:clearFightCD()
		GuildBossData:askForGuildBossBattle()
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

function rpc_client_group_boss_fight_cd(remainTime)
	local remainTime = remainTime or 0
	if remainTime > 0 then
		local GuildBossData = getGameData():getGuildBossData()
		GuildBossData:bossFightCD(remainTime)
	end
end

function rpc_client_group_info_update(grade, curExp, maxExp, maxSize)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setGuildGrade(grade)
	guildInfoData:setCurExp(curExp)
	guildInfoData:setMaxExp(maxExp)
	guildInfoData:setGuildMaxMembersNum(maxSize)

	--公会升级，修改场景建筑
	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui)then
		guild_main_ui:updateGuildLevel()

		---公会升级请求商会研究所的数据
		local guild_research_data = getGameData():getGuildResearchData()
		guild_research_data:askResearchData()
		guild_research_data:askStudyData()	
	end
end

--商会声望数值变动
function rpc_client_group_prestige_update( prestige )
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setPrestige(prestige)

	--商会声望，公会信息界面更新
	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
end

function rpc_client_group_member_list(list)
	--print("==================rpc_client_group_member_list=========")
	--table.print(list)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setGuildInfoMembers(list)
	guildInfoData:setGuildMembersNum(#list)
	--guildInfoData:getSortByPost(true)

	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
end

function rpc_client_group_member_contribute_update(member, contribute, maxContribute)
	local playerData = getGameData():getPlayerData()
	local uid = playerData:getUid()
	local guildInfoData = getGameData():getGuildInfoData()
	local memberData = guildInfoData:getGuildInfoMemberByUid(member)
	if memberData then
		memberData.contribute = contribute
		memberData.maxContribute = maxContribute

		local guild_info_ui = getUIManager():get("ClsGuildMainUI")
		if not tolua.isnull(guild_info_ui) then
			guild_info_ui:updateGuildHallView()
		end
	end
end

--设置商会徽章操作
function rpc_client_group_edit_icon(result, error)
	if result == 1 then -- 设置商会徽章成功
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ClsUiWord.STR_GUILD_ERROR_CODE .. " %d", error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

--更新商会徽章操作
function rpc_client_group_update_icon(icon)
	local guild_info_data = getGameData():getGuildInfoData()
	guild_info_data:setBadgeId(icon)

	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
end

----------------------------------------------------------------------------
-------------------------------商会战协议-------------------------------------

function rpc_client_group_battle_info(remain_time, battle_infos, guard_data)
	if getUIManager():isLive("clsGuildFightUI") then
		getUIManager():close("clsGuildFightUI")
	end
	getUIManager():create("gameobj/guild/clsGuildFightUI")
	
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setGuardData(guard_data)
	guild_fight_data:setFightTime(remain_time)
	guild_fight_data:setVSData(battle_infos)
end

function rpc_client_group_battle_mvp_info(mvpInfo)
	getGameData():getGuildFightData():setMVPData(mvpInfo)
end

function rpc_client_enter_group_battle(error_code)
	if error_code ~= 0 then
		Alert:warning({msg = error_info[error_code].message, size = 26})
		return
	end
end

function rpc_client_group_battle_chart(charts)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setChartData(charts)
end

function rpc_client_group_battle_solo_info(solo_info_camp_1, solo_info_camp_2)
	local guild_fight_data = getGameData():getGuildFightData()
	local solo_1 = {}
	local solo_2 = {}
	for k, v in pairs(solo_info_camp_1) do
		solo_1[v.index] = v
	end

	for k, v in pairs(solo_info_camp_2) do
		solo_2[v.index] = v
	end
	guild_fight_data:setSoloInfo({solo_1, solo_2})

	local solo_ui = getUIManager():get("ClsGuildBattleSoloUI")
	if not tolua.isnull(solo_ui) then
		solo_ui:updataUI()
	end
end

-----------------------------商会战协议 --------------------------------------

-- 221 class boss_rank_t {
-- 222     int uid;
-- 223     int rank;
-- 224     string name;
-- 225     int point;
-- 226 }
-- 227
function rpc_client_group_boss_rank_top_three(myRank, myPoint, ranks)
	local guild_boss_data = getGameData():getGuildBossData()
	guild_boss_data:setMyRank({rank = myRank, point = myPoint})
	table.sort(ranks, function(a, b) return a.rank < b.rank end)
	guild_boss_data:setFightingRanks(ranks)
end

-- ranks {
-- 	int uid;
-- 	string name;
-- 	int invest;
-- }
--昨天公会投资排行榜前十名
function rpc_client_group_invest_rank(ranks)
	local guildPrestigePanel = getUIManager():get("ClsGuildPrestigePanel")
	if not tolua.isnull(guildPrestigePanel) then
		guildPrestigePanel:updateStarList(ranks)
	end
end

-- ranks {
-- 	int uid;
-- 	string name;
-- 	int invest;
-- }
--今日公会投资排行榜
function rpc_client_group_invest_rank_cur(ranks)
	local guildPrestigePanel = getUIManager():get("ClsGuildPrestigePanel")
	if not tolua.isnull(guildPrestigePanel) then
		guildPrestigePanel:updateStarList(ranks)
	end
end

function rpc_client_group_member_mail(err)
	if err == 0 then
		Alert:warning({msg = ClsUiWord.STR_GUILD_SEND_MAIL_SUCCESS, size = 26})
	else
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end


function rpc_client_group_recruit(err)
	if err == 0 then
		Alert:warning({msg = ClsUiWord.STR_GUILD_SEND_CALL_SUCCESS, size = 26})
	else
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end


function rpc_client_group_boss_set_start_time(result, error)
	if result == 1 then
		Alert:warning({msg = ClsUiWord.STR_GUILD_BOSS_OPEN_TIME_SUCCESS, size = 26})
		getGameData():getGuildBossData():askGuildBossInfo()
	else
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end

function rpc_client_group_boss_box_reward(reward)
	getGameData():getGuildBossData():setGuildBossBoxReward(reward)
end

--商会礼包信息
function rpc_client_group_gift_info(gift_list)
	if not gift_list or #gift_list < 1 then return end
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:setGiftList(gift_list)
end

function rpc_client_a_group_gift_info(gift_info)
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:updateGift(gift_info)
end

function rpc_client_create_group_gift(gift_id, gold, cnt, reason)
	print("--------------------商会通知我有礼包------------------------------------")
	local gift_info = {
		giftId = gift_id,
		gold = gold,
		cnt = cnt,
		reason = reason,
	}
	local popup_ui = getUIManager():get("ClsGuildGiftPopupUI")
	if not tolua.isnull(popup_ui) then
		popup_ui:closeView()
	end
	getUIManager():create("gameobj/guild/ClsGuildGiftPopup", nil, {kind = GUILD_GIFT_GIVE, gift_info = gift_info})--创建

end

function rpc_client_notice_gift_open(gift_id)
	print("-------------------通知有宝箱可以领了---------------------------创建宝箱按钮抢红包")
	local info = {
		giftId = gift_id
	}
	local tip_ui = getUIManager():get("ClsGuildGiftTip")
	if tolua.isnull(tip_ui) then
		getUIManager():create("gameobj/guild/ClsGuildGiftTip", nil, {gift_info = info})--创建
	else
		tip_ui:updateData(info)
	end
end

--发放礼包
function rpc_client_open_group_gift(gift_id, err)
	if err ~= 0 then
		Alert:warning({msg = error_info[err].message, size = 26})
		local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
		if tolua.isnull(guild_shop_ui) then return end
		guild_shop_ui:setTouch(true)
	end
end

--抢礼包
function rpc_client_grab_group_gift(gift_info, err)
	err = err or 0
	if err == 0 then
		local guild_shop_data = getGameData():getGuildShopData()
		local gift_ui
		local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
		if not tolua.isnull(guild_shop_ui) then
			local gift_ui = guild_shop_ui:getGuildGiftUI()
		end
		if tolua.isnull(gift_ui) then
			local status = guild_shop_data:getGiftStatus(gift_info.giftId)--表示是否抢到过红包
			if status == nil then
				Alert:warning({msg = ClsUiWord.THIS_GIFT_EMPTY, size = 26})
				return
			elseif status == GIFT_GETTED then
				Alert:warning({msg = ClsUiWord.GUILD_CLICK_TEXT_READ_GIFT, size = 26})
				return
			end
		end

		local popup_ui = getUIManager():get("ClsGuildGiftPopupUI")
		if not tolua.isnull(popup_ui) then
			popup_ui:closeView()
		end
		getUIManager():create("gameobj/guild/ClsGuildGiftPopup", nil, {kind = GUILD_GIFT_GRAB_INFO, gift_info = gift_info})--创建
	else
		if not error_info[err] then return end
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end

function rpc_client_first_grab(gift_id, first)
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:setGiftStatus(gift_id, GIFT_GET)
end


--
--class random_reward_t {
--     int id;
--     int amount;
--     int type;
--     string memoJson;
--}

-- void rpc_client_group_invest(int uid, int consume, int times, int allTimes, random_reward_t* rewards)
-- invest_time 这个数字减1表示当前总共捐赠了多少次
function rpc_client_group_invest(consume, invest_time, all_times, reward)
	local guild_invest_info = {
		consume = consume,
		invest_time = invest_time,
		invest_all = all_times,
		reward = reward,
	}
	local guild_data = getGameData():getGuildInfoData()
	guild_data:setInvestInfo(guild_invest_info)

	local guild_ui = getUIManager():get("ClsGuildDonatePanel")
	if not tolua.isnull(guild_ui) then
		guild_ui:updateInvestInfo(guild_invest_info)
	end
end


function rpc_client_guild_bind_group(error_id, str_md5, guild_key)
	if error_id == 0 then--成功
		local module_game_sdk = require("module/sdk/gameSdk")
		local guildInfoData = getGameData():getGuildInfoData()
		local guild_name = guildInfoData:getGuildName()
		local player_name = getGameData():getPlayerData():getName()
		print(guild_key, guild_name, str_md5, player_name)
		module_game_sdk.bindGroup(guild_key, guild_name, str_md5, player_name)

	else
		Alert:warning({msg = error_info[error_id].message, size = 26})
	end
end

------------------------------
function rpc_client_guild_update_group_openid(group_openid)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setGuildGroupOpenID(group_openid)

	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
end

--是否加入群
function rpc_client_guild_join_group_status(status)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setIsJoinGroup(status)
	local guild_info_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_info_ui) then
		guild_info_ui:updateGuildHallView()
	end
end

function rpc_client_guild_join_group(error_id, group_md5, group_key)
	if error_id == 0 then --成功
		local module_game_sdk = require("module/sdk/gameSdk")
		local player_name = getGameData():getPlayerData():getName()
		module_game_sdk.joinGroup(group_md5, group_key, player_name)
	else
		Alert:warning({msg = error_info[error_id].message, size = 26})
	end
	
end

function rpc_client_guild_unbind_group(error_id)
	Alert:warning({msg = error_info[error_id].message, size = 26})
end


--------商会研究所----------------
---研究所技能数据
function rpc_client_group_skill(skill_list)
	local guild_research_data = getGameData():getGuildResearchData()
	guild_research_data:setResearchData(skill_list)

	local ClsGuildSkillResearchMain = getUIManager():get("ClsGuildSkillResearchMain")
	if not tolua.isnull(ClsGuildSkillResearchMain) then
		ClsGuildSkillResearchMain:updateGuildSkillLevel()
	end

	local ClsGuildSkillResearchTab = getUIManager():get("ClsGuildSkillResearchTab")
	if not tolua.isnull(ClsGuildSkillResearchTab) then
		ClsGuildSkillResearchTab:initResearchView()
	end

	local ClsGuildMainUI = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(ClsGuildMainUI) then
		ClsGuildMainUI:updateGuildSkill()
	end
end


--更新单个技能的等级以及材料信息
function rpc_client_group_single_skill(skill_mater_info)
	local ClsGuildResearchGoodsTips = getUIManager():get("ClsGuildResearchGoodsTips")
	if not tolua.isnull(ClsGuildResearchGoodsTips) then
		ClsGuildResearchGoodsTips:updateGoodsLab(skill_mater_info)
	end

	local guild_research_data = getGameData():getGuildResearchData()
	--guild_research_data:updateResearchData(skill_mater_info)
	guild_research_data:askResearchData()
	guild_research_data:updateResearchSelectSkillInfo(skill_mater_info)

	-- local ClsGuildSkillResearchTab = getUIManager():get("ClsGuildSkillResearchTab")
	-- if not tolua.isnull(ClsGuildSkillResearchTab) then
	-- 	ClsGuildSkillResearchTab:initResearchView()
	-- end	
end

---贡献材料
function rpc_client_take_material(error)
	if error == 0 then
		
	else
		if not error_info[error] then return end
		Alert:warning({msg = error_info[error].message, size = 26})
	end	
end

---钻石贡献材料
function rpc_client_take_material_by_gold(error)
	if error == 0 then

	else
		if not error_info[error] then return end
		Alert:warning({msg = error_info[error].message, size = 26})
	end

end

----研究所学习技能
function rpc_client_group_skill_learn(error,skill_id)
	if error == 0 then
		Alert:warning({msg = ClsUiWord.GUILD_RESEARCH_SKILL_UPLEVEL , size = 26})

		if GUILD_SKILL_STUDY[skill_id] then
			local curZhandouli  = getGameData():getPlayerData():getBattlePower()
			local DialogQuene = require("gameobj/quene/clsDialogQuene")
			local clsBattlePower = require("gameobj/quene/clsBattlePower")
			DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = curZhandouli,oldPower = 0}))
		end		
	else
		if not error_info[error] then return end
		Alert:warning({msg = error_info[error].message, size = 26})
	end
	
end

---学习技能信息
function rpc_client_group_skill_learn_info(learn_skill_info)
	local guild_research_data = getGameData():getGuildResearchData()
	guild_research_data:setStudySkillData(learn_skill_info)
	
	local ClsGuildSkillStudyTab = getUIManager():get("ClsGuildSkillStudyTab")
	if not tolua.isnull(ClsGuildSkillStudyTab) then
		ClsGuildSkillStudyTab:initStudyView()
	end
end

---商会召集次数
function rpc_client_update_group_recruit(times)
	--print("----------------商会召集次数",times)
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:setCallTimes(times)
    local clsGuildNoTicePanel = getUIManager():get("ClsGuildNoTicePanel")
    if not tolua.isnull(clsGuildNoTicePanel) then
        clsGuildNoTicePanel:updataCallTimes()
    end	
end
