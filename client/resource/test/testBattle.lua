
require("gameobj/mainInit3d")
local gameRpc = require("module/gameRpc")
package.loaded["3d_testData"] = nil
package.loaded["bullet"] = nil

local battleData_test = require("3d_testData")
local battleMain = require("gameobj/battle/battleScene")
battleMain.startBattle(battleData_test)