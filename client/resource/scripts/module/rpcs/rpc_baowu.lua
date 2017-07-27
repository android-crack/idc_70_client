local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
--[[
 class baowu_attr {
  4     string type;
  5     int id;
  6     int value;
  7 }
  8 
  9 class baowu_t {
 10     string baowuKey;
 10     int baowuId;
 11     int step;
 12     int status;
 13     baowu_attr_t* attr;
 14 }
]]--


-- 单个宝物信息， 对应水手宝物
function  rpc_client_baowu_info(info)
	local baowuData = getGameData():getBaowuData()
	baowuData:addBaowu(info)
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_BAOWU)
end 

-- class boat_baowu_t {
--     int baowuId;
--     int amount;
--     int upload_amount
--     int step;
--     int color;
--     baowu_attr_t* attr;
-- }
-- 单个宝物信息，对应船舶宝物
function  rpc_client_boat_baowu_info(info)
	local baowuData = getGameData():getBaowuData()
	if info.amount > 0 then
		baowuData:addBoatBaowu(info)
	else
		baowuData:delBaowu(info.baowuId)
	end
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_BAOWU)
end 

-- 宝物列表---》新加了boat_baowu_t，baowu_t是水手宝物，boat_baowu_t是船舶宝物
--rpc_client_baowu_list(int uid, baowu_t* baowu, boat_baowu_t* boat_baowu);
function rpc_client_baowu_list(baowu_list, boat_baowu)
	local baowuData = getGameData():getBaowuData()
	baowuData:receive(baowu_list, boat_baowu)
	local bagDataHandle = getGameData():getBagDataHandler()
	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_BAOWU)
end 

--洗练
function rpc_client_baowu_refining(err)
	if err == 0 then 
	else 
		Alert:warning({msg =error_info[err].message})
	end 
	local baowu_refine_ui = getUIManager():get("ClsBaowuRefineUI")
	if not tolua.isnull(baowu_refine_ui) then
		baowu_refine_ui:reqRefineBack(err)
	end
end 

--洗练查询
function rpc_client_baowu_refining_check(index, pos, power,attr_data)
	local baowu_refine_ui = getUIManager():get("ClsBaowuRefineUI")
	if not tolua.isnull(baowu_refine_ui) then
		baowu_refine_ui:showRefineTempData(index, pos, attr_data,power)
		baowu_refine_ui:updatePerfetRefineBack()
	end
end 

--洗练保留
function rpc_client_baowu_refining_save(err)
	if err == 0 then 
		Alert:warning({msg = ui_word.BAOWU_TIP_REFINING_SAVE_BACK})
	else 
		Alert:warning({msg =error_info[err].message})
	end 
	local baowu_refine_ui = getUIManager():get("ClsBaowuRefineUI")
	if not tolua.isnull(baowu_refine_ui) then
		baowu_refine_ui:refiningSaveBack(err)
	end
end 

--突破
function rpc_client_baowu_surmount( baowuKey, error)
	if error ~= 0 then 
		Alert:warning({msg =error_info[error].message})
	end 

	local baowu_refine_ui = getUIManager():get("ClsBaowuRefineUI")
	if not tolua.isnull(baowu_refine_ui) then
		baowu_refine_ui:refiningSaveBack(error)
	end
end 

--宝物拆解
function rpc_client_baowu_disassembly(baowu_key, rewards, err)
	if err == 0 then 
		local baowuData = getGameData():getBaowuData()
		baowuData:delBaowu(baowu_key)

		Alert:showCommonReward(rewards)
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			-- backpack_ui:disassembleEffect(rewards, baowu_key)
			backpack_ui:refreshBackpackInfo()
		end

		local clsFleetPartner = getUIManager():get("ClsFleetPartner")
		if not tolua.isnull(clsFleetPartner) then 
			clsFleetPartner:updateView()
		end
	else 
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:setViewTouchEnabled(true)
		end

		local clsFleetPartner = getUIManager():get("ClsFleetPartner")
		if not tolua.isnull(clsFleetPartner) then 
			clsFleetPartner:setViewTouchEnabled(true)
		end
		Alert:warning({msg =error_info[err].message})
	end 
end

--材料合成
function rpc_client_material_synthetise(err, new_material, amount)
	if err == 0 then 
		local equip_material_info = require("game_config/boat/equip_material_info")
		local new_material_name = ""
		local new_material_item = equip_material_info[new_material]
		if new_material_item then
			new_material_name = new_material_item.name
		end
		Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_STR, amount, new_material_name)})
	else 
		Alert:warning({msg =error_info[err].message})
	end 
end

--道具合成
function rpc_client_item_synthetise(err, new_item_id, amount)
	if err == 0 then 
		local item_info = require("game_config/propItem/item_info")
		local new_item_name = ""
		local new_item = item_info[new_item_id]
		if new_item then
			new_item_name = new_item.name
		end
		Alert:warning({msg = string.format(ui_word.BAOWU_MATERIAL_SYNTHETISE_STR, amount, new_item_name)})
	else 
		Alert:warning({msg =error_info[err].message})
	end 
end

--宝物盒子使用返回
function rpc_client_use_baowu_box(itemId, rewards, err)
	if err == 0 then 
		Alert:showCommonReward(rewards)
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo(BAG_PROP_TYPE_SAILOR_BAOWU)
		end
	else 
		Alert:warning({msg = error_info[err].message})
	end 
end

--船舶宝物合成返回
function rpc_client_compose_baowu(baowu_key, err)
	if err == 0 then 
		local get_reward = {}
		get_reward[1] = {amount = 1, id = baowu_key, type = ITEM_INDEX_BAOWU}
		Alert:showCommonReward(get_reward)
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo(BAG_PROP_TYPE_BOAT_BAOWU)
		end
	else 
		Alert:warning({msg = error_info[err].message})
	end 
end

--装备的船舶宝物合成返回
function rpc_client_boat_compose_baowu(baowu_key, err)
	if err == 0 then 
		local get_reward = {}
		get_reward[1] = {amount = 1, id = baowu_key, type = ITEM_INDEX_BAOWU}
		Alert:showCommonReward(get_reward)
	else 
		Alert:warning({msg = error_info[err].message})
	end 
	
	local backpack_equip_ui = getUIManager():get("ClsFleetEquipUI")
	if not tolua.isnull(backpack_equip_ui) then
		backpack_equip_ui:updateView(err)
	end
end


