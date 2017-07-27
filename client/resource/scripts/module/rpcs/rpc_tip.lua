-- require("base/cocos_common/event_trigger")
-- require("module/eventHandlers")
local Alert = require("ui/tools/alert")
local rpc_down_info = require("game_config/rpc_down_info")
local error_info = require("game_config/error_info")
local parseMsg = require("module/message_parse.lua")

function rpc_client_show_tip(tip_id, msgs)
	EventTrigger(EVENT_SHOW_TIP, tip_id, msgs)
end

--服务端下发提示信息给客户端 
function rpc_client_download_info(msgs)
	local showStr = require("module/message_parse").parse(msgs)
	Alert:warning({msg = showStr} )
end

function rpc_client_show_error(error, message)
	message = parseMsg.parse(message)
	local msg = "unknow error"
	if error > 0 then
		if error_info[error] then
			msg = error_info[error].message
		end
		-- local ClsPortTeamUI = getUIManager():get("ClsPortTeamUI")
		-- if not tolua.isnull(ClsPortTeamUI) then
		-- 	ClsPortTeamUI:setTouch(true)
		-- end

		local ClsActivityMain = getUIManager():get("ClsActivityMain")
		if not tolua.isnull(ClsActivityMain) then
			ClsActivityMain:setTouch(true)
		end
	else
		if message ~= "" then
			msg = message
		end
	end

	Alert:warning({msg = msg})
end

function rpc_client_tell_tips(msg)
	Alert:warning({msg = msg, size = 26}) 
end