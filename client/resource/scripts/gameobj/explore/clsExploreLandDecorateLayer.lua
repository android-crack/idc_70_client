--2017/02/02
--create by wmh0497
--用于显示在地图上的粒子装饰

local ClsCompositeEffect = require("gameobj/composite_effect")
local land_decorate_cfg = require("game_config/explore/land_decorate_cfg")

local ClsExploreLandDecorateLayer = class("ClsExploreLandDecorateLayer", function() return display.newSprite() end)

function ClsExploreLandDecorateLayer:ctor(land, explore_layer)
	self.m_title_width = land:getTitleWidth()
	self.m_explore_layer = explore_layer
	self.m_avtive_particles = {}
	self.m_useless_particles = {}
	
	self:registerScriptHandler(function(event)
		if event == "exit" then
			self.m_explore_layer = nil
		end
	end)
end

function ClsExploreLandDecorateLayer:getKey(tx, ty)
	return self.m_title_width * ty + tx
end

local TITLE_X_OFFSET = 8
local TITLE_Y_OFFSET = 6
local math_abs = math.abs
--地图更新回调
function ClsExploreLandDecorateLayer:updateBolck(tx, ty)
	
	local remove_keys = {}
	for key, particle_info in pairs(self.m_avtive_particles) do
		if (math_abs(particle_info.tx - tx) > TITLE_X_OFFSET) or (math_abs(particle_info.ty - ty) > TITLE_Y_OFFSET) then
			remove_keys[#remove_keys + 1] = key --不要在删除的时候做移除，防止意外
		end
	end
	
	for _, key in ipairs(remove_keys) do
		self:removeUesslessParticle(key)
	end
	
	for i_tx = tx - TITLE_X_OFFSET, tx + TITLE_X_OFFSET do
		local config_tx = land_decorate_cfg[i_tx]
		if config_tx then
			for i_ty = ty - TITLE_Y_OFFSET, ty + TITLE_Y_OFFSET do
				local target_res = config_tx[i_ty]
				if target_res then
					local key = self:getKey(i_tx, i_ty)
					if not self.m_avtive_particles[key] then
						self:createParticle(key, target_res, i_tx, i_ty)
					end
				end
			end
		end
	end
	
end

function ClsExploreLandDecorateLayer:removeUesslessParticle(key)
	local particle_info = self.m_avtive_particles[key]
	if particle_info then
		self.m_avtive_particles[key] = nil
		if not self.m_useless_particles[particle_info.res] then
			self.m_useless_particles[particle_info.res] = {}
		end
		local res_list = self.m_useless_particles[particle_info.res]
		res_list[#res_list + 1] = particle_info.node
		particle_info.node:setVisible(false)
	end
end

function ClsExploreLandDecorateLayer:createParticle(key, res_str, tx, ty)
	local particle_node = self:getPartileNodeFromPool(res_str)
	if not particle_node then
		particle_node = ClsCompositeEffect.new(res_str, 0, 0, self)
	end
	local x, y = self.m_explore_layer:getShipsLayer():tileToCocos(tx, ty)
	particle_node:setPosition(ccp(x, y))
	particle_node:setVisible(true)
	self.m_avtive_particles[key] = {
			tx = tx,
			ty = ty,
			node = particle_node,
			res = res_str,
		}
end

function ClsExploreLandDecorateLayer:getPartileNodeFromPool(res_str)
	local particle_list = self.m_useless_particles[res_str]
	if particle_list and #particle_list > 0 then
		local index = #particle_list
		local particle_node = particle_list[index]
		table.remove(particle_list, index)
		return particle_node
	end
end

return ClsExploreLandDecorateLayer
