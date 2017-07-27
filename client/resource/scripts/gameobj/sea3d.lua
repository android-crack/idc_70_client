local ClsSea3d = class("ClsSea3d")

function ClsSea3d:ctor(path, pos)
	self.node = Node.create("sea")
	self.sea = Sea.create(path)
	self.node:setSea(self.sea)
	if pos then 
		self.node:setTranslation(pos)
	end
end

function ClsSea3d:setUniforms(uniform_tab)
	local mat = self.sea:getMaterial()
	for k, v in pairs(uniform_tab) do
		local para = mat:getParameter(k)
		local para_type = para:getType()
		if para_type == MATERIAL_PARAM_TYPE.FLOAT then 
			para:setValue(unpack(v))
		elseif para_type == MATERIAL_PARAM_TYPE.INT then 
			para:setValue(unpack(v))
		elseif para_type == MATERIAL_PARAM_TYPE.VECTOR3 then 
			para:setValue(Vector3.new(unpack(v)))
		elseif para_type == MATERIAL_PARAM_TYPE.VECTOR4 then 
			para:setValue(Vector4.new(unpack(v)))
		elseif para_type == MATERIAL_PARAM_TYPE.SAMPLER then 
			local sampler = para:setValue(SEA_3D_PATH..unpack(v), true)
			if sampler then
				sampler:setWrapMode("REPEAT", "REPEAT")
				sampler:setFilterMode("LINEAR_MIPMAP_LINEAR", "LINEAR");
			end
		end
	end
end

return ClsSea3d