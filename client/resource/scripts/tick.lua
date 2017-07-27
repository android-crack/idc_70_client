-- 脚本的逻辑帧
-- 定义脚本的全局context
-- 默认当前帧为1
local ModContext = require("framework.api.Context")
require("base/perftime")
require("base/gc")

-- 系统上下文
local SYSTEM_CONTEXT = ModContext:new()

-- 每秒帧数
FRAME_CNT_PER_SEC = 1 / CCDirector:sharedDirector():getAnimationInterval()

SHIP_HEART_BEAT_CNT_PER_SEC = 3

function getCurrentFrame()
	return SYSTEM_CONTEXT:get( "current_frame", 1 )
end

local old_frame = nil;
local frame_data = { name = "frame_update" };

local function setCurrentFrame(curFrame)
	old_frame = getCurrentFrame()

	SYSTEM_CONTEXT:set( "current_frame", curFrame )

	if ( old_frame ~= curFrame ) then
		-- fire frame_update
		SYSTEM_CONTEXT:dispatchEvent( frame_data );
	end

end

function getCurrentLogicTime()
	return SYSTEM_CONTEXT:get( "current_time", 0 )
end

local function setCurrentLogicTime(curTime)
	return SYSTEM_CONTEXT:set( "current_time", curTime )
end

local pause_flg = false

function resumeTick()
	pause_flg = false
end

function pauseTick()
	pause_flg = true
end

local time = 0

local cur_frame
local cur_time
-- 帧心跳，
-- deltaTime为上帧与本帧的间隔
local function frameUpdate(delta_time)
	-- print("================ frameUpdate:", delta_time)
	--require("game3d"):update(delta_time*1000)
	
	perftime.gperf_begin("tick_update")

	if BattleInit3D.is_start then 
		BattleInit3D:updateScene3D(delta_time*1000)
	elseif Explore3D.is_start  then 
		Explore3D:updateScene3D(delta_time*1000)
	end	

	perftime.gperf_end("tick_update")
	
	if ( pause_flg ) then
		return
	end

	cur_frame = getCurrentFrame()
	cur_time = getCurrentLogicTime()

	cur_frame = cur_frame + 1
	cur_time = cur_time + delta_time

	perftime.gperf_begin("tick_heartbeat")
	
	-- 记录逻辑时间
	setCurrentLogicTime( cur_time )

	-- 记录当前帧
	setCurrentFrame( cur_frame )

	perftime.gperf_end("tick_heartbeat")
	
	perftime.update(delta_time)
	
	gc.update_gc(delta_time)
	
	-- TODO:战斗心跳
	--
	--

	------------------------------------------------------
	-- modify By Hal 2015-10-23, Type(BUG) - 定期清理LUA缓存
	--[[
	if getUIManager():get("ClsPortLayer") then
		time = time + delta_time;
		if time > 2.0 then
			time = 0
			collectgarbage("collect")
			--local mem_count = collectgarbage("count");
			-- print( "currectly memory --------------------- "..mem_count );
		end
	end
	--]]
	------------------------------------------------------
end

function getSystemContext()
	return SYSTEM_CONTEXT
end

-- 系统上下文的初始化
local function initSystemContext()
	-- 暂时没有内容
end

-- 调用系统上下文初始化
initSystemContext()
QTick:sharedQTick():registerHandler(frameUpdate)

