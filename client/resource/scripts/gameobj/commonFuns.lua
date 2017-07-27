---- 一些通用的函数

local sailor_info = require("game_config/sailor/sailor_info")

local CommonBase = {}

-- 创建动画帧（包括播放）
--item = {frame_num = 1 , frame_name = "sea_rock2_", frame_time = 0.1, is_forever = false, call_back}
-- 注意 frame_name的形式如： sea_rock2_1.png ，则传参数为 sea_rock2_
function CommonBase:mkFrameAnimation(item)
	local frame_num  = item.frame_num or 0
	local frame_name = item.frame_name
	local frame_format = item.frame_format or "%d.png"
	local frame_time = item.frame_time or 0.1   -- 一帧播放时间
	local is_forever = item.is_forever or false
	local call_back  = item.call_back           -- 回调函数
	local is_remove  = item.is_remove or false  -- 释放自动释放
	local is_inverse = item.is_inverse or false --倒序
	
	if frame_num < 1 then
		cclog("%s frame_num < 1", frame_name)
		return
	end
	
	local str = frame_name..frame_format
	local last_sp   -- 最好一帧
	local ret 
	
	if frame_num == 1 then 
		local file_name = string.format("#"..str, 1)
		ret = display.newSprite(file_name)
		last_sp = display.newSprite(file_name)
	elseif frame_num > 1 then                          -- animation
		ret = display.newSprite()
		local frame_array = {}
		local catch = CCSpriteFrameCache:sharedSpriteFrameCache()

		if is_inverse then 
			for i = frame_num, 1, -1 do
				local file_name = string.format(str, i)
				local temp_frame = catch:spriteFrameByName(file_name)
				if temp_frame then
					table.insert(frame_array, temp_frame)
				else
					cclog("No such file or not load plist of sprite frame (%s).", file_name)
				end
			end
				
			local file_name = string.format("#"..str, 1)
			last_sp = display.newSprite(file_name)
		
		else 
			for i = 1, frame_num do
				local file_name = string.format(str, i)
				local temp_frame = catch:spriteFrameByName(file_name)
				if temp_frame then
					table.insert(frame_array, temp_frame)
				else
					cclog("No such file or not load plist of sprite frame (%s).", file_name)
				end
			end
			
			local file_name = string.format("#"..str, frame_num)
			last_sp = display.newSprite(file_name)
		end 

		local animation = display.newAnimation(frame_array, frame_time)

		if is_forever then
			local ac1 = CCAnimate:create(animation)
			local ac2 = CCCallFunc:create(function()
				if type(call_back) == "function" then
					call_back(ret)
				end
			end)
			local action = CCSequence:createWithTwoActions(ac1, ac2)
			ret:runAction(CCRepeatForever:create(action))
			
		else
			local ac1 = CCAnimate:create(animation)
			local ac2 = CCCallFunc:create(function()
				if type(call_back) == "function" then
					call_back()
				end
				if is_remove then
					ret:removeFromParentAndCleanup(true)
				end
			end)
			local action = CCSequence:createWithTwoActions(ac1, ac2)
			ret:runAction(action)
		end
	end
	return ret, last_sp
end


-- 和上面 有些不同，其指定初始帧， 而只创建动画（不播放）
function CommonBase:newAnimation(item)
	local frame_num  = item.frame_num or 0
	local frame_name = item.frame_name
	local frame_start= item.frame_start or 1
	local frame_time = item.frame_time or 0.1  -- 一帧播放时间
	local is_forever = item.is_forever or false
	local call_back  = item.call_back          -- 回调函数

	if frame_num < 1 then
		cclog("%s ,frame_num < 1", frame_name)
		return
	end

	local frame_array = {}
	local catch = CCSpriteFrameCache:sharedSpriteFrameCache()

	for i = frame_start, frame_num do
		local file_name = string.format("%s%d.png", frame_name, i)
		local temp_frame = catch:spriteFrameByName(file_name)
		if temp_frame then
			table.insert(frame_array, temp_frame)
		else
			cclog("No such file or not load plist of sprite frame (%s).", file_name)
		end
	end

	local animation = display.newAnimation(frame_array, frame_time)
	if is_forever then
		local action = CCRepeatForever:create(CCAnimate:create(animation))
		return action
	elseif type(call_back) == "function" then
		local ac1 = CCAnimate:create(animation)
		local ac2 = CCCallFunc:create(function() call_back() end)
		local action = CCSequence:createWithTwoActions(ac1, ac2)
		return action
	else
		local action = CCAnimate:create(animation)
		return action
	end
