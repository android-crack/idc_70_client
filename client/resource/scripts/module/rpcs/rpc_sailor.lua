local error_info=require("game_config/error_info")
local voice_info=getLangVoiceInfo()
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local tool=require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local on_off_info=require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local item_info = require("game_config/propItem/item_info")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsSailorWineRecuitQuene = require("gameobj/quene/clsSailorWineRecuitQuene")
local ClsSkillTipsQuene = require("gameobj/quene/clsSkillTipsQuene")
local ClsExploreSailorUpLevel = require("gameobj/quene/clsExploreSailorUpLevel")
local ClsSailorUpLevelEffect = require("gameobj/quene/clsSailorUplevelEffect")
--[[
--升星
]]
function rpc_client_sailor_upstar(result, err)
	if result ~= 1 then
		local errorRes = error_info[err]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

    if getUIManager():isLive("ClsSailorListView") then
        getUIManager():get("ClsSailorListView"):updateStarNum()
    end

    local partner_info_view = getUIManager():get("ClsPartnerInfoView")
    if partner_info_view and not tolua.isnull(partner_info_view) then
        partner_info_view:updateStarNum()
        partner_info_view:updateAttrPanel()
        partner_info_view:updateSkillPanel(true)
       -- partner_info_view:updateAptitudePanel()
    end
end

--[[
--honour recruit result
--result:1 - success
--error: if result not equal with 1, show tips for user
]]
----荣誉招募
function rpc_client_sailor_honour_enlist(result, error)
	if result ~= 1 then
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end

		local clsSailorRecruit = getUIManager():get("clsSailorRecruit")
		if not tolua.isnull(clsSailorRecruit) then
			clsSailorRecruit:setBtnTouch(true)
		end
	end

end

-----金币招募
function rpc_client_sailor_gold_enlist(result, error)
	if result ~= 1 then
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

end
--[[
--the sailor infos of recruited
]]

-----招募奖励协议
function rpc_client_random_enlist_sailor_reward(rewards, type_n)

    getGameData():getSailorData():setRecruitSailorInfo(rewards)
	--print("=============招募到info================",sailorId)
	--table.print(rewards)
    local WINE_RECRUIT = 1
    if type_n == WINE_RECRUIT then
		if rewards[1]["type"] == ITEM_INDEX_SAILOR then
			---getUIManager():create("gameobj/sailor/ClsSailorWineRecruit",{}, rewards[1].id)
			ClsDialogSequene:insertTaskToQuene(ClsSailorWineRecuitQuene.new({sailor_id = rewards[1].id}))

		else
			Alert:showCommonReward(rewards)
			if getUIManager():isLive("clsSailorRecruit") then
				local view_obj = getUIManager():get("clsSailorRecruit")
				view_obj:setBtnTouch(true)
			end
		end
	else

		local clsSailorRecruitView = getUIManager():get("clsSailorRecruitView")
		if not tolua.isnull(clsSailorRecruitView) then
			clsSailorRecruitView:initView()
		else
			getUIManager():create("gameobj/sailor/clsSailorRecruitView", {}, 2)
		end
    end
end

---招募额外特定奖励

function rpc_client_enlist_extra_reward(type,rewards)
	-- print("-----------------招募额外特定奖励")
	-- table.print(rewards)
	if type == 1 then
		Alert:showCommonReward(rewards)
	else
		Alert:showCommonReward(rewards)
	end
	
end

----招募到航海士的星章奖励
function rpc_client_repeat_sailor_reward(rewards, sailorId, error)
	-- print("=============招募到航海士的星章奖励================",sailorId)
	-- table.print(rewards)
	if error == 0 then
		local sailorData = getGameData():getSailorData()
		sailorData:setRecruitSailorReward(rewards,sailorId)
	end

end

---招募到首个A级航海士的tips
function rpc_client_sailor_pop_window(sailor_id)
	local sailorData = getGameData():getSailorData()
	sailorData:setFirstASailor(sailor_id)
end


function rpc_client_sailor_own_list(list)
	local sailorData = getGameData():getSailorData()
	sailorData:receiveOwnSailors(list)
end

