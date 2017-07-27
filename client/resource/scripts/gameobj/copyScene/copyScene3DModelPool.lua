--
-- Author: lzg0496
-- Date: 2016-06-20 20:19:28
-- Function: 存放副本的全部事件的3D模型内存池

local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ClsPropEntity = require("gameobj/copyScene/copySceneProp")
local ClsParticleProp = require ("gameobj/copyScene/copySceneParticle")

local copyScene3DModelPool = class("copyScene3DModelPool")

--由相应的副本传参
-- MODEL_OBJECTS = {
-- 	[SCENE_OBJECT_TYPE_ROCK] = 0 --礁石
-- 	[SCENE_OBJECT_TYPE_ICE] = 0 --浮冰
-- 	[SCENE_OBJECT_TYPE_BITE_BOAT] = 0 --鲨鱼
-- 	[SCENE_OBJECT_TYPE_BOX] = 0 --宝箱
-- 	[SCENE_OBJECT_TYPE_FLAT] = 0 --酒桶
-- 	[SCENE_OBJECT_TYPE_SEA_WRECK] = 0 --沉船
-- 	[SCENE_OBJECT_TYPE_MONSTER] = 0 --海怪
-- 	[SCENE_OBJECT_TYPE_XUANWO] = 0 --漩涡
-- }
function copyScene3DModelPool:ctor(MODEL_OBJECTS)
	self.model_objects = {}
	self.del_model_objects = {}
	for event_type, model_counts in pairs(MODEL_OBJECTS) do
		self.model_objects[event_type] = {}
		for i = 1, model_counts do
			local arr_len = #self.model_objects[event_type]
			local model = self:createModel(event_type)
			self.model_objects[event_type][arr_len + 1] = model
		end
	end
end

function copyScene3DModelPool:getModel(event_type)
	local model = nil
    if self.model_objects[event_type] then
        model = self.model_objects[event_type][1] 
    end
	if not model then
		model = self:createModel(event_type)
		self.model_objects[event_type] = {}
		self.model_objects[event_type][1] = model
	end
	table.remove(self.model_objects[event_type], 1)
	self.del_model_objects[#self.del_model_objects + 1] = model
	return model
end

function copyScene3DModelPool:createModel(event_type)
	local config = ClsSceneConfig[event_type]
	local params = {}
    params.res = config.res
	if event_type ~= SCENE_OBJECT_TYPE_XUANWO and event_type ~= SCENE_OBJECT_TYPE_WHIRLPOOL then
		params.animation_res = config.animation_res
		params.water_res = config.water_res
		params.sea_level = config.sea_level
		params.type = event_type
		params.hit_radius = config.hit_radius
		params.sea_down = config.sea_down

		if event_type == SCENE_OBJECT_TYPE_BOX or 
			event_type == SCENE_OBJECT_TYPE_FLAT or 
			event_type == SCENE_OBJECT_TYPE_SEA_WRECK or 
			event_type == SCENE_OBJECT_TYPE_ICE or event_type == SCENE_OBJECT_TYPE_ROCK then
				params.hit_radius = 1
		end

		if event_type == SCENE_OBJECT_TYPE_MONSTER or event_type == SCENE_OBJECT_TYPE_BITE_BOAT then
			params.auto_speed = 60
		end

		if event_type == SCENE_OBJECT_TYPE_MERMAID then
			params.auto_speed = 80
		end

		return ClsPropEntity.new(params)
	else
		return ClsParticleProp.new(params)
	end
end

function copyScene3DModelPool:removeModel(del_model)
	for index, model in pairs(self.del_model_objects) do
		if model == del_model then
			self.del_model_objects[index] = nil
		end
	end
	del_model:release()
end

function copyScene3DModelPool:cleanAllModel()
	for _, models in pairs(self.model_objects) do
		for _, model in ipairs(models) do
			model:release()
		end
	end

	for _, model in pairs(self.del_model_objects) do
		model:release()
	end
	self.model_objects = {}
	self.del_model_objects = {}
	GameUtil.luaFullGc()
end

return copyScene3DModelPool