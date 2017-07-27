local compositeEffectInfo = require("game_config/composite_effect")
local tween = require("gameobj/tween")
local preload_mgr = require("module/preload/preload_mgr")
local math_floor = math.floor
local math_sqrt = math.sqrt
local math_deg = math.deg
local math_rad = math.rad
local math_atan = math.atan
local math_cos = math.cos
local math_sin = math.sin
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_pow = math.pow

-- 重力常数
local GRAVITY = 100 


TEXTURE_FORMAT = {
	["char"] 		= kCCTexture2DPixelFormat_RGBA4444,
	["building"]	= kCCTexture2DPixelFormat_RGBA4444,
    ["effect"]    = kCCTexture2DPixelFormat_RGBA8888,
	["default"]		= kCCTexture2DPixelFormat_RGBA8888, 
}
local blendNameMap = {
	["GL_ZERO"] = GL_ZERO,               
	["GL_ONE"] = GL_ONE,                
	["GL_SRC_COLOR"] = GL_SRC_COLOR,          
	["GL_ONE_MINUS_SRC_COLOR"] = GL_ONE_MINUS_SRC_COLOR,
	["GL_SRC_ALPHA"] = GL_SRC_ALPHA,          
	["GL_ONE_MINUS_SRC_ALPHA"] = GL_ONE_MINUS_SRC_ALPHA,
	["GL_DST_ALPHA"] = GL_DST_ALPHA,          
	["GL_ONE_MINUS_DST_ALPHA"] = GL_ONE_MINUS_DST_ALPHA,
	["GL_DST_COLOR"] = GL_DST_COLOR,          
	["GL_ONE_MINUS_DST_COLOR"] = GL_ONE_MINUS_DST_COLOR,
}


local CompositeEffect = class("CompositeEffect",function()
	local layer = CCNodeRGBA:create() 
	layer:setCascadeOpacityEnabled(true) -- 使其子节点也会跟着父节点的透明度变化
	return layer
end
)

----------- consts ---------------
local LAYER_TOP = "TOP"
local LAYER_NORMAL = "NORMAL"
local LAYER_FLOOR = "FLOOR"
local LAYER_TOPEST = "TOPEST"



local EFFECT_PATH = "effects/"
local PARTICLE_SUFFIX = ".plist"
local PNG_SUFFIX = ".png"
local PLIST_SUFFIX = ".plist"
local JSON_SUFFIX = ".ExportJson"
----------------------------------

----------- local functions ------
local _clearAll = nil
----------------------------------

local function sequenceAction(actions)
    if #actions < 1 then return end
    if #actions < 2 then return actions[1] end

    local prev = actions[1]
    for i = 2, #actions do
        prev = CCSequence:createWithTwoActions(prev, actions[i])
    end
    return prev
end

function CompositeEffect:removeAction(action)
	local actionManager = CCDirector:sharedDirector():getActionManager()
    if not tolua.isnull(action) then
        actionManager:removeAction(action)
    end
end

function CompositeEffect:stopEffect()
    local actionManager = CCDirector:sharedDirector():getActionManager()
    if self.animations then
        for _, ani in pairs(self.animations) do
            ani:getAnimation():stop()
        end
    end

    if self.particles then
        for _, particle in pairs(self.particles) do
            particle:setVisible(false)
        end
    end
end

function CompositeEffect:performWithDelay(callback, delay)
    local action = sequenceAction({
        CCDelayTime:create(delay),
        CCCallFunc:create(callback),
    })
    self:runAction(action)
    return action
end

-- rotateAngle: 以垂直向上方向为0度, 顺时针旋转.
function CompositeEffect:ctor(id, x, y, parent, duration, onClear, onClearParams, rotateAngle)
   self:__perform(id, x, y, parent, duration, onClear, onClearParams, rotateAngle) 
end

