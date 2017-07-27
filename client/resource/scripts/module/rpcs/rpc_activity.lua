local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")


-- class activity_info_t {
--     int id;
		--     int remain_time;      距离结束剩余时间
--     int status;           状态
--     int times;             剩余次数
		--     int start_remain_time; 距离开始剩余时间
		--     int start_real_time;  活动开始的时间
--     int all_times;    总次数
		--     int start_time;   开始时间
		--     int end_time;     结束时间
-- }
-- void rpc_client_get_activity_list(int uid, activity_info_t* list);
function rpc_client_get_activity_list(activity_list)
	local activity_data = getGameData():getActivityData()
	activity_data:setActivityList(activity_list)

	local activity_main = getUIManager():get("ClsActivityMain")
	if not tolua.isnull(activity_main) then
		local doing_activity_view = activity_main:getRegChild("clsDoingActivityTab")
		if not tolua.isnull(doing_activity_view) then
			doing_activity_view:updateView()
		end
	end
end

--海神的挑战活动获得奖励提示
function rpc_client_seagod_gate_reward( rewards )
	local activity_data = getGameData():getActivityData()

	for k,v in pairs(rewards) do
		if v.type == ITEM_INDEX_SAILOR then
			activity_data:setSeagodRewardId(v.id)
		end
	end
	Alert:showCommonReward(rewards)
end

--海神下发玩家确认
function rpc_client_seagod_enter_confirm(is_leader)
	local max_grade = 0
	local my_grade = 0
	local is_show_level_tip = nil
	local my_team_info = getGameData():getTeamData():getMyTeamInfo()
	local my_uid = getGameData():getPlayerData():getUid()
	if not my_team_info then return end
	for _, info in pairs(my_team_info.info) do
		if info.uid == my_uid then
			my_grade = info.grade
		end
		if info.grade > max_grade then
			max_grade = info.grade
		end
	end
	-- if max_grade - my_grade >= 5 then is_show_level_tip = true end
	local function accept_call_back()
		local activity_data = getGameData():getActivityData()
		activity_data:acceptSeaGodRequst(true)
	end
	if is_leader ~= 1 then
		Alert:showBayInvite(nil, accept_call_back, function()
			local activity_data = getGameData():getActivityData()
			activity_data:acceptSeaGodRequst()
		end, nil, nil, nil, ui_word.SEA_GOD_INVEST_TIPS, nil, nil, nil, nil,
		ui_word.SEA_GOD_INVEST_TIPS_LEADER, is_show_level_tip)
	else
		Alert:showBayInvite(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
			ui_word.SEA_GOD_INVEST_TIPS_LEADER, is_show_level_tip)
	end
	
end

function rpc_client_seagod_enter_confirm_refuse(uid)
	local my_uid = getGameData():getPlayerData():getUid()
	if my_uid == uid then
		return
	end
	local team_data = getGameData():getTeamData()
	local info = team_data:getTeamUserInfoByUid(uid)
	getUIManager():close("AlertShowBayInvite")
	
	if info then
		local str_tips = string.format(ui_word.STR_COPY_SCENE_DECLINE_TIPS1, info.name)
		Alert:warning({msg = str_tips})
	end
	
end

function rpc_client_huodong_open_tip(info)
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	local ClsPanelPopView = require("gameobj/quene/clsPanelPopView")
	ClsDialogSequence:insertTaskToQuene(ClsPanelPopView.new("unlock_activity_anounce", {data = info}))
end


function rpc_client_sailor_awake_huodong(activity_info)
	local time = os.time()
	local activity_data = getGameData():getActivityData()
	activity_info.time = time
	activity_data:setSailorAwakeActivityInfo(activity_info)
	if getUIManager():isLive("ClsActivityMain") then
		local main_tab = getUIManager():get("ClsActivityMain"):getRegChild("ClsSailorAwake")
		if not tolua.isnull(main_tab) then
			main_tab:updateView()
		end
	end
	if getUIManager():isLive("ClsSailorAwakeView") then
		local ClsSailorAwakeView = getUIManager():get("ClsSailorAwakeView")
		if not tolua.isnull(ClsSailorAwakeView) then
			ClsSailorAwakeView:updateUI()
		end
	end
end