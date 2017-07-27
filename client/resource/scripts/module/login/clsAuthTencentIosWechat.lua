--腾讯ios，微信登录
local ClsAuthTencentIosQQ = require("module/login/clsAuthTencentIosQQ")

local ClsAuthTencentIosWechat = class("ClsAuthTencentIosWechat", ClsAuthTencentIosQQ)

function ClsAuthTencentIosWechat:ctor(chn)
	ClsAuthTencentIosWechat.super.ctor(self, chn)
	self.platform = PLATFORM_WEIXIN
	self.safe_world_id = SAFE_TENCENT_IOS_WECHAT
end

function ClsAuthTencentIosWechat:switchAccount()
    ClsAuthTencentIosWechat.super.switchAccount(self)
	local ui_word = require("game_config/ui_word")
    local Alert = require("ui/tools/alert")
    Alert:warning({msg = ui_word.LOGIN_SWITCH_WECHAT_TIPS, size = 26})
end

function ClsAuthTencentIosWechat:bindGroup(group_key, group_name, signature, player_name)
	self:canOperate(function()
    	QSDK:sharedQSDK():createWXGroup(group_key, group_name, player_name)
    end)
end

function ClsAuthTencentIosWechat:joinGroup(signature, group_key, player_name)
	self:canOperate(function()
		QSDK:sharedQSDK():joinWXGroup(group_key, player_name)
	end)
end

function ClsAuthTencentIosWechat:openWeiXinDeeplink(link_url)
	QSDK:sharedQSDK():openWeiXinDeeplink(link_url)
end

return ClsAuthTencentIosWechat