----拥有过的航海士
-- function rpc_client_user_get_usable_sailor_icon_list(list)
-- 	local sailorData = getGameData():getSailorData()
-- 	sailorData:setHasOwnSailr(list)
-- end

function rpc_client_port_sailor_list(idPort,idSailors,idUnlockSailors)--{id,sailor}
	local portData = getGameData():getPortData()
	local portId = portData:getPortId()
	if portId == idPort then
		local sailorData = getGameData():getSailorData()
		sailorData:receivePortSailors(idSailors,idUnlockSailors)
	end
	local tipsData = getGameData():getTipsData()
	tipsData:recieveSailorInfo(idPort, idUnlockSailors)
end

function rpc_client_sailor_buy(result,err)
	local sailorData = getGameData():getSailorData()
	sailorData:receiveRecruitSailorResult(result,err)
end

function rpc_client_sailor_add(sailorId)
	local sailorData = getGameData():getSailorData()
	sailorData:addOwnSailor(sailorId)
	local sailor = sailorData:getOwnSailorsById(sailorId)
	sailor.info = 1

end

--[[
class sailor_skill_t {
    int id;
    int level;
    int pos;
}

class sailor_attr_t {
    string attrName;
    int attrValue;
}
]]

function rpc_client_sailor_list(awaken_times,sailors)
	local sailorData = getGameData():getSailorData()
	sailorData:setAwakenTimes(awaken_times)
	for _, sailor in pairs(sailors) do
		sailorData:receiveSailorInfo(sailor)
	end
end

function rpc_client_sailor_info(sailor)
	local sailorData = getGameData():getSailorData()
	sailorData:receiveSailorInfo(sailor)
