local music_info = require("game_config/music_info")
local CompositeEffect = require("gameobj/composite_effect")
local plotVoiceAudio = require("gameobj/plotVoiceAudio")

local ClsBaseView = require("ui/view/clsBaseView")
local BattleEffectLayer = class("BattleEffectLayer", ClsBaseView)

function BattleEffectLayer:getViewConfig()
    return {
        name = "battleEffectLayer",
        type = UI_TYPE.VIEW,
        is_swallow = false,
    }
end

function BattleEffectLayer:onEnter()
	self.clouds = {}
	self.visibleCloud = true
	self.armature_list = {}
end

-- 点击屏幕
function BattleEffectLayer.showClickCallBack(x, y)
	local battleData = getGameData():getBattleDataMt()
	CompositeEffect.bollow(CLICK_EFFECT, x, y, battleData:GetLayer("battle_scene"), 0.5)
end

function BattleEffectLayer:showStome(duration)  --暴风雨
	self:hideAllWeather()

	if self.stomeAcHandler~=nil then
		self:stopAction(self.stomeAcHandler)
		self.stomeAcHandler = nil
	end
	local stome_sound = music_info.EX_STORM.res  -- 音效
	local blink_sound = music_info.EX_THUNDER.res 
	
	self.stome_sound_hander = audioExt.playEffect(stome_sound, true)
	
	if self.stromLayer==nil or tolua.isnull(self.stromLayer) then 
		self.stromLayer = CCLayer:create()
		self.stromLayer:setTouchEnabled(false)
		self:addChild(self.stromLayer)
	else
		self.stromLayer:setVisible(true)
	end 
	self.stromLayer.layerColor = CCLayerColor:create(ccc4(0,0,0,120))
	self.stromLayer:addChild(self.stromLayer.layerColor)
	local emitter = CCParticleSystemQuad:create("explorer/rain.plist")
	self.stromLayer:addChild(emitter)	
	emitter:setBlendAdditive(true)
	emitter:setPosition(ccp(display.cx, display.height))
	-- 闪电效果
	local actions = {}
	actions[1] = CCDelayTime:create(2)
	actions[2] = CCCallFunc:create(function() 
		audioExt.playEffect(blink_sound, false)
	end)
	actions[3] = CCBlink:create(0.2, 1)
	actions[4] = CCDelayTime:create(1)
	actions[5] = CCCallFunc:create(function() 
		audioExt.playEffect(blink_sound, false)
	end)
	actions[6] = CCBlink:create(0.6, 3)
	actions[7] = CCDelayTime:create(2)
	actions[8] = CCCallFunc:create(function() 
		audioExt.playEffect(blink_sound, false)
	end)
	actions[9] = CCBlink:create(0.4, 2)
	local ac = transition.sequence(actions)	
	self.stromLayer.layerColor:runAction(ac)

	local delay_time = duration or 4
	local ac1 = CCDelayTime:create(delay_time)
	local ac2 = CCCallFunc:create(function() 
		self:hideStome()
		self:setAllCloudVisible(true)
	end)
	self.stomeAcHandler = CCSequence:createWithTwoActions(ac1, ac2)
	self:runAction(self.stomeAcHandler)
end

