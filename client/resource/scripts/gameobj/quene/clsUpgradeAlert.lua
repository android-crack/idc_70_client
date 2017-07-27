--
-- Author: Ltian
-- Date: 2016-11-18 10:13:54
--
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsUpgradeAlert = class("ClsUpgradeAlert", ClsQueneBase)
local scheduler = CCDirector:sharedDirector():getScheduler()

-- 定时器重置
function ClsUpgradeAlert:resetTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function ClsUpgradeAlert:ctor(level,value)
	self.level = level
	self.value = value
	self:resetTimer()
end

function ClsUpgradeAlert:getQueneType()
	return self:getDialogType().upgrade
end

function ClsUpgradeAlert:excTask()
	audioExt.pauseMusic()
	local upgradeLevel = getUIManager():get("upgradeLayer")
	if not tolua.isnull(upgradeLevel) then
		upgradeLevel:close()
	end
	getUIManager():create("gameobj/upgradeLayer", nil, self.level,self.value, function( )
		self:TaskEnd()
	end)
end

return ClsUpgradeAlert
