--create by wmh0497
--2016/11/19
--把队列的探索获取奖励的代码搬到新的队列
local music_info = require("game_config/music_info")
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsExploreRewardEffect = class("ClsExploreRewardEffect", ClsQueneBase)

function ClsExploreRewardEffect:ctor(data)
	self.data = data
end

function ClsExploreRewardEffect:getQueneType()
	return self:getDialogType().exploreRewardEffect
end

function ClsExploreRewardEffect:excTask()
	if not tolua.isnull(getExploreUI()) then
		local uiTools = require("gameobj/uiTools")
		uiTools:showGetRewardEfffect(getExploreUI(), function() self:TaskEnd() end, self.data.image, self.data.num, nil,nil,nil,nil,self.data.reward)
		audioExt.playEffect(music_info.SHIPYARD_DISMANTLE_AWARD.res)
    end
end

return ClsExploreRewardEffect

