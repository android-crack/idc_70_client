-- 战斗录像
-- ---------------------------

local battleRecording = {}

battleRecording.VIEW_TO_ID = 
{
	["add_effect"] = 1,
	["add_scene_effect"] = 2,
	["battle_alert"] = 3,
	["battle_autofight"] = 4,
	["battle_change_control_ship"] = 5,
	["battle_create_goal"] = 6,
	["battle_enter_scene"] = 7,
	["battle_escape"] = 8,
	["battle_fenshen"] = 9,
	["battle_forge_weather"] = 10,
	["battle_guide_point"] = 11,
	["battle_play_plot_end"] = 12,
	["battle_play_plot"] = 13,
	["battle_scene_shake"] = 14,
	["battle_set_buff"] = 15,
	["battle_set_server"] = 16,
	["battle_set_target"] = 17,
	["battle_set_technique"] = 18,
	["battle_skip_plot"] = 19,
	["battle_stop_ship"] = 20,
	["battle_use_skill"] = 21,
	["battle_use_skill_result"] = 22,
	["change_team"] = 23,
	["del_effect"] = 24,
	["del_util_effect"] = 25,
	["drown"] = 26,
	["frame_sync"] = 27,
	["hide_effect"] = 28,
	["look_at_point_animation"] = 29,
	["play_effect"] = 30,
	["play_effect_music"] = 31,
	["release"] = 32,
	["say"] = 33,
	["set_ban_rotate"] = 34,
	["set_ban_turn"] = 35,
	["set_ship_hp"] = 36,
	["set_speed"] = 37,
	["set_speed_rate"] = 38,
	["set_turn_speed"] = 39,
	["set_win_side"] = 40,
	["show_damage_word"] = 41,
	["state_client_all_ready"] = 42,
	["state_client_ready"] = 43,
	["translate_animation"] = 44,
	["util_effect"] = 45,
	["set_pos"] = 46,
	["del_scene_effect"] = 47,
	["battle_use_skill_return"] = 48,
	["battle_set_time"] = 49,
	["battle_add_skill"] = 50,
	["battle_set_data"] = 51,
	["battle_pvp_kill_tips"] = 52,
	["battle_sailor_slogan"] = 53,
	["add_ship_effect"] = 54,
	["del_ship_effect"] = 55,
	["show_cloud"] = 56,
	["sync_move_to"] = 57,
	["battle_show_miss"] = 58,
	["battle_story_mode"] = 59,
	["battle_camera_follow"] = 60,
	["battle_add_status"] = 61,
	["battle_clear_skill_cd"] = 62,
	["battle_set_skill_cd"] = 63,
}

battleRecording.ID_TO_VIEW = {}

for view, id in pairs(battleRecording.VIEW_TO_ID) do
	battleRecording.ID_TO_VIEW[id] = view
end

local ALLOW_FRAME_DIFF = 30 

-- 开始战斗是的初始化
-- 初始化数据
function battleRecording:startBattle()
	self:setCurrentFrame(0)
	self:setServerFrame(0)
end

function battleRecording:showRecord()
	local cur_frame = self:getCurrentFrame()

	local battle_data = getGameData():getBattleDataMt()

	local battle_recording = battle_data:GetData("recording_data")

	if battle_recording and battle_recording[cur_frame] then
		for k, v in ipairs(battle_recording[cur_frame]) do
			v.view:Show()
		end
	end
end

function battleRecording:incFrame(not_normal)

	local battle_data = getGameData():getBattleDataMt()

	self:setCurrentFrame(self:getCurrentFrame() + 1)

	if not not_normal then
		-- 自增服务器未帧同步帧数
		battle_data:incNoSetServerFrame()
	end

	self:showRecord()
end

-- 心跳
function battleRecording:heartBeat()
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsPlaying() then return end
	if not battle_data:BattleIsRunning() then 
		-- if battle_data:getNoSetServerFrame() >= ALLOW_FRAME_DIFF then
			return 
		-- else
			-- battle_data:GetTable("battle_layer").setBattlePaused(false)
		-- end
	end

	self:incFrame()
	
	local cur_frame = self:getCurrentFrame()
	local server_frame = self:getServerFrame()

	-- 如果本地帧数跟服务器帧数差别太大，如果超过服务器太多，自动暂停减帧
	if battle_data:getNoSetServerFrame() >= ALLOW_FRAME_DIFF then 
		-- battle_data:GetTable("battle_layer").setBattlePaused(true)
		-- print("本地比服务器端播放速度大于", ALLOW_FRAME_DIFF, "帧", cur_frame, server_frame)
		return
	end
		
	-- 补帧
	if cur_frame < server_frame then
		for i = cur_frame, server_frame do
			-- print("本地比服务器端播放速度慢:", cur_frame, server_frame, i)
			self:incFrame(true)
		end
	end

	local ships = battle_data:GetShips()
	for id, ship_obj in pairs(ships) do
		if not ship_obj:is_deaded() then
			ship_obj:checkServerPos()
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
local function recordData(cur_frame, event, view)
	local battle_data = getGameData():getBattleDataMt()
	local recording_data = battle_data:GetData("recording_data")
	if not recording_data then
		recording_data = {}
	end
	if not recording_data[cur_frame] then
		recording_data[cur_frame] = {}
	end
	recording_data[cur_frame][#recording_data[cur_frame] + 1] = {event = event, view = view}
	battle_data:SetData("recording_data", recording_data)
end

function rpc_client_fight_view(session, source_id, id, args)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:GetBattleSwitch() then return end

	if battle_data:getSession() ~= session then return end

	local path = "gameobj/battle/view/" .. battleRecording.ID_TO_VIEW[id]
	local view = require(path).new()
	local cur_frame = view:unserialize(args)

	view:setSourceId(source_id)
	
	view:gotProtcol(cur_frame)

	-- if cur_frame <= battle_data:getCurrentFrame() then
	view:Show()
	--  return 
	-- end

	-- recordData(cur_frame, event, view)
end

------------------------------------------------------------------------------------------------------------------------
function battleRecording:getCurrentFrame()
	local battle_data = getGameData():getBattleDataMt()
	return battle_data:getCurrentFrame() or 0
end

function battleRecording:setCurrentFrame(value)
	local battle_data = getGameData():getBattleDataMt()
	battle_data:setCurrentFrame(value)
end

function battleRecording:getServerFrame()
	local battle_data = getGameData():getBattleDataMt()
	return battle_data:getServerFrame()
end

function battleRecording:setServerFrame(value)
	local battle_data = getGameData():getBattleDataMt()
	battle_data:setServerFrame(value)
end
------------------------------------------------------------------------------------------------------------------------
function battleRecording:recordVarArgs(event, ...)
	local battle_data = getGameData():getBattleDataMt()

	local cur_frame = self:getCurrentFrame()

	local path = "gameobj/battle/view/" .. event
	local view = require(path).new(...)

	local serialize_params = view:serialize(cur_frame)

	view:record(self)

	battle_data:broadcastMsg(event, serialize_params)
end

return battleRecording
