--[[
--船长信息服务器结果返回
]]
local error_info = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")

function rpc_client_captain_info(datas)
	local captainInfoData = getGameData():getCaptainInfoData()
	captainInfoData:receiveCaptainInfo(datas)
end

function rpc_client_user_set_icon(err, icon)
	-- local captain_main_ui = element_mgr:get_element("CaptainMain")
	-- if not tolua.isnull(captain_main_ui) then
	-- 	captain_main_ui:setIconToBase(icon)
	-- 	captain_main_ui:updateHead(icon)
	-- end

	local player_data = getGameData():getPlayerData()
	player_data:setIcon(icon)

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:updateHead(icon)
	end
	Alert:warning({msg = ui_word.CHANGE_HEAD_SUCCESS})
end
