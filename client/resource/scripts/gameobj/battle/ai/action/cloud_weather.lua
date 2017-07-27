--************************************--
-- author: hal
-- date: 2015-08-11
-- descript: 设置暴风雨
--
-- modify:
-- who         date            reason
--
--
--************************************--

-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCloudWeather = class("ClsAIActionCloudWeather", ClsAIActionBase) 

local shipEntity = require("gameobj/battle/newShipEntity")

function ClsAIActionCloudWeather:getId()
	return "cloud_weather"
end

-- 
function ClsAIActionCloudWeather:initAction( delay_time, from_pos, to_pos )
	-- body
	self.delay_time = delay_time;				-- 气候类型
	self.from_pos = from_pos;					-- 气候类型
	self.to_pos = to_pos;						-- 气候类型

end

function ClsAIActionCloudWeather:__dealAction( target_id, delta_time )
	local battleData = getGameData():getBattleDataMt()

	if not self.delay_time then return end
	if not battleData then return end
	
	local battle_effect_layer = battleData:GetLayer( "effect_layer" );
	if tolua.isnull( battle_effect_layer ) then 
		return 
	end
	battle_effect_layer:showCloud( { self.delay_time, self.from_pos, self.to_pos } );

end

return ClsAIActionCloudWeather
