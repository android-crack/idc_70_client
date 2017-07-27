local ClsBattleUseSkillResult = class("ClsBattleUseSkillResult", require("gameobj/battle/view/base"))

function ClsBattleUseSkillResult:ctor(id, skill_id, is_success, remain_cd, common_cd)
    self:InitArgs(id, skill_id, is_success, remain_cd, common_cd)
end

function ClsBattleUseSkillResult:InitArgs(id, skill_id, is_success, remain_cd, common_cd)
    self.id = id 
    self.skill_id = skill_id
    self.is_success = is_success
    self.remain_cd = remain_cd
    self.common_cd = common_cd

    self.args = {id, skill_id, is_success, remain_cd, common_cd}
end

function ClsBattleUseSkillResult:GetId()
    return "battle_use_skill_result"
end

-- 收到协议
function ClsBattleUseSkillResult:gotProtcol()
    local battle_data = getGameData():getBattleDataMt()
    local ship = battle_data:getShipByGenID(self.id)

    -- local skill_effect_util = require("module/battleAttrs/skill_effect_util")
    -- if ship then
    --     skill_effect_util.del_effect_funcs["particle_local"]({owner = ship, id = "jn_xuli"})
    -- end

    local battle_ui = battle_data:GetLayer("battle_ui")
    if tolua.isnull(battle_ui) then return end

    if not self.is_success then return end

    local skill_ex_id = require("game_config/skill/skill_info")[self.skill_id].skill_ex_id
    
    if ship and not ship:is_deaded() then
        ship:set_skill_cd(skill_ex_id, self.remain_cd)

        if battle_data:isCurClientControlShip(self.id) then
            if self.common_cd > 0 then
                ship:set_common_skill_cd(self.common_cd)
                return
            end

            battle_ui:updateSkillUI(skill_ex_id)
        end
    end
end

function ClsBattleUseSkillResult:serialize(frame)
    return json.encode({frame, self.id, self.skill_id, self.is_success, self.remain_cd, self.common_cd})  
end

function ClsBattleUseSkillResult:unserialize(str)
    local frame,id, skill_id, is_success, remain_cd, common_cd = unpack(json.decode(str))
    self:InitArgs(id, skill_id, is_success, remain_cd, common_cd)
    return self.args
end

return ClsBattleUseSkillResult
