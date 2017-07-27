-- unity to gameplay 动画数据解析

local  Animation3D = {}

-- 插值方式。
--HERMITE = 3
--LINEAR = 4
--STEP = 6


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
	u_lightmapAlpha = {type = MaterialParameter.ANIMATE_UNIFORM()},
	u_effectAlpha = {type = MaterialParameter.ANIMATE_UNIFORM()},
}

local function getCurveFirstValue(type_str, curve)
    if type_str == "PositionX" or type_str == "PositionY" or type_str == "PositionZ" or 
        type_str == "ScaleX" or type_str == "ScaleY" or type_str == "ScaleZ" then
        
        return curve[1].value[1]
    end
    if type_str == "Rotation" then
        local result_tab = {}
        for i = 1, 4 do
            result_tab[i] = curve[1].value[i]
        end
        return result_tab
    end
    
    if type_str == "u_lightmapAlpha" or type_str == "u_effectAlpha" then
        return curve[1].value[1]
    end
    
    if type_str == "u_mainColor" or type_str == "u_flowTexColor" then
        local result_tab = {}
        for i = 1, 4 do
            result_tab[i] = curve[1].value[i]
        end
        return result_tab
    end
end

--params --is_loop:是否循环
function Animation3D:loadAnimation(node, anim_data, out_animations, params)
    local animations_reset_info = {}
    animations_reset_info.transform = self:transformParse(node, anim_data, out_animations, params)
    animations_reset_info.material = self:materialParse(node, anim_data, out_animations, params)
    return animations_reset_info
end 

function Animation3D:transformParse(node, anim_data, out_animations, params)
    local u3d_animations = {}
    local transform_reset_info = {}
    for key, value in pairs(TransformConfig) do
        if anim_data[key] then
            local data = anim_data[key]
            local curve = data.curve
            local key_count = #curve
            if key_count >= 2 then
                local key_time = {}
                local key_value = {}
                local key_in = {}
                local key_out = {}
                local key_type = {}
                
                -- 组装曲线数据
                for k, v in ipairs(curve) do
                    table.insert(key_time, v.time)
                    table.insert(key_type, v.type)
                    
                    for _, value in ipairs(v.value) do
                        table.insert(key_value, value)
                    end 
                    
                    for _, value in ipairs(v.inTangent) do
                        table.insert(key_in, value)
                    end 
                    
                    for _, value in ipairs(v.outTangent) do
                        table.insert(key_out, value)
                    end 
                end
                
                transform_reset_info[key] = getCurveFirstValue(key, curve)
                node:setAnimationTargetType(data.type)
                local animation = node:createAnimationExt(key, value.type, key_count, key_time, key_value, key_in, key_out, key_type)
                local clip = animation:getClip()
                if params.is_loop then 
                    clip:setRepeatCount(0)
                end 
                clip:stop()
                out_animations[key] = animation
            else
                print("warning!!!!!, animation key <= 1, key = ", key)
            end
        end 
    end 
    return transform_reset_info
end 


function Animation3D:materialParse(node, anim_data, out_animations, params)
    local material_reset_info = {}
    if params.body and params.body.node then
        node = params.body.node
    end
    for key, value in pairs(MaterialConfig) do
        if anim_data[key] then
            local param_handle = GetShaderParam(node, key, params.type)
            if param_handle then
                local data = anim_data[key]
                local curve = data.curve
                local key_count = #curve
                local key_time = {}
                local key_value = {}
                local key_in = {}
                local key_out = {}
                local key_type = {}
                
                -- 组装曲线数据
                for k, v in ipairs(curve) do
                    table.insert(key_time, v.time)
                    table.insert(key_type, v.type)
                    
                    for _, value in ipairs(v.value) do
                        table.insert(key_value, value)
                    end 
                    
                    for _, value in ipairs(v.inTangent) do
                        table.insert(key_in, value)
                    end 
                    
                    for _, value in ipairs(v.outTangent) do
                        table.insert(key_out, value)
                    end 
                end 
                material_reset_info[key] = getCurveFirstValue(key, curve)
                param_handle:setAnimationTargetType(data.type)
                local animation = param_handle:createAnimationExt(key, value.type, key_count, key_time, key_value, key_in, key_out, key_type)
                local clip = animation:getClip()
                if self.is_loop then 
                    clip:setRepeatCount(0)
                end 
                clip:stop()
                out_animations[key] = animation
            end
        end
    end
    return material_reset_info
end 


return Animation3D