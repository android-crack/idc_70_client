battle_config = table.read_only_table{
	-- 客户端与服务端同步
	fight_type_battle = 1,            			-- 普通战斗
	fight_type_arena = 4,             			-- 竞技场
	fight_type_portPve = 6,           			-- Pve
	fight_type_relicBattle = 7,       			-- 遗迹战斗
	fight_type_guild_boss = 8,        			-- 公会boss
	fight_type_friend = 10,          		 	-- 好友切磋
	fight_type_guild_explore = 11,    			-- 公会战战斗
	fight_type_sea_boss_explore = 12, 		   	-- 探索boss海域战斗
	fight_type_guild_player_attack = 13, 	   	-- 商会据点战玩家单独攻击
	fight_type_team_arena = 15,					-- 多人战斗

	-- pve
	fight_type_auto_play = 100,        			-- 演示战斗
	fight_type_pve_elite_battle = 101,			-- 精英战役
	fight_type_pve_relic_battle = 102,			-- 遗迹战斗
	fight_type_pve_bounty_battle = 103, 		-- 悬赏战斗
	fight_type_pve_mission_battle = 104, 		-- 主线战斗
	fight_type_pve_treasure = 105,				-- 藏宝图
	fight_type_area_boss = 106,					-- 海域boss 七海追击
	fight_type_pve_seaforce = 108,				-- 任务巡逻海盗

	fight_type_plunder = 200,           		-- 掠夺

	-- 客户端自用
	fight_type_same_guild_boss = 996,			-- 
	fight_type_recording = 995,					-- 战斗录像播放
	fight_type_test = 996,              		-- F7测试
	fight_type_relic_sailor_fight = 998, 	   	-- 遗迹航海士单挑
	fight_type_plot_battle = 999,              	-- 剧情战斗,客户端用
	fight_type_explore_copy_result = 1000,     	-- 探索副本，结算界面和战斗结算界面类似

	---------- 战斗时间 ----------
	battle_time = 120,
	---------- 战斗时间 ----------

	---------- 近战技能，远战技能 ----------
	near_skill_id = 1,
	far_skill_id = 2,
	---------- 近战技能，远战技能 ----------

	---------- 嘲讽、突击 ----------
	chaofeng = "chaofeng",
	tuji = "tuji",
	---------- 嘲讽、突击 ----------
	
	---------- 输赢 ----------
	our_win = 1,
	our_lose = 2,
	---------- 输赢 ----------

	---------- 阵营 ----------
	team_id_min = 1,
	--玩家方
	default_team_id = 1, 
	--防守方
	target_team_id = 2,
	--中立方(1,2不能攻击)
	neutral_team_id = 3,
	--敌对方(1,2都能攻击)
	enemy_team_id = 4,
    -- 玩家友方
	friend_team_id = 5, 
	
	team_id_max = 5,
	---------- 阵营 ----------

	---------- 实时战斗转态 ----------
    state_unknow = -1,
    -- 初始化，等待其他机器准备完毕
    state_record_init = 0,
    -- 所有机器都ready了，通常状态
    state_record_already = 1,
    -- 主机暂停
    state_record_pause = 2,

    -- 等待主机通知开始
    state_playing_init = 0,
    -- 主机发送完already，才设置为waite_already 
    state_playing_wait_already = 1,
    -- 主机告诉所有机器OK才能跑
    state_playing_already = 2,
    -- 暂停
    state_playing_pause = 3,
    ---------- 实时战斗转态 ----------

	---------- 近战距离 ----------
	near_dist_min = 170,
	near_dist_mid = 190,
	near_dist_max = 220,
	---------- 近战距离 ----------

	---------- 伤害类型 ----------
	damage_type_far = 1,
	damage_type_near = 2,
	damage_type_all = 3,
	---------- 伤害类型 ----------

	battle_end_rotate_cam_tm = 3,

	---------- 分身TAG ----------
	FEN_SHEN_TAG = "fenshen",
	---------- 分身TAG ----------

	---------- 战斗资源 ----------
	user_touch = "tx_dianji",
	destination = "tx_dianji_yellow",
	cloud_1 = "explorer/explore_yun1.png",
	cloud_2 = "explorer/explore_yun1.png",
	gousuo_1 = "tiegou1",
	gousuo_2 = "tiegou",
	---------- 战斗资源 ----------
}
