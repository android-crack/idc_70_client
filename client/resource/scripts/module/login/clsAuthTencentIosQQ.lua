--腾讯ios，qq登录
local ClsAuthBase = require("module/login/clsAuthBase")

local ClsAuthTencentIosQQ = class("ClsAuthTencentIosQQ", ClsAuthBase)

local userDefault = CCUserDefault:sharedUserDefault()

function ClsAuthTencentIosQQ:ctor(chn)
	self.platform = PLATFORM_QQ
	self.safe_world_id = SAFE_TENCENT_IOS_QQ
    ClsAuthTencentIosQQ.super.ctor(self, chn)
end


function ClsAuthTencentIosQQ:__init__(select_account_type, select_account_val)
    --self.__init_flag = true
    updateVersonInfo(LOG_1030)
    local qsdk = QSDK:sharedQSDK()
	qsdk:init(self.platform, function(event)
	    local eventType = event.eventType
	    if eventType == SDK_EVENT_INIT then
            if select_account_type and select_account_type == LOGIN_TYPE_SELECT_ACCOUNT then
                local result = qsdk:switchUser(select_account_val)
                print("===============result", result)
                self:switchUserBack(result)
            else
                qsdk:login()
            end
	    end

	    if eventType == SDK_EVENT_LOGIN then
            if not self.begin_login then
                return
            end
            self.begin_login = false
            self.openId = qsdk:getOpenId()
            self.token = qsdk:getAccessToken()
            self.payToken = qsdk:getPayToken()
            self.pf = qsdk:getPf()
            self.pfKey = qsdk:getPfKey()
            local uid = qsdk:getUid()
            local udid = qsdk:getUdid()
            print("SDK =====:", self.auth_chn, self.openId, self.token, self.platform)
			
            if event.isSuccess then
            	updateVersonInfo(LOG_1031)
            	self.login_info = {}
			    self.login_info.openId = self.openId
			    self.login_info.accessToken = self.token
			    self.login_info.payToken = self.payToken
			    self.login_info.pf = self.pf
			    self.login_info.pfKey = self.pfKey
    
		    	local game_rpc = require("module/gameRpc")
		    	game_rpc.checkSocketConnectByAuth(self.auth_chn)

                local login_layer = getUIManager():get("LoginLayer")
                if not tolua.isnull(login_layer) then
                    login_layer:setViewTouchEnabled(false)
                end
                self:showSDKFlagAlert(0)
                -- self:beginGetUserInfo()
                -- self:beginGetFriendsInfo()
            else
            	updateVersonInfo(LOG_1032)
                print("==================event.msg", event.msg)
		        self:showSDKFlagAlert(event.msg)
            end
	    end

	    if eventType == SDK_EVENT_LOGOUT then
	        self:logout()
	    end

	    if eventType == SDK_EVENT_PAY then
	        self:payCallBack(event.isSuccess, event.msg)
	    end

	    if eventType == SDK_EVENT_USER_INFO then
	        self.user_info = json.decode(event.msg)
	    end

	    if eventType == SDK_EVENT_FRIEND_INFO then
	        self.friends_info = json.decode(event.msg)
	    end

	    if eventType == SDK_EVENT_NEARBY_PERSON_INFO then
	    	self:setNearByPersonInfo(event)
	    end

	    if eventType == SDK_EVENT_LOCATION_INFO then
	    	self:setLocationInfo(event)
	    end

        -- if eventType == SDK_EVENT_SHARE_NOTICE then--返回的应该是QQ綁群后的回调
        -- end
	end) 
end

function ClsAuthTencentIosQQ:reportEvent(name, content, is_real_time)
    QSDK:sharedQSDK():reportEvent(name, content, is_real_tim)
end

function ClsAuthTencentIosQQ:switchAccount()
    QSDK:sharedQSDK():logout()
    ClsAuthTencentIosQQ.super.switchAccount(self)
end

--ios支付
function ClsAuthTencentIosQQ:beginPay(product_id, amount, info)
    ClsAuthTencentIosQQ.super.beginPay(self, product_id, amount, self.login_info)
end

function ClsAuthTencentIosQQ:pay(info)
    print("=========info", info)
	local pay_info, pay_config = self:getPayConfig(info)
    local ext_info = {}
    ext_info.type = pay_config.type
    ext_info.serviceday = tostring(pay_config.serviceday)
    ext_info.zoneId = (MIDAS_PAYMENT_GROW + self.safe_world_id) .. "_" .. pay_info.uid
    QSDK:sharedQSDK():pay(pay_info.uid, pay_info.trade_no, pay_info.product_id, pay_config.product_name, pay_config.diamond, json.encode(ext_info));
end

