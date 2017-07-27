--2016/10/24
--create by clr0462
--用于海水的

local ClsSea3d = require("gameobj/sea3d")
local ClsU3dNodeBase = require("gameobj/u3d/clsU3dNodeBase")
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local DEFAULT_CONF = "res/sea_3d/loginSea.conf"

local other_materials = {
	["juqing01"] = "res/sea_3d/juqing1_sea.conf",
	["juqing02"] = "res/sea_3d/juqing2_sea.conf",
	["juqing03"] = "res/sea_3d/juqing3_sea.conf",
}

local ClsU3dSea = class("ClsU3dSea", ClsU3dNodeBase)

function ClsU3dSea:init()
    self.m_type = TYPE_SEA
    self.m_body = nil
    self:initSea()
	-- self:initModelAnim()
end

function ClsU3dSea:initSea()
    local transform = self.m_cfg.transform
    -- if transform then 
    --     self:setScale(unpack(transform.scale))
    --     self:setRotation(unpack(transform.rotation))
    --     self:setTranslation(unpack(transform.position))
    -- end
	local res_str = nil
	if self.m_cfg.materials and self.m_cfg.materials[1] then
		res_str = other_materials[self.m_cfg.materials[1]]
	end
	res_str = res_str or DEFAULT_CONF
    local sea = ClsSea3d.new(res_str, Vector3.new(unpack(transform.position)))
    self.m_node = sea.node
    self.m_parent_node:addChild(self.m_node)
    --self.m_node:getSea():setUnlimit(true)

    self:initModelAnim()
end

return ClsU3dSea