local sceneData = {
	["sky_xuanzhuang"] = {
		res = "sky_xuanzhuang",
		type = "model",
		transform = {
			position = {-8.869595, 12.40186, 6.161021},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
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
				materials = {"sky_2001", },
				animations = {"sky", },
			},
		},
		animations = {"sky_xuanzhuang", },
	},
	["role_ship_01"] = {
		res = "role_ship_01",
		type = "model",
		transform = {
			position = {-12.09941, 8.246344, -2.297531},
			rotation = {0, 0.959772, 0, 0.2807806},
			scale = {0.8147214, 0.8147214, 0.8147214},
		},
		materials = {"role_ship_01", },
		animations = {"role_ship_01_light", },
	},
	["effects"] = {
		res = "effects",
		type = "model",
		transform = {
			position = {0, 0, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["shuibo2001"] = {
				res = "boat_shuibo",
				type = "particleSystem",
				transform = {
					position = {-4.94, 8.26793, 1.4},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["shuibo2002"] = {
				res = "boat_shuibo",
				type = "particleSystem",
				transform = {
					position = {-10.11633, 8.277929, 2.31625},
					rotation = {0, -0.1953128, 0, 0.980741},
					scale = {1, 1, 1},
				},
			},
			["shuibo2003"] = {
				res = "boat_shuibo",
				type = "particleSystem",
				transform = {
					position = {-13.69633, 8.197929, 0.56625},
					rotation = {0, -0.2854634, 0, 0.9583896},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2003C"] = {
		type = "camara",
		transform = {
			position = {-9.32, 9.750215, 10.40873},
			rotation = {0.04787527, 0, 0, 0.9988533},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.777419,
		fieldOfView = 40,
		animations = {"2003", },
	},
	["2003"] = {
		res = "2003",
		type = "model",
		transform = {
			position = {-4.9, 8.094, -1.602},
			rotation = {0, 0.999965, 0, 0.008362629},
			scale = {1, 1, 1},
		},
		materials = {"2003", },
		animations = {"2003_light", },
	},
	["2002"] = {
		res = "2002",
		type = "model",
		transform = {
			position = {-8.829414, 8.042344, -0.748531},
			rotation = {0, 0.9820424, 0, 0.1886601},
			scale = {1.025314, 1.025314, 1.025314},
		},
		materials = {"2002", },
		animations = {"2002_light", },
	},
	["mountain"] = {
		res = "mountain",
		type = "model",
		transform = {
			position = {-9.100952, 10.83984, -4.789063},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["Free_Mountain"] = {
				res = "Free_Mountain",
				type = "model",
				transform = {
					position = {16.78, -1.3, -16.74},
					rotation = {0, -0.5093163, 0, 0.8605794},
					scale = {0.03649491, 0.03649496, 0.03649496},
				},
				materials = {"Free_Mountain", },
			},
			["Free_Mountain1"] = {
				res = "Free_Mountain",
				type = "model",
				transform = {
					position = {18.45, -2.85, -40.53},
					rotation = {0, 0.9641364, 0, 0.2654072},
					scale = {0.03649492, 0.03649496, 0.03649496},
				},
				materials = {"Free_Mountain", },
			},
			["Free_Mountain2"] = {
				res = "Free_Mountain",
				type = "model",
				transform = {
					position = {-16.94, -0.52, -14.14},
					rotation = {0, -0.959694, 0, 0.281047},
					scale = {0.04457089, 0.04457092, 0.04457092},
				},
				materials = {"Free_Mountain", },
			},
			["Free_Mountain3"] = {
				res = "Free_Mountain",
				type = "model",
				transform = {
					position = {-14.48, -0.8333797, -25.95},
					rotation = {0, -0.6472083, 0, 0.7623132},
					scale = {0.03649491, 0.03649497, 0.03649496},
				},
				materials = {"Free_Mountain", },
			},
			["Free_Mountain4"] = {
				res = "Free_Mountain",
				type = "model",
				transform = {
					position = {39.01593, 0.8000002, -56.08348},
					rotation = {0, 0.04629825, 0, -0.9989277},
					scale = {0.05158609, 0.07680726, 0.05158613},
				},
				materials = {"Free_Mountain", },
			},
		},
		animations = {"mountain", },
	},
	["2003effects"] = {
		res = "2003effects",
		type = "model",
		transform = {
			position = {0, 0, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["tx_thunder"] = {
				res = "tx_thunder",
				type = "particleSystem",
				transform = {
					position = {-6.99, 10.73, -4.18},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["tx_rain"] = {
				res = "tx_rain",
				type = "particleSystem",
				transform = {
					position = {-6.193, 11.26, -3.07},
					rotation = {0, 0, 0, 1},
					scale = {0.5, 0.5, 0.5},
				},
			},
			["tx_rain (1)"] = {
				res = "tx_rain",
				type = "particleSystem",
				transform = {
					position = {-6.531, 11.08, -2.72},
					rotation = {0, 0, 0, 1},
					scale = {0.5, 0.5, 0.5},
				},
			},
			["tx_rain (2)"] = {
				res = "tx_rain",
				type = "particleSystem",
				transform = {
					position = {-6.531, 11.08, -3.115},
					rotation = {0, 0, 0, 1},
					scale = {0.5, 0.5, 0.5},
				},
			},
			["tx_rain (3)"] = {
				res = "tx_rain",
				type = "particleSystem",
				transform = {
					position = {-6.193, 11.08, -2.72},
					rotation = {0, 0, 0, 1},
					scale = {0.5, 0.5, 0.5},
				},
			},
			["tx_smoke_behind"] = {
				res = "tx_smoke_behind",
				type = "particleSystem",
				transform = {
					position = {-26.24, 10.76, -2.59},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["tx_smoke_front"] = {
				res = "tx_smoke_front",
				type = "particleSystem",
				transform = {
					position = {-14.07, 9.41, 6.059999},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["dengguang1"] = {
				res = "tx_light00",
				type = "particleSystem",
				transform = {
					position = {-4.70029, 9.581012, -2.501932},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["dengguang2"] = {
				res = "tx_light00",
				type = "particleSystem",
				transform = {
					position = {-5.067, 9.581012, -2.501932},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["shan"] = {
				res = "tx_2003c_shanlei",
				type = "particleSystem",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2002C"] = {
		type = "camara",
		transform = {
			position = {-9.32, 9.750215, 10.40873},
			rotation = {0.04787492, 0, 0, 0.9988533},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.777419,
		fieldOfView = 40,
		animations = {"2002", },
	},
	["role_ship_03"] = {
		res = "role_ship_03",
		type = "model",
		transform = {
			position = {-4.9, 8.094, -1.602},
			rotation = {0, 0.999965, 0, 0.008362629},
			scale = {1, 1, 1},
		},
		materials = {"role_ship_03", },
		animations = {"role_ship_03_light", },
	},
	["2001effects"] = {
		res = "2001effects",
		type = "model",
		transform = {
			position = {-10.80916, 11.49204, -3.941267},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["huoxing"] = {
				res = "tx_2001c_yanhuo",
				type = "particleSystem",
				transform = {
					position = {-2.03, -1.1, 1.01},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["fire1"] = {
				res = "tx_2001c_fire",
				type = "particleSystem",
				transform = {
					position = {-1.03484, -2.579042, 2.167267},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["fire2"] = {
				res = "tx_2001c_fire",
				type = "particleSystem",
				transform = {
					position = {-0.9648399, -2.579042, 0.02326679},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["fire3"] = {
				res = "tx_2001c_fire",
				type = "particleSystem",
				transform = {
					position = {-2.31, -0.71, 1.807},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["2001paohuo"] = {
				res = "2001effects",
				type = "model",
				transform = {
					position = {-1.652458, -1.329865, 1.340694},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				children = {
					["tx_2001c_paohuo (1)"] = {
						res = "tx_2001c_paohuo",
						type = "particleSystem",
						transform = {
							position = {12.46162, -10.16218, 2.600573},
							rotation = {0, 0, 0, 1},
							scale = {1, 1, 1},
						},
					},
					["tx_2001c_paohuo"] = {
						res = "tx_2001c_paohuo",
						type = "particleSystem",
						transform = {
							position = {12.46162, -10.16218, 2.600573},
							rotation = {0, 0, 0, 1},
							scale = {1, 1, 1},
						},
					},
					["tx_2001c_paohuo (2)"] = {
						res = "tx_2001c_paohuo",
						type = "particleSystem",
						transform = {
							position = {12.46162, -10.16218, 2.600573},
							rotation = {0, 0, 0, 1},
							scale = {1, 1, 1},
						},
					},
					["tx_2001c_paohuo (3)"] = {
						res = "tx_2001c_paohuo",
						type = "particleSystem",
						transform = {
							position = {12.46162, -10.16218, 2.600573},
							rotation = {0, 0, 0, 1},
							scale = {1, 1, 1},
						},
					},
				},
				animations = {"tx_2001c_paohuo", },
			},
		},
	},
	["2002effects"] = {
		res = "2002effects",
		type = "model",
		transform = {
			position = {-10.80916, 11.49204, -3.941267},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["tx_2002C_sunshine"] = {
				res = "tx_2002C_sunshine",
				type = "particleSystem",
				transform = {
					position = {0.48, -1.53, 4.511267},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["2002shuihua"] = {
				res = "tx_2002C_shuihua",
				type = "particleSystem",
				transform = {
					position = {0.6181602, -1.570043, 4.641267},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2001C"] = {
		type = "camara",
		transform = {
			position = {-9.32, 9.750215, 10.40873},
			rotation = {0.0478749, -4.163467E-05, 0.0008686579, 0.998853},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.777419,
		fieldOfView = 40,
		animations = {"2001", },
	},
	["role_ship_02"] = {
		res = "role_ship_02",
		type = "model",
		transform = {
			position = {-8.829414, 8.042344, -0.748531},
			rotation = {0, 0.9820424, 0, 0.1886601},
			scale = {1.025314, 1.025314, 1.025314},
		},
		materials = {"role_ship_02", },
		animations = {"role_ship_02_light", },
	},
	["waiteffects"] = {
		res = "waiteffects",
		type = "model",
		transform = {
			position = {-4.749738, 9.455432, -2.271656},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["yangguang"] = {
				res = "tx_sunshine",
				type = "particleSystem",
				transform = {
					position = {-10.19659, 8.572497, 0.3179055},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2001"] = {
		res = "2001",
		type = "model",
		transform = {
			position = {-12.09941, 8.246344, -2.297},
			rotation = {0, 0.959772, 0, 0.2807806},
			scale = {0.8147216, 0.8147215, 0.8147215},
		},
		materials = {"2001", },
		animations = {"2001_light", },
	},
	["WaterSurface"] = {
		type = "sea",
		transform = {
			position = {-9, 8.231198, -15.7},
			rotation = {0, 0, 0, 1},
			scale = {17.73361, 0.1773361, 17.7336},
		},
		materials = {"WaterSurface_1", },
		animations = {"water", },
	},
}

return sceneData
