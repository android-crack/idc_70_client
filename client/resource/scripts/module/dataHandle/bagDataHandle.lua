local boat_attr = require("game_config/boat/boat_attr")
local sailor_info = require("game_config/sailor/sailor_info")
local equip_material_info = require("game_config/boat/equip_material_info")
local baozang_info = require("game_config/collect/baozang_info")
local nobility_data = require("game_config/nobility_data")
local on_off_info = require("game_config/on_off_info")
local ClsBagDataHandle = class("bagDataHandle")

local BOAT_TAG = 1
local BAOWU_TAG = 2
local filter_boat_id = 36

ClsBagDataHandle.ctor = function(self)
	self.compose_list = {}
end

--一键合成请求
ClsBagDataHandle.askOnekeyCompose = function(self, list)
	GameUtil.callRpc("rpc_server_onekey_compose", {list})
end

ClsBagDataHandle.askPropsByType = function(self, propType)
	if propType == BAG_PROP_TYPE_ASSEMB then
		
	elseif propType == BAG_PROP_TYPE_COMSUME then

	end
end

ClsBagDataHandle.updatePropsByType = function(self, propType)
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) and propType then
		backpack_ui:refreshBackpackInfo(propType)
	end
end

ClsBagDataHandle.getPropsByType = function(self, propType, ...)
	if not propType then
		return {}
	end
	local baowuData = getGameData():getBaowuData()
	local materialDataHandle = getGameData():getMaterialData()
	local propDataHandle = getGameData():getPropDataHandler()

	if propType == BAG_PROP_TYPE_SAILOR_BAOWU or propType == BAG_PROP_TYPE_BOAT_BAOWU then
		local propSubType1 = nil
		local propSubType2 = nil
		for i=1,select("#",...) do
			local arg=select(i,...)
			if i == 1 then
				propSubType1 = arg
			elseif i == 2 then
				propSubType2 = arg
			end
		end
		return baowuData:getArrayList(propType, propSubType1, propSubType2)
	elseif propType == BAG_PROP_TYPE_ASSEMB then
		return materialDataHandle:get_materials()
	elseif propType == BAG_PROP_TYPE_COMSUME then
		return propDataHandle:get_propItems()
	end
end

--对应背包数据索引
ClsBagDataHandle.getBackpackTabData = function(self, prop_type, select_index)
	local baowu_data = getGameData():getBaowuData()
	local material_data_handle = getGameData():getMaterialData()
	local prop_data_handle = getGameData():getPropDataHandler()
	local ship_data = getGameData():getShipData()
	local list = {}
	self.compose_list = {}
	
	if prop_type == BACKPACK_TAB_ALWAYS then
		local fleet_list = ship_data:getOwnBoats()
		local baowu_list = baowu_data:getSailorBaowuList()
		local common_list = prop_data_handle:getPropItemsCommon()
		local skin_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_SKIN)

		self.dismantle_list = {}
		list[1] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(skin_list, BAG_PROP_TYPE_COMSUME, select_index, nil, true)} --皮肤
		list[2] = {type = BAG_PROP_TYPE_FLEET, list = self:sortBackpackList(fleet_list, BAG_PROP_TYPE_FLEET, select_index, nil, true)}
		list[3] = {type = BAG_PROP_TYPE_SAILOR_BAOWU, list = self:sortBackpackList(baowu_list, BAG_PROP_TYPE_SAILOR_BAOWU, select_index, nil, true)}
		list[4] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(common_list, BAG_PROP_TYPE_COMSUME, select_index, nil, true)} --图纸

	elseif prop_type == BACKPACK_TAB_BOAT then
		local fleet_list = ship_data:getOwnBoats()
		local boat_baowu_list = baowu_data:getBoatBaoWuList()
		local boat_box_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_BOAT_BOX)
		local drawing_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_DRAWING)
		local skin_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_SKIN)
		local material_list = material_data_handle:get_materials()

		list[1] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(skin_list, BAG_PROP_TYPE_COMSUME, select_index)}
		list[2] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(boat_box_list, BAG_PROP_TYPE_COMSUME, select_index)}
		list[3] = {type = BAG_PROP_TYPE_FLEET, list = self:sortBackpackList(fleet_list, BAG_PROP_TYPE_FLEET, select_index)}
		list[4] = {type = BAG_PROP_TYPE_BOAT_BAOWU, list = self:sortBackpackList(boat_baowu_list, BAG_PROP_TYPE_BOAT_BAOWU, select_index)}
		list[5] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(drawing_list, BAG_PROP_TYPE_COMSUME, select_index)} --图纸
		list[6] = {type = BAG_PROP_TYPE_ASSEMB, list = self:sortBackpackList(material_list, BAG_PROP_TYPE_ASSEMB, select_index)} --造船材料
	
	elseif prop_type == BACKPACK_TAB_EQUIP then
		local box_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_BOX)
		local baowu_list = baowu_data:getSailorBaowuList()
		local essence_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_ESSENCE)

		list[1] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(box_list, BAG_PROP_TYPE_COMSUME, select_index)} --宝物盒子
		list[2] = {type = BAG_PROP_TYPE_SAILOR_BAOWU, list = self:sortBackpackList(baowu_list, BAG_PROP_TYPE_SAILOR_BAOWU, select_index)}
		list[3] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(essence_list, BAG_PROP_TYPE_COMSUME, select_index)} --宝物精华
	
	else
		local prop_other_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_OTHER)
		list[1] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(prop_other_list, BAG_PROP_TYPE_COMSUME, select_index)} --其它类别
	end

	return list
