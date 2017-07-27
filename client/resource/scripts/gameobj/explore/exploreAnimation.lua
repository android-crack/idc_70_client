local exploreAnimation = {}

local exploreAnimation = class()

function exploreAnimation:ctor(node, aniFile, aniName)
    self.ani_t = { }

    if not node then 
        cclog("animation node is nil") 
        return 
    end

    if not aniFile then 
        cclog("invalid animation file") 
        return 
    end

	self._animation = node:getAnimation("animations")
	if not self._animation then return end 
	
	self._animation:createClips(aniFile)
    for _, ani_name in pairs(aniName) do
        local tmp = self._animation:getClip(ani_name)
        self.ani_t[ani_name] = self._animation:getClip(ani_name)
    end

    --table.print(self.ani_t)
end

function exploreAnimation:getClipsTable()
	return self.ani_t
end

function exploreAnimation:playDefault()
	if self._animation then 
		self._animation:play()
	end 
end

return exploreAnimation
