local shopRule={}

--银币加速规则

local cash=43200
function shopRule:getQuickCompleteCash(value)
	--cclog("时间"..value.."需要银币"..math.ceil(value/timeCash))
	local isEnough = true
	local playerData = getGameData():getPlayerData()
	if playerData:getCash()<cash then 
		isEnough=false
	end
	return cash,isEnough
end


--金币加速规则
--hardCode
local ranges={60,3600,86400,604800}
local gems={1,20,260,1000}
function shopRule:getQuickCompleteGold(value)
	local gold=nil
	if value< ranges[1] then return gems[1] end
	for i=1,#gems-1 do
		if value >=ranges[i] and value <ranges[i+1] then
			gold=math.floor(0.5+(value-ranges[i])/((ranges[i+1]-ranges[i])/(gems[i+1]-gems[i]))+gems[i])
		end
	end
	if not gold then gold=gems[#gems] end
	local isEnough=true
	local playerData = getGameData():getPlayerData()
	if playerData:getGold()<gold then 
		isEnough=false
	end
	return gold,isEnough
end

--购买席位
local seatGold={0,1000,2000,5000,10000}
function shopRule:getSeatGold(value)
	if value>5 or value<1 then return end
	return seatGold[value]
end

return shopRule