local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local clsLoginAward = class("clsLoginAward", ClsQueneBase)
function clsLoginAward:ctor(data)
	self.data = data
end

function clsLoginAward:getQueneType()
	return self:getDialogType().loginAward
end

function clsLoginAward:excTask()
	EventTrigger(EVENT_LOGIN_VIP_AWARD_GET_SUC, 1, self.data.reward.day, 0, self.data.reward.config, self.data.reward.vip_reward,  self.data.is_update_welfare, function()
			if(self.data.fun)then self.data.fun()end
			self:TaskEnd()			
		end)

end

return clsLoginAward