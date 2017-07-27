return {
	liushui=
	{

		blend = 'true',
		cullFace = 'false',
		depthTest = 'true',
		depthWrite = 'false',
		u_texSpeed = { 0, 0.3, 0, 0.5},
		u_mainColor= {0.6470588, 0.8977687, 1, 1},
		u_diffuseTextureST= {3, 2, 0, 0},
		u_diffuseTexture=
		{
			path = "flowTex_3d/blue-liuguang.png",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},
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
		u_flowTexColor= {1, 1, 1, 1},
		u_flowTexST= {4, 2, 0, 0},
		u_flowTex=
		{
			path = "flowTex_3d/liushui.png",
			minFilter = "LINEAR_MIPMAP_LINEAR",
			magFilter = "LINEAR",
			wrapS = "REPEAT",
			wrapT = "REPEAT",
			mipmap = "true",
		},

	},

}
