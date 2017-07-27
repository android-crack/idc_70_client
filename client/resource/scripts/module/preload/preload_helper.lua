local role_info = require("game_config/role/role_info")
local boat_info = require("game_config/boat/boat_info")
local proj_eff = require("game_config/battle/proj_eff")
local dataTools = require("module/dataHandle/dataTools")
local sailor_info = require("game_config/sailor/sailor_info")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
local skill_map = require("game_config/battleSkill/skill_map")
local skill_info = require("game_config/skill/skill_info")

local helper = {}

local PARTICLE_COMMON = 
{
	["tx_dianji"] = true,
	["tx_shuihua"] = true,
}
local MODEL_COMMON = 
{
	[1] = "pd_01",
	[2] = "pd_02",
	[3] = "pd_03",
	[4] = "sea_whale",
	[5] = "plane001",
}

local MODELPARTICLE_COMMON = 
{
	[1] = "pd_01",
	[2] = "pd_02",
	[3] = "pd_03",
}

local PROPERTIES_COMMON = 
{
	-- [1] = MODEL_3D_PATH.."fullscreen.material",
}

function helper.addParticleEmitterList_3d(list, file, order)
	helper.addLoadInfoToList("particleemitter_3d", list, file, nil, order)
end

function helper.addModelLoadInfoToList_3d(list, file)
	helper.addLoadInfoToList("model_3d", list, file)
end

function helper.addPropertiesFileLoadInfoToList_3d(list, file)
	helper.addLoadInfoToList("propertiesfile_3d", list, file)
end

local list_info = {}
function helper.addLoadInfoToList(loadType, list, file, textureFormat, value)
	if list_info[file] then return end
	list_info[file] = true

    textureFormat = textureFormat or TEXTURE_FORMAT.default
    table.insert(list, {["loadtype"] = loadType, ["file"]= file, ["tf"] = textureFormat, ["value"] = value})
end

function helper.addTexture_3d(list, file)
	helper.addLoadInfoToList("texture_3d", list, file)
end

function helper.addParticle_3d(list, file)
	helper.addPropertiesFile_3d(list, file)
	local properties = ResourceManager:LoadPropertiesFile(file)
	if properties == nil then return end
	local archives = properties:getNamespace("ParticleSystem", true, false)
	archives:rewind()
	while true do
		-- 获取粒子特效子段设置
		local configs = archives:getNextNamespace()
		if configs == nil then break end

		local child_type = configs:getNamespace()
		if child_type == nil then break end

		local object = nil
		-- 按不同类型创建对象
		if child_type == "Model" then
			local model_name = configs:getString("model_name")
			local action_name = configs:getString("action_name")
			local gpb_path = string.format("%s%s/%s.gpb", MODEL_3D_PATH, model_name, model_name)
			helper.addModel_3d(list, gpb_path)

			--又嵌particl_system
			local fire_effect = configs:getString("fire_effect")
			if fire_effect and fire_effect ~= "" then
				local path = string.format("%s%s%s", EFFECT_3D_PATH, fire_effect, MODELPARTICLE_EXT)
				helper.addModelParticleSystems_3d(list, path)
			end
		elseif child_type == "Emitter" then
			local filename = configs:getPath("file")
			local order = configs:getInt("order") 
			helper.addParticleEmitterList_3d(list, filename, order)
		else
			print("======================Error!!!, Unknow type!", child_type)
		end
	end
end

function helper.addModel_3d(list, file, nodename)
	helper.addModelLoadInfoToList_3d(list, file)
end

function helper.addArmature(list, file)
	helper.addLoadInfoToList("armature", list, file)
end

function helper.addModelParticleSystems_3d(list, file)
	if not FileSystem.fileExists(file) then return end 
	
	helper.addPropertiesFile_3d(list, file)
	local properties = ResourceManager:LoadPropertiesFile( file )
	if not properties then 
		echoInfo("addModelParticleSystems_3d fail:%s", file)
		return
	end
	local batch_effect = properties:getNamespace( "ModelParticleConfig", true, false );
	batch_effect:rewind();
	
	while true do
		-- 获取粒子特效子段设置
		local config = batch_effect:getNextNamespace()
		if config == nil then break end

		local filename = config:getPath("file")
		helper.addParticle_3d(list, filename)
	end
