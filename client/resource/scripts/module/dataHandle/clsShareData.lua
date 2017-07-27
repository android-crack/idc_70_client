-- 分享模块
-- Author: Ltian
-- Date: 2016-12-10 11:12:58
--

local ClsShareData = class("ClsShareData")

function ClsShareData:ctor( ... )
	-- body
end

--scene :分享类型 1：朋友圈   0：会话
--port_id: 港口id
--callback：回调

-- 发现新港口大图分享
function ClsShareData:shareImg(scene, res, rect, callback)
	local module_game_sdk = require("module/sdk/gameSdk")
    module_game_sdk.shareWithPhoto(scene, res, SHARE_TAG_MSG_INVITE, "", SHARE_ACTION_SNS_JUMP_APP, rect,
    	function (share_result)
    		if callback then
    			callback(share_result)
    		end
    	end
    )
end

--结构化分享
function ClsShareData:share(share_id)
	local share_info = self:getShareInfo(share_id)
	if not share_info then
		return
	end
	local module_game_sdk = require("module/sdk/gameSdk")
    module_game_sdk.share(share_info.title, share_info.desc, share_info.url, share_info.img_url, share_info.scene, share_info.media_tag_name, share_info.message_ext)
end

--后端分享
--message_ext看是否要透传数据
function ClsShareData:shareToFriend(fopen_id, share_id, message_ext)
local share_info = self:getShareInfo(share_id)
	if not share_info then
		return
	end
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.shareToFriend(fopen_id, share_info.title, share_info.desc, share_info.url, share_info.img_url, share_info.media_tag_name, share_info.message_ext)
end

--根据id直接给予表数据
function ClsShareData:getShareInfo(share_id)
	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()
	local share_info = nil
	local share_config_name = nil
	if platform == PLATFORM_WEIXIN then
		share_config_name = "share_info_wechat"
	elseif platform == PLATFORM_QQ then
		share_config_name = "share_info_qq"
	end
	if share_config_name then
		local share_config = require(string.format("game_config/share/%s", share_config_name))
		share_info = share_config[share_id]
	end
	return share_info
end

--港口分享成功后告知服务器
function ClsShareData:askPortShareSucc(port_id)
	if port_id and port_id > 0 then
		CCUserDefault:sharedUserDefault()
		local user_data = CCUserDefault:sharedUserDefault()
		local time = os.time()
     	local cur_share_time = user_data:setStringForKey("CurshareTime", tostring(time))
		GameUtil.callRpc("rpc_server_port_share", {port_id})
	end
end
return ClsShareData
