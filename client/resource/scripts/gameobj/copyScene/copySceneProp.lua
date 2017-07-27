--道具 模型
local ClsProp = require("gameobj/explore/exploreProp")

local ClsCopyScenePropModel = class("ClsCopyScenePropModel", ClsProp)

function ClsCopyScenePropModel:ctor(param)
	ClsCopyScenePropModel.super.ctor(self, param)
end

function ClsCopyScenePropModel:initUI()
    self.ui = CCNode:create()
    local exploreData = getGameData():getExploreData()
    local shipUI = getSceneShipUI()
    if not tolua.isnull(shipUI) then
        shipUI:addChild(self.ui)
    else
        print(T("到这里为空=========================="))
    end
end

function ClsCopyScenePropModel:goToDesitinaion(end_pos, call_back, param)
    local p = ccp(self:getPos())
    local pos_st = self.land:cocosToTileSize(p) -- 开始坐标
    local pos_end = end_pos           -- 目标点
    
    local path = self.land:getSearchPath(pos_st, pos_end)
    if not path then
        return
    end 
    local path_len = #path
    local index = 3

    local auto
    auto = function()
        if index > path_len then
            if call_back then
                call_back(param)
                self:rotateStop()
            end
            return
        end
        local x = path[index]
        local y = path[index + 1]
        index = index + 2
        local pos = self.land:tileSizeToCocos2(ccp(x, y))
        self:autoMoveToPos(pos, auto)
    end
    auto()
end

function ClsCopyScenePropModel:stopFindPath()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.ship_auto_hander then
        scheduler:unscheduleScriptEntry(self.ship_auto_hander)
    end
    self.ship_auto_hander = nil
end

return ClsCopyScenePropModel
