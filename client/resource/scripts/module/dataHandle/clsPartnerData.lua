--伙伴系统数据管理
local error_info = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local boat_attr = require("game_config/boat/boat_attr")
local DialogQuene = require("gameobj/quene/clsDialogQuene")
local clsBattlePower = require("gameobj/quene/clsBattlePower")
local ClsPartnerData = class("ClsPartnerData")

function ClsPartnerData:ctor()
	self.bag_equip_list = {}
	self.bag_ids = {}
	self.role_info = {}

	self.partner_info = {}
	self.role_open_skill_id = {}
	self.bag_equip_power = 0
end

---设置开放的主角技能id
function ClsPartnerData:setRoleOpenSkillId(skill_id)
	self.role_open_skill_id = skill_id
end

function ClsPartnerData:getRoleOpenSkillId()
	return self.role_open_skill_id
end

function ClsPartnerData:clearRoleOpenSkillId(skill_id)
	self.role_open_skill_id = skill_id
end

-- 背包中主角伙伴的装备数据
function ClsPartnerData:setBagEquipInfo(ids, bag_equip_list)
	self.bag_ids = ids --顺序水手id
	self.bag_equip_list = {}
	for i, v in ipairs(bag_equip_list) do
		self.bag_equip_list[v.id] = v
		if v.id == -1 then	---主舰的index
			self.bag_equip_power = v.power
		end
	end

	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:updateView()
	end
	
	local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
	if not tolua.isnull(shipyard_main_ui) then
		shipyard_main_ui:updateBackpackData()
	end

	local baowu_refine_ui = getUIManager():get("ClsBaowuRefineUI")
	if not tolua.isnull(baowu_refine_ui) then
		baowu_refine_ui:showpartnerInfo()
	end

	local strength_ui = getUIManager():get("ClsFleetStrengthenUI")
	if not tolua.isnull(strength_ui) then
		strength_ui:updateBarPercent()
	end
end

-- 背包中主角伙伴的装备数据
function ClsPartnerData:updateBagEquipInfo(bag_equip_info) 


	if self.bag_equip_list[bag_equip_info.id] then
		if self.bag_equip_power < bag_equip_info.power then
			DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = bag_equip_info.power,oldPower = self.bag_equip_power}))
		end
	end
	self.bag_equip_power = bag_equip_info.power
	self.bag_equip_list[bag_equip_info.id] = bag_equip_info
	if bag_equip_info.id == -1 then
		local new_boat_key = bag_equip_info.boatKey
		if self:getMainBoatKey() ~= new_boat_key then
			local ship_data = getGameData():getShipData()
			local boat = ship_data:getBoatDataByKey(new_boat_key)
			local boat_id = 0
			if boat then
				boat_id = boat.id
			end
			self:receiveBoat(new_boat_key, boat_id)
		end
		
		--只有主角数据要改动背包的
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:updateView()
		end
		EventTrigger(EVENT_PORT_CHANGE_BOAT, self:getShowMainBoatId())
	else
		local clsFleetPartner = getUIManager():get("ClsFleetPartner")
		if not tolua.isnull(clsFleetPartner) then 
			clsFleetPartner:updateView()
		end
	end
	
end

function ClsPartnerData:getBagEquipIds()
	return self.bag_ids
end

function ClsPartnerData:getBagEquipList()
	return self.bag_equip_list
end

function ClsPartnerData:getBagEquipInfo(index)
	local sailor_id = self.bag_ids[index]
	return self.bag_equip_list[sailor_id]
end

-- 获取伙伴皮肤 1主舰 2345伙伴
function ClsPartnerData:getBagEquipSkin(index)
	local sailor_id = self.bag_ids[index]
	local bag_equip_info = self.bag_equip_list[sailor_id]
	if bag_equip_info and bag_equip_info.boatKey ~= 0 and bag_equip_info.boat_skin_id and  bag_equip_info.boat_skin_id ~= 0 then--有水手且有船只
		local boat_info = require("game_config/boat/boat_info")
		local skin_id = bag_equip_info.boat_skin_id
		return { skin_id =skin_id,
				 skin_end_time = bag_equip_info.boat_skin_end,
				 skin_enable = bag_equip_info.boat_skin_enable,
				 skin_name = boat_info[skin_id].name,
				 skin_res = boat_info[skin_id].res,
				 item_id = bag_equip_info.boat_skin_item,
	            }
	end
