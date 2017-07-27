-- 港口主界面loading 

-- name 
-- port 港口
-- zhanyi 战役

local ModulePortLoading = {}
function ModulePortLoading:loading(callback, res, name)
	---------------------------------------------------------------
	-- modify By Hal 2015-09-08, Type(BUG) - redmine 19515
	local exploreData = getGameData():getExploreData()
	if exploreData then
		exploreData:setAutoPos(nil)
	end
	IS_AUTO = false
	---------------------------------------------------------------	
	if callback == nil or res == nil or name == nil then 
		assert(false, "ModulePortLoading:loading callback == nil or res == nil or name == nil")
		return 
	end 
	
	if self.loadTable == nil then 
		self.loadTable = {}
	end 
	self.loadTable[name] = res 
	
	require("gameobj/loadingUI"):start(res, callback)
end


function ModulePortLoading:clearPreloadByName(name)
	if self.loadTable[name] then 
		require("module/preload/preload_mgr").clearPreLoad(self.loadTable[name])
		self.loadTable[name] = nil
	end 
end 

function ModulePortLoading:clearAll()
	for k, v in pairs(self.loadTable) do
		require("module/preload/preload_mgr").clearPreLoad(v)
	end 
	self.loadTable = nil
end 

return ModulePortLoading



