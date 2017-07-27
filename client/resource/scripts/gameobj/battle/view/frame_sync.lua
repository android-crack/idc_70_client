local ClsBase =  require("gameobj/battle/view/base")
local ClsFrameSync = class("ClsFrameSync", ClsBase)

function ClsFrameSync:ctor()
end

function ClsFrameSync:GetId()
    return "frame_sync"
end

function ClsFrameSync:Show()
	local battleData = getGameData():getBattleDataMt()
	battleData:setLastRpcTime()
end

return ClsFrameSync