function CompositeEffect:__perform(id, x, y, parent, duration, onClear, onClearParams, rotateAngle)
    local effConfig = compositeEffectInfo[id]
	
	self.config = effConfig
    self.id = id
    self.delayers = {}
    self.onClear = onClear
    self.onClearParams = onClearParams
    self.rotateAngle = rotateAngle or 0

    if not effConfig then
        cclog("[Composite effect]:\"" .. tostring(id) .. "\" is not exist!!!")
        return
    end

    if parent then
        self:setPosition(ccp(x, y))
        if effConfig.layer == LAYER_TOP then
            self:setZOrder(TOP_ZORDER)
        elseif effConfig.layer == LAYER_TOPEST then
            self:setZOrder(TOPEST_ZORDER)
        elseif effConfig.layer == LAYER_FLOOR then
            self:setZOrder(-10)
        end
    end

    -- 保存初始位置
    self.oX, self.oY = self:getPosition()

    if parent and not tolua.isnull(parent) then
        if type(parent.addCCNode) == "function" then
            parent:addCCNode(self)
        else
            parent:addChild(self)
        end
    else
        cclog("[Composite effect]:%s Must have a parent!!!", self.id)
    end

    self:setAnchorPoint(ccp(0, 0))

    if not duration then
        duration = effConfig.duration
    end
	self.isshake = effConfig.isshake
	
    self.particlesInfoList = effConfig.particles or {}
    self.animationsInfoList = effConfig.animations or {}
	self.frameAnimations = effConfig.frameAnimations
    if duration and duration > 0 then

         table.insert(self.delayers,  self:performWithDelay(function()
            _clearAll(self) 
        end, duration))
    end
    
    self.duration = duration or 0
	
    if self.particles then
        self:playParticles()
    else
        self:createParticles()
    end

    if self.animations then
        self:playAnimations()
    else
        self:createAnimation()
    end
	
	if self.isshake then
		self.shakeInfos = effConfig.shake
		self:makeShakes()
	end
	
	if self.frameAnimations then
		local res = self.frameAnimations.res
		local startFrame = self.frameAnimations.startFrame or 1
		local frmNum = self.frameAnimations.num
		local delayPerUnit = self.frameAnimations.delayPerUnit
		local frameAni = self:createFrameAnimations(res, startFrame, frmNum, delayPerUnit)
		parent:addChild(frameAni)
	end
	
	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)
end

local playingEffectInArea = {}

local AREA_PART_BASE = 84 
function CompositeEffect.checkRepeatInArea(id, x, y, parent, maxRepeat)
    if not playingEffectInArea[parent] then
        playingEffectInArea[parent] = {}
    end

    if not playingEffectInArea[parent][id] then
        playingEffectInArea[parent][id] = {}
    end

    local index = CompositeEffect.getAreaDepartIndex(x, y)
    local curEffectCount = playingEffectInArea[parent][id][index] or 0
    if curEffectCount >= maxRepeat then 
        return false 
    end
    playingEffectInArea[parent][id][index] = curEffectCount + 1

    return true
end

function CompositeEffect.getAreaDepartIndex(x, y)
    local col = math_floor(x / AREA_PART_BASE)
    local row = math_floor(y / AREA_PART_BASE)
    local index = math_floor(col * 100000 + row)
    return index
end

function CompositeEffect:subEffectRepeatCountInArea()
    local parent = self:getParent()
    local id = self.id
    if not playingEffectInArea[parent] 
        or not playingEffectInArea[parent][id] then 
        return 
    end
    local index = CompositeEffect.getAreaDepartIndex(self.oX, self.oY)
    local curEffectCount = playingEffectInArea[parent][id][index]
    if not curEffectCount then 
        return 
    end
    playingEffectInArea[parent][id][index] = curEffectCount - 1
end

function CompositeEffect:playParticles()
    for i, particle in ipairs(self.particlesInfoList) do
        local key = particle.res
        local offsetX = particle.x or 0
        local offsetY = particle.y or 0
        local zOrder = particle.z or 0
        local showTime = particle.showTime or 0 
        local hideBeforeEnd = particle.hideBeforeEnd or 0
        local isRotate = particle.isRotate == 1 or false

        local particleNode = self.particles[i] 
        particleNode:setAnchorPoint(ccp(0.5, 0.5))
        particleNode:setPosition(ccp(offsetX, offsetY))
        particleNode:setZOrder(zOrder)
        --particleNode:setAutoRemoveOnFinish(true)
        particleNode:setPositionType(kCCPositionTypeRelative)
		--print("isRotate, self.rotateAngle",isRotate, self.rotateAngle)
        if isRotate and self.rotateAngle then
            particleNode:setAngle(90 - self.rotateAngle)
        end

        local showFunc = function()
            particleNode:setVisible(true)
            particleNode:resetSystem()
        end

        if showTime > 0 then 
            table.insert(self.delayers, self:performWithDelay(showFunc, showTime))
        else 
            showFunc() 
        end

        if self.duration and self.duration > 0 and hideBeforeEnd and hideBeforeEnd > 0 then 
            local duration = self.duration - hideBeforeEnd 
            table.insert(self.delayers, self:performWithDelay(function()
                particleNode:setEmissionRate(0)              
            end, duration))
        end
    end
