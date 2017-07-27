--particle
local ClsParticleProp = require ("gameobj/explore/exploreParticle")

local ClsCopySceneParticleProp = class("ClsCopySceneParticleProp", ClsParticleProp)

function ClsCopySceneParticleProp:initUI()
	self.ui = CCNode:create()
	local exploreData = getGameData():getExploreData()
	local shipUI = getSceneShipUI()
	if not tolua.isnull(shipUI) then
		shipUI:addChild(self.ui)
	end
end

return ClsCopySceneParticleProp
