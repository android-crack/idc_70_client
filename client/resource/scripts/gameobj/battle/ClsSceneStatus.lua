local ClsSceneStatus = class("ClsSceneStatus")

function ClsSceneStatus:ctor()
	self:init()
end

function ClsSceneStatus:clear()
	self:init()
end

function ClsSceneStatus:init()
	if type(self.buffs) == "table" then
		for k, buff in pairs() do
			buff:del()
		end
	end
	self.buffs = {}
end

function ClsSceneStatus:addBuff(buff)
	if not buff then return end

	self.buffs[buff:get_status_id()] = buff

	-- getGameData():getBattleDataMt():uploadAddStatus(buff)
end

function ClsSceneStatus:delBuff(status_id)
	self.buffs[status_id] = nil
end

------------------------------------------------------------------------------------------------------------------------

function ClsSceneStatus:hasBuff(buff)
	return nil
end

function ClsSceneStatus:getId()
	return 0
end

------------------------------------------------------------------------------------------------------------------------