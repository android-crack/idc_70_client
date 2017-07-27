-- A*寻路算法，目前只适用于 01图, 0可通行， 1不可通行
-- 此项目中，图比较小，有不错的效率，因此没有再去做些优化；可用最小堆去维护open_list (O(logn)的效率)
-- 而不用每次都要遍历一边open_list(O(n)的效率) 



local dir = {{1,1},{1,0},{1,-1},{0,1},{0,-1},{-1,1},{-1,0},{-1,-1}}  --行走的8个方向

local AStar = {}

AStar.init = function(self, map, startPoint, endPoint)  --地图、起始点、终点

	self.startPoint = startPoint
	self.endPoint   = endPoint
	self.map        = map
	self.cost       = 10 --单位花费
	self.diag       = 1.4  --对角线长， 根号2 一位小数
	self.open_list  = {}
	self.close_list = {}
	self.mapWidth   = #map
	self.mapHeight  = #map[1]
end

AStar.searchPath = function(self) --搜索路径 ,核心代码
	
	local startNode = {}  --把第一节点加入 open_list中
	startNode.x = self.startPoint.x
	startNode.y = self.startPoint.y
	startNode.g = 0
	startNode.h = 0
	startNode.f = 0
	table.insert(self.open_list, startNode)
	
	local function check(x, y) --检查边界、障碍点	
		if x >= 1 and x <= self.mapWidth and y >= 1 and y <= self.mapHeight then
			if self.map[x][y] == 0 or (x == self.endPoint.x and y == self.endPoint.y) then
				return true
			end
		end
		return false
	end
	
	while #self.open_list > 0 do
		local node = self:getMinNode()
		if node.x == self.endPoint.x and node.y == self.endPoint.y then  --找到路径
			return self:buildPath(node)
		end
		
		for i =1 , #dir do  -- 每一个子节点
			local x = node.x + dir[i][1]
			local y = node.y + dir[i][2]
			if check(x,y) then
				local curNode = self:getFGH(node, x, y, (x ~= node.x and y ~= node.y))  
				local openNode, openIndex = self:nodeInOpenList(x,y)
				local closeNode, closeIndex = self:nodeInCloseList(x,y)
				
				if not openNode and not closeNode then      --不在OPEN表和CLOSE表中 
					table.insert(self.open_list, curNode)	--添加特定节点到 open list
				
				elseif openNode then   -- 在OPEN表
					if openNode.f > curNode.f then
						self.open_list[openIndex] = curNode  --更新OPEN表中的估价值
					end
					
				else    --在CLOSE表中
					if closeNode.f > curNode.f then
						table.insert(self.open_list, curNode)
						table.remove(self.close_list, closeIndex)
					end	
				end		
			end
			
		end	
		table.insert(self.close_list, node) --节点放入到 close list 里面
	end
	return nil  -- 不存在路径
end

AStar.getFGH = function(self, father, x, y, isdiag) --获取 f ,g ,h, 最后参数是否对角线走

	local node = {}
	local cost = self.cost
	if isdiag then cost = cost*self.diag end
	node.father = father
	node.x = x
	node.y = y
	node.g = father.g + cost
	node.h = self:diagonal(x,y)  -- 估计值h 
	node.f = node.g + node.h  -- f = g + h 
	return node
end

AStar.nodeInOpenList = function(self, x, y) --判断节点是否已经存在 open list 里面
	for i = 1, #self.open_list do
		local node = self.open_list[i]
		if node.x == x and node.y == y then
			return node, i   --返回节点和下标
		end
	end
	return nil
end

AStar.nodeInCloseList = function(self, x, y) --判断节点是否已经存在 close list 里面
	for i = 1, #self.close_list do
		local node = self.close_list[i]
		if node.x == x and node.y == y then
			return node, i
		end
	end
	return nil
end

AStar.getMinNode = function(self)  --在open_list中找到最佳点,并删除

	if #self.open_list < 1 then return nil end
	local min_node = self.open_list[1]
	local min_i = 1
	for i,v in ipairs(self.open_list) do
		if min_node.f > v.f then
			min_node = v
			min_i = i
		end
	end
	table.remove(self.open_list, min_i)
	return min_node
end

AStar.buildPath = function(self, node)  --- 计算路径
	local path = {}
	local sumCost = node.f   --路径的总花费
	while node do
		path[#path + 1] = {x = node.x, y = node.y}
		node = node.father
	end
	return path, sumCost
end

--估价h函数

AStar.manhattan = function(self, x, y)  --曼哈顿估价法（用于不能对角行走）
	local h = math.abs(x - self.endPoint.x) + math.abs(y - self.endPoint.y)  -- 估计值h 
	return h*self.cost
end

AStar.diagonal = function(self, x, y)  -- 对角线估价法,先按对角线走，一直走到与终点水平或垂直平行后，再笔直的走
	local dx = math.abs(x - self.endPoint.x)
	local dy = math.abs(y - self.endPoint.y)
	local minD = math.min(dx, dy)
	local h = minD*self.diag + dx + dy - 2*minD
	return h*self.cost
end

return AStar






