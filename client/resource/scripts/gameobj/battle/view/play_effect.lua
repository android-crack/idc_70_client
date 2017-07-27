local ClsPlayEffect = class("ClsPlayEffect", require("gameobj/battle/view/base"))

function ClsPlayEffect:ctor(id, effect_name, batch_exclude, duration, pos, speed )
	self.args = {}

    if not params then return end

    --[[
    self:InitArgs(params.id, params.effect_name, params.batch_exclude, params.duration, 
        params.pos, params.speed)
    --]]

    self:InitArgs(id, effect_name, batch_exclude, duration, pos, speed)
end

function ClsPlayEffect:InitArgs(id, effect_name, batch_exclude, duration, pos, speed)
    self.id = id
    self.effect_name = effect_name
    self.batch_exclude = batch_exclude or {}
    self.duration = duration
    self.pos = pos
    self.speed = speed

    self.args = {id, effect_name, batch_exclude, duration, pos, speed}
end

function ClsPlayEffect:GetId()
    return "play_effect"
end

-- 播放
function ClsPlayEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj and ship_obj.body and ship_obj.body.effect_control then
		ship_obj.body.effect_control:show(nil, self.effect_name, self.batch_exclude, self.duration, 
			self.pos and Vector3.new(self.pos.x, self.pos.y, self.pos.z), self.speed)
	end
end

function ClsPlayEffect:serialize(frame)
    return json.encode({frame,self.id,self.effect_name,self.batch_exclude,self.duration,self.pos,self.speed })  
end

function ClsPlayEffect:unserialize(str)
    local frame,id,effect_name,batch_exclude,duration,pos,speed = unpack(json.decode(str))
    self:InitArgs(id, effect_name, batch_exclude, duration, pos, speed)
    return self.args
end

return ClsPlayEffect