end

--通过boatKey获取船皮肤
function ClsPartnerData:getBagEquipSkinByBoatKey(boat_key)
	for k,v in pairs(self.bag_equip_list) do
		if v.boatKey == boat_key and v.boat_skin_id and v.boat_skin_id ~= 0 then
			local boat_info = require("game_config/boat/boat_info")
			local skin_id = v.boat_skin_id
			return { skin_id =skin_id,
					 skin_end_time = v.boat_skin_end,
					 skin_enable = v.boat_skin_enable,
					 skin_name = boat_info[skin_id].name,
					 skin_res = boat_info[skin_id].res,
					 item_id = v.boat_skin_item,
		            }
		end
	end
end

-- ['percentage_add'] = {{["remote"]=10}},
-- 		['business_add'] = 0,
-- 		['sailing_speed'] = 80,
-- 		['goods_capacity'] = 80,

function ClsPartnerData:getSkinAddBuff(boat_id)
	local skin_add_list = {
		"business_add",
		"sailing_speed",
		"goods_capacity"
	}
	local this_skin_add_list = {}
	local dataTools = require("module/dataHandle/dataTools")
	table.print(boat_attr[boat_id])
	local percentage_add = boat_attr[boat_id].percentage_add
	if percentage_add and percentage_add[1] then
		for k,v in pairs(percentage_add[1]) do
			this_skin_add_list[k] = dataTools:getBoatBaowuAttr(k, v)
		end
	end
	for k,v in pairs(skin_add_list) do
		local attr =  boat_attr[boat_id][v]
		if attr and attr ~= 0 then
			this_skin_add_list[v] = dataTools:getBoatBaowuAttr(v, attr)
		end
	end
	return this_skin_add_list
	-- body
end

--切换皮肤 boat_site 0 主舰 1234伙伴
function ClsPartnerData:changeBoatSkin(boat_site)
	
	GameUtil.callRpc("rpc_server_boat_skin_switch", {boat_site or 0})
end

-- 获取主舰皮肤
function ClsPartnerData:getMainBoatSkin()
	return self:getBagEquipSkin(1)
end

function ClsPartnerData:getBagEquipInfoById(sailor_id)
	return self.bag_equip_list[sailor_id]
end

--获取装备上小伙伴
function ClsPartnerData:getEquipSailorId(index)
	return self.bag_ids[index]
end

--是否有装备上小伙伴
function ClsPartnerData:hasEquipId(index)
	return self.bag_ids[index] ~= 0
end

--请求背包装备数据
function ClsPartnerData:askBagEquipInfo()
	GameUtil.callRpc("rpc_server_bag_equip_info", {}, "rpc_client_bag_equip_info")
end

--请求伙伴装备船
function ClsPartnerData:askUploadBoat(index, boat_key)
	GameUtil.callRpc("rpc_server_partner_upload_boat", {index - 1, boat_key}, "rpc_client_partner_upload_boat")
end

--请求伙伴卸下船
function ClsPartnerData:askDownloadBoat(index)
	if index == 1 then --主角
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:setViewTouchEnabled(true)
		end

		local clsFleetPartner = getUIManager():get("ClsFleetPartner")
		if not tolua.isnull(clsFleetPartner) then 
			clsFleetPartner:setViewTouchEnabled(true)
		end
		Alert:warning({msg = ui_word.BACKPCAK_ROLE_UNDOWNLOAD_BOAT, size = 26})
		return
	end
	GameUtil.callRpc("rpc_server_partner_download_boat", {index - 1}, "rpc_client_partner_download_boat")
end

