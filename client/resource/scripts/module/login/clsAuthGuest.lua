local ClsAuthBase = require("module/login/clsAuthBase")
--默认登录
local ClsAuthGuest = class("ClsAuthGuest", ClsAuthBase)

-- 开始登录
function ClsAuthGuest:beginLogin(open_udid)
	self:checkInit()
	self.open_udid = open_udid
	self.is_logining = true

	local token = open_udid.."dhh_is_greate"
	local md5_token = CCCrypto:MD5Lua(token, false)

	self:loginCallBack(1, open_udid, md5_token, {})
end

return ClsAuthGuest