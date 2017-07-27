local animationData = {
	loop = true, 
	["root"] = {
		PositionX = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
				[2] = {time = 1000, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
			}, 
		}, 

		PositionY = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {100}, outTangent = {100}, type = 3},
				[2] = {time = 1000, value = {100}, inTangent = {100}, outTangent = {100}, type = 3},
			}, 
		}, 

		PositionZ = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
				[2] = {time = 1000, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
			}, 
		}, 

		ScaleX = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {1}, inTangent = {0.4499678}, outTangent = {0.4499678}, type = 3},
				[2] = {time = 283.3333, value = {1.127491}, inTangent = {1.041575}, outTangent = {1.041575}, type = 3},
				[3] = {time = 550, value = {1.563006}, inTangent = {3.524362}, outTangent = {3.524362}, type = 3},
				[4] = {time = 1000, value = {4}, inTangent = {5.415542}, outTangent = {5.415542}, type = 3},
			}, 
		}, 

		ScaleY = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {1}, inTangent = {0}, outTangent = {0}, type = 3},
				[2] = {time = 1000, value = {1}, inTangent = {0}, outTangent = {0}, type = 3},
			}, 
		}, 

		ScaleZ = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {1}, inTangent = {0.4965343}, outTangent = {0.4965343}, type = 3},
				[2] = {time = 283.3333, value = {1.140685}, inTangent = {1.050069}, outTangent = {1.050069}, type = 3},
				[3] = {time = 550, value = {1.568312}, inTangent = {3.503677}, outTangent = {3.503677}, type = 3},
				[4] = {time = 1000, value = {4}, inTangent = {5.403751}, outTangent = {5.403751}, type = 3},
			}, 
		}, 
	},

	["root/diamond_01"] = {
		PositionX = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
				[2] = {time = 1000, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
			}, 
		}, 

		PositionY = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {-140}, outTangent = {-140}, type = 3},
				[2] = {time = 1000, value = {-140}, inTangent = {-140}, outTangent = {-140}, type = 3},
			}, 
		}, 

		PositionZ = {
			type = "Transform", 
			curve = {
				[1] = {time = 0, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
				[2] = {time = 1000, value = {0}, inTangent = {0}, outTangent = {0}, type = 3},
			}, 
		}, 
	},

}
return animationData
