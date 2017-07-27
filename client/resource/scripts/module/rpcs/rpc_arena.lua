local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local error_info = require("game_config/error_info")

--下发竞技场信息
function rpc_client_arena_info(info)
	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if not tolua.isnull(arena_ui) then
		arena_ui:tryShowCommonUI()
	end
	local arena_data = getGameData():getArenaData()
    arena_data:setArenaInfo(info)
end

--匹配的对手信息
function rpc_client_arena_match(err, info)
	if err == 0 then
		local arena_data = getGameData():getArenaData()
    	arena_data:setMatchInfo(info)
    else
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
		getUIManager():close("ClsShieldLayer")
		local arena_ui = getUIManager():get("ClsArenaMainUI")
		if not tolua.isnull(arena_ui) then
			arena_ui:resetView()
		end
    end
end

--领取每日的俸禄
function rpc_client_arena_take_day_reward(rewards)
	Alert:showCommonReward(rewards)
end

--段位升级的奖励
function rpc_client_arena_take_stage_reward(stage_id, rewards)
	local arena_data = getGameData():getArenaData()
	arena_data:setStageUpReward(stage_id, rewards)
end

function rpc_client_arena_task_reward(stage_id, task_count, task_exp)
	
end

function rpc_client_arena_day_reward_preview(rewards)
	local arena_data = getGameData():getArenaData()
	arena_data:setDayReward(rewards)
end

function rpc_client_arena_target_info(info)
	local arena_data = getGameData():getArenaData()
	arena_data:setTargetInfo(info)
end

function rpc_client_arena_reset_target()
	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if not tolua.isnull(arena_ui) then
		arena_ui:setResetBtnVisible(false)
		arena_ui:startMatchTarget()
	end
end


function rpc_client_arena_status(is_completed, has_reward)
	local arena_data = getGameData():getArenaData()
	if is_completed == 0 then --未完成
		arena_data:setActivityArenaStatus(0)
	elseif is_completed == 1 and has_reward == 1 then --完成了但是没领奖
		arena_data:setActivityArenaStatus(1)
	
	elseif is_completed == 1 and has_reward == 0 then  --完成了也领奖了
		arena_data:setActivityArenaStatus(2)
	end
end

function rpc_client_legend_arena_info(legend_info)
	local arena_ui = getUIManager():get("ClsArenaMainUI")
	if not tolua.isnull(arena_ui) then
		arena_ui:tryShowLegendUI()
	end

	local arena_data = getGameData():getArenaData()
	arena_data:setLegendPlayerInfo(legend_info)
	local arena_legend_ui = getUIManager():get("ClsArenaLegendUI")
	if not tolua.isnull(arena_legend_ui) then
		arena_legend_ui:updataUI()
	end
end

function rpc_client_legend_arena_fight_win(old_rank, new_rank, attack_name)
	local arena_data = getGameData():getArenaData()
	arena_data:setLegendChangePlayerInfo({old_rank = old_rank, new_rank = new_rank, attack_name = attack_name})
end