--请求伙伴装备宝物
function ClsPartnerData:askPartnerUploadBaowu(index, baowu_key)
	GameUtil.callRpc("rpc_server_partner_upload_baowu", {index - 1, baowu_key}, "rpc_client_partner_upload_baowu")
end

--请求伙伴卸载宝物
function ClsPartnerData:askPartnerDownloadBaowu(index, baowu_key)
	GameUtil.callRpc("rpc_server_partner_download_baowu", {index - 1, baowu_key}, "rpc_client_partner_download_baowu")
end

--请求船舶装备宝物
function ClsPartnerData:askBoatUploadBaowu(index, baowu_key, pos)
	GameUtil.callRpc("rpc_server_boat_upload_baowu", {index - 1, baowu_key, pos}, "rpc_client_boat_upload_baowu")
end

--一键装备船舶宝物
function ClsPartnerData:oneKeySetBaowu(index)
	print("index", index)
	GameUtil.callRpc("rpc_server_boat_perfet_upload", {index - 1}, "rpc_client_boat_perfet_upload")
end

--请求船舶卸载宝物
function ClsPartnerData:askBoatDownloadBaowu(index, baowu_key, pos)
	GameUtil.callRpc("rpc_server_boat_download_baowu", {index - 1, baowu_key, pos}, "rpc_client_boat_download_baowu")
end

--请求伙伴船只强化
function ClsPartnerData:askPartnerEnhance(index)
	GameUtil.callRpc("rpc_server_partner_intensify", {index - 1}, "rpc_client_partner_intensify")
end

--请求一键装备
function ClsPartnerData:askPartnerPrefetUpload(index)
	GameUtil.callRpc("rpc_server_role_perfet_upload", {index - 1}, "rpc_client_role_perfet_upload")
end

--请求一键拆解
function ClsPartnerData:askPartnerPrefetDismantic(dismantic_list)
	GameUtil.callRpc("rpc_server_root_disassembly", {dismantic_list.baowu, dismantic_list.boat}, "rpc_client_root_disassembly")
end

----请求主角数据
function ClsPartnerData:askRoleInfo()
	GameUtil.callRpc("rpc_server_role_info", {}, "rpc_client_role_info")
end

---技能加点
function ClsPartnerData:upgradeRoleSkill(skillId)
	GameUtil.callRpc("rpc_server_role_skill_upgrade", {skillId})
end

---重置技能
function ClsPartnerData:resetSkillPoint()
	GameUtil.callRpc("rpc_server_role_skill_reset", {}, "rpc_client_role_skill_reset")
end

function ClsPartnerData:setRoleInfo(role_info)
	self.role_info = role_info	
end

function ClsPartnerData:getRoleInfo()
	return self.role_info	
end

---判断升级的主角技能等级是否满级
function ClsPartnerData:getSkillLevel(skill_id)

	if not self.role_info then return end 
	for k,v in pairs(self.role_info.skills) do
		if v.skillId == skill_id then
			return v.level
		end
	end
end


--是否装备船
function ClsPartnerData:isEquipBoat(boat_key)
	for i, v in pairs(self.bag_equip_list) do
		if tonumber(v.boatKey) == tonumber(boat_key) then
			return true
		end
	end
	return false	
end

--是否装备水手宝物
function ClsPartnerData:isEquipSailorBaowu(baowu_key)
	for i, v in pairs(self.bag_equip_list) do
		for k, id in pairs(v.partnerBaowu) do
			if id == baowu_key then
				return true
			end
		end
	end
	return false	
end

--是否装备船舶宝物
function ClsPartnerData:isEquipBoatBaowu(baowu_key)
	local equip_count = 0
	for i, v in pairs(self.bag_equip_list) do
		for k, id in pairs(v.boatBaowu) do
			if id == baowu_key then
				equip_count = equip_count + 1
			end
		end
	end
	return equip_count	
end

--获取主舰船key
function ClsPartnerData:receiveBoat(boat_key, boat_id)
	self.main_boat_key = boat_key
	self.main_boat_id = boat_id
end

--获取主舰船key
function ClsPartnerData:getMainBoatKey()
	return self.main_boat_key
end

