--
-- Author: lzg0946
-- Date: 2016-07-04 20:54:29
-- Function: 爵位协议返回

local error_info = require("game_config/error_info")
local ClsAlert = require("ui/tools/alert")

--同步爵位的信息(经验, 爵位id)
function rpc_client_sync_nobility_info(id, elite_id)
	local nobility_data = getGameData():getNobilityData()
	nobility_data:setNobilityID(id)
	nobility_data:setEliteID(elite_id)

	if getUIManager():isLive("clsNobilityUI") then
		local nobilityUI = getUIManager():get("clsNobilityUI")
		nobilityUI:initUI()
	end

	if getUIManager():isLive("ClsPortLayer") then
		local port_layer = getUIManager():get("ClsPortLayer")
		port_layer:updateProsperLevel()
	end

	--仓库刷新
	if getUIManager():isLive("ClsBackpackMainUI") then
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		backpack_ui:updateView()
	end

	--伙伴刷新
 	if getUIManager():isLive("ClsFleetPartner") then 
 		local fleet_ui = getUIManager():get("ClsFleetPartner")
 		fleet_ui:updateView()
  	end
end

--晋升爵位(错误码)
function rpc_client_nobility_upstep(error_code)
	--错误码等于 0 表示进阶成功
	if getUIManager():isLive("clsNobilityUI") then
		local nobilityUI = getUIManager():get("clsNobilityUI")
		if error_code == 0 then
			nobilityUI:updataUI()
		else
			local nobilityData = getGameData():getNobilityData()
			if nobilityData:isFullLevel() then
				nobilityUI:setTouch(true)
				return
			end
			nobilityUI:setTouch(true)
			EventTrigger(EVENT_DEL_PORT_ITEM)
			nobilityUI:close()
			getUIManager():create("ui/clsPrestigeMainUI")
		end
	end
end


---升级下发声望协议
function rpc_client_prestige_effect(old_prestige, new_prestige)
	--print("=========升级下发声望====old_prestige, new_prestige===============",old_prestige, new_prestige)
	if new_prestige > old_prestige then
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsBattlePower = require("gameobj/quene/clsBattlePower")
		DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = new_prestige,oldPower = old_prestige}))		
	end	
end

---声望提升
function rpc_client_prestige_progress(progress_list)
	local nobility_data = getGameData():getNobilityData()
	nobility_data:setPrestigeInfo(progress_list)

	if getUIManager():isLive("ClsPrestigeMainUI") then
		local ClsPrestigeMainUI = getUIManager():get("ClsPrestigeMainUI")
		ClsPrestigeMainUI:mkUI()	
	end
end

---声望获得
function rpc_client_prestige_increase_effect(get_prestige)
	local DialogQuene = require("gameobj/quene/clsDialogQuene")
	local clsBattlePower = require("gameobj/quene/clsBattlePower")
	DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = get_prestige}))		
end

function rpc_client_go_to_upstep_nobility(error_code)
	if error_code ~= 0 then
		ClsAlert:warning({msg = error_info[error_code].message})
	end
end
