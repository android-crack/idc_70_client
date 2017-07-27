local mission_play_cfg = {
	scene_cfg = "juqing3",
	active_camera = "2006C",
	--waiting_close = {"role_ship_06_1", "move"},
	delay_close_time = 7.9,
	bg_music = "PLOT_STORY_3",
	u3d_anim = {
			{"2006C"},
		},
	model_anim = {
		[1] = {"role_ship_06_1", "move"},
		[2] = {"role_ship_06_2", "move"},
		[3] = {"role_ship_06_3", "move"},
		[4] = {"role_ship_06_4", "move"},
		[5] = {"role_ship_06_5", "move"},
		[6] = {"role_ship_06_6", "move"},
		[7] = {"role_ship_06_7", "move"},
		},
}

return mission_play_cfg