end

function helper.addPropertiesFile_3d(list, file)
	helper.addPropertiesFileLoadInfoToList_3d(list, file)
end

function helper.addBoat_3d(list, ship_id)
	local boat_cfg = boat_info[ship_id]
	if not boat_cfg then 
		echoError("not has ship which id is %s:", ship_id)
	end
	local res_3d_id = boat_cfg.res_3d_id
	local is_oar = boat_cfg.is_oar
	local model_path = string.format("%sboat%.2d/boat%.2d%s", SHIP_3D_PATH, res_3d_id, res_3d_id, GPB_EXT)
	helper.addModel_3d(list, model_path)
	local modelparticle_path_self = string.format("%sboat%.2d%s", EFFECT_3D_PATH, res_3d_id, MODELPARTICLE_EXT)
	helper.addModelParticleSystems_3d(list, modelparticle_path_self)
	local modelparticle_path_cm = string.format("%sboat%s", EFFECT_3D_PATH, MODELPARTICLE_EXT)
	helper.addModelParticleSystems_3d(list, modelparticle_path_cm)
	local modelparticle_path_oar
	if is_oar == 1 then 
		modelparticle_path_oar = string.format("%sboat%.2d_oar%s", EFFECT_3D_PATH, res_3d_id, MODELPARTICLE_EXT)
		helper.addModelParticleSystems_3d(list, modelparticle_path_oar)
	end
	-- TODO:写死pic_count的数量，如果资源贴图加了的话，对应的要修改
	local pic_count = 4
	for i = 1, pic_count do
		local path = string.format("%sboat%0.2d/boat%0.2d.fbm/boat%0.2d_%0.3d.png", SHIP_3D_PATH, res_3d_id, res_3d_id, res_3d_id, i)
		if FileSystem.fileExists(path) then 
			helper.addTexture_3d(list, path)
		end
	end
end

function helper.addProp_3d(list, prop_id)
	local prop_info = require("game_config/battle/prop_info")

	local prop_detail = prop_info[prop_id]
	if not prop_detail then return end
	
	local prop_type = prop_detail.type
	if prop_type == 0 then
		local path = prop_detail.path
		local res = prop_detail.res
		local model_path = string.format("%s%s/%s%s", path, res, res, GPB_EXT)
		helper.addModel_3d(list, model_path)
		local modelparticle_path = string.format("%s%s%s", EFFECT_3D_PATH, res, MODELPARTICLE_EXT)
		helper.addModelParticleSystems_3d(list, modelparticle_path)
	elseif prop_type == 1 then
		local full_path = prop_detail.path
		helper.addParticle_3d(list, full_path)
	end
end

local bullet_alread_load = {}
local function addBulletEffect(list, eff_name)
	if bullet_alread_load[eff_name] then return end
	bullet_alread_load[eff_name] = true

	local cfg = proj_eff[eff_name]
	local eff = cfg.start_effect
	local path = string.format("%s%s%s", EFFECT_3D_PATH, eff, PARTICLE_3D_EXT)
	helper.addParticle_3d(list, path)
	local bullet_id = cfg.bullet_id
	local bullet_info = require("game_config/battle/bullet_info")
	local bullet = bullet_info[bullet_id]
	local bullet_eff = bullet.fire_effect
	path = string.format("%s%s%s", EFFECT_3D_PATH, bullet_eff, MODELPARTICLE_EXT)
	helper.addModelParticleSystems_3d(list, path)
	if bullet.name == "" then return end
	path = string.format("%s%s/%s%s", MODEL_3D_PATH, bullet.name, bullet.name, GPB_EXT)
	helper.addModel_3d(list, path)
end

