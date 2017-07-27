--
-- Author: Ltian
-- Date: 2015-10-26 14:12:12
--
local ClsAlert = require("ui/tools/alert")
local error_info=require("game_config/error_info")
local on_off_info=require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")


function rpc_client_mail_list(mail_list)
	local mail_data = getGameData():getmailData()
	mail_data:setMailInfo(mail_list)

end

function rpc_client_mail_get_attachment(result, error, mail_id)
	local mail_data = getGameData():getmailData()
	local mails = mail_data:getMailInfo()
	if result == 1 then
		local mail = mail_data:getMailByID(mail_id)
		if not mail then return end
		local reward = mail.attachment
		local rewards_tab = {}
		if reward then	
			ClsAlert:showCommonReward(reward)
		end
	else
		ClsAlert:warning({msg =error_info[error].message})
		local mail_main = getUIManager():get("ClsMailMain")
		if mail_main and not tolua.isnull(mail_main) then
			mail_main:updateAllCell()
		end
	end
	
end

function rpc_client_mail_change_status(mail_id, status)
	local mail_data = getGameData():getmailData()
	local mails = mail_data:getMailInfo()
	mail_data:updateMailInfoStatus(mail_id, status)
	local mail_main = getUIManager():get("ClsMailMain")
	if mail_main and not tolua.isnull(mail_main) then
		if status == 2 or (3 == status) then
			mail_main:updateAllCell()
		end
	end
	
end

function rpc_client_mail_receive(mail_info)
	local mail_id = mail_info.id
	local mail_main = getUIManager():get("ClsMailMain")
	local mail_data = getGameData():getmailData()
	
	mail_info.content = replaceValidText(mail_info.content) --过滤敏感字
	mail_data:insertMailInfo(mail_info)
	if mail_main and not tolua.isnull(mail_main) then
		mail_main:updateView(mail_id)
	end
end

----邮件中的体力
function rpc_client_mail_tili_full_tips(mailId, cur, max)
	if cur > max then
		local alert = require("ui/tools/alert")
		local lable_des = string.format(ui_word.MAIL_TILI_TIPS, cur-max)
		local function ok_call_back_func( )
			local mail_have_tips = 1
			GameUtil.callRpc("rpc_server_mail_get_attachment", {mailId, mail_have_tips})
		end
		alert:showAttention(lable_des, ok_call_back_func, nil, nil, {ok_text = ui_word.YES, cancel_text = ui_word.NO})
	end
end

function rpc_client_mail_del(mail_id, error_id)
	if error_id == 0 then
		local mail_data = getGameData():getmailData()
		local mail_info = mail_data:getMailInfo()
		local index = 0
		for i,v in ipairs(mail_info) do
			if v.id == mail_id then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(mail_info, index)
		end

		mail_data:setMailInfo(mail_info)
		local mail_main = getUIManager():get("ClsMailMain")
		if mail_main and not tolua.isnull(mail_main) then
			mail_main:updateAllCell()
		end

	end
end