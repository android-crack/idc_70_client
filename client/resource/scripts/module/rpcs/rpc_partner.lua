--伙伴系统服务端下发协议
local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local skill_info = require("game_config/skill/skill_info")
 -- 67 class refine_attr {
 -- 68     string attr;
 -- 69     int value;
 -- 70     int color;
 -- 71 }
 -- 72 
 -- 73 class partner_baowu_attr {
 -- 74     // 格子
 -- 75     int index;
 -- 76     // 洗练属性列表
 -- 77     refine_attr* refine;
 -- 78 }
 -- 79 
 -- 80 class bag_equip_info {
 -- 81     // 水手id，主角是-1
 -- 82     int id;
 -- 83     // 战斗力
 -- 84     int power;
 -- 85     // 伙伴装备宝物
 -- 86     string* partnerBaowu;
 -- 87     // 伙伴宝物格子洗练属性
 -- 88     partner_baowu_attr* refineAttr;
 -- 89     // 伙伴装备船
 -- 90     int boatKey;
 -- 89     // 伙伴装备船战斗力
 -- 90     int boatPower;
 -- 91     // 伙伴船强化等级
 -- 92     int boatLevel;
 -- 93     // 伙伴船强化成功概率
 -- 94     int boatRate;
 -- 95     // 船装备宝物
 -- 96     string* boatBaowu;
 -- 97 }
--背包中的主角和小伙伴数据
function rpc_client_bag_equip_info(ids, bag_equip_list)
	local partner_data = getGameData():getPartnerData()
	partner_data:setBagEquipInfo(ids, bag_equip_list)
end

--更新单个小伙伴数据
function rpc_client_partner_bag_equip(bag_equip_info)
	local partner_data = getGameData():getPartnerData()
	partner_data:updateBagEquipInfo(bag_equip_info)
end

--伙伴装备船只
function rpc_client_partner_upload_boat(index, boat_key, errno)
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	local fleet_ui = getUIManager():get("ClsFleetPartner")
	if errno == 0 then
	else
		if(errno == 662 and (not tolua.isnull(backpack_ui) or not tolua.isnull(fleet_ui)))then	
            Alert:showJumpWindow(NOBILITY_NOT_ENOUGH, backpack_ui or fleet_ui, {ignore_sea = false})
        else
            Alert:warning({msg =error_info[errno].message, size = 26})
        end
	end
end

--伙伴卸下了船只
function rpc_client_partner_download_boat(errno)
	if errno == 0 then
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

--伙伴装备宝物
function rpc_client_partner_upload_baowu(baowu_key, errno)
	if errno == 0 then

	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

--伙伴卸下宝物
function rpc_client_partner_download_baowu(errno)
	if errno == 0 then
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

--船舶装备宝物
function rpc_client_boat_upload_baowu(errno)
	if errno == 0 then
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
	local backpack_equip_ui = getUIManager():get("ClsFleetEquipUI")
	if not tolua.isnull(backpack_equip_ui) then
		backpack_equip_ui:updateView(errno)
		Alert:warning({msg = ui_word.STR_UP_OK, size = 26})
	end
end


function rpc_client_boat_perfet_upload(errno)
	if errno == 0 then
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
	local backpack_equip_ui = getUIManager():get("ClsFleetEquipUI")
	if not tolua.isnull(backpack_equip_ui) then
		backpack_equip_ui:updateView(errno)
	end
end

--船舶卸下宝物
function rpc_client_boat_download_baowu(errno)
	if errno == 0 then
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
	local backpack_equip_ui = getUIManager():get("ClsFleetEquipUI")
	if not tolua.isnull(backpack_equip_ui) then
		backpack_equip_ui:updateView(errno)
	end
end

--船舶强化  error非0则标识有错误，error为0时，is_success非0则标识成功
function rpc_client_partner_intensify(index, errno, is_success, rate_change)
	if errno > 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
		return
	end

	local strengthen_ui = getUIManager():get("ClsFleetStrengthenUI")
	if not tolua.isnull(strengthen_ui) then
		local partner_data = getGameData():getPartnerData()	
		partner_data:askBagEquipInfo()
		strengthen_ui:updateStrengthenEffect(index, errno, is_success, rate_change)
	end
end

--一键装备返回
function rpc_client_role_perfet_upload(errno)
	if errno == 0 then
		Alert:warning({msg = ui_word.BACKPCAK_PERFECT_UPLOAD, size = 26})
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:updatePerfetUploadBack()
	end
end

--一键拆解返回
function rpc_client_root_disassembly(rewards, errno)
	if errno == 0 then
		local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
		local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
		ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = rewards}))

		local bag_data_handle = getGameData():getBagDataHandler()
		local dismantic_list = bag_data_handle:getDismantleList()
		for _, baowu_key in ipairs(dismantic_list.baowu) do
			getGameData():getBaowuData():delBaowu(baowu_key)
		end
		for _, boat_key in ipairs(dismantic_list.boat) do
			getGameData():getShipData():delBoat(boat_key)
		end
		bag_data_handle:resetDismantleList()

		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo()
			backpack_ui:updatePerfetDismanticBack(true)
			backpack_ui:setViewTouchEnabled(true)
		end
	end
end

