require("resource_manager")

local ParticleControl ={} class("ParticleControl")

function ParticleControl:ctor()
     
     self._particleSystem = nil
     self._particleSystemNode = nil
     self.isBeginMoveNode = false
end


function ParticleControl:drawControl()
    if self._particleSystem == nil then 
        return 
    end
    self._particleSystem:Draw()

end
function ParticleControl:updateControl(elapsedTime)
    
    if self._particleSystem == nil then 
        return 
    end
    if self._moveTargetNode ~= nil then 
        self:MoveNode(elapsedTime)
    end 
    
    self._particleSystem:Update(elapsedTime)
    
    
end

function ParticleControl:Follow(followNode, filename, sceen, ParContainer)
	local ParticleSystem = require("particle_system")
    local parSystem = ParticleSystem.new(filename)
    sceen:addNode( parSystem:GetNode())
    parSystem:Start()
    self:setTarget(parSystem)
    ParContainer:Add(self)

    followNode:addChild(self._particleSystemNode)
end 

function ParticleControl:MoveNode(elapsedTime)
 
    if not self.isBeginMoveNode then 
        return 
    end 
    local myTranslation = self._particleSystemNode:getTranslation()
    local targetTranslation = self._moveTargetNode:getTranslation()
    local moveDirection = Vector3.new()
    Vector3.subtract(targetTranslation, myTranslation, moveDirection)
    if moveDirection:length() >= 0.1 then 
        elapsedTime = elapsedTime / 1000
        moveDirection:normalize()
        moveDirection:scale(self._moveNodeSpeed * elapsedTime)
        myTranslation:add(moveDirection)
        self._particleSystemNode:setTranslation(myTranslation)
    else
        self.isBeginMoveNode = false
        print(tostring(self.isBeginMoveNode))
    end
end 


function ParticleControl:beginMoveNode(originNode, targetNode, speed, filename, sceen, ParContainer)
	local ParticleSystem = require("particle_system")
    local parSystem = ParticleSystem.new(filename)
    sceen:addNode( parSystem:GetNode())
    parSystem:Start()
    self:setTarget(parSystem)
    ParContainer:Add(self)

    self._moveNodeSpeed = speed
    self._particleSystemNode:setTranslation(originNode:getTranslation())
    self._moveTargetNode = targetNode
    self.isBeginMoveNode = true
end


function ParticleControl:setTarget(particlesystem)
    self._particleSystem = particlesystem
    self._particleSystemNode = particlesystem:GetNode()

end

function BeginMoveNode(originNode, targetNode, speed, filename, sceen, ParContainer)
    local parControl = ParticleControl.new()
    parControl:beginMoveNode(originNode, targetNode, speed, filename, sceen, ParContainer)
end 

function Follow(followNode, filename, sceen, ParContainer)
    local parControl = ParticleControl.new()
    parControl:Follow( followNode, filename, sceen, ParContainer)
end 
return st