end


 --[[9 #define I_STATUS_NULL 0
 10 #define I_STATUS_APPOINT 1
 11 #define I_STATUS_LEARN 2]]
function rpc_client_sailor_status(sailorId,status)
	local sailorData = getGameData():getSailorData()
	sailorData:setSailorStatus(sailorId,status)
end

function rpc_client_sailor_use_item(result, err, itemId)
	if result == 1 then
		local item_mail_id = 209  ---密信id
		if itemId == item_mail_id then
			local str = ui_word.BACKPCAK_ITEM_USE
			Alert:warning({msg = str, size = 26})
		end

		if getUIManager():get("ClsPartnerInfoView") then
			local sailorData = getGameData():getSailorData()
			local ownSailors = 	sailorData:getOwnSailors()
			local id = getUIManager():get("ClsPartnerInfoView"):getUpLevelSailorId()
			local sailor = ownSailors[id]

			ClsDialogSequene:insertTaskToQuene(ClsSailorUpLevelEffect.new({sailor_data = sailor}))

			--getUIManager():get("ClsPartnerInfoView"):updateExpNum()
			getUIManager():get("ClsPartnerInfoView"):updateAttrPanel()
		end

		if getUIManager():get("ClsUpExpTip") then
			getUIManager():get("ClsUpExpTip"):updateUI()
		end
	else
		-- if err == 454 then  ---密信使用失败
		-- 	local errInfo = error_info[err]
		-- 	local str = errInfo.message
		-- 	Alert:warning({msg = str, size = 26})
		-- 	return
		-- end

		local errInfo = error_info[err]
		local str = nil
		if errInfo then
            str = errInfo.message
		else
			str = string.format(ui_word.COMMON_ERROR_MSG_CODE, err)
		end
		Alert:warning({msg = str, size = 26})
	end
end

function  rpc_client_sailor_skill_use_item(result, err, skillId, upgrade_result)
	if result == 1 then
		local element_mgr = require("base/element_mgr")
    	local view = element_mgr:get_element("SailorUpgradeView")
		if upgrade_result == 1 then

    		if view then
    			view:updateRightView(skillId)
    		end
		else
			view:sailorSkillLevelEffect(skillId, false)
		end
	else
	end
end

--显示技能框
function rpc_client_sailor_show_dialog(sailorId, skill, msg)
	-- local SkillDialogView = require("gameobj/skillDialog")
 --    SkillDialogView:showDialog(sailorId, skill)

    ClsDialogSequene:insertTaskToQuene(ClsSkillTipsQuene.new({sailor_id = sailorId, skillId = skill}))
end

local oneFreeTime = nil
local fiveFreeTime = nil
local curScheduler = nil

local sailorFreeRedTask_unscheduleHandler = function()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	scheduler:unscheduleScriptEntry(curScheduler)
	curScheduler = nil
	oneFreeTime = nil
	fiveFreeTime = nil
end

-- local sailorFreeRedTask_updateTaskState = function(taskKey, state) ---红点
-- 	local taskData = getGameData():getTaskData()
-- 	taskData:setTask(taskKey, state)
-- end

-- local sailorFreeRedTask_scheduleCB = function()
-- 	local curTime = os.time()
-- 	if fiveFreeTime then
-- 		if fiveFreeTime <= curTime then
-- 			sailorFreeRedTask_updateTaskState(on_off_info.RECRUIT_DIAMOND.value, true)
-- 			fiveFreeTime = nil
-- 		end
-- 	end

-- 	if not fiveFreeTime then
-- 		sailorFreeRedTask_unscheduleHandler()
-- 	end
-- end

function rpc_client_sailor_enlist_free_info(one_remain, honour_free_all_times, five_remain, activit_times, activit_all_times)--times,

	if getUIManager():isLive("clsSailorRecruit") then
		getUIManager():get("clsSailorRecruit"):setData(one_remain, honour_free_all_times, five_remain, activit_times,activit_all_times)
	end

end


---招募限时活动
function rpc_client_enlist_time_limit_huodong(huodong_Info)
	local sailorData = getGameData():getSailorData()
	sailorData:setLimitActivityInfo(huodong_Info)

	local clsSailorRecruit = getUIManager():get("clsSailorRecruit")
	if not tolua.isnull(clsSailorRecruit) then
		clsSailorRecruit:updateLimitActivitView()
		clsSailorRecruit:limitActivityWillStop()		
	end
end

function rpc_client_sailor_fire(result, error, sailor_ids)
	if result == 1 then
		local sailorData = getGameData():getSailorData()
		for k,v in pairs(sailor_ids) do
			sailorData:delOwnSailor(v)
			--sailorData:delFullStarSailor(v)
		end

	else
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

    if getUIManager():isLive("ClsSailorListView") then
        getUIManager():get("ClsSailorListView"):updateSailorList()
    end

    local ClsPartnerInfoView = getUIManager():get("ClsPartnerInfoView")
    if not tolua.isnull(ClsPartnerInfoView) then
        ClsPartnerInfoView:close()
    end

    local clsAppointSailorUI = getUIManager():get("clsAppointSailorUI")
    if not tolua.isnull(clsAppointSailorUI) then
        clsAppointSailorUI:closeSailorViewCB()
    end

end

function rpc_client_sailor_fire_reward(rewards,result, error)

	if #rewards >0 then
		Alert:showCommonReward(rewards)
	end

	local ClsPartnerInfoView = getUIManager():get("ClsPartnerInfoView")
	if not tolua.isnull(ClsPartnerInfoView) then
		ClsPartnerInfoView:updateStarView()
	end

end

----满星解雇奖励
function rpc_client_sailor_full_star_reward(rewards, sailorId, result, error)

	-- print("===========满星解雇奖励=============",sailorId)
	-- table.print(rewards)
	local clsSailorRecruit = getUIManager():get("clsSailorRecruit")
	local clsSailorRecruitView = getUIManager():get("clsSailorRecruitView")

	if  not tolua.isnull(clsSailorRecruit)  or not tolua.isnull(clsSailorRecruitView) then
		local sailorData = getGameData():getSailorData()
		sailorData:setFullStarReward(rewards,sailorId)
		return
	end
	Alert:showCommonReward(rewards)
	Alert:warning({msg = ui_word.SAILOR_FULL_STAR_REWARD_TIPS, size = 26})
end


function rpc_client_sailor_upstep(sailor_id,rewards, result, error)
	if result == 1 then
		local sailorData = getGameData():getSailorData()

		if rewards then
			for k,v in pairs(rewards) do
				local item_name = item_info[v.id].name
				Alert:warning({msg = string.format(ui_word.SAILOR_REWRDS_UPSTEP, v.amount, item_name), size = 26})
			end
		end

		local ClsPartnerInfoView = getUIManager():get("ClsPartnerInfoView")
		if ClsPartnerInfoView and not tolua.isnull(ClsPartnerInfoView) then
			ClsPartnerInfoView:upStepRefreshUI()
		end

		local ClsSailorListView = getUIManager():get("ClsSailorListView")
	    if ClsSailorListView and not tolua.isnull(ClsSailorListView)  then
	        ClsSailorListView:closeSailorViewCB()
			ClsSailorListView:updateStarNum()
	    end


		local clsAppointSailorUI = getUIManager():get("clsAppointSailorUI")
		if clsAppointSailorUI and not tolua.isnull(clsAppointSailorUI) then
		    clsAppointSailorUI:closeSailorViewCB()
		end
	else
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end
end

----升星名仕活动
function rpc_client_sailor_upstar_mjms_huodong(oldSailor,sailorId)
	Alert:warning({msg = ui_word.SAILOR_MINGSHI_MISSION, size = 26, color =ccc3(dexToColor3B(COLOR_RED))})

	local sailorData = getGameData():getSailorData()
	--local sailor = sailorData:getFireSailorId()
	sailorData:delOwnSailor(oldSailor)
	getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, sailor_id)
end

----航海士设置宝物装备
function rpc_client_sailor_set_baowu(errno,pos,baowuId)
	if errno == 0 then

	else
		local errorRes = error_info[errno]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

end
----替换装备
function rpc_client_sailor_change_baowu(errno,pos)
	if errno == 0 then
	else
	 	local errorRes = error_info[errno]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

end


-- 水手岗位数据，由服务端主动下发通知
-- class job_room_t {
--     int job;
--     int sailorId;
-- }
function rpc_client_job_room_info( job_list )
	local sailor_data = getGameData():getSailorData()
	sailor_data:setSailorJobData(job_list)
end


-- 水手传记系统
function rpc_client_memoir_mission_open(error)
	if error == 0 then
	else
		Alert:warning({msg =error_info[error].message, size = 26})
	end
end

function rpc_client_memoir_mission_refresh(sailor, chapter, status)

end

--水手触发技能的东东
function rpc_client_active_skills_info( active_skills)
    local skills_info = {}
    for k, v in pairs(active_skills) do
        --兼容以前的格式
        local info = {}
        info.id = v.skillId
        info.level = v.skillLevel
        info.sailorId = v.sailorId
        skills_info[info.id] = info
    end
    getGameData():getSailorData():setRoomSailorsSkill(skills_info)
end


function rpc_client_sailor_exp_change(sailorId,exp)
	local tag = 1
	local attr_table ={}
	attr_table["exp"] = exp
    attr_table["tag"] = tag
    attr_table["id"] = sailorId
	local sailorData = getGameData():getSailorData()
	sailorData:pushUpLevelSeque(attr_table)
end

function rpc_client_sailor_attr_change(sailorId, lv, curExp, attr_diff)
	local tag = 2
	local attr_table ={}
	attr_table["exp"] = curExp
    attr_table["tag"] = tag
    attr_table["id"] = sailorId
    attr_table["lv"] = lv
    attr_table["attr"] = attr_diff
	local sailorData = getGameData():getSailorData()
	sailorData:pushUpLevelSeque(attr_table)

end
function rpc_client_have_memoir_mission(sailor_id)
	local sailorData = getGameData():getSailorData()
	sailorData:saveSailorTaskID(sailor_id)
end

function rpc_client_memoir_mission_cancel(mission_id, errors)
	if errors == 0 then
		local playerData = getGameData():getPlayerData()
		if playerData.missionInfo then
			playerData.missionInfo[mission_id] = nil
			EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)

			local missionMainUI = ElementMgr:get_element("ClsMissionMainUI")
			if missionMainUI and not tolua.isnull(missionMainUI) then
				missionMainUI:updateMissionList()
			end
		end
		-- local dialogSequence = require("gameobj/mission/dialogSequence")
		-- local dialogType = dialogSequence:getDialogType()
		-- dialogSequence:deleteDialogTable({id = mission_id, dialogType = dialogType.mission})  --新任务
	end