local effect_table = {}
local function handleAddEffect(list, eff_type, eff_name)
	if eff_type == "" or eff_name == "" then return end 

	if effect_table[eff_name] then return end
	effect_table[eff_name] = true

	local path 
	if eff_type == "particle" or eff_type == "model_particle" or eff_type == "particle_local" or
		eff_type == "particle_scene" or eff_type == "particle_share" or eff_type == "particle_launch" then 
		path = string.format("%s%s%s", EFFECT_3D_PATH, eff_name, PARTICLE_3D_EXT)
		helper.addParticle_3d(list, path)
	elseif eff_type == "composite" or eff_type == "model" then 
		path = string.format("%s%s/%s%s", MODEL_3D_PATH, eff_name, eff_name, GPB_EXT)
		helper.addModel_3d(list, path)
		path = string.format("%s%s%s", EFFECT_3D_PATH, eff_name, MODELPARTICLE_EXT)
		helper.addModelParticleSystems_3d(list, path)
	elseif eff_type == "proj" then 
		addBulletEffect(list, eff_name)
	elseif eff_type == "gousuo" then
		path = string.format("%s%s/%s%s", MODEL_3D_PATH, battle_config.gousuo_1, battle_config.gousuo_1, GPB_EXT)
		helper.addModel_3d(list, path)
		path = string.format("%s%s/%s%s", MODEL_3D_PATH, battle_config.gousuo_2, battle_config.gousuo_2, GPB_EXT)
		helper.addModel_3d(list, path)
	elseif eff_type == "armature_scene" then
		path = string.format("effects/%s.ExportJson", eff_name)
		helper.addArmature(list, path)
	elseif eff_type ~= "liuguang" then
		print("================Error!!! Not Loaded", eff_type, eff_name)
	end	
end

local function addEffect(list, eff_types, eff_names)
	if type(eff_types) ~= "table" or #eff_types < 1 then return end

	for k, effect_type in ipairs(eff_types) do
		local func = skill_effect_util.effect_funcs[effect_type]
		local eff_name = eff_names[k]
		if func and eff_name and eff_name ~= "" then
			handleAddEffect(list, effect_type, eff_name)
		end
	end
end

function helper.addSkill_3d(list, skill_ex_id)
	local cls_skill = skill_map[skill_ex_id]

	if not cls_skill or cls_skill:get_skill_type() == "passive" then
		return
	end

	local hit_effect = cls_skill:get_preload_hit_effect()
	if hit_effect and hit_effect ~= "" then
		handleAddEffect(list, "particle_scene", hit_effect)
	end

	local eff_types = cls_skill:get_before_effect_type()
	local eff_names = cls_skill:get_before_effect_name()
	addEffect(list, eff_types, eff_names)
	
	local status_add = cls_skill:get_add_status()
	for i, status in ipairs(status_add) do
		eff_name = status.effect_name
		eff_type = status.effect_type
		handleAddEffect(list, eff_type, eff_name)
		
		local status_map = require("game_config/buff/status_map")
		local cls_status = status_map[status.status]
		eff_types = cls_status:get_status_effect_type()
		eff_names = cls_status:get_status_effect()
		addEffect(list, eff_types, eff_names)
	end
end

local ai_already_load = {}

local function preloadAIRes(new_ai_id, preload_skills, preload_images)
	if ai_already_load[new_ai_id] then return end
	ai_already_load[new_ai_id] = true

	local new_ai = require("game_config/battle_ai/" .. new_ai_id)
	for _, action in pairs(new_ai:getActions()) do
		local action_name = action[1]
		local action_para = action[3]
		if action_name == "add_ai" or action_name == "run_ai" then
			for k, ai_id in pairs(action_para[1]) do
				preloadAIRes(ai_id, preload_skills, preload_images)
			end
		elseif action_name == "add_skill" then
			local skill_id = action_para[1]
			if not preload_skills[skill_id] then
				preload_skills[skill_id] = true
			end
		-- 添加船只特效目前都是运行AI调的AI执行的，当前没有二级遍历
		elseif action_name == "add_effect_to_ship" or action_name == "add_effect_to_scene" then
			local particle_name = action_para[2]
			if not PARTICLE_COMMON[particle_name] then
				PARTICLE_COMMON[particle_name] = true
			end
		elseif action_name == "show_cloud" then
			preload_images[battle_config.cloud_1] = TEXTURE_FORMAT.default
			preload_images[battle_config.cloud_2] = TEXTURE_FORMAT.default
		elseif action_name == "guide_point" then
			if not PARTICLE_COMMON[DIANJI_YELLOW] then
				PARTICLE_COMMON[DIANJI_YELLOW] = true
			end
		end
	end
