--腾讯Android，微信登录
local ClsAuthTencentQQ = require("module/login/clsAuthTencentQQ")
local ClsAuthTencentWechat = class("ClsAuthTencentWechat", ClsAuthTencentQQ)
local bind_group_fun_name = "createWXGroup"
local join_group_fun_name = "joinWXGroup"
local open_deep_link_fun_name = "openWeiXinDeeplink"
local login_cls_name = "com/qtz/dhh/msdk/DhhMsdk"

function ClsAuthTencentWechat:ctor(chn)
	ClsAuthTencentWechat.super.ctor(self, chn)
	self.platform = PLATFORM_WEIXIN
	self.safe_info_func_name = "onWeixinLogin"
	self.safe_world_id = SAFE_TENCENT_ANDRIOD_WECHAT
end

function ClsAuthTencentWechat:__init__(select_account_type, select_account_val)
	self:isPlatformInstalled(self.platform, function(is_installed)
		if is_installed then
			self.login_fun_name = "login"
		else
			self.login_fun_name = "qrCodeLogin"
		end
		ClsAuthTencentWechat.super.__init__(self, select_account_type, select_account_val)
	end)
end

function ClsAuthTencentWechat:switchAccount()
    ClsAuthTencentWechat.super.switchAccount(self)
    local ui_word = require("game_config/ui_word")
    local Alert = require("ui/tools/alert")
    Alert:warning({msg = ui_word.LOGIN_SWITCH_WECHAT_TIPS, size = 26})
end

function ClsAuthTencentWechat:bindGroup(group_key, group_name, signature, player_name)
	self:canOperate(function()
	    local args = {group_key, group_name, player_name}
	    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	    -- 调用 Java 方法
	    luaj.callStaticMethod(login_cls_name, bind_group_fun_name, args, sig)
	end)
end

function ClsAuthTencentWechat:joinGroup(signature, group_key, player_name)
	self:canOperate(function()
	    local args = {group_key, player_name}
	    local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
	    -- 调用 Java 方法
	    luaj.callStaticMethod(login_cls_name, join_group_fun_name, args, sig)
	end)
end

function ClsAuthTencentWechat:openWeiXinDeeplink(link_url)
	local args = {link_url}
    local sig = "(Ljava/lang/String;)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, open_deep_link_fun_name, args, sig)
end

return ClsAuthTencentWechat