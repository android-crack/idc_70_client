local preload_helper = require("module/preload/preload_helper")
local preload_mgr = require("module/preload/preload_mgr")

local preload_battle = {}

local battle_preload_list = {}

local preload_res_tab = {
 	["plist"] = {
		["ui/ship_icon.plist"]				= true,
		["ui/skill_icon.plist"]				= true,

        -- 新增
        ["ui/box.plist"]					= true,
        ["ui/battle_ui.plist"]				= true,
        ["ui/ship_skill.plist"]				= true,
        ["ui/buff_icon.plist"]				= true,
        ["ui/chat_ui.plist"]				= true,
        ["ui/head_frame.plist"]             = true,
        ["ui/title_name.plist"]             = true,
        ["ui/instance_ui.plist"]             = true,
	},
	
	["armature"] = {
		["effects/tx_0198.ExportJson"] = true,
		["effects/tx_0072.ExportJson"] = true,
        ["effects/tx_0088.ExportJson"] = true,
        ["effects/tx_combo.ExportJson"] = true,
        ["effects/tx_death_line.ExportJson"] = true,
	}
}


preload_battle.get_battle_preload_list = function(battle_field_data)
	if battle_field_data == nil then
		return battle_preload_list
	end

	local battle_preload_array = {}

	preload_helper.add3d_helper(battle_field_data, battle_preload_array)
	
	--处理下载列表，以适应reload_mgr模块
	battle_preload_list = {
		["plist"] = preload_res_tab.plist,
		["armature"] = preload_res_tab.armature,
		["model_3d"] = {},
		["propertiesfile_3d"] = {},
		["particleemitter_3d"] = {},
		["texture_3d"] = {},
		["image"] = {},
		
	}
	for _, preload_case in pairs(battle_preload_array) do
		if preload_case.file and preload_case ~= "" then	
			if preload_case.loadtype == "plist" then
				battle_preload_list.plist[preload_case.file] = true
			elseif preload_case.loadtype == "armature" then
				battle_preload_list.armature[preload_case.file]	= true
			elseif preload_case.loadtype == "model_3d" then		
				battle_preload_list.model_3d[preload_case.file] = true
			elseif preload_case.loadtype == "propertiesfile_3d" then
				battle_preload_list.propertiesfile_3d[preload_case.file] = true
			elseif preload_case.loadtype == "particleemitter_3d" then 
				battle_preload_list.particleemitter_3d[preload_case.file] = preload_case.value
			elseif preload_case.loadtype == "texture_3d" then 
				battle_preload_list.texture_3d[preload_case.file] = true
			elseif preload_case.loadtype == "image" then
				battle_preload_list.image[preload_case.file] = preload_case.tf
			else
				print( "unknow preload type:", preload_case.loadtype )
			end
		end
	end
	return battle_preload_list
end


preload_battle.start_preload = function(battle_field_data, call_back )
	
	local battle_preload_list = preload_battle.get_battle_preload_list(battle_field_data)
	--preload_mgr.asyncLoadRes(battle_preload_list, call_back )
	require("gameobj/ClsbattleLoadingUI"):start(battle_preload_list, call_back)
end

preload_battle.clear_preload = function ()
	local battle_preload_list = preload_battle.get_battle_preload_list()
	preload_mgr.clearPreLoad(battle_preload_list)
end

return preload_battle