end

function CompositeEffect:createParticles()
    self.particles = {}
	for _, particle in ipairs(self.particlesInfoList) do
        local key = particle.res
		local fileName = string.format("%s%s%s", EFFECT_PATH, key, PARTICLE_SUFFIX)

        ------ 序列帧纹理相关 ---------
        local aniTex = particle.aniTex
        local aniRes = particle.aniRes
        local aniStartFrm = particle.aniStart or 0
        local aniFrms = particle.aniFrms or 1
        local aniDelay = particle.aniDelay or 8 / 60
        local scaleX = particle.scaleX or 1
        local scaleY = particle.scaleY or 1
        -------------------------------

		local particleNode = nil
        if not aniTex then
            if preload_mgr.particle_plist_buff[fileName] then
                particleNode = CCParticleSystemQuad:create(preload_mgr.particle_plist_buff[fileName], "effects/")
            else
                particleNode = CCParticleSystemQuad:create(fileName)
            end
            --particleNode = CCParticleSystemQuad:create(fileName)
        else
            particleNode = QParticleSpriteQuad:create(fileName)
            local animation = self:createParticleAnimationTexture(aniRes, aniTex, aniStartFrm, aniFrms, aniDelay) 
            particleNode:setAnimation(animation)
        end

        -- 记录原始的emissionRate, 用于复用时重置
        particleNode.realEmissionRate = particleNode:getEmissionRate()
        particleNode.realAngle = particleNode:getAngle()
        particleNode.realAngleVar = particleNode:getAngleVar()
        particleNode:stopSystem()
        particleNode:setVisible(false)
        self:addChild(particleNode)
        particleNode:setScaleX(scaleX)
        particleNode:setScaleY(scaleY)
        
        -- 维护粒子列表, 用于特效池复用
        table.insert(self.particles, particleNode)
	end

    self:playParticles()
end

function CompositeEffect:playAnimations()
    for i, animation in ipairs(self.animationsInfoList) do
        local key = animation.res
        local ani = animation.ani
        local offsetX = animation.x or 0
        local offsetY = animation.y or 0
		local scaleX  = animation.scaleX or 1
		local scaleY  = animation.scaleY or 1
        local zOrder = animation.z or 0
        local showTime = animation.showTime or 0
        local loop = animation.isLoop or 0
        local blending = animation.blending or nil
        local isRotate = animation.isRotate == 1 or false

		local armature = self.animations[i] 
        armature:setAnchorPoint(ccp(0.5, 0.5))
		armature:setPosition(ccp(offsetX, offsetY))
        armature:setZOrder(zOrder)
		armature:setScaleX(scaleX)
		armature:setScaleY(scaleY)

        if isRotate and self.rotateAngle then
            armature:setRotation(270 + self.rotateAngle)
            if self.rotateAngle > 90 then
                armature:setScaleY(-1)
            else
                armature:setScaleY(1)
            end
        end

        -- 混合模式
        if blending then
            local blendFunc = ccBlendFunc()
            blendFunc.src =  blendNameMap[blending[1]]
            blendFunc.dst = blendNameMap[blending[2]]
            armature:setBlendFunc(blendFunc)
        end

        local showFunc = function()
            local animation = armature:getAnimation()
            if not tolua.isnull(animation) then 
				local speedScale = CCDirector:sharedDirector():getAnimationInterval() * RES_FPS
				animation:setSpeedScale(speedScale)
                animation:play(ani, -1, -1, loop)
            end
           
			armature:setAnchorPoint(ccp(0.5, 0.5))
            armature:setVisible(true)
        end

        if showTime > 0 then 
           table.insert(self.delayers, self:performWithDelay(showFunc, showTime))
        else 
            showFunc() 
        end
    end
end

function CompositeEffect:createAnimation() --CCArmature动画
    self.animations = {}
    for _, animation in ipairs(self.animationsInfoList) do
            local key = animation.res
			local jsonFile = string.format("effects/%s.ExportJson", key)
			LoadArmature(jsonFile)
			local armature = CCArmature:create(key)
            armature:setVisible(false)
            self:addChild(armature)
           
            -- 维护粒子列表, 用于特效池复用
            table.insert(self.animations, armature)
    end

    self:playAnimations()
