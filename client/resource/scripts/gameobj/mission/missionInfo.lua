
---4个角色，每个角色对应相应的任务表
function getMissionInfo()
	local playerData = getGameData():getPlayerData()
	local role_id = playerData:getRoleId()
	local obj = string.format("game_config/mission/mission_%s_info", role_id)
	return require(obj)
end