-- 战斗胜率鲸鱼跳跃
function BattleEffectLayer.showWhale(shipPos)
	local prop_info = require("game_config/battle/prop_info")
	local battleProp = require("gameobj/battle/battleProp")
	local SceneEffect = require("gameobj/battle/sceneEffect")

	local whale_id = 26
	if not prop_info[whale_id] then return end 
	
	local pos1 = ccp(shipPos.x - 60, shipPos.y - 30)
	pos1.rota = 1
	local whale1 = battleProp.new({prop_id = whale_id, attr = {}, pos = pos1}, 1)
	local duration = whale1.curAni:getDuration()/1000
	whale1.node:setActive(false)
	local particle1 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
	local pNode1 = particle1:GetNode()
	pNode1:setTranslation(whale1.node:getTranslationWorld())
	particle1:Stop()
	
	local pos2 = ccp(shipPos.x - 60, shipPos.y - 60)
	pos2.rota = 3
	local whale2 = battleProp.new({prop_id = whale_id, attr = {}, pos = pos2}, 1)
	local particle2 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
	local pNode2 = particle2:GetNode()
	pNode2:setTranslation(whale2.node:getTranslationWorld())
	particle2:Start()

	local pos3 = ccp(shipPos.x + 60, shipPos.y + 60)
	pos3.rota = 7
	local whale3 = battleProp.new({prop_id = whale_id, attr = {}, pos = pos3}, 1)
	local particle3 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
	local pNode3 = particle3:GetNode()
	pNode3:setTranslation(whale3.node:getTranslationWorld())
	particle3:Start()
	
	local node = display.newNode()
	local battleData = getGameData():getBattleDataMt()
	battleData:GetLayer("battle_scene"):addChild(node)

	local actions = {}
	local act1_tm = 1.0
	local act3_tm = 0.3
	local act5_tm = 1.0 
	local act7_tm = 0.3
	assert(act1_tm + act3_tm + act5_tm + act7_tm < battle_config.battle_end_rotate_cam_tm) 
	actions[1] = CCDelayTime:create(act1_tm)
	actions[2] = CCCallFunc:create(function() 
		local particle5 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
		if particle5 then
			local pNode5 = particle5:GetNode()
			local tran = whale2.node:getTranslationWorld()
			pNode5:setTranslation(tran:x() + 100, tran:y(), tran:z())
			particle5:Start()
		end
		
		local particle6 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
		if particle6 then
			local pNode6 = particle6:GetNode()
			local tran = whale3.node:getTranslationWorld()
			pNode6:setTranslation(tran:x() - 100, tran:y(), tran:z())
			particle6:Start()
		end
	end)
	actions[3] = CCDelayTime:create(act3_tm)
	actions[4] = CCCallFunc:create(function() 
		whale1.node:setActive(true)
		particle1:Start()
		whale2.node:setActive(false)
		whale3.node:setActive(false)
	end)
	
	actions[5] = CCDelayTime:create(act5_tm)
	actions[6] = CCCallFunc:create(function() 
		local particle4 = SceneEffect.createEffect({file = EFFECT_3D_PATH.."tx_shuihua.particlesystem"})
		if particle4 then
			local pNode4 = particle4:GetNode()
			local tran = whale1.node:getTranslationWorld()
			pNode4:setTranslation(tran:x(), tran:y(), tran:z()-50)
			particle4:Start()
		end
	end)
	actions[7] = CCDelayTime:create(act7_tm)
	actions[8] = CCCallFunc:create(function() 
		whale1.node:setActive(false)
		local parent = whale1.node:getParent()
		parent:removeChild(whale1)
		local parent = whale2.node:getParent()
		parent:removeChild(whale2)
		local parent = whale3.node:getParent()
		parent:removeChild(whale3)
	end)
	
	local action = transition.sequence(actions)
	node:runAction(action)
end 

function BattleEffectLayer:hideStome()
	--if tolua.isnull(self) then return end
	if self.stromLayer~=nil then
		if self.stromLayer.layerColor then 
			self.stromLayer.layerColor:stopAllActions()
		end
		self.stromLayer:removeFromParentAndCleanup(true)
		self.stromLayer = nil
	end

	if self.stome_sound_hander~=nil then
		audioExt.stopEffect(self.stome_sound_hander)
		self.stome_sound_hander = nil
	end
end


