return {
	default =
	{
		cullFace = "true",
		depthTest = "true",
		blend = "true",
		blendSrc = "ONE,ZERO",
		blendDst = "ZERO,ZERO",
		
		u_texSpeed = {0, 0, 0, 0},
		u_mainColor = {1, 1, 1, 1},
		u_mainIntensity = 1,
		u_maskTexST = {1, 1, 0, 0},	
		u_maskTex = 
		{
			path = "WHITE",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
		u_flowIntensity = 1.0,
		u_flowTexColor = {0.7132353, 0.5768008, 0.2464857, 0.4705882},
		u_flowTexST = {1, 1, 0, 0},
		u_flowTex = 
		{
			path = "BLACK",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
	},
}
