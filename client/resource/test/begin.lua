-- require("test/convert").convert("scripts", false) --路径 是否递归遍历文件夹
-- package.loaded["test/convert"] = nil
-- do return end

--进入某场战役，不用时直接注释掉
if not getGameData():getStartAndLoginData():getLoginFinish() then
	getGameData():getPlayerData():setName("Test")
	getGameData():getPlayerData().roleId = 1
	require("test/enterBattle").new()
else
	-- GameUtil.callRpc("rpc_server_fight_start", {-1}, "rpc_client_fight_start")
	-- GameUtil.callRpc("rpc_server_fight_pve", {1201002, 107, ""})
	GameUtil.callRpc("rpc_server_fight_pve", {1000082, 104, ""})
end