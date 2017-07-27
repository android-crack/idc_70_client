local ClsAuthBase = require("module/login/clsAuthBase")
--默认登录,使用账户密码
local ClsAuthDefault = class("ClsAuthDefault", ClsAuthBase)

function ClsAuthDefault:sdkCallBack( result , openid, token, extArgs, ...)
	self.openId = openid
    self.token = token
    local ext_data = json.encode(extArgs)

    local login_layer = getUIManager():get("LoginLayer")
    if not tolua.isnull(login_layer) then
        login_layer:setViewTouchEnabled(false)
    end
    
    local game_rpc = require("module/gameRpc")
    local userDefault = CCUserDefault:sharedUserDefault()
    local server_name = userDefault:getStringForKey(STR_SERVER_NAME)
    server_name = server_name or ""
	game_rpc.checkSocketConnectByAuth(server_name)
end

return ClsAuthDefault