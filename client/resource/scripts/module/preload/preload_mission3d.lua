local preload_helper = require("module/preload/preload_helper")
local preload_mgr = require("module/preload/preload_mgr")

local preload_mission3d = {}
preload_mission3d.get_preload_list = function(cfg)
	--处理下载列表，以适应reload_mgr模块
	local preload_list = {
		["plist"] = {},
		["armature"] = {},
		["model_3d"] = {},
		["propertiesfile_3d"] = {},
		["particleemitter_3d"] = {},
		["texture_3d"] = {},
		["image"] = {},
	}
	
	local hander_record_func
	hander_record_func = function(item)
		if item.type == "model" then
			if item.res and item.materials then
				local path = string.format("%s%s/%s%s", MODEL_PATH, item.res, item.res, GPB_EXT)
				preload_list.model_3d[path] = true
			end
		elseif item.type == "particleSystem" then
			if item.res then
				local path = string.format("%s%s%s", EFFECT_PATH, item.res, PARTICLE_3D_EXT)
				preload_list.propertiesfile_3d[path] = true
			end
		end
		if item.children then
			for _, c_item in pairs(item.children) do
				hander_record_func(c_item)
			end
		end
	end
	
	local scene_cfg = require("game_config/mission3d/" .. cfg.scene_cfg)
	hander_record_func({["children"] = scene_cfg})
	
	for i = 0, 14 do
		local id = tostring(i)
		if i < 10 then
			id = "0" .. id
		end
		local path = string.format("3d/textures/water_hm%s.png", id)
		preload_list.image[path] = true
	end
	
	return preload_list
end


preload_mission3d.start_preload = function(cfg, call_back)
	preload_mission3d_list = preload_mission3d.get_preload_list(cfg)
	require("gameobj/loadingUI"):start(preload_mission3d_list, call_back)
end

preload_mission3d.clear_preload = function()
	preload_mgr.clearPreLoad(preload_mission3d_list)
	preload_mission3d_list = {}
end

return preload_mission3d