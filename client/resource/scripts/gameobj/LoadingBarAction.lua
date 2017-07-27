local  FLT_EPSILON  =   1.192092896e-07       -- /* smallest such that 1.0+FLT_EPSILON != 1.0 */

local ClsLoadingBarAction = class("ClsLoadingBarAction")

function ClsLoadingBarAction:isDone(void)
    return self.elapsed >= self.duration
end

function ClsLoadingBarAction:ctor(to, from, duration, target)
	self.target = target 
    self.to = to
    self.from = from
    self.duration = duration
    self.elapsed = 0
    --
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.UpdateHander then 
        scheduler:unscheduleScriptEntry(self.UpdateHander) 
        self.UpdateItemHander = nil
    end
    local function updateTime(dt)
        if tolua.isnull(self.target) then
            scheduler:unscheduleScriptEntry(self.UpdateHander) 
            self.UpdateItemHander = nil
            self = nil
            return
        end
    	self:step(dt)
        if self:isDone() then
        	scheduler:unscheduleScriptEntry(self.UpdateHander) 
        	self.UpdateItemHander = nil
        end
    end
    self.UpdateHander = scheduler:scheduleScriptFunc(updateTime, 0, false)
end

function ClsLoadingBarAction:step(dt)
    self.elapsed = self.elapsed + dt
    self:update(math.max(0,                                  --// needed for rewind. elapsed could be negative
                      math.min(1, self.elapsed /
                          math.max(self.duration, FLT_EPSILON)   --// division by 0
                          )
                      )
                )
end

function ClsLoadingBarAction:update(time)
    self.target:setPercent(self.from + (self.to - self.from) * time)
end

return ClsLoadingBarAction