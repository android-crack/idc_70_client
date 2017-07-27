return {
	texture_flow3 =
	{
		u_texSpeed = { 0, 0, 0.3, 0},
		u_mainIntensity = 1.0,
		u_mainColor= {1, 1, 1, 1},
		u_maskTexST= {1, 1, 0, 0},
		u_maskTex=
		{
			path = "alpha.png",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
		u_flowIntensity = 1,
		u_flowTexColor= {0.521,0.313,0,0.627},
		u_flowTexST= {1, 1, 0, 0},
		u_flowTex=
		{
			path = "fireball.png",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
	},
}
