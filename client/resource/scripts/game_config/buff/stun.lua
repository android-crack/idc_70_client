----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_stun = class("cls_stun", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_stun.get_status_id = function(self)
	return "stun";
end


-- 状态名 
cls_stun.get_status_name = function(self)
	return T("眩晕");
end

-- 增减益 
cls_stun.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_stun.get_status_effect = function(self)
	return {"tx_0161", };
end

-- 特效类型 
cls_stun.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态提示 
cls_stun.get_status_prompt = function(self)
	return T("眩晕");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"clear_debuff", "wudi", "unstun", "mianyikongzhi", }

cls_stun.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------
cls_stun.deal_result = function(self, tbResult)
	cls_stun.super.deal_result(self, tbResult)

	if not self.target or self.target:is_deaded() then return end
	if not self.target.body then return end
	self.target.body:setBanTurn(true)
	self.target.body:setBanRotate(true)
	
	-- local action_name = "tx_xuanyun"
	-- local action_data = require(string.format("game_config/u3d_data/action/%s", action_name))
	-- require("module/u3dAnimationParse"):loadAnimation(self.target.body, action_data, false)
end

cls_stun.un_deal_result = function(self, tbResult)
	cls_stun.super.un_deal_result(self, self.tbResult)

	if not self.target or self.target:is_deaded() then return end
	if not self.target.body then return end
	self.target.body:setBanTurn(false)
	self.target.body:setBanRotate(false)
	
	-- if self.target.body.u3d_animations then 
	-- 	for k, animation in pairs(self.target.body.u3d_animations) do
	-- 		local clip = animation:getClip()
	-- 		clip:stop()
	-- 	end 
	-- end 
end