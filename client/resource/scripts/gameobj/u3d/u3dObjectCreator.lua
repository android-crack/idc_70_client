--2016/09/05
--create by wmh0497
--用于模型的创建的接口之类
local ClsU3dModel = require("gameobj/u3d/clsU3dModel")
local ClsU3dCamera = require("gameobj/u3d/clsU3dCamera")
local ClsU3dSprite = require("gameobj/u3d/clsU3dSprite")
local ClsU3dParticle = require("gameobj/u3d/clsU3dParticle")
local ClsU3dFollowParticle = require("gameobj/u3d/clsU3dFollowParticle")
local ClsU3dSea = require("gameobj/u3d/clsU3dSea")

-- u3d scene 解析
local function createModel(scene_parser, parent, name, cfg, params)
    return ClsU3dModel.new(parent, name, cfg, params)
end 

-- 创建摄像机
local function createCamera(scene_parser, parent, name, camera_cfg, params)
    if camera_cfg == nil then return end 
	params.scene = scene_parser:getScene()
    return ClsU3dCamera.new(parent, name, camera_cfg, params)
end

local function createSprite(scene_parser, parent, name, cfg, params)
    return ClsU3dSprite.new(parent, name, cfg, params)
end

local function createParticleSystem(scene_parser, parent, name, cfg, params)
	if params.follow_node then
		return ClsU3dFollowParticle.new(parent, name, cfg, params)
	end
	return ClsU3dParticle.new(parent, name, cfg, params)
end

local function createSea(scene_parser, parent, name, cfg, params)
    return ClsU3dSea.new(parent, name, cfg, params)
end 

return {
    ["model"] = createModel,
    ["camara"] = createCamera,
    ["sprite"] = createSprite,
    ["particleSystem"] = createParticleSystem,
    ["sea"] = createSea,
}