function ClsAuthTencentIosQQ:payCallBack(success, msg)
    local ui_word = require("game_config/ui_word")
    local Alert = require("ui/tools/alert")
    if success then
        print("pay succ, msg is: " .. msg)
        Alert:warning({msg = ui_word.SDK_PAY_SUCCESS_TIPS, size = 26})
        userDefault:setStringForKey(string.format("%s_pay", self.relink_uid), msg)
        ClsAuthTencentIosQQ.super.payCallBack(self, success, msg)
    else   
        if tonumber(msg) == 10000 then
            QSDK:sharedQSDK():logout()
            self:showMidasLoginFail()
        end
        Alert:warning({msg = ui_word.SDK_PAY_FAIL_TIPS, size = 26})
        self:cleanPayCdTime()
    	print("pay fail, msg type is: " .. msg)
    end
end

-- set 重联 token
function ClsAuthTencentIosQQ:setRelinkUid(uid)
    if not self.hasRegisterPay then
        QSDK:sharedQSDK():registerPay(GTab.MIDAS_IAP_ENV)
        self.hasRegisterPay = true
    end
    ClsAuthTencentIosQQ.super.setRelinkUid(self, uid)
    local msg = userDefault:getStringForKey(string.format("%s_pay", uid), "") 
    if msg ~= "" then
        print("resend pay")
        local paydes = json.decode(msg)
        paydes.openId = self.openId
        paydes.pf   = self.pf
        paydes.pfKey = self.pfKey
        paydes.payToken = self.payToken
        paydes.accessToken = self.token
        table.print(paydes)
        self:payCallBack(true, json.encode(paydes))
    end
    print("there is no pay", msg)
    --print("=================ClsAuthTencentIosQQ:setRelinkUid(uid)", uid)
end

-- 保证服务端收到订单，然后就删除订单
function ClsAuthTencentIosQQ:payResponse(response)
    ClsAuthTencentIosQQ.super.payResponse(self, response)
    print("pay response")
    userDefault:setStringForKey(string.format("%s_pay", self.relink_uid), "") 
end


function ClsAuthTencentIosQQ:beginGetUserInfo()
	QSDK:sharedQSDK():getUserInfo()
end

function ClsAuthTencentIosQQ:beginGetFriendsInfo()
	QSDK:sharedQSDK():getFriendsInfo()
end

function ClsAuthTencentIosQQ:openQQVip(url)
    local qq_vip_url = url .. string.format("?sRoleId=%s&sPartition=%s&sPfkey=%s", self.relink_uid, self.safe_world_id, self.pfKey)
    self:openURL(qq_vip_url)
end

function ClsAuthTencentIosQQ:openURL(url)
    QSDK:sharedQSDK():openURL(url)
end

--附近的人
function ClsAuthTencentIosQQ:getNearbyPersonInfo()
    print("==============ClsAuthTencentIosQQ:getNearbyPersonInfo()")
	QSDK:sharedQSDK():getNearbyPersonInfo()
end

--清除位置信息
function ClsAuthTencentIosQQ:cleanLocation()
	QSDK:sharedQSDK():cleanLocation()
end

--获取玩家位置信息
function ClsAuthTencentIosQQ:getLocationInfo()
	QSDK:sharedQSDK():getLocationInfo()
end

function ClsAuthTencentIosQQ:setNearByPersonInfo(event)
	print("ClsAuthTencentIosQQ:setNearByPersonInfo(event)=================")
	if event.isSuccess then
		local nearby_person_info = json.decode(event.msg)
    	table.print(nearby_person_info)
        ClsAuthTencentIosQQ.super.setNearByPersonInfo(self, nearby_person_info)
    else
    	print(event.msg)
    end
end

function ClsAuthTencentIosQQ:setLocationInfo(event)
	print("ClsAuthTencentIosQQ:setNearByPersonInfo(event)=================")
	if event.isSuccess then
		self.location_info = json.decode(event.msg)
    	table.print(self.location_info)
    else
    	print(event.msg)
    end
end

function ClsAuthTencentIosQQ:sendSafeInfoByLogin( uid )
	QTssSDK:getInstance():setUserInfo(self.platform, self.openId, self.safe_world_id, uid)
end

function ClsAuthTencentIosQQ:tssSdkGetAntiBack(content)
	--print("======ClsAuthTencentIosQQ:tssSdkGetAntiBack===========")
	QTssSDK:getInstance():send_server_data(content)
end


function ClsAuthTencentIosQQ:isPlatformInstalled(platform, call_back)
    local is_installed = QSDK:sharedQSDK():isPlatformInstalled(platform)
    call_back(is_installed)
end

function ClsAuthTencentIosQQ:bindGroup(group_key, group_name, signature, player_name)
    self:canOperate(function()
        QSDK:sharedQSDK():bindQQGroup(group_key, group_name, self.safe_world_id, signature)
    end)
end

function ClsAuthTencentIosQQ:joinGroup(signature, group_key, player_name)
    self:canOperate(function()
        QSDK:sharedQSDK():joinQQGroup("", signature)
    end)
end

function ClsAuthTencentIosQQ:feedback(str)
    QSDK:sharedQSDK():feedback(str)
end

return ClsAuthTencentIosQQ
