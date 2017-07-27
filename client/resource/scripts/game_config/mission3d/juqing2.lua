local sceneData = {
	["sky_xuanzhuang"] = {
		res = "sky_xuanzhuang",
		type = "model",
		transform = {
			position = {7.08, -0.9000015, -33},
			rotation = {0, -0.2338221, 0, 0.9722794},
			scale = {1.978209, 1.978209, 1.978209},
		},
		children = {
			["sky"] = {
				res = "sky",
				type = "model",
				transform = {
					position = {7.08, -2.7, -33},
					rotation = {0, 0.1967573, 0, 0.9804522},
					scale = {1.725374, 1.834121, 1.752612},
				},
				materials = {"sky_2005", },
			},
		},
	},
	["juqing2_effects"] = {
		res = "juqing2_effects",
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
					position = {0.29, 8.49, -4.3},
					rotation = {-0.01074076, -0.9992834, -0.001006525, -0.03628256},
					scale = {1, 1, 1},
				},
			},
			["juqing2_rain"] = {
				res = "tx_juqing2_rain",
				type = "particleSystem",
				transform = {
					position = {0, 10.76, 0.68},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["tx_juqing2_thunder"] = {
				res = "tx_juqing2_thunder",
				type = "particleSystem",
				transform = {
					position = {0, 10, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2005C"] = {
		type = "camara",
		transform = {
			position = {0.6501314, 10.1644, -1.273511},
			rotation = {-0.07582406, 0.8650261, 0.3644792, 0.3363562},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.778189,
		fieldOfView = 40,
		animations = {"2005", },
		children = {
		},
	},
	["WaterSurface"] = {
		type = "sea",
		transform = {
			position = {4.320556, 8.771, -5.509},
			rotation = {0, 0, 0, 1},
			scale = {17.73361, 1, 17.73361},
		},
		materials = {"juqing02", },
	},
	["juqing2_model"] = {
		type = "model",
		transform = {
			position = {0, 8.62, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["role_ship_05"] = {
				res = "role_ship_05",
				type = "model",
				transform = {
					position = {0, -0.184, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_05", },
			},
			["2005_jp"] = {
				res = "2005_jp",
				type = "model",
				transform = {
					position = {0.488, 1.2686, -1.096},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"2005_jp", },
			},
			["2005"] = {
				res = "2005",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"2005", },
			},
		},
	},
}

return sceneData
