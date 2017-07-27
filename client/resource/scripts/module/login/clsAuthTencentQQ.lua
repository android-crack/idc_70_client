--腾讯Android，qq登录
local ClsAuthBase = require("module/login/clsAuthBase")
local ClsAuthTencentQQ = class("ClsAuthDefault", ClsAuthBase)

local login_cls_name = "com/qtz/dhh/msdk/DhhMsdk"
local pay_cls_name = "com/qtz/dhh/midas/MidasWrapper"
local safe_sdk_cls_anme = "com/qtz/dhh/safesdk/TssSdkWrapper"

local report_fun_name = "WGReportEvent"
local pay_fun_name = "pay"
local pay_init_fun_name = "init"
local user_info_fun_name = "getUserInfo"
local friends_info_fun_name = "getFriendsInfo"
local open_url_fun_name = "openUrl"
local tss_data_to_sdk_fun_name = "onRecvDataWhichNeedSendToClientSdk"
local get_nearby_person_fun_name = "getNearbyPersonInfo"
local clean_location_fun_name = "cleanLocation"
local get_location_fun_name = "getLocationInfo"
local is_platform_installed_fun_name = "isPlatformInstalled"
local open_QQ_vip_fun_name = "openQQVIP"
local bind_group_fun_name = "bindQQGroup"
local join_group_fun_name = "joinQQGroup"
local feed_back_fun_name = "feedback"
local switch_user_fun_name = "switchUser"
local logout_fun_name = "logout"

function ClsAuthTencentQQ:ctor(chn)
    self.platform = PLATFORM_QQ
    self.login_fun_name = "login"
	self.safe_info_func_name = "onQQLogin"
	self.safe_world_id = SAFE_TENCENT_ANDRIOD_QQ
    ClsAuthTencentQQ.super.ctor(self, chn)
end

function ClsAuthTencentQQ:__init__(select_account_type, select_account_val)
	updateVersonInfo(LOG_1023)
    if select_account_type and select_account_type == LOGIN_TYPE_SELECT_ACCOUNT then
        self:swichUserLogin(select_account_val)
        return
    end
	local args = {self.platform}
    local sig = "(I)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, self.login_fun_name, args, sig)
end

function ClsAuthTencentQQ:swichUserLogin(select_account_val)
    local args = {select_account_val, function(result)
        print("==============swichUserLogin=========result", result)
        self:switchUserBack(result == "0")
    end}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, switch_user_fun_name, args)
end


-- 登录回调，安卓拉起票据后统一由这里分发
function ClsAuthTencentQQ:sdkCallBack( result, openid, token, extArgs, ...)
    if not self.begin_login then
        return
    end
    self.begin_login = false
	-- self:beginGetUserInfo()
	-- self:beginGetFriendsInfo()
	self.login_info = ...
	self.openId = openid
    self.token = token
    self.extArgs = extArgs

    local game_rpc = require("module/gameRpc")
	game_rpc.checkSocketConnectByAuth(self.auth_chn)
	self:showSDKFlagAlert(0)
end

function ClsAuthTencentQQ:reportEvent(name, content, is_real_time)
    local args = {name, content, is_real_time}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, report_fun_name, args)
end

function ClsAuthTencentQQ:switchAccount()
    local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, logout_fun_name, args)
    ClsAuthTencentQQ.super.switchAccount(self)
end

function ClsAuthTencentQQ:setRelinkUid(uid)
    if not self.hasRegisterPay then
       local args = {GTab.MIDAS_IAP_ENV}
       -- 调用 Java 方法
       luaj.callStaticMethod(pay_cls_name, pay_init_fun_name, args)
       self.hasRegisterPay = true
    end
    ClsAuthTencentQQ.super.setRelinkUid(self, uid)
end

function ClsAuthTencentQQ:beginPay(product_id, amount, info)
    --todo info
    print("begin...pay....", self.login_info)
    ClsAuthTencentQQ.super.beginPay(self, product_id, amount, self.login_info)
end

function ClsAuthTencentQQ:pay(info)
	local pay_info, pay_config = self:getPayConfig(info)
    local ext_info = {}
    ext_info.type = pay_config.type
    ext_info.serviceCode = pay_config.serviceCode
    ext_info.zoneId = (MIDAS_PAYMENT_GROW + self.safe_world_id).. "_" .. pay_info.uid
    local pay_cash = pay_config.cash
    if pay_info.test and pay_info.test == 1 then
        pay_cash = 0.1
    end
    local args = {pay_info.uid, pay_info.trade_no, pay_info.product_id, pay_config.product_name, pay_cash * 10, json.encode(ext_info)}
    local sig = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(pay_cls_name, pay_fun_name, args, sig)
