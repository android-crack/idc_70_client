----  探索相关配置

EXPLORE_RATE = 30       -- 地图与探索的比例
EXPLORE_ADD_SPEED = 80  -- 探索速度增加 
EXPLORE_EX_SPEED = 20   -- 探索航海士添加速度 
EXPLORE_BASE_SPEED = 150 --基础探索速度

--探索风向
--按夹角顺序
WIND_NORTH_EAST = 1  --东北风
WIND_SOUTH_EAST = 2  --东南风
WIND_SOUTH_WEST = 3  --西南风
WIND_NORTH_WEST = 4  --西北风
WIND_NON        = 0  --无风

-- 逆风顺风
WIND_DOWN = 1  -- 顺
WIND_HEAD = 2  -- 逆
WIND_NO_EFFECT = 3  -- 无风标志

-- 帆的状态
SAIL_UP   = 1   -- 升帆
SAIL_DOWN = 0   -- 降帆

-- 速度相关
SPEED_NORNAL = 1 -- 正常

-- 顺风、逆风时的速度变化
SPEED_RATE_DOWNWIND = 2
SPEED_RATE_HEADWIND = 0.7
SPEED_RATE_DOUBLE = 2

--暴风雨速度变化
SPEED_STROM_SAIL = 0.7 

--Buff速度变化
SPEED_RATE_BUFF_UP = SPEED_RATE_DOWNWIND

-- 地图对速度影响
SPEED_MAP_EDGE = 1   -- 边缘速度比
SPEED_MAP_LAND = 0     -- 陆地
SPEED_MAP_SEA  = 1     -- 海面

-- 地图属性
MAP_LAND = 0   --陆地
MAP_SEA  = 1   --海面
MAP_EDGE = 2   --边缘（减速带）
MAP_TILE_SIZE = 64 --一个tilemax像素大小

IS_AUTO = false       -- 是否自动导航




