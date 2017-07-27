local animationData = {
	loop = false, 
	["root"] = {
		ScaleZ = {
			type = "Transform" , 
			time = {0, 250, }, 
			values = {0,1,}, 
			tangentMode = {10, 10, }, 
			inTangent = {2.5,2.5}, 
			outTangent = {2.5,2.5}, 
		}

	}

}
return animationData