function BattleEffectLayer:showCloud(args)  --云朵
	self:hideAllWeather()

	self:setAllCloudVisible(true)

	local cloudNum = 0
	local cloudArgs = {}
	if #args==3 then
		cloudNum = 1
		cloudArgs[#cloudArgs+1] = {args[1],args[2],args[3]}
	elseif #args==6 then
		cloudNum = 2
		cloudArgs[#cloudArgs+1] = {args[1],args[2],args[3]}
		cloudArgs[#cloudArgs+1] = {args[4],args[5],args[6]}
	else

	end
	for i=1,cloudNum do
		self:mkCloud(cloudArgs[i])
	end
end

local CloudSp = class("CloudSp", function(res) return display.newSprite(res) end)

function CloudSp:ctor(res)
	self.moveTime = 1
	self.beginPos = ccp(0,0)
	self.endPos = ccp(0,0)
	self.isRuning = false
end

function CloudSp:begin()
	if self.isRuning==true then
		return
	end
	self.isRuning = true

	local array = CCArray:create()
	array:addObject(CCMoveTo:create(self.moveTime, self.endPosEx))
	array:addObject(CCFadeOut:create(0.5))
	--array:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(self.moveTime, self.endPos), CCFadeOut:create(self.moveTime*2)))
	array:addObject(CCCallFunc:create(function()
		self:removeFromParentAndCleanup(true)
		if self.finishCallBack~=nil then
			self.finishCallBack()
		end
		end))
	self:runAction(CCSequence:create(array))
end

function CloudSp:setFinishCallBack(func)
	self.finishCallBack = func
end

function BattleEffectLayer:mkCloud(args)
	if self.curCloundNum==nil then
		self.curCloundNum = 1
	else
		self.curCloundNum = self.curCloundNum + 1
	end
	if self.curCloundNum>2 then
		self.curCloundNum = 2
		return
	end 

	local cloudSp = CloudSp.new("explorer/explore_yun"..math.random(2)..".png")
	local cloudIndex = "cloud_"..self.curCloundNum
	local w,h = display.width,display.height
	local cloudYs = {}
	for k,v in pairs(self.clouds) do
		if v~=nil and not tolua.isnull(v) then
			local cloudY1 = {["y1"]=0,["y2"]=h}
			local cloudY2 = {["y1"]=0,["y2"]=h}
			cloudY1["y2"] = v.beginPos.y - v:getContentSize().height/2 - cloudSp:getContentSize().height/2
			cloudY2["y1"] = v.beginPos.y + v:getContentSize().height/2 + cloudSp:getContentSize().height/2
			if cloudY1["y2"]<0 then
				cloudY1["y2"] = 0
			end
			if cloudY2["y1"]>h then
				cloudY2["y1"] = h
			end
			if cloudY1["y1"]~=cloudY1["y2"] then
				cloudYs[#cloudYs+1] = cloudY1
			end
			if cloudY2["y1"]~=cloudY2["y2"] then
				cloudYs[#cloudYs+1] = cloudY2
			end
			break
		end
	end
	local spW,spH = cloudSp:getContentSize().width,cloudSp:getContentSize().height
	cloudSp.moveSpeed = 20 + math.random(30)
	cloudSp.moveTime = 10
	cloudSp.beginPos = ccp(0,0)
	cloudSp.endPos = ccp(0,0)
	if args[2]==nil then
		cloudSp.beginPos.x = w+spW/2+5

		if #cloudYs>0 then
			local cloudY = cloudYs[math.random(#cloudYs)]
			cloudSp.beginPos.y = cloudY["y1"] + math.random(math.abs(cloudY["y2"]-cloudY["y1"]))
		else
			cloudSp.beginPos.y = math.random(h)
		end
	else
		cloudSp.beginPos.x = args[2][1]
		cloudSp.beginPos.y = args[2][2]
	end
	if args[3]==nil then
		cloudSp.endPos.x = -spW/2-math.random(w)
		cloudSp.endPos.y = cloudSp.beginPos.y
	else
		cloudSp.endPos.x = args[3][1]
		cloudSp.endPos.y = args[3][2]
	end
	if args[1]==nil then
		cloudSp.moveTime = math.sqrt(math.pow(cloudSp.endPos.x-cloudSp.beginPos.x,2)+math.pow(cloudSp.endPos.y-cloudSp.beginPos.y,2))/cloudSp.moveSpeed
	else
		cloudSp.moveTime = args[1]
	end
	cloudSp:setFinishCallBack(function()
		self.curCloundNum = self.curCloundNum - 1
		if self.curCloundNum<0 then
			self.curCloundNum = 0
		end
		end)
	if self.cloudLayer~=nil and not tolua.isnull(self.cloudLayer) then
		cloudSp.beginPosEx = self.cloudLayer:convertToNodeSpace(cloudSp.beginPos)
		cloudSp.endPosEx = self.cloudLayer:convertToNodeSpace(cloudSp.endPos)
		cloudSp:setPosition(ccp(cloudSp.beginPosEx.x,cloudSp.beginPosEx.y))
		cloudSp:setVisible(self.visibleCloud)
		self.cloudLayer:addChild(cloudSp)
		cloudSp:begin()
		self.clouds[cloudIndex] = cloudSp
	end
end

function BattleEffectLayer:setAllCloudVisible(visible)
	self.visibleCloud = visible
	if self.clouds==nil then
		return
	end
	for k,v in pairs(self.clouds) do
		if v~=nil and not tolua.isnull(v) then
			v:setVisible(visible)
		end
	end
end

function BattleEffectLayer:hideAllWeather()
	self:setAllCloudVisible(false)

	if self.stomeAcHandler~=nil then
		self:stopAction(self.stomeAcHandler)
		self.stomeAcHandler = nil
	end

	self:hideStome()
	if self.forgeAcHandler~=nil then
		self:stopAction(self.forgeAcHandler)
		self.forgeAcHandler = nil
	end
end

function BattleEffectLayer:setCloudLayer(layer)
	self.cloudLayer = layer
end

function BattleEffectLayer:showArmatureSceneEffect(effect_id, duration)
	local key = effect_id

    local armatureTab = {}
    armatureTab[1] = "effects/"..key..".ExportJson"
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(armatureTab[1])
    local bg_sprite = CCArmature:create(key)
    bg_sprite:getAnimation():playByIndex(0)
    bg_sprite:setPosition(display.cx, display.cy)
    bg_sprite:setCascadeOpacityEnabled(true)
	self:addChild(bg_sprite, 2)
	self.armature_list[effect_id] = bg_sprite
	local array = CCArray:create()
	local time = duration -0.5
	if time < 0 then
		time = 0.1
	end
	array:addObject(CCDelayTime:create(tonumber(time)))
	array:addObject(CCCallFunc:create(function ()
		self:removeArmatureSceneEffect(effect_id)
	end))
	self:runAction(CCSequence:create(array))
end

function BattleEffectLayer:removeArmatureSceneEffect(effect_id)
	if not tolua.isnull(self.armature_list[effect_id]) then
		local array = CCArray:create()
		local time = 10
		for i=1,time do
			array:addObject(CCDelayTime:create(0.5/time))
			array:addObject(CCCallFunc:create(function( )
				local opacity = 255 *(time - i)/time
				if not tolua.isnull(self.armature_list[effect_id]) then
					self.armature_list[effect_id]:setOpacity(opacity) 
				end
				
			end))
		
		end
		array:addObject(CCCallFunc:create(function ()
			if not tolua.isnull(self.armature_list[effect_id]) then
				self.armature_list[effect_id]:removeFromParentAndCleanup(true)
			end
			
		end))
		self:runAction(CCSequence:create(array))
	end
end

function BattleEffectLayer:showCocosSceneEffect(effect_id, duration, callBack)
	local effect = CompositeEffect.new(effect_id, display.cx, display.top, self, 2)
	self.armature_list[effect_id] = effect
	if duration and duration > 0 then 
		local array = CCArray:create()
		local time = duration -0.5
		if time < 0 then
			time = 0.1
		end
		local delay = CCDelayTime:create(time)
		local callfunc = CCCallFunc:create(function()
			if callback then callback() end 
			self:removeArmatureSceneEffect(effect_id)
		end)
		array:addObject(delay)
		array:addObject(callfunc)
		self:runAction(CCSequence:create(array))
	else 	
		if callback then callback() end 
	end 
end


return BattleEffectLayer