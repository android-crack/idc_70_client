require("module/dataManager")
require("module/gameRpc")

local ClsTestEnterBattle = class("ClsTestEnterBattle")

function ClsTestEnterBattle:ctor(fighter, battleId, end_call_back)
	LoadPlist({
        ["ui/common_ui.plist"] = 1,
    })

	local fighter_mine = fighter or
	{
		["name"] = "艾萨克凯普伦",
		["partners"] = {
		    [1] = {
		        ["anti_crits"] = 30.000000,
		        ["boat_id"] = 1.000000,
		        ["boat_key"] = 1.000000,
		        ["boat_lv"] = 1.000000,
		        ["boat_name"] = "轻木帆船",
		        ["new_ai_id"] = {},
		        ["crits"] = 30.000000,
		        ["damage_increase"] = 30.000000,
		        ["damage_reduction"] = 30.000000,
		        ["defense"] = 275.000000,
		        ["dodge"] = 30.000000,
		        ["durable"] = 99999849.000000,
		        ["hit"] = 30.000000,
		        ["hp"] = 99999849.000000,
		        ["melee"] = 253.000000,
		        ["pos"] = 3.000000,
		        ["range"] = 3300.000000,
		        ["remote"] = 282.000000,
		        ["rota"] = 3.000000,
		        ["sailor_id"] = -1.000000,
		        ["skills"] = {
		        	{["id"] = 3501, ["level"] = 1, ["ord"] = 1, ["sailor"] = 1},
		        },
		        ["speed"] = 90.000000,
		        ["x"] = 918.000000,
		        ["y"] = 640.000000,
		        },

		    },
		["power"] = 1459.000000,
		["role"] = 1.000000,
		["uid"] = 10349.000000,
	}
	
	local fighter_enemy = 
	{
		["name"] = "利奥波特艾林",
		["partners"] = {
		    [1] = {
		        ["anti_crits"] = 29.000000,
		        ["boat_id"] = 1.000000,
		        ["boat_key"] = 11.000000,
		        ["boat_lv"] = 1.000000,
		        ["boat_name"] = "轻木帆船",
		        ["crits"] = 29.000000,
		        ["damage_increase"] = 29.000000,
		        ["damage_reduction"] = 29.000000,
		        ["defense"] = 300.000000,
		        ["dodge"] = 29.000000,
		        ["durable"] = 1226000.000000,
		        ["hit"] = 29.000000,
		        ["hp"] = 1226000.000000,
		        ["melee"] = 265.000000,
		        ["pos"] = 3.000000,
		        ["range"] = 3290.000000,
		        ["remote"] = 3130.000000,
		        ["rota"] = 7.000000,
		        ["sailor_id"] = -1.000000,
		        ["skills"] = {
		            },
		        ["speed"] = 89.000000,
		        ["x"] = 1642.000000,
		        ["y"] = 640.000000,
		        },
		    [2] = {
		        ["anti_crits"] = 29.000000,
		        ["boat_id"] = 1.000000,
		        ["boat_key"] = 22.000000,
		        ["boat_lv"] = 1.000000,
		        ["boat_name"] = "轻木帆船",
		        ["crits"] = 29.000000,
		        ["damage_increase"] = 29.000000,
		        ["damage_reduction"] = 29.000000,
		        ["defense"] = 300.000000,
		        ["dodge"] = 29.000000,
		        ["durable"] = 1226000.000000,
		        ["hit"] = 29.000000,
		        ["hp"] = 1226000.000000,
		        ["melee"] = 265.000000,
		        ["pos"] = 3.000000,
		        ["range"] = 329.000000,
		        ["remote"] = 313.000000,
		        ["rota"] = 7.000000,
		        ["sailor_id"] = 2.000000,
		        ["skills"] = {
		            },
		        ["speed"] = 89.000000,
		        ["x"] = 1642.000000,
		        ["y"] = 540.000000,
		        },
		    },
		["power"] = 10000.000000,
		["role"] = 1.000000,
		["uid"] = 10333.000000,
	}

	getGameData():getPlayerData().uid = 10349

	local params = {}
	-- 战役id
	params.battleId = battleId or 41
	-- 场景id
	params.layer_id = 1
	-- 战斗数据文件名
	params.ships_file_name = string.format("ship_%s_info", params.battleId)
	-- 战斗旧AI文件名
	params.ai_file_name = string.format("ai_%s_info", params.battleId)
	-- 战斗旧剧情文件名
	params.plot_file_name = string.format("plot_%s_info", params.battleId)
	-- 我方战斗数据
	params.fighter_mine = fighter_mine
	-- 敌方战斗数据
	local not_use_fighter_enemy = true  -- true为使用本文件中敌方战斗数据，false为不使用
	params.fighter_enemy = nil
	if not_use_fighter_enemy then
		params.fighter_enemy = fighter_enemy
	end
	-- 战斗回调
	local call_back = function()
		getGameData():getWorldMapAttrsData():tryToEnterDefaultPort()
	end
	if type(end_call_back) == "function" then
		params.call_back = end_call_back
	else
		if not fighter then
			params.call_back = require("gameobj/login/LoginScene").startLoginScene
		else
			params.call_back = call_back
		end
	end

	-- local is_demo = true  --是否进入演示战斗
	if is_demo then
		params.layer_id = 3
		require("gameobj/battle/ClsEnterBattle"):auto_play_battle(14, params.call_back)
	else
		-- 进入战斗
		require("gameobj/battle/ClsEnterBattle"):f7_test_battle(params)
	end
	-- 避免重启游戏
	package.loaded["test/enterBattle"] = nil
	package.loaded["game_config/battles/" .. params.ships_file_name] = nil
	package.loaded["game_config/battles/" .. params.ai_file_name] = nil
	package.loaded["game_config/battles/" .. params.plot_file_name] = nil
end

return ClsTestEnterBattle