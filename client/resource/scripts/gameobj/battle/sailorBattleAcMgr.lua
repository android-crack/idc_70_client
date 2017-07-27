local sailorBattleAcMgr = {}
local actMgr = CCDirector:sharedDirector():getActionManager()

function sailorBattleAcMgr:runAction(target,actionHandler)
	if target~=nil and not tolua.isnull(target) then
		target:runAction(actionHandler)
		if target.isPause then
			actMgr:pauseTarget(target)
		end
	end
end

function sailorBattleAcMgr:pauseTarget(target)
	if target~=nil and not tolua.isnull(target) then
		actMgr:pauseTarget(target)
		target.isPause = true
	end
end

function sailorBattleAcMgr:resumeTarget(target)
	if target~=nil and not tolua.isnull(target) then
		actMgr:resumeTarget(target)
		target.isPause = false
	end
end

return sailorBattleAcMgr