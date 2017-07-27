
require("gameobj/mainInit3d")
--local gameRpc = require("module/gameRpc")
    LoadPlist({
        ["ui/common_ui.plist"] = 1,
    })
package.loaded["test/3d_testBoat"] = nil
package.loaded["bullet"] = nil
local boat_info = require("game_config/boat/boat_info")

--把对应的资源以文件夹形式放在res/ship_3d里面，然后修改这里的船舶id
boat_info[1].res_3d_id = 5

local battleData_test = require("test/3d_testData")
local battleMain = require("gameobj/battle/battleScene")
battleMain.startBattle(battleData_test,    require("gameobj/login/LoginScene").startLoginScene)