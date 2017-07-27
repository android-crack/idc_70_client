--Bezier.lua
--Date 2015.06.15

--起始点,结束点,pointContentSize是必要参数
clsBezierCubicLine = class("clsBezierCubicLine")


--起始点,结束点,pointContentSize是必要参数，其他可使用默认值
function clsBezierCubicLine:ctor(pointBegin,pointTarget,pointContentSize,inflectionPoint1,inflectionPoint2)
    
    local middleX = (pointBegin.x + pointTarget.x)/2
    local middleY = (pointBegin.y + pointTarget.y)/2
    local middleZ = (pointBegin.z + pointTarget.z)/2
    --local middlePoint = { x = middleX, y = middleY, z = middleZ}

    local diffX = math.abs(pointBegin.x - pointTarget.x)
    local diffY = math.abs(pointBegin.y - pointTarget.y)

    local tempPoint1 = { x = middleX, y = pointBegin.y, z = middleZ}
    local tempPoint2 = { x = middleX, y = pointTarget.y, z = middleZ}
    inflectionPoint1 = inflectionPoint1 or tempPoint1
    inflectionPoint2 = inflectionPoint2 or tempPoint2

    if diffX >= diffY then
        self.totalIndex = math.ceil(diffX/pointContentSize.width)
    else
        self.totalIndex = math.ceil(diffY/pointContentSize.height)
    end 
    self.curIndex = 0
    self:setBezierLineArgs(pointBegin,pointTarget,pointContentSize,inflectionPoint1,inflectionPoint2)
end

function clsBezierCubicLine:setBezierLineArgs(pointBegin,pointTarget,pointContentSize,inflectionPoint1,inflectionPoint2)
    self.pointBegin = pointBegin
    self.pointTarget = pointTarget
    self.pointContentSize = pointContentSize
    self.inflectionPoint1 = inflectionPoint1
    self.inflectionPoint2 = inflectionPoint2
end

function clsBezierCubicLine:getTotalIndex()
    return self.totalIndex
end

function clsBezierCubicLine:getCurIndex()
    return self.curIndex
end

function clsBezierCubicLine:setCurIndex(index)
    if index < 0 or index > self.totalIndex then
        return
    end
    self.curIndex = index
end


--会自动递增
function clsBezierCubicLine:getNextPoint()
    self.curIndex = self.curIndex + 1
    if self.curIndex >= self.totalIndex then
        return self.pointTarget
    end
    local t = self.curIndex/self.totalIndex
    local quadraticT = math.pow(t,2)
    local cubicT = math.pow(t,3)
    local oneSubT = 1.0 - t
    local quadraticOneSubT = math.pow(oneSubT,2)
    local cubicOneSubT = math.pow(oneSubT,3)
    

    local x = self.pointBegin.x * cubicOneSubT + 3 * self.inflectionPoint1.x * t * quadraticOneSubT + 3 * self.inflectionPoint2.x * quadraticT * oneSubT + self.pointTarget.x * cubicT 
    local y = self.pointBegin.y * cubicOneSubT + 3 * self.inflectionPoint1.y * t * quadraticOneSubT + 3 * self.inflectionPoint2.y * quadraticT * oneSubT + self.pointTarget.y * cubicT 
    local z = self.pointBegin.z * cubicOneSubT + 3 * self.inflectionPoint1.z * t * quadraticOneSubT + 3 * self.inflectionPoint2.z * quadraticT * oneSubT + self.pointTarget.z * cubicT 

    return {x = x, y = y, z = z}
end



return clsBezierCubicLine