end

function CompositeEffect:createFrameAnimations(ani, startFrame, frmNum, delayPerUnit) --CCAnimate 动画
	local animation = CCAnimation:create()
    animation:setDelayPerUnit(delayPerUnit)
    for i=startFrame, startFrame + frmNum - 1 do
        local s = string.format("%s%04d.png", ani, i)
        local frame = display.newSpriteFrame(s) 
        animation:addSpriteFrame(frame) 
    end
	--self.parent:addChild(animation)
    return animation
end

function CompositeEffect:createParticleAnimationTexture(res, ani, startFrame, frmNum, delayPerUnit)
    local plistFile = string.format("%s%s.plist", EFFECT_PATH, res)
	SetResFormat(plistFile)
	AddPlist(plistFile)
	ResetResFormat(plistFile)
    local animation = CCAnimation:create()
    animation:setDelayPerUnit(delayPerUnit)
    for i=startFrame, startFrame + frmNum - 1 do
        local s = string.format("%s%04d.png", ani, i)
        local frame = display.newSpriteFrame(s) 
        animation:addSpriteFrame(frame) 
    end

    return animation
end

function CompositeEffect:makeShakes()
	local shakeInfos = self.shakeInfos 
	if not shakeInfos then return end
	self:doShake(shakeInfos)
end

function CompositeEffect:doShake(shakeInfo)
	if not shakeInfo then return end


    if not shakeInfo.showTime or shakeInfo.showTime <= 0 then
        -- 停止之前的震动
        tween.stopShake(display.getRunningScene())
	    tween.shake(display.getRunningScene(), shakeInfo.duration, shakeInfo.shakeX, shakeInfo.shakeY, shakeInfo.shakeTimes)
    else
       local showFunc = function()
           -- 停止之前的震动
           tween.stopShake(display.getRunningScene())
           tween.shake(display.getRunningScene(), shakeInfo.duration, shakeInfo.shakeX, shakeInfo.shakeY, shakeInfo.shakeTimes)
       end
       table.insert(self.delayers, self:performWithDelay(showFunc, shakeInfo.showTime)) 
    end
end

_clearAll = function(self)
    if tolua.isnull(self) then return end
    if self.delayers then
        for _, delayer in pairs(self.delayers) do
            self:removeAction(delayer)
        end
        self.delayers = nil
    end
    self:subEffectRepeatCountInArea()

    local onClear = self.onClear
    local params = self.onClearParams
    self.onClear = nil
    self.onClearParams = nil

    if not self.isBollow then
        self:removeAllChildrenWithCleanup(true)
        self:removeFromParentAndCleanup(true)
    else
        CompositeEffect.repay(self)
    end

    -- 清理完毕后调用
    if onClear then
        if not params then 
            onClear()
        else 
            onClear(unpack(params))
        end
    end
end

-- 删除纹理
function CompositeEffect:removeTexture()
	-- particle
	for k, v in pairs(self.particlesInfoList) do
		local res = v.res 
		local plistFile = string.format("effects/%s.plist", res)
		RemovePlist(plistFile)
	end 
	
	-- armature
	for k, v in pairs(self.animationsInfoList) do
		local res = v.res 
		local jsonFile = string.format("effects/%s.ExportJson", res)
		UnLoadArmature({jsonFile})
	end 
end

--给外部调用
function CompositeEffect:clearAll()
	_clearAll(self)
end

function CompositeEffect:onExit()
	self:removeTexture()
end 

-------------------------  特效池相关 -------------------------------
-- 重置特效, 以便复用
function CompositeEffect:reset()
    -- 停止所有外部action
    self:stopAllActions()
    if self.animations then
        for _, ani in pairs(self.animations) do
            ani:getAnimation():stop()
            ani:setVisible(false)
        end
    end

    if self.particles then
        for _, particle in pairs(self.particles) do
            particle:resetSystem()
            particle:setEmissionRate(particle.realEmissionRate)
            particle:setAngle(particle.realAngle)
            particle:setAngleVar(particle.realAngleVar)
            particle:setVisible(false)
        end
    end
    self.rotateAngle = nil
    -- 清空clear函数
    self.onClear = nil
    self.oremoveHeadEffecinClearParams = nil
