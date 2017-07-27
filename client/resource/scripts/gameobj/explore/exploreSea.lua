---- 探索海浪层

local TILE_SIZE = 256
local TILE_WIDTH = 7   --维护一个 7*256 X 7*256 的正方形海浪
local TILE_HEIGHT = 7
local MAP_SIZE = TILE_SIZE * TILE_HEIGHT
local WIN_WIDTH = 960
local WIN_HEIGHT = 540


local ExploreSea = class("ExploreSea", function()
	return CCLayer:create() 
end)

local sea_color = 0x1a6396
ExploreSea.ctor = function(self)
	self.is_pause = false
	
	self.res_tab = { ["sea/sea_wave.plist"] = 1,}
	LoadPlist(self.res_tab)
	
	local map_bg = CCLayerColor:create(ccc4(0,0,0,255))
	map_bg:setColor(ccc3(dexToColor3B(sea_color)))
	self:addChild(map_bg)
	
	local SEA_WAVE_IMAGE_FILENAME = "sea/sea_wave.pvr.ccz"
	self.batch_wave = display.newBatchNode(SEA_WAVE_IMAGE_FILENAME, 50)
	self:addChild(self.batch_wave)
	self:create_TileMap()
	
	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)	
end

ExploreSea.start = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
	
	local parent = self:getParent()
	self.last_pos_x = -self:getPositionX()
	self.last_pos_y = -self:getPositionY()
	
	self.last_pos_bg_x = -self:getPositionX()
	self.last_pos_bg_y = -self:getPositionY()
	
	local function doUpdate(dt)
		if self.is_pause  then return end
		local x, y = parent:getPosition()
		
		----------------海浪维护---------------
		--x轴方向调整
		if x - self.last_pos_x > TILE_SIZE then -- 向右边移动
			self.last_pos_x = self.last_pos_x + TILE_SIZE
			self.start_x = self.start_x - 1 
			for i = self.start_y, self.end_y do
				self.map[i][self.start_x] = self.map[i][self.end_x]
				self.map[i][self.start_x]:setPosition(TILE_SIZE*self.start_x, TILE_SIZE*i)
				self.map[i][self.end_x] = nil
			end 
			self.end_x = self.end_x - 1
			
		elseif x - self.last_pos_x <= -TILE_SIZE then -- 向左边移动 
			self.last_pos_x = self.last_pos_x - TILE_SIZE
			self.end_x = self.end_x + 1 
			for i = self.start_y, self.end_y do
				self.map[i][self.end_x] = self.map[i][self.start_x]
				self.map[i][self.end_x]:setPosition(TILE_SIZE*self.end_x, TILE_SIZE*i)
				self.map[i][self.start_x] = nil
			end 
			self.start_x = self.start_x + 1 
		end 
		
		-- y轴方向调整
		if y - self.last_pos_y > TILE_SIZE then -- 向上边移动
			self.last_pos_y = self.last_pos_y + TILE_SIZE
			self.start_y = self.start_y - 1 
			self.map[self.start_y] = {}
			for i = self.start_x, self.end_x do
				self.map[self.start_y][i] = self.map[self.end_y][i]
				self.map[self.start_y][i]:setPosition(TILE_SIZE*i, TILE_SIZE*self.start_y)
				self.map[self.end_y][i] = nil
			end 
			self.map[self.end_y] = nil
			self.end_y = self.end_y - 1
				
		elseif y - self.last_pos_y <= -TILE_SIZE then -- 向下边移动 
			self.last_pos_y = self.last_pos_y - TILE_SIZE
			self.end_y = self.end_y + 1
			self.map[self.end_y] = {}
			for i = self.start_x, self.end_x do
				self.map[self.end_y][i] = self.map[self.start_y][i]
				self.map[self.end_y][i]:setPosition(TILE_SIZE*i, TILE_SIZE*self.end_y)
				self.map[self.start_y][i] = nil
			end 
			self.map[self.start_y] = nil
			self.start_y = self.start_y + 1 
		end 
		
		---------------------背景维护-----------------------
		--[[
		--x轴方向调整
		if x - self.last_pos_bg_x > WIN_WIDTH then -- 向右边移动
			self.last_pos_bg_x = self.last_pos_bg_x + WIN_WIDTH
			self.start_bg_x = self.start_bg_x - 1 
			for i = self.start_bg_y, self.end_bg_y do
				self.map_bg[i][self.start_bg_x] = self.map_bg[i][self.end_bg_x]
				self.map_bg[i][self.start_bg_x]:setPosition(WIN_WIDTH*self.start_bg_x, WIN_HEIGHT*i)
				self.map_bg[i][self.end_bg_x] = nil
			end 
			self.end_bg_x = self.end_bg_x - 1
			
		elseif x - self.last_pos_bg_x <= -WIN_WIDTH then -- 向左边移动 
			self.last_pos_bg_x = self.last_pos_bg_x - WIN_WIDTH
			self.end_bg_x = self.end_bg_x + 1 
			for i = self.start_bg_y, self.end_bg_y do
				self.map_bg[i][self.end_bg_x] = self.map_bg[i][self.start_bg_x]
				self.map_bg[i][self.end_bg_x]:setPosition(WIN_WIDTH*self.end_bg_x, WIN_HEIGHT*i)
				self.map_bg[i][self.start_bg_x] = nil
			end 
			self.start_bg_x = self.start_bg_x + 1 
		end 
		
		--y轴方向调整
		if y - self.last_pos_bg_y > WIN_HEIGHT then -- 向上边移动
			self.last_pos_bg_y = self.last_pos_bg_y + WIN_HEIGHT
			self.start_bg_y = self.start_bg_y - 1 
			self.map_bg[self.start_bg_y] = {}
			for i = self.start_bg_x, self.end_bg_x do
				self.map_bg[self.start_bg_y][i] = self.map_bg[self.end_bg_y][i]
				self.map_bg[self.start_bg_y][i]:setPosition(WIN_WIDTH*i, WIN_HEIGHT*self.start_bg_y)
				self.map_bg[self.end_bg_y][i] = nil
			end 
			self.map_bg[self.end_bg_y] = nil
			self.end_bg_y = self.end_bg_y - 1
				
		elseif y - self.last_pos_bg_y <= -WIN_HEIGHT then -- 向下边移动 
			self.last_pos_bg_y = self.last_pos_bg_y - WIN_HEIGHT
			self.end_bg_y = self.end_bg_y + 1
			self.map_bg[self.end_bg_y] = {}
			for i = self.start_bg_x, self.end_bg_x do
				self.map_bg[self.end_bg_y][i] = self.map_bg[self.start_bg_y][i]
				self.map_bg[self.end_bg_y][i]:setPosition(WIN_WIDTH*i, WIN_HEIGHT*self.end_bg_y)
				self.map_bg[self.start_bg_y][i] = nil
			end 
			self.map_bg[self.start_bg_y] = nil
			self.start_bg_y = self.start_bg_y + 1 
		end 
		--]]
	end
	self.hander_time = scheduler:scheduleScriptFunc(doUpdate, 0.1, false)  -- 刷新
