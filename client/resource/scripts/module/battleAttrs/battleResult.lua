-- 战斗结果界面
local function showBattleResult(rewards, star_rewards, is_get)
	
	-- 结算单独一个场景
	local function mkScene()
		local runScene = GameUtil.getRunningScene()
		return runScene
	end
	
	GameUtil.runScene(mkScene, SCENE_TYPE_BATTLE_ACCOUNT)	
	getUIManager():create("gameobj/battle/clsBattleAccounts", ewards, {}, nil, nil, is_get, star_rewards)--创建
end

local battle_result = {
	showBattleResult = showBattleResult,
}
return battle_result
