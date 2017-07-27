return {
	texture_flow2 =
	{
		cullFace = "true",
		depthTest = "true",
		blend = "true",
		blendSrc = "SRC_ALPHA,ZERO",
		blendDst = "ONE,ZERO",
		
		u_texSpeed = {0, 0, 0, 0.2},
		u_mainColor= {0, 0.29019608, 1, 0.354902},
		u_mainIntensity = 2.0,
		u_maskTexST= {1, 1, 0, 0},
		u_maskTex=
		{
			path = "WHITE",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
		u_flowIntensity = 2,
		u_flowTexColor= {1.0,1.0,1.0,1.0},
		u_flowTexST= {1, 1, 0, 0},
		u_flowTex=
		{
			path = "gas.png",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
	},

}