end

function rpc_client_mission_random_reward(error, rewards)
	local sailor_data = getGameData():getSailorData()
	sailor_data:setSailorMissionReward(rewards)
end


---探索界面航海士升级

function rpc_client_explore_upgrade(sailorId)
	--print("=================探索界面航海士升级============")
    local my_uid = getGameData():getPlayerData():getUid()
    local explore_layer = getExploreLayer()
    if not tolua.isnull(explore_layer) then
        local ship = explore_layer:getShipsLayer():getShipWithMyShip(my_uid)

		local sailor_data = getGameData():getSailorData()
		local explore_sailor_up_level = sailor_data:getExploreSailorUpLevel()
		if ship and explore_sailor_up_level then
			sailor_data:setExploreSailorUpLevel(false)
			ship:createSailorUpLevelEffect(sailorId, function () 
				local sailor_data = getGameData():getSailorData()
				sailor_data:setExploreSailorUpLevel(true)
			end)

		end
		-- if ship then
		-- 	print("=====================rpc_client_explore_upgrade=========插入===")
		-- 	ClsDialogSequene:insertTaskToQuene(ClsExploreSailorUpLevel.new({sailor_id = sailorId , my_ship = ship}))
		-- end
    end

end


-----水手觉醒
function rpc_client_sailor_awake(oldSailor,newSailor, rewards, times, error)
	if error == 0 then
		local sailorData = getGameData():getSailorData()
		sailorData:setAwakenTimes(times)

		if newSailor ~= 0 then  ---觉醒了航海士

			if #rewards > 0 then  ---觉醒到的航海士已有
				--print("============觉醒到的航海士已有======")
				Alert:warning({msg = ui_word.SAILOR_AWAKEN_TIPS , size = 26})
				if oldSailor ~= 0 then
					sailorData:delOwnSailor(oldSailor)
				end
				
			else
				--print("============觉醒到的xin航海士======")
				if oldSailor ~= 0 then
					sailorData:delOwnSailor(oldSailor)
				end
			end	
			getUIManager():create("gameobj/partner/clsPartnerAwakenEffect",{}, newSailor,rewards)		
			local ClsPartnerAwakenTips  = getUIManager():get("ClsSailorAwakeView")
			if not tolua.isnull(ClsPartnerAwakenTips) then
				ClsPartnerAwakenTips:close()
			end
			local ClsSailorAwakeList  = getUIManager():get("ClsSailorAwakeList")
			if not tolua.isnull(ClsSailorAwakeList) then
				ClsSailorAwakeList:updateList()
			end
			

		else ---觉醒失败
			--print("======================觉醒失败")
			Alert:warning({msg = ui_word.SAILOR_AWAKEN_FAILURE , size = 26})
			local ClsPartnerAwakenTips  = getUIManager():get("ClsSailorAwakeView")
			if not tolua.isnull(ClsPartnerAwakenTips) then
				ClsPartnerAwakenTips:updateUI()
			end
			local ClsSailorAwakeList  = getUIManager():get("ClsSailorAwakeList")
			if not tolua.isnull(ClsSailorAwakeList) then
				ClsSailorAwakeList:updateStarNum()
			end

		end

	else
		local errorRes = error_info[error]
		if errorRes then
			Alert:warning({msg = errorRes.message, size = 26})
		end
	end

end

----招募限时活动信息
function rpc_client_gold_enlist_limit_huodong_info(info)
	local sailorData = getGameData():getSailorData()
	sailorData:setLimitRewardInfo(info)
	local clsSailorRecruit = getUIManager():get("clsSailorRecruit")
	if not tolua.isnull(clsSailorRecruit) then
		clsSailorRecruit:updateLimitActivitView()
	end

end

---领取限时活动奖励
function rpc_client_gold_enlist_limit_huodong_reward(rewards,error)
	if error == 0 then
		ClsDialogSequene:insertTaskToQuene(ClsSailorWineRecuitQuene.new({sailor_id = rewards[1].id}))
	else
		Alert:warning({msg = error_info[error].message, size = 26})
	end

end