end

function helper.addPicture(list, path, format)
	if not path or path == "" then return end
	helper.addLoadInfoToList("image", list, path, format)
end

--  通过指令加的模型或者特效目前没有做预加载
function helper.add3d_helper(battle_field_data, list)
	local preload_boats = {}	-- 船
	local preload_skills = {}	-- 技能
	local preload_images = {}	-- 2D图片

	-- 远近普攻技能相关资源缓存
	preload_skills[1] = true
	preload_skills[2] = true

	local preload_list = battle_field_data.preload_list
	for _, boat_type in pairs(preload_list.boat_type) do
		preload_boats[boat_type] = true

		addBulletEffect(list, boat_info[boat_type].fire_res_2)
	end
	for _, skill_id in pairs(preload_list.skill_id) do
		preload_skills[skill_id] = true
	end
	for _, prop_type in pairs(preload_list.prop_type) do
		helper.addProp_3d(list, prop_type)
	end
	for _, sailor_id in pairs(preload_list.sailors) do
		if sailor_id and sailor_info[sailor_id] then
			preload_images[sailor_info[sailor_id].res] = TEXTURE_FORMAT.default
		end
	end
	for _, ai in pairs(preload_list.all_ai) do
		preloadAIRes(ai, preload_skills, preload_images)
	end

	-- 剧情资源预加载
	if battle_field_data.plot_file_name and battle_field_data.plot_file_name ~= "" then
		local plot_list = dataTools:getOldPlotList(battle_field_data.plot_file_name)
		for k, v in ipairs(plot_list) do
			if v.plot == "dialog" and v.param[1] > 0 then
				local sailor = dataTools:getSailor(v.param[1])
				if sailor and not preload_images[sailor.res] then
					preload_images[sailor.res] = TEXTURE_FORMAT.default
				end
			elseif v.plot == "add_sprite" then
				local sprite_path, format = v.param[1], v.param[8]
				if not preload_images[sprite_path] then
					preload_images[sprite_path] = format or TEXTURE_FORMAT.default
				end
			end
		end
	end
	
	-- 预加载船舶
	for boat_id, _ in pairs(preload_boats) do
		helper.addBoat_3d(list, boat_id)
	end
	-- 预加载技能
	for skillId, _ in pairs(preload_skills) do
		if skill_info[skillId] then 
			local skill_ex_id = skill_info[skillId].skill_ex_id
			helper.addSkill_3d(list, skill_ex_id)

			if skill_info[skillId].trigger_skill ~= "" then
				helper.addSkill_3d(list, skill_info[skillId].trigger_skill)
			end
		end
	end
	-- 预加载图片
	for res, format in pairs(preload_images) do
		helper.addPicture(list, res, format)
	end

	for particle_name, _ in pairs(PARTICLE_COMMON) do
		local path = string.format("%s%s%s", EFFECT_3D_PATH, particle_name, PARTICLE_3D_EXT)
		helper.addParticle_3d(list, path)
	end

	for _, v in ipairs(MODEL_COMMON) do
		local path = string.format("%s%s/%s%s", MODEL_3D_PATH, v, v, GPB_EXT)
		helper.addModel_3d(list, path)
	end
	for _, v in ipairs(MODELPARTICLE_COMMON) do
		local path = string.format("%s%s%s", EFFECT_3D_PATH, v, MODELPARTICLE_EXT)
		helper.addModelParticleSystems_3d(list, path)
	end
	for _, v in ipairs(PROPERTIES_COMMON) do
		helper.addPropertiesFile_3d(list, v)
	end

	list_info = {}
	effect_table = {}
	bullet_alread_load = {}
end

return helper