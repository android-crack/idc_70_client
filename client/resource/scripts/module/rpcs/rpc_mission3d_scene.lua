--2017/02/17
--create by wmh0497
--用于3d的任务场景协议处理

--空场景下发
function rpc_client_null_scene(mission3d_id)
	local sceneDataHandler = getGameData():getSceneDataHandler()
	sceneDataHandler:cleanInfo()
	sceneDataHandler:setMissionScene(mission3d_id)
	if not sceneDataHandler:isSameScene(true) then
		startMission3dScene(mission3d_id)
	end
end