end

ExploreSea.stop = function(self)
	self.is_pause = false
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
end

ExploreSea.create_TileMap = function(self)
	local temp_frame
	local frame_array = {}
	for i= 1, 14 do
		temp_frame = display.newSpriteFrame(string.format("sea_water_%d.png",i))
		table.insert(frame_array, temp_frame)
	end
	local animation = display.newAnimation(frame_array, 0.1)

	self.map = {}
	for i=-1, TILE_HEIGHT-2 do
		self.map[i] = {}
		for j=-1, TILE_WIDTH-2 do
			self.map[i][j] = self:create_wave_sprite(animation, TILE_SIZE*j, TILE_SIZE*i)
			self.batch_wave:addChild(self.map[i][j], 1)	
		end	
	end
	
	self.start_x = -1  -- 起点、终点位置
	self.start_y = -1
	self.end_x   = TILE_HEIGHT - 2
	self.end_y   = TILE_WIDTH - 2
	
	--[[
	self.map_bg = {}
	for i = -2, 2 do
		self.map_bg[i] = {}
		for j = -2, 2 do
			local wave_bg = display.newSprite("#wave_bg.png")
			wave_bg:setAnchorPoint(ccp(0, 0))
			wave_bg:setScale(2)
			wave_bg:setPosition(j*WIN_WIDTH, i*WIN_HEIGHT)
			self.batch_wave:addChild(wave_bg)
			self.map_bg[i][j] = wave_bg
			--wave_bg:getTexture():setAliasTexParameters()  -- 设置非抗锯齿（解决黑线问题）
		end
	end 
	self.start_bg_x = -2  -- 起点、终点位置
	self.start_bg_y = -2
	self.end_bg_x   = 2
	self.end_bg_y   = 2
	--]]
end

ExploreSea.create_wave_sprite = function(self, animation, x, y)
	local temp_sprite = display.newSprite("#sea_water_1.png")
	temp_sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	temp_sprite:setPosition(x, y)
	return temp_sprite
end

ExploreSea.pauseMove = function(self)
	self.is_pause = true
end 

ExploreSea.resumeMove = function(self)
	self.is_pause = false
end 

ExploreSea.onExit = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
	UnLoadPlist(self.res_tab)
end

function createExploreSea()
	local map_layer = ExploreSea.new()
	return map_layer
end