end

-----------------------------------------------------------
---- 字符串解析

local function getRepTable()
	local playerData = getGameData():getPlayerData()
	local boatData = getGameData():getBoatData()
	local tab = {
		["shipname"] = boatData:getPlayerBoatName(boatData:getKeyOfFlagShip()) or "",
		["usename"]  = playerData:getName() or "",
	}
	return tab
end

function CommonBase:repString(msg, rep_table)
	local rep_table = rep_table or getRepTable()
	local ret = string.gsub(msg, "$%((%w+)%)", rep_table)
	return ret
end

--[[ exp
nihao = "$(UID)去了$(SCENE), 使用了$(CASH)"
local goto = {
["UID"]=1,
["SCENE"]="西岐",
["CASH"] = "100金钱",
}
print(replace_string(nihao, goto))

--]]


function CommonBase:cnstrlen(str) --计算中文产度 一个英文字符算0.5
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then
                left=left-i
                if i>=3 then
                    cnt=cnt+1
                else
                    cnt=cnt+0.5
                end
                break
            end
            i=i-1
        end
--        cnt=cnt+1
    end
    return cnt
end

function CommonBase:utfstrlen(str) --计算utf8字符长度
	local len = #str
	local left = len
	local cnt = 0
	local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
	while left ~= 0 do
		local tmp = string.byte(str, -left)
		if left < 0 or (tmp == nil) then
			return cnt - 1
		end
		local i = #arr
		while arr[i] do
			if tmp>=arr[i] then
				left=left-i
				break
			end
			i=i-1
		end
		cnt=cnt+1
	end
	return cnt
end

function CommonBase:returnUTF_8CharValid(str) --utf截取乱码前合法的字符
	if str == "" then
		return ""
	end
	local len = self:utfstrlen(str)
	str = self:utf8sub(str, 1, len)
	return str
end

-- 判断utf8字符byte长度
function CommonBase:utfByteSize(char)
	if char == nil then
		return 0
	end
 	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local i = #arr
	while arr[i] do
		if char >= arr[i] then
			return i
		end
		i = i - 1
	end
end

function CommonBase:utf8sub(str, startChar, numChars) --utf截取, startChar起始位置，numChars截取的个数
 	local startIndex = 1
 	while startChar > 1 do
 		local char = string.byte(str, startIndex)
 		startIndex = startIndex + self:utfByteSize(char)
 		startChar = startChar - 1
 	end
 	local currentIndex = startIndex
 	while numChars > 0 and currentIndex <= #str do
 		local char = string.byte(str, currentIndex)
 		currentIndex = currentIndex + self:utfByteSize(char)
 		numChars = numChars -1
 	end
 	return str:sub(startIndex, currentIndex - 1)
 end

function CommonBase:inTable(val, tab)
	for k, v in pairs(tab) do
		if v == val then 
			return true 
		end 
	end 
	return false 
end 

