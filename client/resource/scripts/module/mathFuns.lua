-- 一些常用的数学函数
require("module/gameBases")


Math = {}

-- 效率
Math.sqrt = math.sqrt
Math.floor = math.floor
Math.ceil = math.ceil
Math.sin = math.sin
Math.cos = math.cos
Math.deg = math.deg
Math.rad = math.rad
Math.asin = math.asin
Math.acos = math.acos
Math.tan = math.tan 
Math.abs = math.abs
Math.max = math.max
Math.min = math.min
Math.random = math.random
Math.mod = math.mod 

Math.distance_square = function(x1, y1, x2, y2)
    local dx, dy = x2-x1, y2-y1
    return dx*dx + dy*dy
end

Math.distance = function(x1, y1, x2, y2)
	return Math.sqrt(Math.distance_square(x1, y1, x2, y2))
end

--四舍五入
Math.round = function(v)
	return Math.floor(v + 0.5)
end

Math.clamp = function(left_val, right_val, val)
	if val < left_val then 
		return left_val
	elseif val > right_val then 
		return right_val
	end 
	return val
end 

--根据2个点 算出水平夹角 （-90,270）逆时针为正
Math.getAngle = function(x1, y1, x2, y2) 
	local a = y2 - y1
	local c = Math.distance(x1, y1, x2, y2)
	if c == 0 then 
		return 0 
	end 
	local angle = Math.deg(Math.asin(a/c)) --反正弦
	if x2 < x1 then 
		angle = 180-angle
	end
	return angle
end

-- 余玄定理 cosC = (a*a + b*b - c*c)/2ab
Math.getCosAngle = function(pA, pB, pC)
	local a = Math.distance(pB.x, pB.y, pC.x, pC.y)
	local b = Math.distance(pA.x, pA.y, pC.x, pC.y)
	local c = Math.distance(pA.x, pA.y, pB.x, pB.y)
	local cosC = (a*a + b*b - c*c)/2*a*b
	local angle = Math.deg(Math.acos(cosC))
	return angle
end 

Math.getQuadrantByAngle = function(angle)
	angle = angle%FULL_ANGLE
	if angle < 0 then angle = angle + FULL_ANGLE end

	if angle < RIGHT_ANGLE then return QUADRANT_ONE end
	if angle < STRAIGHT_ANGLE then return QUADRANT_TWO end
	if angle < ANTRIGHT_ANGLE then return QUADRANT_THR end
	return QUADRANT_FOR
end

Math.getSinCos = function(angle)
	local rad_ang = Math.rad(angle)
	return Math.sin(rad_ang), Math.cos(rad_ang)
end



--2个向量叉积
--[[
计算向量的叉积（ABxAC A(x1,y1) B(x2,y2) C(x3,y3)）是计算行列式    
 | x1-x0 y1-y0 |                      
 | x2-x0 y2-y0 |                         
 的结果(向量的叉积 AB X AC)  
P1XP2 = |P1||P2|sina 
 sina = P1XP2 / (|P1||P2|)
--]]

Math.getCross = function(p0, p1, p2)  -- p0p1 X p0p2 的叉积
	return (p1.x - p0.x)*(p2.y - p0.y) - (p2.x - p0.x)*(p1.y - p0.y)
end

Math.getIntersectionAngle = function(p0, p1, p2) --获取 角p1p0p2的夹角，大于0顺时钟，小于0逆时针
	local cross = Math.getCross(p0, p1, p2)
	local dis_p1 = Math.distance(p0.x, p0.y, p1.x, p1.y)
	local dis_p2 = Math.distance(p0.x, p0.y, p2.x, p2.y)
	if dis_p1 == 0 or dis_p2 == 0 then 
		return 180
	end 
	local value_sin = cross/(dis_p1*dis_p2)  -- sina
	return Math.deg(Math.asin(value_sin)) --反正弦
end 

Math.xyToAngle = function(x1, y1, x2, y2)
	local _x, _y = x2 - x1, y2 - y1
	local tan_value = Math.atan2(_x, _y)
	local ang = Math.deg(tan_value)

	return ang
end


-- 根据双方距离返回距离
Math.distanRange = function(attacker_data, target_data)
	local px, py = attacker_data:getPosition()
	local tx, ty = target_data:getPosition()
	return Math.distance(px, py, tx, ty)
end

-- 点在多变形内判断
--[[点线判别法
	如果判断点在所有边界线的同侧，就能判定该点在多边形内部。
	判断方法就是判断两条同起点射线斜率差。
]]--
Math.insidePolygon = function(polygon, p) -- 多边形点、顶点个数、要判断的点
	local lastSide = nil  -- 保存点在线段的哪一侧
	local n1 = 0
	local n2 = 0
	local n = #polygon
	for i = 1, n do
		j = (i%n)+1 
		local value = (p.x - polygon[j].x) * (polygon[i].y - polygon[j].y) - (p.y - polygon[j].y) * (polygon[i].x - polygon[j].x)
		local side = (value > 0)
		if lastSide ~= nil and side ~= lastSide then
			return false --不相交
		end
		lastSide = side
	end
	return true  
end

-- 2个凸多边形是否相交
Math.intersectPolygon = function(polygon1, polygon2) -- 2个多边形
	for k, p in ipairs(polygon1) do
		if Math.insidePolygon(polygon2, p) then
			return true
		end
	end
	for k, p in ipairs(polygon2) do
		if Math.insidePolygon(polygon1, p) then
			return true
		end
	end
	return false
end 

Math.bit_and = function(a, b)
	return QTZUtil._and(a, b)
end

Math.bit_or = function(a, b)
	return QTZUtil._or(a, b)
end

Math.bit_xor = function(a, b)
	return QTZUtil._xor(a, b)
end

Math.bit_not = function(a)
	return QTZUtil._not(a)
end

Math.bit_lshift = function(a, b)
	return QTZUtil._lshift(a, b)
end

Math.bit_rshift = function(a, b)
	return QTZUtil._rshift(a, b)
end


