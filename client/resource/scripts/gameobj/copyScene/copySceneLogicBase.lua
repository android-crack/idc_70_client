--
-- Author: 0496
-- Date: 2016-05-30 17:14:57
-- Function: 副本系统的部分玩法逻辑
--(不同的逻辑操作被抽出来到子类实现，相同的将留在copySceneManage里)

local copySceneLogicBase = class("copySceneLogicBase")


function copySceneLogicBase:ctor()
	self.activity_over_times = 0 --副本活动正式开启的剩余时间(s)
    self.map_land_params = {} --存放地图数据 子类必须重写 
    self.model_count = {} --存放副本事件种类和数量的数据 子类如果没有事件,可不重写
end

function copySceneLogicBase:doLogic(str_event, ...)
	if self[str_event] then
		return self[str_event](self, ...)
	end
end

function copySceneLogicBase:getMapLandParams()
    return self.map_land_params
end

function copySceneLogicBase:getModelCounts()
    return self.model_count
end

function copySceneLogicBase:getExitTips()
    local tips = require("game_config/tips")
    return tips[170].msg
end

--是否要检查空气墙阻挡问题，如果要检查，则子类重写。
function copySceneLogicBase:checkPassPos(screen_x, screen_y)
    return true
end

function copySceneLogicBase:updataEventObjectAttr(obj, key, value)
    if obj then
        obj:updataAttr(key, value)
    end
end

return copySceneLogicBase