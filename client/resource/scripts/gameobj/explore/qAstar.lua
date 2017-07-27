---- 航海寻路

local QAstar = class("QAstar")

function QAstar:ctor()
	self.m_width = 0
	self.m_height = 0
	self.castar = castar.create()
end

function QAstar:init(map, width, height)
	self.m_width = width
	self.m_height = height
	self.castar:initMap(map, width, height)
end

function QAstar:searchPath(sx, sy, ex, ey, rate)
	return self.castar:findPath(sx, sy, ex, ey, rate)
end

function QAstar:fixWeight(x, y, rate)
	self.castar:fixWeight(x, y, rate)
end

--0 不可走
--1 可走
function QAstar:fixMap(x, y, w, h, value)
	self.castar:fixMap(x, y, w, h, value)
end

function QAstar:getWeight(x, y)
	if (x < 0) or (y < 0) or (x >= self.m_width) or (y >= self.m_height) then
		return 0
	end
	return self.castar:getWeight(x,y)
end

function QAstar:initByBit(fileName, width, height)
	self.m_width = width
	self.m_height = height
	self.castar:initMapByBit(fileName, width, height)
end

return QAstar