end

ClsBagDataHandle.getFleetPartnerData = function(self, select_index)
	local baowu_data = getGameData():getBaowuData()
	local ship_data = getGameData():getShipData()
	local prop_data_handle = getGameData():getPropDataHandler()
	local skin_list = prop_data_handle:getPropItemsByType(PROP_ITEM_BACKPACK_SKIN)
	local list = {}
	list[1] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(skin_list, BAG_PROP_TYPE_COMSUME, select_index, nil, true)} --皮肤
	list[2] = {type = BAG_PROP_TYPE_FLEET, list = self:sortBackpackList(ship_data:getOwnBoats(), BAG_PROP_TYPE_FLEET, select_index)}
	list[3] = {type = BAG_PROP_TYPE_SAILOR_BAOWU, list = self:sortBackpackList(baowu_data:getSailorBaowuList(), BAG_PROP_TYPE_SAILOR_BAOWU, select_index)}
	return list
end

ClsBagDataHandle.getBackpackData = function(self, prop_type, select_index, is_refine_view)
	local baowu_data = getGameData():getBaowuData()
	local material_data_handle = getGameData():getMaterialData()
	local prop_data_handle = getGameData():getPropDataHandler()
	local ship_data = getGameData():getShipData()
	local list = {}
	if prop_type == BAG_PROP_TYPE_SAILOR_BAOWU then
		list[1] = {type = prop_type, list = self:sortBackpackList(baowu_data:getSailorBaowuList(), prop_type, select_index, is_refine_view)}

	elseif prop_type == BAG_PROP_TYPE_BOAT_BAOWU then
		list[1] = {type = prop_type, list = self:sortBackpackList(baowu_data:getBoatBaoWuList(), prop_type, select_index, is_refine_view)}

	elseif prop_type == BAG_PROP_TYPE_ASSEMB then
		list[1] = {type = prop_type, list = self:sortBackpackList(material_data_handle:get_materials(), prop_type, select_index, is_refine_view)}

	elseif prop_type == BAG_PROP_TYPE_COMSUME then
		list[1] = {type = prop_type, list = self:sortBackpackList(prop_data_handle:get_propItems(), prop_type, select_index, is_refine_view)}

	elseif prop_type == BAG_PROP_TYPE_FLEET then
		list[1] = {type = prop_type, list = self:sortBackpackList(ship_data:getOwnBoats(), prop_type, select_index, is_refine_view)}

	elseif prop_type == BAG_PROP_TYPE_ALL then
		
		list[1] = {type = BAG_PROP_TYPE_BOAT_BAOWU, list = self:sortBackpackList(baowu_data:getBoatBaoWuList(), BAG_PROP_TYPE_BOAT_BAOWU, select_index, is_refine_view)}
		list[2] = {type = BAG_PROP_TYPE_ASSEMB, list = self:sortBackpackList(material_data_handle:get_materials(), BAG_PROP_TYPE_ASSEMB, select_index, is_refine_view)}
		list[3] = {type = BAG_PROP_TYPE_COMSUME, list = self:sortBackpackList(prop_data_handle:get_propItems(), BAG_PROP_TYPE_COMSUME, select_index, is_refine_view)}
	end
	return list
