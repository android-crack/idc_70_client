--沉船图标刷新

local ClsExploreShipWrecksPoint = class("ClsExploreShipWrecksPoint")

function ClsExploreShipWrecksPoint:updateShipWrecksPoint()
	-- print("=======================刷新沉船图标==================")
    local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map_obj) then
    	explore_map_obj:resetPoint(EXPLORE_NAV_TYPE_SALVE_SHIP)
	end
end


return ClsExploreShipWrecksPoint
