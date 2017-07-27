local battle_info = require("game_config/battle/battle_info")
local battle_jy_info = require("game_config/battle/battle_jy_info")

local ClsBattleInfoConfigDataHandle = class("BattleInfoConfigDataHandle")

function ClsBattleInfoConfigDataHandle:ctor()
	self.GENERAL_CONFIG = "battle_general"
	self.ELITE_CONFIG = "battle_elite"
	self.LastConfigFileFlag = self.GENERAL_CONFIG
	self.CurConfigFileFlag = self.GENERAL_CONFIG
end

-- 设置精英战或普通战
function ClsBattleInfoConfigDataHandle:setConfigFileFlag(ConfigFileFlag)
    self.LastConfigFileFlag = self.CurConfigFileFlag
    self.CurConfigFileFlag = ConfigFileFlag
end

-- 获取当前战役类型
function ClsBattleInfoConfigDataHandle:getConfigFileFlag()
    return self.CurConfigFileFlag
end

function ClsBattleInfoConfigDataHandle:getBattleConfigFileInfo(battle_type_flag) 
    local battle_type_flag = battle_type_flag or self.CurConfigFileFlag

    if battle_type_flag == "battle_general" then
        return battle_info
    else
        return battle_jy_info
    end
end 

function ClsBattleInfoConfigDataHandle:isGeneralConfig()
	return self.CurConfigFileFlag == self.GENERAL_CONFIG
end

function ClsBattleInfoConfigDataHandle:isEliteConfig()
	return self.CurConfigFileFlag == self.ELITE_CONFIG
end

return ClsBattleInfoConfigDataHandle