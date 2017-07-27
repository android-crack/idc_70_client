--探索公式
--------------------------------------------------
local ExploreFormula = {}

--计算出海补给所需银币
ExploreFormula.calcCostCashByExploreSupply = function(sailorNum, foodNum)
	-- local cashPerSailor = 5
	-- local cashPerFood = 2

	local sailorCash = math.min(math.floor(math.pow(2, math.floor(sailorNum / 25)) * 40), sailorNum * 200)
	local foodCash = math.min(math.floor(math.pow(1.4, math.floor(foodNum / 500)) * 100), foodNum * 1)

	return sailorCash + foodCash
end

--计算出海所需食物
ExploreFormula.calcNeedFoodByExplore = function(sailorNum, sailorTime)
	local costFoodPerTime = 3 --3秒扣一次食物

	return math.ceil(sailorTime / costFoodPerTime)*sailorNum
end

--计算出海可以航行的时间
ExploreFormula.calcTimeByExplore = function(sailorNum, foodNum)
	local costFoodPerTime = 3 --3秒扣一次食物
	if sailorNum <= 0 then
		return 0
	end
	return math.ceil(foodNum / sailorNum)*costFoodPerTime
end

return ExploreFormula