----主角数据
function rpc_client_role_info(role_info)
	local partner_data = getGameData():getPartnerData()	
	partner_data:setRoleInfo(role_info)
	local ClsRoleInfoView = getUIManager():get("ClsRoleInfoView")
	if not tolua.isnull(ClsRoleInfoView) then
		ClsRoleInfoView:mkUI(role_info)
	end

	-- local ClsRoleSkill = getUIManager():get("clsRoleSkill")
 --    if not tolua.isnull(ClsRoleSkill) then
	-- 	ClsRoleSkill:changePanel()
 --    end

	local ClsRoleSkillView = getUIManager():get("clsRoleSkillView")
	if not tolua.isnull(ClsRoleSkillView) then
		ClsRoleSkillView:mkUI()
	end


	local clsRoleAttrSkillView = getUIManager():get("clsRoleAttrSkillView")
	if not tolua.isnull(clsRoleAttrSkillView) then
		clsRoleAttrSkillView:mkUI()
	end

	
end

---主角技能重置
function rpc_client_role_skill_reset(errno)
	if errno  == 0 then
		Alert:warning({msg = ui_word.RESET_SKILL_SUCCEED, size = 26})
	end
		
end

---------小伙伴数据
function rpc_client_partner_info(pos, partner_attrs, ids, powers, partner_pos, boat_keys)
	local partner_data = getGameData():getPartnerData()	
	partner_data:setPartnersInfo(pos, partner_attrs, ids, powers, partner_pos, boat_keys)
end

--上阵成功
function rpc_client_partner_appoint(errno)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
		return
	end

	local ui = getUIManager():get("clsAppointSailorUI")
	if not tolua.isnull(ui) then
		ui:closeView()
	end
end

function rpc_client_partner_change_pos(errno, index, pos)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
	end

end

function rpc_client_partner_change_formation_pos(errno)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})

		return
	end
end

function rpc_client_sailor_use_skillbook(errno,skillId,type,skill_pos)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
		return
	end

	local ClsPartnerSkillBookTips = getUIManager():get("ClsPartnerSkillBookTips")
	if not tolua.isnull(ClsPartnerSkillBookTips) then 
		--ClsPartnerSkillBookTips:initUI()
		ClsPartnerSkillBookTips:close()

	end	

	local ClsPartnerInfoView = getUIManager():get("ClsPartnerInfoView")
	if not tolua.isnull(ClsPartnerInfoView) then
		ClsPartnerInfoView:setSelectSkillTips(skill_pos)
		ClsPartnerInfoView:updateSkillPanel()
	end

	local TYPE_ADD_SKILL = 1  --添加水手技能
	local TYPE_UP_SKILL = 3 ----升级水手技能
	local TYPE_EXCHAGE_SKILL = 2
	local text_name = ""
	if type ==TYPE_ADD_SKILL then
		local skill_name = skill_info[skillId].name
		text_name = string.format(ui_word.ADD_SAILOR_SKILL_LEVEL, skill_name) 
		Alert:warning({msg = text_name, size = 26})		
	elseif type == TYPE_UP_SKILL then
		text_name = ui_word.UP_SAILOR_SKILL_LEVEL
		Alert:warning({msg = text_name, size = 26}) 

	elseif type == TYPE_EXCHAGE_SKILL then
		local skill_name = skill_info[skillId].name
		text_name = string.format(ui_word.EXCHAGE_SAILOR_SKILL, skill_name) 
		Alert:warning({msg = text_name, size = 26}) 		
	end

end

function rpc_client_role_skill_upgrade(skill_id,errno)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
		return
	end

	local partner_data = getGameData():getPartnerData()	
	local skill_level = partner_data:getSkillLevel(skill_id)

	if skill_level == ROLE_SKILL_FULL_LEVEL  then
		local ClsRoleSkillView = getUIManager():get("clsRoleSkillView")
		if not tolua.isnull(ClsRoleSkillView) then
			ClsRoleSkillView:playSkillUpLevelEffect(skill_id)
		end
	end

	Alert:warning({msg = ui_word.UP_SAILOR_SKILL_LEVEL, size = 26})

end

function rpc_client_role_add_skill_point(errno)
	if errno == 0 then
		Alert:warning({msg = ui_word.ADD_ROLE_SKILL_POINT, size = 26})
	end
end


function rpc_client_sailor_train(errno)
	if errno ~= 0 then
		Alert:warning({msg = error_info[errno].message, size = 26})
		return
	end

	local ClsPartnerInfoView = getUIManager():get("ClsPartnerInfoView")
	if not tolua.isnull(ClsPartnerInfoView) then 
		--ClsPartnerInfoView:updateAptitudePanel()
		ClsPartnerInfoView:updateStarView()
	end
end

---主角技能开启
function rpc_client_role_open_skill(skill_id)
	local partner_data = getGameData():getPartnerData()	
	partner_data:setRoleOpenSkillId(skill_id)
end
------小伙伴数据

function rpc_client_boat_skin_switch(error, index)
	-- body
end

function rpc_client_boat_skin_expired(index, item_id)
	local dialogQuene = require("gameobj/quene/clsDialogQuene")
	local ClsBoatSkinAlert = require("gameobj/quene/clsBoatSkinAlert")
	dialogQuene:insertTaskToQuene(ClsBoatSkinAlert.new(item_id))
end

