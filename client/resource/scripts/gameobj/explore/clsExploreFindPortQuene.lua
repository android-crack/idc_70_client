local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsExploreFindPortQuene = class("ClsExploreFindPortQuene", ClsQueneBase)
--数据初始化
function ClsExploreFindPortQuene:ctor(data)
	self.data = data
end

function ClsExploreFindPortQuene:getQueneType()
	return self:getDialogType().explore_find_new_port
end

function ClsExploreFindPortQuene:excTask()
	if getGameData():getSceneDataHandler():isInExplore() then
		getUIManager():create("gameobj/explore/clsExploreFindPortPanel",nil,self.data) --显示后直接就播放
	end
	self:TaskEnd()
end

return ClsExploreFindPortQuene