end

-- 特效池列表
local effPool = {}
function CompositeEffect.__getPoolByName(id)
    if not effPool then
        effPool = {}
    end

    if not effPool[id] then
        effPool[id] = {}
    end
    
    return effPool[id]
end

function CompositeEffect.bollow(id, x, y, parent, duration, onClear, onClearParams, rotateAngle, maxRepeatInArea)
    if not id then return end

    local effConfig = compositeEffectInfo[id]

    if not effConfig then
        cclog("[Composite effect]:\"" .. tostring(id) .. "\" is not exist!!!")
        return
    end

    -- 默认父容器为buildingLayer
    if not parent then
		cclog("[Composite effect]:no parent,use current scene as parent")
        parent = display.getRunningScene()
    end

   -- 同一区域, 同一特效超出一定的当前数量太多, 则不予生成
    if maxRepeatInArea and maxRepeatInArea > 0 
        and (not parent 
               or not CompositeEffect.checkRepeatInArea(id, x, y, parent, maxRepeatInArea)) then
        return
    end

   local effList = CompositeEffect.__getPoolByName(id)
   local isNew = false

   local eff = nil

   if #effList > 0 then
       eff = effList[#effList]
       effList[#effList] = nil
       if tolua.isnull(eff) then
           eff = nil
           cclog("[ERROR]: try to a bollow a released CompositeEffect")
       end
   end

   if not eff then
       eff = CompositeEffect.new(id, x, y, parent, duration, onClear, onClearParams, rotateAngle) 
       isNew = true
       eff.isBollow = true
   else
       eff:__perform(id, x, y, parent, duration, onClear, onClearParams, rotateAngle)
   end

   -- TODO: 考虑parent被移除的情况, 自己随之被搞掉的问题

   -- release 需在addChild后调用, 不然引用计数为0, 会被立即从内存中移除
   if not isNew then eff:release() end

   -- 标记正处于出借状态
   eff.isBollowing = true

   -- 每次借出, 都给该对象赋予一个新的序列号, 以标记其已是不同对象
   eff.pSn = eff.pSn and eff.pSn + 1 or 1

   return eff 
end

function CompositeEffect.repay(eff)
   -- 如果没有出借, 则无需回收
    if not eff.isBollowing  then
        return 
    end

    eff.isBollowing = false

    if tolua.isnull(eff) then
       cclog("[ERROR]: try to a repay a released effectile")
       return 
    end

    -- retain 需在removeFromParent前调用, 否则有可能会导致eff被移除
    eff:retain()
    eff:reset()
    eff:removeFromParentAndCleanup(false)
    local pool = CompositeEffect.__getPoolByName(eff.id)
    pool[#pool + 1] = eff
	--print("CompositeEffect.repay", self.id)
	--releaseTab[#releaseTab + 1] = self.id
end
local function clearCompositePool()
	CompositeEffect.clearPool()
end

function CompositeEffect.clearPool()
    if not effPool then return end
    for _, pool in pairs(effPool) do 
        for _, eff in pairs(pool) do
            if not tolua.isnull(eff) then
				eff.particles = {}
                eff:removeAllChildrenWithCleanup(true)
                eff:release()
                if not tolua.isnull(eff) then
                    cclog("[WARNING]: possible memory leak:%d, %d, %d ", eff.id, eff:retainCount(), eff)
                end
            else
                cclog("[ERROR]: a CompositeEffect has released when clear Pool")
            end
        end
    end
    CompositeEffect.printPoolInfo()	
    effPool = {}
end

function CompositeEffect:fadeOutParticles()
    if not self.particles then return end
    for _, particleNode in pairs(self.particles) do
        if particleNode and not tolua.isnull(particleNode) then
            particleNode:setEmissionRate(0)
            particleNode:setDuration(0.2)
        end
    end
end

-- 朝某个位置发射
function CompositeEffect:shootTo(params)
	local owner, startX, startY, tx, ty, onComplete
	if params.owner then
		local pt = params.owner:getPosition()
		startX = pt.x
		startY = pt.y
	else
		startX = params.x
		startY = params.y
	end
	ty = params.ty
	tx = params.tx
	onComplete = params.onComplete
	local isAutoRemove = params.isAutoRemove or false
	
	local speed = self.config.speed or 800
	local isBallistic = self.config.isBallistic
	--local particles = self.config.particles
	local startHeight = self.config.startHeight or 0
	local shadowRes = self.config.shadowRes

	self:setPosition(ccp(startX, startY))

    if not realStartX then  realStartX = startX end
    if not realStartY then  realStartY = startY end

	local s = math_sqrt(math_pow(realStartX - tx, 2) + math_pow(realStartY - ty, 2))
	local t = s / speed
	
	-- vertical velocity=1/2*t*g, average vertical velocity=v/2, h=v_a*t
	local h = startHeight + 0.25 * GRAVITY * t * t

   
	
	-- local shadow = nil
	-- if shadowRes and string.len(shadowRes) > 0 then
		-- shadow = display.newSprite(SHADOW_FOLDER..shadowRes..".png")
		-- shadow:setPosition(ccp(proj:getPosition()))

		-- attachPropToProj(proj, "shadow", shadow)

		-- if proj:getParent() then
			-- proj:getParent():addChild(shadow)	
			-- local shadowAction = CCMoveTo:create(t,  ccp(tx, ty))
			-- shadow:runAction(shadowAction)
		-- end
	-- end

	-- if(isBallistic==1) then
		-- regBallistic(proj)
	-- end
	
	local callback = function()
		self:fadeOutParticles()
		
		if shadow and not tolua.isnull(shadow) then
			shadow:removeFromParent()
		end
		if(type(onComplete)=="function") then
			onComplete()
		end

		if isAutoRemove then
			_clearAll(self)
		end 
	end

	local projectileAction = CCJumpTo:create(t, ccp(tx,ty), h, 1)
	local seqAction = projectileAction
	if callback then
		local callbackAction = CCCallFunc:create(callback)
		seqAction = transition.sequence({projectileAction, callbackAction})
	end
	
	self:runAction(seqAction) 
end 

---------------- 离开场景时, 清理特效池 -------------------

--gEvent.regEvent(gEvent.SCENE_EXIT, CompositeEffect.clearPool)

-----------------------------------------------------------

function CompositeEffect.printPoolInfo()
    print("=========== CompositeEffect pool info ===============")
    if not effPool then
        print("pool num:", 0)
    else
        print("pool num:", table.nums(effPool))
        for n, p in pairs(effPool) do
            print(n, table.nums(p))
        end
    end    
    print("=====================================================")
end
-------------------------  特效池相关 END -------------------------------


------------------------------添加触摸区域-------------------------------

function CompositeEffect:setTouchSize(width, height)
	self.touch_size = {x = width, y = height}
	self.touch_radius = math_sqrt(width*width + height*height)/4   -- (触摸半径)对角长度一半
	local ang = math_abs(math_deg(math_atan(height/width)))
	self.rad_angle = {}
	self.rad_angle[1] = 180 + ang
	self.rad_angle[2] = 180 - ang
	self.rad_angle[3] = ang 
	self.rad_angle[4] = 360 - ang 
end 

function CompositeEffect:getTouchRect()  --获取触摸区域
	if not self.touch_radius then 
		return CCRectMake(0,0,0,0)
	end 

	local angle = self:getRotation()
	local scale = self:getScale()
	local r = self.touch_radius * scale
	local x, y = self:getPosition()
	
	local x1 = x + r*math_cos(math_rad(self.rad_angle[1]-angle))
	local x2 = x + r*math_cos(math_rad(self.rad_angle[2]-angle))
	local x3 = x + r*math_cos(math_rad(self.rad_angle[3]-angle))
	local x4 = x + r*math_cos(math_rad(self.rad_angle[4]-angle))
	
	local y1 = y + r*math_sin(math_rad(self.rad_angle[1]-angle))
	local y2 = y + r*math_sin(math_rad(self.rad_angle[2]-angle))
	local y3 = y + r*math_sin(math_rad(self.rad_angle[3]-angle))
	local y4 = y + r*math_sin(math_rad(self.rad_angle[4]-angle))
	
	local minX = math_min(math_min(x1, x2), math_min(x3, x4))
    local maxX = math_max(math_max(x1, x2), math_max(x3, x4))
    local minY = math_min(math_min(y1, y2), math_min(y3, y4))
    local maxY = math_max(math_max(y1, y2), math_max(y3, y4))
        
    return CCRectMake(minX, minY, (maxX - minX), (maxY - minY))
end 

return CompositeEffect
