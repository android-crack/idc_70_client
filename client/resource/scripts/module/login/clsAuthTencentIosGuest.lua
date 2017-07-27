--腾讯ios，游客登录
local ClsAuthTencentIosQQ = require("module/login/clsAuthTencentIosQQ")

local ClsAuthTencentIosGuest = class("ClsAuthTencentIosGuest", ClsAuthTencentIosQQ)

function ClsAuthTencentIosGuest:ctor(chn)
	ClsAuthTencentIosGuest.super.ctor(self, chn)
	self.platform = PLATFORM_GUEST
	self.safe_world_id = SAFE_TENCENT_IOS_GUEST
end

return ClsAuthTencentIosGuest