end

ClsBagDataHandle.sortBackpackList = function(self, list, prop_type, select_index, is_refine_view, is_alway_tab)
	local sort_fun
	local data_list = {}
	local partner_data = getGameData():getPartnerData()
	if prop_type == BAG_PROP_TYPE_SAILOR_BAOWU then
		for k,v in pairs(list) do
			local is_equip = false
			local show_tag = nil
			if select_index then
				is_equip = partner_data:isEquipSailorBaowu(v.baowuKey)
				show_tag = self:getSailorBaoWuTag(v, is_equip, select_index)
				if not show_tag then --当不可洗练显示是否可以拆解
					show_tag = self:getSailorBaoWuDismantlingTag(v, is_equip, select_index)
					if show_tag and is_alway_tab then
						self.dismantle_list[v.baowuKey] = BAOWU_TAG
					end
				end
			end
			if not is_equip then
				data_list[#data_list + 1] = {type = prop_type, data = v, tag = show_tag}
			end
		end

		sort_fun = function(a, b)
			local a_tag = 0
			local b_tag = 0
			if a.tag then
				a_tag = a.tag.value
			end
			if b.tag then
				b_tag = b.tag.value
			end
			if a_tag ~= b_tag then
				return a_tag > b_tag
			end
			local a_baowu_level = baozang_info[a.data.baowuId].limitLevel
			local b_baowu_level = baozang_info[b.data.baowuId].limitLevel
			if a_baowu_level ~= b_baowu_level then
				return a_baowu_level > b_baowu_level
			end
			return a.data.color > b.data.color
		end

	elseif prop_type == BAG_PROP_TYPE_BOAT_BAOWU then
		for k,v in pairs(list) do
			local left_num = v.amount - v.upload_amount
			local show_tag = self:getBoatBaoWuTag(v, left_num, select_index)
			if left_num > 0 then
				data_list[#data_list + 1] = {type = prop_type, data = v, tag = show_tag}
			end
		end

		sort_fun = function(a, b)
			local a_tag = 0
			local b_tag = 0
			if a.tag then
				a_tag = a.tag.value
			end
			if b.tag then
				b_tag = b.tag.value
			end
			if a_tag ~= b_tag then
				return a_tag > b_tag
			end
			local a_baowu_level = baozang_info[a.data.baowuId].level
			local b_baowu_level = baozang_info[b.data.baowuId].level
			if a_baowu_level ~= b_baowu_level then
				return a_baowu_level > b_baowu_level
			end
			return a.data.baowuId > b.data.baowuId
		end

	elseif prop_type == BAG_PROP_TYPE_ASSEMB then
		for k,v in pairs(list) do
			local show_tag = self:getCommonItemTag(prop_type, v)
			data_list[#data_list + 1] = {type = prop_type, data = v, tag = show_tag}
		end

		sort_fun = function(a, b)
			local a_tag = 0
			local b_tag = 0
			if a.tag then
				a_tag = a.tag.value
			end
			if b.tag then
				b_tag = b.tag.value
			end
			if a_tag ~= b_tag then
				return a_tag > b_tag
			end
			
			if a.data.baseData.type == b.data.baseData.type then
				return a.data.baseData.level > b.data.baseData.level
			else
				return a.data.baseData.type > b.data.baseData.type
			end
		end

	elseif prop_type == BAG_PROP_TYPE_COMSUME then
		for k,v in pairs(list) do
			local show_tag = self:getItemUseTag(prop_type, v)
			if not show_tag then
				show_tag = self:getCommonItemTag(prop_type, v)
			end
			data_list[#data_list + 1] = {type = prop_type, data = v, tag = show_tag}
		end

		sort_fun = function(a, b)
			local a_tag = 0
			local b_tag = 0
			if a.tag then
				a_tag = a.tag.value
			end
			if b.tag then
				b_tag = b.tag.value
			end
			if a_tag ~= b_tag then
				return a_tag > b_tag
			end

			if a.data.baseData.sort == b.data.baseData.sort then
				return a.data.id < b.data.id
			else
				return a.data.baseData.sort < b.data.baseData.sort
			end
			
		end
	elseif prop_type == BAG_PROP_TYPE_FLEET then
		for k,v in pairs(list) do
			local is_equip = false
			local show_tag = nil
			
			if select_index then
				is_equip = partner_data:isEquipBoat(v.guid)
				if is_refine_view then--洗练界面只要洗练状态
					local non_attr_num
					show_tag, non_attr_num = self:getBoatRefineTag(v, is_equip, select_index)
					is_equip = non_attr_num or is_equip
				else
					show_tag = self:getBoatEquipTag(v, is_equip, select_index)  --优先显示可装备
					if not show_tag then
						show_tag = self:getBoatRefineTag(v, is_equip, select_index)
						if not show_tag then --当不可洗练显示是否可以拆解
							show_tag = self:getBoatDismantlingTag(v, is_equip, select_index)
							if show_tag then
								if show_tag and is_alway_tab then
									self.dismantle_list[v.guid] = BOAT_TAG
								end
							end
						end
					end
				end
			end
			if not is_equip then
				data_list[#data_list + 1] = {type = prop_type, data = v, tag = show_tag}
			end
		end

		sort_fun = function(a, b)
			if a and b then
				local a_boat_type = a.data.id
				local b_boat_type = b.data.id
				local a_tag = 0
				local b_tag = 0
				if a.tag then
					a_tag = a.tag.value
				end
				if b.tag then
					b_tag = b.tag.value
				end
				if a_tag ~= b_tag then
					return a_tag > b_tag
				end

				--判断逻辑由船只等级>品质，改为爵位>品质
				if boat_attr[a_boat_type].nobility_id ~= boat_attr[b_boat_type].nobility_id then
					return boat_attr[a_boat_type].nobility_id > boat_attr[b_boat_type].nobility_id
				end

				if a.data.quality ~= b.data.quality then
					return a.data.quality > b.data.quality
				end

				return a_boat_type > b_boat_type
			end
		end
	end

	table.sort(data_list, sort_fun)
	return data_list
end

ClsBagDataHandle.getDismantleList = function(self)
	local dismantle_list = {}
	dismantle_list.baowu = {}
	dismantle_list.boat = {}
	for baowuKey, tag in pairs(self.dismantle_list or {}) do
		if tag == BAOWU_TAG then
			table.insert(dismantle_list.baowu, baowuKey)
		else
			table.insert(dismantle_list.boat, baowuKey)
		end
	end
	return dismantle_list
end

ClsBagDataHandle.resetDismantleList = function(self)
	self.dismantle_list = {}
end

--获得可合成的道具物品列表
ClsBagDataHandle.getComposeList = function(self)
	local total_cost = 0
	local list = {}
	for i,v in ipairs(self.compose_list) do
		total_cost = total_cost + v.cost
		list[#list + 1] = {id = v.id, type = v.type}
	end
	return list, total_cost
end

--判断水手宝物与已装备宝物进行对比
ClsBagDataHandle.getSailorBaoWuTag = function(self, data , is_equip, select_index)
	if is_equip then return nil end

	local partner_data = getGameData():getPartnerData()
	local equip_sailor_id = partner_data:getEquipSailorId(select_index)
	local player_data = getGameData():getPlayerData()
	local equip_level = player_data:getLevel()
	local baowu_info = baozang_info[data.baowuId]
	if equip_level < baowu_info.limitLevel then
		return nil
	end

	local cur_bag_equip_info = partner_data:getBagEquipInfo(select_index)

	for i, v in ipairs(cur_bag_equip_info.partnerBaowu) do
		if string.len(v) > 0 then
			local baowu_data = getGameData():getBaowuData()
			local partner_baowu_info = baowu_data:getInfoById(v)
			local cur_equip_info = baozang_info[partner_baowu_info.baowuId]

			if cur_equip_info.type == baowu_info.type then

				if cur_equip_info.limitLevel < baowu_info.limitLevel then
					return TAG_TYPE.CAN_EQUIP
				elseif cur_equip_info.limitLevel == baowu_info.limitLevel then
					if partner_baowu_info.color < data.color then
						return TAG_TYPE.CAN_EQUIP   
					end                 
				end
				return nil
			end
		end
	end
	return TAG_TYPE.CAN_EQUIP
end

--判断水手宝物与已装备宝物进行对比，是否可拆解
ClsBagDataHandle.getSailorBaoWuDismantlingTag = function(self, data , is_equip, select_index)
	if is_equip then return nil end

	local onOffData = getGameData():getOnOffData()
	if(not onOffData:isOpen(on_off_info.TREASURE_DISMANTLE.value))then return nil end

	local baowu_info = baozang_info[data.baowuId]
	local partner_data = getGameData():getPartnerData()
	local cur_bag_equip_info = partner_data:getBagEquipInfo(select_index)

	for i, v in ipairs(cur_bag_equip_info.partnerBaowu) do
		if string.len(v) > 0 then
			local baowu_data = getGameData():getBaowuData()
			local partner_baowu_info = baowu_data:getInfoById(v)
			local cur_equip_info = baozang_info[partner_baowu_info.baowuId]

			if cur_equip_info.type == baowu_info.type then
				if cur_equip_info.limitLevel > baowu_info.limitLevel then
					return TAG_TYPE.CAN_DISMANTLE
				elseif cur_equip_info.limitLevel == baowu_info.limitLevel then
					if partner_baowu_info.color > data.color then
						return TAG_TYPE.CAN_DISMANTLE   
					end                 
				end
				return nil
			end
		end
	end
	return nil
end

--判断船只的状态，已装备或者是否可以装备(改成可出战)
ClsBagDataHandle.getBoatEquipTag = function(self, data, is_equip, select_index)
	if is_equip then return nil end
	if data.id == filter_boat_id then return nil end

	local partner_data = getGameData():getPartnerData()
	local equip_sailor_id = partner_data:getEquipSailorId(select_index)
	local player_data = getGameData():getPlayerData()
	-- local equip_level = player_data:getLevel()
	local equip_profession = -1
	if equip_sailor_id == -1 then 
		equip_profession = player_data:getProfession()
	else
		equip_profession = sailor_info[equip_sailor_id].job[1]
	end
	local boat_info = boat_attr[data.id]

	local nobility_config = nobility_data[boat_info.nobility_id]
	if nobility_config then -- 有爵位才判断
		local current_level = getGameData():getNobilityData():getCurrentNobilityData().level
		if current_level < nobility_config.level then
			return nil
		end
	end

	local occup = boat_info.occup
	local can_equip = false
	for k, v in ipairs(occup) do
		if equip_profession == v then
			can_equip = true
			break
		end
	end
	if not can_equip then return nil end

	local cur_bag_equip_info = partner_data:getBagEquipInfo(select_index)
	local cur_boat_key = cur_bag_equip_info.boatKey
	if cur_boat_key == 0 then
		return TAG_TYPE.CAN_BATTLE
	end

	local ship_data = getGameData():getShipData()
	local ship_info = ship_data:getBoatDataByKey(cur_boat_key)
	if ship_info.id == filter_boat_id then return nil end
	local cur_boat_info = boat_attr[ship_info.id]

	if cur_boat_info.nobility_id < boat_info.nobility_id then
		return TAG_TYPE.CAN_BATTLE
	end
	if cur_boat_info.nobility_id == boat_info.nobility_id then
		if ship_info.quality < data.quality then
			return TAG_TYPE.CAN_BATTLE
		end
	end
	return nil
end

--船只洗练状态
ClsBagDataHandle.getBoatRefineTag = function(self, data, is_equip, select_index)
	if is_equip then return nil end
	if data.id == filter_boat_id then return nil end

	local onOffData = getGameData():getOnOffData()
	if(not onOffData:isOpen(on_off_info.BACKPACK_BOATWASH.value))then return nil end

	local partner_data = getGameData():getPartnerData()
	local cur_bag_equip_info = partner_data:getBagEquipInfo(select_index)
	local cur_boat_key = cur_bag_equip_info.boatKey
	if cur_boat_key == 0 then return nil end

	local ship_data = getGameData():getShipData()
	local bp_ship_info = ship_data:getBoatDataByKey(data.guid)
	local bp_rand_attr = bp_ship_info.rand_attrs
	if #bp_rand_attr == 0 then
		return nil, true
	end

	--爵位够才显示
	local boat_info = boat_attr[data.id]
	local nobility_config = nobility_data[boat_info.nobility_id]
	if nobility_config then -- 有爵位才判断
		local current_level = getGameData():getNobilityData():getCurrentNobilityData().level
		if current_level < nobility_config.level then
			return nil
		end
	end
	
	local cur_ship_info = ship_data:getBoatDataByKey(cur_boat_key)
	local cur_rand_amount = cur_ship_info.rand_amount
	local cur_rand_attr = cur_ship_info.rand_attrs
	local cur_attr_worst_color = 100
	if #cur_rand_attr < cur_rand_amount then
		cur_attr_worst_color = -1
	end

	for i, bp_attr in ipairs(bp_rand_attr) do
		local has_same = false

		for j, cur_attr in ipairs(cur_rand_attr) do
			if cur_attr.attr == bp_attr.attr then
				has_same = true
				if cur_attr.value < bp_attr.value then
					return TAG_TYPE.CAN_REFINE
				end
			end
			if cur_attr_worst_color ~= -1 and cur_attr.quality < cur_attr_worst_color then
				cur_attr_worst_color = cur_attr.quality
			end
		end

		if  not has_same and bp_attr.quality > cur_attr_worst_color then
			return TAG_TYPE.CAN_REFINE
		end 
	end

	return nil
end

--船是否可以拆解
ClsBagDataHandle.getBoatDismantlingTag = function(self, data, is_equip, select_index)
	if is_equip then return nil end
	if data.id == filter_boat_id then return nil end

	local onOffData = getGameData():getOnOffData()
	if(not onOffData:isOpen(on_off_info.DISMANTLE.value))then return nil end

	local partner_data = getGameData():getPartnerData()
	local cur_bag_equip_info = partner_data:getBagEquipInfo(select_index)
	local cur_boat_key = cur_bag_equip_info.boatKey

	if cur_boat_key == 0 then return nil end
	if cur_boat_key == filter_boat_id then return nil end

	local ship_data = getGameData():getShipData()
	local bp_ship_info = ship_data:getBoatDataByKey(data.guid)
	local bp_ship_config = boat_attr[data.id]
	
	local cur_ship_info = ship_data:getBoatDataByKey(cur_boat_key)
	local cur_ship_config = boat_attr[cur_ship_info.id]
	local cur_nobility_config = nobility_data[cur_ship_config.nobility_id]
	local bp_nobility_config = nobility_data[bp_ship_config.nobility_id]
	if bp_nobility_config and cur_nobility_config then -- 有爵位才判断
		if bp_nobility_config.level < cur_nobility_config.level then
			return TAG_TYPE.CAN_DISMANTLE
		elseif bp_nobility_config.level == cur_nobility_config.level then
			if bp_ship_info.quality < cur_ship_info.quality then
				return TAG_TYPE.CAN_DISMANTLE
			end
		end
	end
	return nil
end

--船舶宝物 可合成标签判断
ClsBagDataHandle.getBoatBaoWuTag = function(self, data, left_num, select_index) 
	if left_num <= 0 then return nil end

	local partner_data = getGameData():getPartnerData()
	local equip_sailor_id = partner_data:getEquipSailorId(select_index)
	local player_data = getGameData():getPlayerData()
	local equip_level = player_data:getLevel()
	local baowu_info = baozang_info[data.baowuId]
	if equip_level < baowu_info.limitLevel then
		return nil
	elseif baowu_info.compose_amount > 0 then
		local compose_num = math.floor(left_num/baowu_info.compose_amount)
		if compose_num > 0 then
			self.compose_list[#self.compose_list + 1] = {id = data.baowuId, type = ITEM_INDEX_BAOWU, cost = (baowu_info.compose_consume * compose_num)}
			return TAG_TYPE.CAN_SYNTHETISE
		end
	end
end

--道具材料 可合成标签
ClsBagDataHandle.getCommonItemTag = function(self, bag_type, data)
	local base_data = data.baseData
	local amount  = data.count

	--爵位够才显示
	local current_level = getGameData():getNobilityData():getCurrentNobilityData().level
	local nobility_config = nobility_data[base_data.noblelimit]
	if nobility_config then -- 有爵位才判断
		if current_level < nobility_config.level then
			return nil
		end
	end
	
	if bag_type == BAG_PROP_TYPE_COMSUME then
		local player_data = getGameData():getPlayerData()
		local player_level = player_data:getLevel()
		if player_level < base_data.levellimit then
			return nil
		elseif base_data.cansynthetic and base_data.cansynthetic == 1 then
			if amount >= base_data.synthetic_num then
				self.compose_list[#self.compose_list + 1] = {id = data.id, type = ITEM_INDEX_PROP, cost = 0}
				return TAG_TYPE.CAN_SYNTHETISE
			end
		end
	elseif bag_type == BAG_PROP_TYPE_ASSEMB then
		if base_data.flag and base_data.flag == 1 then
			if amount >= base_data.need then
				local synthetise_config = self:getMaterialSynthetiseInfo(base_data)
				if synthetise_config then
					self.compose_list[#self.compose_list + 1] = {id = data.id, type = ITEM_INDEX_MATERIAL, cost = 0}
					return TAG_TYPE.CAN_SYNTHETISE
				end
			end
		end
	end

	return nil
end

--获取可使用标签
ClsBagDataHandle.getItemUseTag = function(self, bag_type, data)
	local base_data = data.baseData   
	local player_data = getGameData():getPlayerData()
	local player_level = player_data:getLevel()
	if player_level < base_data.UseGradeLimit then-- 使用等级到了才显示
		return nil
	end

	if base_data.useable == 1 then
		return TAG_TYPE.CAN_USE
	end

	return nil
end


ClsBagDataHandle.getMaterialSynthetiseInfo = function(self, config)
	for k,v in pairs(equip_material_info) do
		if v.type == config.type and v.level == (config.level + 1) then
			return v
		end
	end
	return nil
end

ClsBagDataHandle.getCanEquipData = function(self, id, site, partner_index)
	local partner_data = getGameData():getPartnerData()
	self.bag_equip_data = partner_data:getBagEquipInfoById(id)
	local boat_equip_data = self.bag_equip_data.boatBaowu
	
	local baowu_type = {}
	for k,v in pairs(boat_equip_data) do
		if baozang_info[v] and site ~= k then
			baowu_type[#baowu_type + 1] = baozang_info[v].type
		end
	end
	
	local data_list = self:getBackpackData(BAG_PROP_TYPE_BOAT_BAOWU, partner_index)
	local equip_list = {}
	local my_level = getGameData():getPlayerData():getLevel()
	for i, v in ipairs(data_list[1].list) do
		if my_level < baozang_info[v.data.baowuId].limitLevel then  --装备等级过高
			
		else  --过滤已经装过的
			local can_use = true
			for k1, v1 in pairs(baowu_type) do
			if v1 == baozang_info[v.data.baowuId].type then
				can_use = false
					break
				end
			end
			
			if can_use then
				equip_list[#equip_list + 1] = v
			end
		end
	end
	return equip_list
end

return ClsBagDataHandle