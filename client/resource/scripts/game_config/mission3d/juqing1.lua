local sceneData = {
	["sky_xuanzhuang"] = {
		res = "sky_xuanzhuang",
		type = "model",
		transform = {
			position = {-8.869595, 45.3, 6.161021},
			rotation = {0, 0, 0, 1},
			scale = {1.875796, 1.875795, 1.875795},
		},
		children = {
			["sky"] = {
				res = "sky",
				type = "model",
				transform = {
					position = {2.369595, -26.50186, -2.761021},
					rotation = {0, -0.6893306, 0, 0.7244469},
					scale = {1.725374, 1.834121, 1.752612},
				},
				materials = {"sky_2004", },
			},
		},
		animations = {"sky_xuanzhuang_jq", },
	},
	["effects_juqing1"] = {
		res = "effects_juqing1",
		type = "model",
		transform = {
			position = {0, 0, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["shuibo2003"] = {
				res = "boat_shuibo",
				type = "particleSystem",
				transform = {
					position = {-7.97, 8.197929, 2.09},
					rotation = {0, 0.05734012, 0, 0.9983547},
					scale = {1, 1, 1},
				},
			},
			["daoguang"] = {
				res = "daoguang",
				type = "particleSystem",
				transform = {
					position = {-8.87, 9.706, -0.432},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["glow"] = {
				res = "glow",
				type = "particleSystem",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["guangyun"] = {
				res = "guangyun",
				type = "particleSystem",
				transform = {
					position = {-9.036, 9.772, -0.427},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["langhua"] = {
				res = "langhua",
				type = "particleSystem",
				transform = {
					position = {-8.129, 9.432, -0.389},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["sun_glow"] = {
				res = "sun_glow",
				type = "particleSystem",
				transform = {
					position = {-1.82, 1.6, -1.84},
					rotation = {0.004119443, -0.0907765, -0.0003754532, 0.9958627},
					scale = {1, 1, 1},
				},
			},
			["tukoushui"] = {
				res = "tukoushui",
				type = "particleSystem",
				transform = {
					position = {-8.734, 9.742, -0.517},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2004C"] = {
		type = "camara",
		transform = {
			position = {13.05945, 11.37792, 156.3162},
			rotation = {-0.00411934, 0.09077693, 0.0003754946, 0.9958627},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.776965,
		fieldOfView = 40,
		animations = {"2004", },
		children = {
			["sunshine_orange"] = {
				res = "sunshine_orange",
				type = "particleSystem",
				transform = {
					position = {-10.9, 8.16, -6.369993},
					rotation = {0.004119443, -0.0907765, -0.0003754532, 0.9958627},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["WaterSurface"] = {
		type = "sea",
		transform = {
			position = {-9, 8.231198, 12.6},
			rotation = {0, 0, 0, 1},
			scale = {35.77131, 0.3577132, 35.77131},
		},
		materials = {"juqing01", },
	},
	["GameObject"] = {
		type = "model",
		transform = {
			position = {-8.75303, 8.246344, -2.302818},
			rotation = {0, 0.9940506, 0, -0.1089189},
			scale = {1, 1, 1},
		},
		children = {
			["2004"] = {
				res = "2004",
				type = "model",
				transform = {
					position = {0, -0.006, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"2004", },
			},
			["role_ship_04"] = {
				res = "role_ship_04",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_04", },
			},
		},
	},
}

return sceneData
