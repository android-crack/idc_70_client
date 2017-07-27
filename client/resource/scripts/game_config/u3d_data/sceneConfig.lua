local sceneData = {
	["Camara"] = {
		type = "camara",
		transform = {
			position = {0, 1, 10},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
		},
		cameraType = "Projection",
		backgroundColor = {r = 0.1921569, g = 0.3019608, b = 0.4745098, a = 0.01960784},
		nearClipPlane = 0.3,
		farClipPlane = 1000,
		aspect = 1.85872,
		fieldOfView = 60,
	},
    ["Q3_02"] = {
		res = "Q3_02",
		type = "model",
		transform = {
			position = {200, 200, 200},
			rotation = {0, 0, 0, 1},
			scale = {1, 1, 1},
        },
        children = {
            ["role_ship_01"] = {
                res = "Q3_02",
                type = "model",
                transform = {
                    position = {0,0,0},
                    rotation = {0, 0, 0, 1},
                    scale = {1, 1, 1},
                },
                materials = {"role_ship_01", },
            },
        },
    },
    ["Q3_03"] = {
        res = "Q3_02",
        type = "model",
        transform = {
            position = {0, 0, 0},
            rotation = {0, 0, 0, 1},
            scale = {1, 1, 1},
        },
        children = {
            ["role_ship_01"] = {
                res = "Q3_02",
                type = "model",
                transform = {
                    position = {0,0,0},
                    rotation = {0, 0, 0, 1},
                    scale = {1, 1, 1},
                },
                materials = {"role_ship_01", },
            },
        },
    },
}

return sceneData
