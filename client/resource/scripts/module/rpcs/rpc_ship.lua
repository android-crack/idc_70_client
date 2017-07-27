-- 船只的协议文件
-- Author: chenlurong
-- Date: 2016-07-05 15:10:42
--

local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

-- imp module.boat.boat_req {
--   2 
--   3 // 船只属性
--   4 class boat_attr_t
--   5 {
--   6     string attr;
--   7     int    value;
--   8 }
--   9 
--  10 // 船只数据
--  11 class boat_t
--  12 {
--  13     int guid; // 唯一guid
--  14     int id; // 配置表的id
--  15     int quality; // 品质
--  16     string name; // 船名
--  17     int is_changed; // 是否改名
--  18     int power; // 战斗力
--  19     boat_attr_t* rand_attrs; // 随机属性列表
--  19     int rand_amount; // 随机属性最大个数
--  19     boat_attr_t* base_attrs; // 基础属性列表
--  20 }
function rpc_client_boat_list(boats)
	local ship_data = getGameData():getShipData()
	ship_data:receiveOwnBoats(boats)
end

--通知船只数据，1-增加，2-删除，3-修改
function rpc_client_notify_boat_info(boat, reason)
	local ship_data = getGameData():getShipData()
	if reason == 1 then
		ship_data:addToOwnBoats(boat)
	elseif reason == 2 then--删
		ship_data:delBoat(boat.guid)
	else --改
		ship_data:changeBoat(boat)
	end
end

--洗练属性返回
function rpc_client_boat_wash(errno, src_boat, dst_boat)
	if errno == 0 then
		local ship_data = getGameData():getShipData()
		ship_data:changeBoat(src_boat)
		ship_data:changeBoat(dst_boat)

		local refine_ui = getUIManager():get("ClsFleetRefineUI")
		if not tolua.isnull(refine_ui) then
			refine_ui:refreshRefineInfo()
		end

		Alert:warning({msg = ui_word.SHIP_REFINE_SUCCESS, size = 26})
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

--拆解船只返回
function rpc_client_boat_split(errno, guid, rewards)
	if errno == 0 then
		local ship_data = getGameData():getShipData()
		ship_data:delBoat(guid)
		
		Alert:showCommonReward(rewards)
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo()
		end

		local refine_panel = getUIManager():get("ClsFleetRefineUI")
		if not tolua.isnull(refine_panel) then
			refine_panel:clearBackpackBoatInfo()
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
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

function rpc_client_boat_create(err, boat)
	if err == 0 then
		local dock_ui = getUIManager():get("ClsDockUI")
		if not tolua.isnull(dock_ui) then 
			dock_ui:updateDataAndViewBySelectShip()
			dock_ui:showShipEffect(boat)
		end

		local partner_ui = getUIManager():get("ClsFleetPartner")
		if not tolua.isnull(partner_ui) then
			partner_ui:updateListView()
		end 
	else
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end

function rpc_client_boat_create_discount(discount)
	local ship_data = getGameData():getShipData()
	ship_data:setBuildDiscount(discount)
end

function rpc_client_boat_buy_material(err)
	if err > 0 then
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end

function rpc_client_boat_wash_attr_preview(right_boat_key, left_boat_key, attr_info)
	local refine_ui = getUIManager():get("ClsFleetRefineUI")
	if not tolua.isnull(refine_ui) then
		refine_ui:updateRightAttrColor(right_boat_key, left_boat_key, attr_info)
	end
end