end

function ClsAuthTencentQQ:payCallBack(msg)
    print("==============payCallBack===========")
    local pay_back_info = json.decode(msg)
    table.print(pay_back_info)
    if pay_back_info.flag == 0 then
        ClsAuthTencentQQ.super.payCallBack(self, true, pay_back_info.info)
    else
        if pay_back_info.flag == 10000 then
            local args = {}
            -- 调用 Java 方法
            luaj.callStaticMethod(login_cls_name, logout_fun_name, args)
            self:showMidasLoginFail()
        end
        GameUtil.callRpc("rpc_server_payment_cancel", {})
    end
end

function ClsAuthTencentQQ:loginCheakPayment(info)
	ClsAuthTencentQQ.super.loginCheakPayment(self, self.login_info)
end

function ClsAuthTencentQQ:beginGetUserInfo()
    local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, user_info_fun_name, args)
end

function ClsAuthTencentQQ:beginGetFriendsInfo()
    local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, friends_info_fun_name, args)
end

function ClsAuthTencentQQ:setSDKInfoData(content)
	local info = json.decode(content)
	if info.type == "0" then
		self.user_info = json.decode(info.msg)
	elseif info.type == "1" then
		self.friends_info = json.decode(info.msg)
	end
end

--附近的人
function ClsAuthTencentQQ:getNearbyPersonInfo()
	local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, get_nearby_person_fun_name, args)
end

--清除位置信息
function ClsAuthTencentQQ:cleanLocation()
	local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, clean_location_fun_name, args)
end

--获取玩家位置信息
function ClsAuthTencentQQ:getLocationInfo()
	local args = {}
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, get_location_fun_name, args)
end

-- "flag": 返回码  //eFlag_LbsNeedOpenLocationService(-4),eFlag_LbsLocateFail(-5), eFlag_Succ(0), eFlag_Error(5)
-- "msg":{
--     "1":{"nickname": xxx, xxx: xxx}
--     "2":
function ClsAuthTencentQQ:setNearByPersonInfo( content )
	local info = json.decode(content)
	if info.flag == 0 then
		local nearby_info = info.msg
        ClsAuthTencentQQ.super.setNearByPersonInfo(self, nearby_info)
	else

	end
end

function ClsAuthTencentQQ:setLocationInfo(content)
	local info = json.decode(content)
	if info.flag == 0 then
		self.location_info = info.msg
	else

	end
end

function ClsAuthTencentQQ:openURL(url)
    -- Java 类的名称
    local args = {url}
    -- 调用 Java 方法
   	luaj.callStaticMethod(login_cls_name, open_url_fun_name, args)
end

function ClsAuthTencentQQ:sendSafeInfoByLogin( uid )
    local args = {self.openId, self.safe_world_id, uid}
    local sig = "(Ljava/lang/String;ILjava/lang/String;)V"
    -- 调用 Java 方法
   	luaj.callStaticMethod(safe_sdk_cls_anme, self.safe_info_func_name, args, sig)
end

function ClsAuthTencentQQ:tssSdkGetAntiBack(content)
	local args = {content}
    -- 调用 Java 方法
   	luaj.callStaticMethod(safe_sdk_cls_anme, tss_data_to_sdk_fun_name, args)
end

function ClsAuthTencentQQ:isPlatformInstalled(platform, call_back) 
    local function is_installed_back(result)
        call_back(result == "0")
    end

    local args = {platform, is_installed_back}
    local sig = "(II)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, is_platform_installed_fun_name, args, sig)
end

function ClsAuthTencentQQ:openQQVip(url)
    local args = {self.safe_world_id, self.relink_uid, url}
    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, open_QQ_vip_fun_name, args, sig)
end

function ClsAuthTencentQQ:bindGroup(group_key, group_name, signature, player_name)
    self:canOperate(function()
        local args = {group_key, group_name, self.safe_world_id, signature}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        -- 调用 Java 方法
        luaj.callStaticMethod(login_cls_name, bind_group_fun_name, args, sig)
    end)
end

function ClsAuthTencentQQ:joinGroup(signature, group_key, player_name)
    self:canOperate(function()
        local args = {signature}
        local sig = "(Ljava/lang/String;)V"
        -- 调用 Java 方法
        luaj.callStaticMethod(login_cls_name, join_group_fun_name, args, sig)
    end)
end

function ClsAuthTencentQQ:feedback(str)
    local args = {str}
    local sig = "(Ljava/lang/String;)V"
    -- 调用 Java 方法
    luaj.callStaticMethod(login_cls_name, feed_back_fun_name, args, sig)
end

return ClsAuthTencentQQ