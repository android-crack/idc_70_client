-- 判断自动战斗监听层
-- Author: Ltian
-- Date: 2016-09-14 10:29:54
--
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsLitenerAutoLayer = class("ClsLitenerAutoLayer", function () return display.newLayer() end)

function ClsLitenerAutoLayer:ctor()
	self.touch_count = 0

	self:doAutoFightListen()
	self:startListen()
	self:regFunc()
end

function ClsLitenerAutoLayer:onTouch(event, x, y)
	self:doAutoFightListen()
	if event == "began" then
		self.touch_count = self.touch_count + 1
		return true
	elseif event ~= "moved" then
		self.touch_count = self.touch_count - 1
	end
end

function ClsLitenerAutoLayer:setAutoFight()
	local battle_data = getGameData():getBattleDataMt()
	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:setAutoFight()
	end
end

function ClsLitenerAutoLayer:doAutoFightListen()
	local battle_data = getGameData():getBattleDataMt()
	self.old_time = battle_data:GetData("battle_time") or 119
end

function ClsLitenerAutoLayer:startListen()
	self.timer = scheduler:scheduleScriptFunc(function()
		if self.touch_count > 0 then return end

		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getCurClientControlShip()

		if not ship or not ship.body then 
			if self.timer then
				scheduler:unscheduleScriptEntry(self.timer)
				self.timer = nil
			end
			return 
		end

		local target_pos = ship.body.target_pos
		local this_time = battle_data:GetData("battle_time") or 0

		if self.old_time and not target_pos and self.old_time - this_time > 5  then
			self:setAutoFight()
		end
	end, 2, false)
end

function ClsLitenerAutoLayer:onExit()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function ClsLitenerAutoLayer:regFunc()
	self:registerScriptHandler(function(event)
		if event == "exit" then self:onExit() end
	end)
end

return ClsLitenerAutoLayer