-- unity to gameplay 动画数据解析

local  Animation3D = {}

local TransformConfig = {
	PositionX = {type = Transform.ANIMATE_TRANSLATE_X()},
	PositionY = {type = Transform.ANIMATE_TRANSLATE_Y()},
	PositionZ = {type = Transform.ANIMATE_TRANSLATE_Z()},
	
	ScaleX = {type = Transform.ANIMATE_SCALE_X()},
	ScaleY = {type = Transform.ANIMATE_SCALE_Y()},
	ScaleZ = {type = Transform.ANIMATE_SCALE_Z()},
	
	Rotation = {type = Transform.ANIMATE_ROTATE()},
}


local MaterialConfig = {
	u_mainColor = {type = MaterialParameter.ANIMATE_UNIFORM()},
	u_flowTexColor = {type = MaterialParameter.ANIMATE_UNIFORM()},
}

function Animation3D:loadAnimation(root_body, data, is_recursion)
	if data == nil or data.root == nil then
		print("animation_data is nil !!!!!!!!!!!!!")
	end

	self.is_loop = data.loop or false 
	self:parse(root_body, data.root)
	
	-- 遍历所有孩子
	if is_recursion then 
	
	end 
end 

function Animation3D:parse(body, animation_data)
	body.u3d_animations = {}
	self:transformParse(body, animation_data)
	self:materialParse(body, animation_data)
end

function Animation3D:transformParse(body, animation_data)
	local node = body.node
	for key, value in pairs(TransformConfig) do
		if animation_data[key] then
			local data = animation_data[key]
			local key_count = #data.time		
			local interpolation = "LINEAR"
			local animation = nil 
			node:setAnimationTargetType(0)
			if key == "Rotation" then 
				animation = node:createAnimation(key, value.type, key_count, data.time, 
						data.values, "LINEAR")
			else
				animation = node:createAnimation(key, value.type, key_count, data.time, 
						data.values, data.inTangent, data.outTangent, interpolation)
			end 
			local clip = animation:getClip()
			if self.is_loop then 
				clip:setRepeatCount(0)
			end 
			clip:play()	
			body.u3d_animations[key] = animation
		end 
	end 
end 


function Animation3D:materialParse(body, animation_data)
	local node = body.node
	for key, value in pairs(MaterialConfig) do
		if animation_data[key] then
			local param_handle = GetShaderParam(node, key)
			if param_handle then
				local data = animation_data[key]
				local key_count = #data.time
				local interpolation = "LINEAR"
				param_handle:setAnimationTargetType(0)
				local animation = param_handle:createAnimation(key, value.type, key_count, data.time, 
					data.values, data.inTangent, data.outTangent, interpolation)
				local clip = animation:getClip()
				
				if self.is_loop then 
					clip:setRepeatCount(0)
				end	
				clip:play()	
				body.u3d_animations[key] = animation
			end
		end
	end	
end 


return Animation3D