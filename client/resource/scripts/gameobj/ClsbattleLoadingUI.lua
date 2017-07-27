local loadingUI = require("gameobj/loadingUI")
local ClsbattleLoadingUI = class("ClsbattleLoadingUI", loadingUI)

function ClsbattleLoadingUI:remove(isRelink)
	if tolua.isnull(self.layer) then
		self:removeHandler()
		return
	end

	self:musicFade(true)
	
	local battle_data = getGameData():getBattleDataMt()
	battle_data:setAlreadyLoad(false)

	self.layer:removeFromParentAndCleanup(true)
	for k, v in pairs(self.res_tab) do
		RemoveTextureForKey(v)
	end
end

function ClsbattleLoadingUI:start(load_res, callback)
	self.call_back = callback

	self:show()
	
	local function loadfunc(current, count)
        if not tolua.isnull(self.progress) then
        	local precent = current/count
			self.progress:setPercentage(precent * 100)
			self.num:setString(tostring(toint(precent * 100)).."%")
        end
		
		if current ~= count then return end

		if type(self.call_back) == "function" then
			self.call_back()
			return
		end

		self:remove()
	end

	require("module/preload/preload_mgr").asyncLoadRes(load_res, loadfunc)
end

return ClsbattleLoadingUI
