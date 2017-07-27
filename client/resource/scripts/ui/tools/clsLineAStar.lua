--
-- Author: lzg0496
-- Date: 2017-02-03 11:57:59
-- Function: 直线寻路Astar

local ClsLineAStar = class("ClsLineAStar")

function ClsLineAStar:ctor(pos_list, speed, map_tile_size)
    if type(pos_list) ~= "table" or #pos_list == 1 or not speed or not map_tile_size then return end
    self.pos_list = pos_list
    self.times = {0}
    self.speed = speed
    local sum_time = 0
    for k, v in ipairs(pos_list) do
        if k == #pos_list then
            break
        end
        local dis = Math.distance(v.x, v.y, pos_list[k + 1].x, pos_list[k + 1].y)
        local time = dis * map_tile_size / speed
        sum_time = sum_time + time
        self.times[#self.times + 1] = sum_time
    end
end

--外部可调用
--返回当前时间的位置ccp
function ClsLineAStar:getCurPos(time)
    if not self.pos_list then return end
    local cur_pos = ccp(0, 0)
    local pos_index = 0
    local rate_n = 1

    if time >= self.times[#self.times] then
        return self.pos_list[#self.pos_list], #self.times, rate_n
    end

    for k, v in ipairs(self.times) do
        if v > time then
            pos_index = k
            break
        end
    end

    if pos_index == 0 then
        return self.pos_list[1], 1, rate_n
    end

    local end_pos = self.pos_list[pos_index]
    local start_pos = self.pos_list[pos_index - 1]
    rate_n = (time - self.times[pos_index - 1]) / (self.times[pos_index] - self.times[pos_index - 1])
    cur_pos.x = start_pos.x + (end_pos.x - start_pos.x) * rate_n
    cur_pos.y = start_pos.y + (end_pos.y - start_pos.y) * rate_n
    return cur_pos, pos_index, rate_n
end

return ClsLineAStar