function CommonBase:executeButtonEffect(target,delay,scale,disabledInAction,isPortButton)   --港口按钮特效
	if tolua.isnull(target) then return end
	target:stopAllActions()

	local enabled=false
	if disabledInAction then
		enabled=target:isEnabled()
		target:setEnabled(false)
	end
	target:setScale(0)

	delay=delay or 0
	scale=scale  or 1
	local arr=CCArray:create()
	if delay>0 then
		arr:addObject(CCDelayTime:create(delay))
	end
	arr:addObject(CCScaleTo:create(0.3,0.8*scale,1.1*scale))
	arr:addObject(CCScaleTo:create(0.1,1*scale,1*scale))
	arr:addObject(CCScaleTo:create(0.1,0.8*scale,1*scale))
	arr:addObject(CCScaleTo:create(0.1,1*scale,1*scale))
	if disabledInAction then
		arr:addObject(CCCallFunc:create(function()
			if isPortButton then
				local portLayer = getUIManager():get("ClsPortLayer")
				if not tolua.isnull(portLayer) then
					target:setEnabled(portLayer:isTouchEnabled())
				else
					target:setEnabled(enabled)
				end
			else
				target:setEnabled(enabled)
			end
		end))
	end

	target:runAction(CCSequence:create(arr))
end

function CommonBase:addNodeEffect(parent, res, vec, time)
	local ParticleSystem = require("particle_system")
	local particle = ParticleSystem.new(EFFECT_3D_PATH .. res .. PARTICLE_3D_EXT, time)
	if not particle	then return end
    local sphereNode = particle:GetNode()
    parent:addChild(sphereNode)
    vec = vec or Vector3.new(0, 10, 0)
    sphereNode:setTranslation(vec) --鲸鱼z = 30, 小人z = -20
	return sphereNode, particle
end 

function CommonBase:getShipNearPos()

	local angle = math.random(360)
	local angleTa = 0
	local x = 0
	local z = 0
	local w = 520
	local h = 820

	local angleSource = w / h
	if angle < 90 and angle > 0 then
		angleTa = angle
		local tan = math.tan(math.rad(angleTa))
		if tan < angleSource then
			x = h * tan
			z = -h
		else
			x = w
			z = -w / tan
		end
	elseif angle < 180 and angle > 90 then
		angleTa = angle - 90
		local tan = math.tan(math.rad(angleTa))
		local angleSource = h / w
		if tan < angleSource then
			x = w
			z = w * tan
		else
			x = h / tan
			z = h
		end

	elseif  angle < 270 and angle > 180 then
		angleTa = angle - 180
		local tan = math.tan(math.rad(angleTa))
		if tan < angleSource then
			x = -h * tan
			z = h
		else
			x = -w
			z = w / tan
		end
    elseif  angle < 360 and angle > 270 then
    	angleTa = angle - 270
		local tan = math.tan(math.rad(angleTa))
		local angleSource = h / w
		if tan < angleSource then
			x = -w
			z = -w * tan
		else
			x = -h / tan
			z = -h
		end
    end

    if angle == 0 or angle == 360 then
    	x = 0
    	z = -h
    elseif angle == 90 then
    	x = w
    	z = 0
    elseif  angle == 180 then
		x = 0
    	z = h
    elseif  angle == 270 then
		x = -w
    	z = 0
    end

    return x, z, angle
end 

--判断文本是否为全空
function CommonBase:checkAllCharacterIsNul( str )
	local char = string.gsub(str, "%s", "")--去掉空格字符
	local len = self:utfstrlen(char)
	return len == 0
end

------------------------------------------------------------------------------------------------------------------------
-- 判断(x, y)是否在线(x1, y1)(x2, y2)左
function CommonBase:IsLineLeft(x1, y1, x2, y2, x, y)
    if x1 == x2 then
        if x1 == x then return 0 end

        if y1 < y2 then
            return x1 - x
        else
            return x - x1
        end
    end

    if y1 == y2 then
        if y1 == y then return 0 end

        if x1 < x2 then
            return y - y1
        else
            return y1 - y
        end
    end

    local k = (y2 - y1)/(x2 - x1)
    local dest_y = (x - x1)*k + y1

    return (y - dest_y)*(x2 >= x1 and 1 or -1)
end

------------------------------------------------------------------------------------------------------------------------

return CommonBase
















