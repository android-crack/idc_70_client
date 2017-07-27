
--Date
--此文件由[BabeLua]插件自动生成
require("resource_manager")

local exploreAnimation = require("gameobj/explore/exploreAnimation")

local ExploreItemModel = class("ExploreItemModel")

function ExploreItemModel:ctor(param)
	self.modelFile = param.modelFile
	self.ship = param.ship
    self.shipNode = param.ship.node
    self.targetNode = param.targetNode
    self.targetData = param.targetData
    self.targetCallBack = param.targetCallBack
	self.tipCallBack = param.tipCallBack
	self.clipAni_name = param.clipName
	self.animationFile = param.animationFile
	self.isSea = param.isSea
	self.speed = param.speed
	self.effectFile = param.effectFile
	self:loadModel()
	self:loadAnimation()
	self:loadEffect()
end

function ExploreItemModel:loadEffect()
	if self.effectFile then		
		if self.effect_control == nil then
			self.effect_control = require( "gameobj/effect/effect" ).new( self.ModelNode );
		end

		if self.effect_control ~= nil then
			self.effect_control:preload( EFFECT_3D_PATH .. self.effectFile );
		else
			assert( false, "error: effect controller was empty!!!!" );
		end
	end
end

function ExploreItemModel:loadModel()
	local modelNode = ResourceManager:LoadModel(MODEL_3D_PATH .. self.modelFile .. "/" ..self.modelFile .. ".gpb", self.modelFile)
	self.ModelNode = modelNode
	if self.isSea then
		local layer3dShip = Explore3D:getLayerSea3d()
		layer3dShip:addChild(self.ModelNode)
	else
		local layer3dShip = Explore3D:getLayerShip3d()
		layer3dShip:addChild(self.ModelNode)
	end
end

function ExploreItemModel:loadAnimation()
	if self.animationFile then
		local aniFile = MODEL_3D_PATH .. self.animationFile .. "/" .. self.animationFile .. ".animation"
		self.animation = exploreAnimation.new(self.ModelNode, aniFile, self.clipAni_name)
	end
end

function ExploreItemModel:hitTargetCB(modeObj)
	if modeObj == nil then
		return
	end
end

function ExploreItemModel:playAnimationByName(name)
	if self.animation then
		self.animation.ani_t[name]:play()
	end
end

function ExploreItemModel:playAnimationDurationByName(name)
	if self.animation then
		return self.animation.ani_t[name]:getDuration()
	end
end


function ExploreItemModel:createCDTimer(callBack)
	local scheduler = CCDirector:sharedDirector():getScheduler()
    self:removeTimeHander()
	self.hander_time = scheduler:scheduleScriptFunc(callBack, 0, false)
end

function ExploreItemModel:removeTimeHander()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil
	end
end

function ExploreItemModel:removeNode()
	if self.ModelNode:getParent() then 
		self.ModelNode:getParent():removeChild(self.ModelNode)
	end 
end

function ExploreItemModel:showEffects()
	self.effect_control:showAll()
end

function ExploreItemModel:hideEffects()
	self.effect_control:hideAll()
end

function ExploreItemModel:releaseEffect()
	if self.effect_control then
		self.effect_control:release()
		self.effect_control = nil
	end
end

function ExploreItemModel:release()
    self.shipNode = nil
	self.targetNode = nil
	self.effect_control = nil
	self.ModelNode = nil
end

return ExploreItemModel