--获取主舰船id
function ClsPartnerData:getMainBoatId()
	return self.main_boat_id
end

function ClsPartnerData:getShowMainBoatId()
	local main_skin_data = self:getMainBoatSkin()
	if main_skin_data and main_skin_data.skin_enable == 1 then
		return main_skin_data.skin_id
	end
	return self:getMainBoatId()
end

--获取主舰船数据
function ClsPartnerData:getMainBoatData()
	local boat_key = self:getMainBoatKey()
	local ship_data = getGameData():getShipData()
	return ship_data:getBoatDataByKey(boat_key)
end

-----------编制数据---
function ClsPartnerData:setPartnersInfo(pos, partner_attrs, ids, powers, partner_pos, boat_keys)
	self.partner_info.pos = pos
	self.partner_info.partner_attrs = partner_attrs
	self.partner_info.ids = ids
	self.partner_info.powers = powers
	self.partner_info.partner_pos = partner_pos
	self.partner_info.boat_keys = boat_keys

	--同步更新背包里面的水手id
	for k,v in pairs(self.bag_ids) do
		if v ~= -1 and v ~= ids[k - 1] then
			self.bag_equip_list[v] = nil
			self.bag_ids[k] = ids[k - 1]
		end
	end

	local clsFleetPartner = getUIManager():get("ClsFleetPartner")
	if not tolua.isnull(clsFleetPartner) then 
		clsFleetPartner:updateView()
	end

end

function ClsPartnerData:getABoatById(id)
	local ship_data = getGameData():getShipData()
	local own_boats = ship_data:getOwnBoats()

	local used_boat = self:getAllUsedBoat()

	local boat = nil
	for k, v in pairs(own_boats) do
		if v.id == id and not used_boat[v.guid] then
			return v
		end
	end

	return nil
end

--获取固定位置对应的船舶key，没有为nil
function ClsPartnerData:getBoatKeyBySailorId(index)
	return self.partner_info.boat_keys[index]
end

--水手与船是否匹配
function ClsPartnerData:sailorMatchBoat(sailor_job, boat_id)

	local boat_occup = boat_attr[boat_id].occup
	local match = false
	for k, v in pairs(boat_occup) do
		if sailor_job == v then
			match = true
		end
	end
	return match
end

--已经上阵的船{[2] = true,[3] = true}
function ClsPartnerData:getAllUsedBoat()
	local player_boat = self:getMainBoatKey()

	local temp = {}
	temp[player_boat] = true

	for k, v in pairs(self.partner_info.boat_keys) do
		if v ~= 0 then
			temp[v] = true
		end
	end
	return temp
end

function ClsPartnerData:getPartnersInfo()
	return self.partner_info
end

--小伙伴列表
function ClsPartnerData:askForPartnersInfo()
	GameUtil.callRpc("rpc_server_partner_info", {}, "rpc_client_partner_info")
end

--上阵
function ClsPartnerData:askForPartnerApponit(index, sailor_id)
	GameUtil.callRpc("rpc_server_partner_appoint", {index, sailor_id}, "rpc_client_partner_appoint")
end

--交换位置
function ClsPartnerData:askForChangePos(old_index, target_index)
	GameUtil.callRpc("rpc_server_partner_change_pos", {old_index, target_index}, "rpc_client_partner_change_pos")
end

--换阵型位置
function ClsPartnerData:askForChangeLineupPos(id, index)
	GameUtil.callRpc("rpc_server_partner_change_formation_pos", {id, index}, "rpc_client_partner_change_formation_pos")
end

--加技能
function ClsPartnerData:askAddSkill(sailorId, itemId, ord, type)
	GameUtil.callRpc("rpc_server_sailor_use_skillbook", {sailorId, itemId, ord, type}, "rpc_client_sailor_use_skillbook")
end

--洗练水手
function ClsPartnerData:askTrainSailor(sailorId)
	GameUtil.callRpc("rpc_server_sailor_train", {sailorId}, "rpc_client_sailor_train")
end
-----------小伙伴数据---


return ClsPartnerData