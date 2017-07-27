-- --物品材料协议
-- function rpc_client_material_all_info(list)
-- 	local materialDataHandle = getGameData():getMaterialData()
--  	materialDataHandle:set_material_list(list)
--  	local bagDataHandle = getGameData():getBagDataHandler()
--  	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_ASSEMB)
-- end

-- function rpc_client_drawing_all_info( list )
-- 	local materialDataHandle = getGameData():getMaterialData()
-- 	materialDataHandle:set_drawing_list(list)
-- end

-- function rpc_client_material_add(  materialId, value )
-- 	local materialDataHandle = getGameData():getMaterialData()
--  	materialDataHandle:add_material_item(materialId, value)
--  	EventTrigger(MATERIAL_UPDATE_EVENT)
--  	local bagDataHandle = getGameData():getBagDataHandler()
--  	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_ASSEMB)
-- end

-- function rpc_client_material_del(materialId, value)
-- 	local materialDataHandle = getGameData():getMaterialData()
--  	materialDataHandle:del_material(materialId, value)
--  	local bagDataHandle = getGameData():getBagDataHandler()
--  	bagDataHandle:updatePropsByType(BAG_PROP_TYPE_ASSEMB)
-- end

-- function rpc_client_drawing_add( drawingId, value )
-- 	local materialDataHandle = getGameData():getMaterialData()
-- 	materialDataHandle:add_drawing_item(drawingId, value)
-- end
