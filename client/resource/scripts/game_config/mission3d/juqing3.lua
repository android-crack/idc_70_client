local sceneData = {
	["sky_xuanzhuang"] = {
		res = "sky_xuanzhuang",
		type = "model",
		transform = {
			position = {61.3946, -10.6, -28.15377},
			rotation = {0, 0.6175638, 0, 0.7865208},
			scale = {1.875796, 1.875795, 1.875795},
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
				materials = {"sky_2006", },
			},
		},
	},
	["effects_juqing3"] = {
		res = "effects_juqing3",
		type = "model",
		transform = {
			position = {0, 0, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["tx_juqing3_cloud"] = {
				res = "tx_juqing3_cloud",
				type = "particleSystem",
				transform = {
					position = {-13.6, 20.5, 22.2},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
			},
			["tx_juqing3_smoke (1)"] = {
				res = "tx_juqing3_smoke",
				type = "particleSystem",
				transform = {
					position = {-6, 11.8, -1.2},
					rotation = {0, -8.742278E-08, 0, -1},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["2006C"] = {
		type = "camara",
		transform = {
			position = {3.7, 9.76, -11.39},
			rotation = {1.48948E-09, 0.9994193, 0.03407534, -4.3686E-08},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.1,
		farClipPlane = 1000,
		aspect = 1.777164,
		fieldOfView = 40,
		animations = {"2006", },
		children = {
			["tx_juqing3_smoke"] = {
				res = "tx_juqing3_smoke",
				type = "particleSystem",
				transform = {
					position = {8.8, 6.9, -22.7},
					rotation = {2.308465E-08, 0.8491727, 0.5281152, -3.711852E-08},
					scale = {1, 1, 1},
				},
			},
		},
	},
	["WaterSurface"] = {
		type = "sea",
		transform = {
			position = {-3.3, 8.231198, -77.5},
			rotation = {0, 0, 0, 1},
			scale = {48, 1, 48},
		},
		materials = {"juqing03", },
	},
	["ship"] = {
		type = "model",
		transform = {
			position = {0, 8.3, 0},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		children = {
			["role_ship_06_7"] = {
				res = "role_ship_06_7",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_7", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-192.0001, -9.000027, 4.172325E-05},
							rotation = {0, -0.7130718, 0, 0.7010911},
							scale = {99.99997, 100, 99.99998},
						},
					},
				},
			},
			["role_ship_06_6"] = {
				res = "role_ship_06_6",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_6", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (1)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-156.0001, -9.000015, -7.999917},
							rotation = {0, -0.7214805, 0, 0.6924347},
							scale = {100, 100, 100},
						},
					},
				},
			},
			["role_ship_06_5"] = {
				res = "role_ship_06_5",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_5", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (2)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-144.9999, -9.000058, -4.000073},
							rotation = {0, -0.7168918, 0, 0.6971845},
							scale = {100, 100, 99.99998},
						},
					},
				},
			},
			["role_ship_06_3"] = {
				res = "role_ship_06_3",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_3", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (3)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-191.1933, -8.637717, -1.439819},
							rotation = {0.00121561, -0.7133644, -0.002977757, 0.7007859},
							scale = {99.99998, 100, 100},
						},
					},
				},
			},
			["role_ship_06_1"] = {
				res = "role_ship_06_1",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_1", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (4)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-151.0001, -9.000031, -7.000017},
							rotation = {0.009413547, -0.7210283, 0.009797493, 0.6927724},
							scale = {100.0001, 100, 100.0001},
						},
					},
				},
			},
			["role_ship_06_2"] = {
				res = "role_ship_06_2",
				type = "model",
				transform = {
					position = {0, 0, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_2", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (5)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-171.0093, -12.63772, 2.314854},
							rotation = {0, 0.7137965, 0, -0.7003532},
							scale = {100, 100, 100},
						},
					},
				},
			},
			["role_ship_06_4"] = {
				res = "role_ship_06_4",
				type = "model",
				transform = {
					position = {0, -0.46, 0},
					rotation = {0, 0, 0, 1},
					scale = {1, 1, 1},
				},
				materials = {"role_ship_06_4", },
				link_particle = {
					[1] = {
						name = "juqing3_shuibo (6)",
						res = "tx_juqing3_shuibo",
						parent_name = "Bone016",
						transform = {
							position = {-182.1462, -18.63768, -3.558737},
							rotation = {-0.009515023, 0.7137733, -0.009698972, -0.700245},
							scale = {100, 100, 100},
						},
					},
				},
			},
		},
	},
}

return sceneData
