-------------- Effect base layer --------------
-- call_back is nil-able
-- isy is nil-able
local function startMoveEffectAnimation(effect_data, distan, ani_tick, isy, side)
	if side == nil then side = SEPARATE_NIL end

	local _is_stop = effect_data.isOver
	if _is_stop then return end

	local _side, _side_re = "spEffect"..side, "spEffectRe"..side
	local function moveEffectCB()
		if _is_stop then return end

		local sp = effect_data[_side]
		local sp_re = effect_data[_side_re]
		local px, py = sp:getPosition()
		local ofc_distan = distan*2
		--effect_data.spEffect:setPosition(0, 0)
		if isy then
			local ofcx = distan
			if side == SEPARATE_L then ofcx = -distan end

			sp:setPosition(px, py + ofc_distan)
		else
			sp:setPosition(px + ofc_distan, py)
		end

		effect_data[_side], effect_data[_side_re] = sp_re, sp
		startMoveEffectAnimation(effect_data, distan, ani_tick, isy, side)
	end

	local ani_distance = distan
	local p1, p2 = nil, nil
	if isy then
		p1, p2 = CCPoint(0, -ani_distance), CCPoint(0, -ani_distance)
	else
		p1, p2 = CCPoint(-ani_distance, 0), CCPoint(-ani_distance, 0)
	end

	local array_action = CCArray:create()
	local array_action_re = CCArray:create()
	local move_act = CCMoveBy:create(ani_tick, p1)
	local move_act_re = CCMoveBy:create(ani_tick, p2)
	local cb = CCCallFunc:create(moveEffectCB)

	array_action:addObject(move_act)
	array_action:addObject(cb)
	array_action_re:addObject(move_act_re)
	local seq = CCSequence:create(array_action)
	local seq_re = CCSequence:create(array_action_re)

	effect_data[_side]:runAction(seq)
	effect_data[_side_re]:runAction(seq_re)
end

local function mkAnimation(aniSprite, animFrames, aTime, call_back)
	local _animation = CCAnimation:createWithSpriteFrames(animFrames, aTime)
	--local animation = CCAnimation:create(animFrames, 0.1)
	local animate = CCAnimate:create(_animation)
	local function _normalCallBack()
		if call_back then
			call_back(aniSprite)
		end
	end

	local cb = CCCallFunc:create(_normalCallBack)
	local seqRp = CCSequence:createWithTwoActions(animate, cb)
	local animateRp = CCRepeatForever:create(seqRp)
	-- aniSprite.isPaused = true
	aniSprite:runAction(animateRp)

	local act_mgr = CCDirector:sharedDirector():getActionManager()
	act_mgr:pauseTarget(aniSprite)
end

local function mkAniSprite(file_name, fn_format, frame_num, call_back, scale, visible)
	if frame_num <= 0 then return nil end

	local aniSprite = CCSprite:create()
	if scale then aniSprite:setScale(scale) end

	local realFrameCount = 0
	local animFrames = CCArray:create()
	local catch = CCSpriteFrameCache:sharedSpriteFrameCache()
	for i = 1, frame_num, 1 do
		local file_name = string.format(fn_format, file_name, i)
		local _frame = catch:spriteFrameByName(file_name)
		if _frame then
			-- _frame:setColor(ccbc)
			animFrames:addObject(_frame)
			aniSprite:setTextureRect(_frame:getRect())
			realFrameCount = realFrameCount + 1
		else
			-- cclog("No such file or not load plist of sprite frame (%s).", file_name)
		end
	end

	if visible == nil then aniSprite:setVisible(false)
	else aniSprite:setVisible(true) end

	aniSprite.realFrameCount = realFrameCount
	aniSprite.animFrames = animFrames

	return aniSprite
end

local function mkFrameAnimation(file_name, fn_format, frame_num, call_back, scale, visible)
	local aniSprite = mkAniSprite(file_name, fn_format, frame_num, call_back, scale, visible)
	if aniSprite == nil then return nil end

	mkAnimation(aniSprite, aniSprite.animFrames, 0.1, call_back)


	return aniSprite
end

local function mkFrameAnimationWithAniTime(file_name, fn_format, frame_num, aTime, call_back, scale, visible)
	local aniSprite = mkAniSprite(file_name, fn_format, frame_num, call_back, scale, visible)
	if aniSprite == nil then return nil end

	mkAnimation(aniSprite, aniSprite.animFrames, aTime, call_back)

	return aniSprite
end

local function mkFixTimeAnimation(file_name, fn_format, frame_num, forceTime, call_back, scale, visible)
	local aniSprite = mkAniSprite(file_name, fn_format, frame_num, call_back, scale, visible)
	if aniSprite == nil then return nil end

	local t = forceTime / aniSprite.realFrameCount
	mkAnimation(aniSprite, aniSprite.animFrames, t, call_back)

	return aniSprite
end

local effectBaseLayer = {
	mkFrameAnimation = mkFrameAnimation,
	mkFixTimeAnimation = mkFixTimeAnimation,
	mkFrameAnimationWithAniTime = mkFrameAnimationWithAniTime,
	startMoveEffectAnimation = startMoveEffectAnimation,
}

return effectBaseLayer