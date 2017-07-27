local ClsBattleAlert = class("ClsBattleAlert", require("gameobj/battle/view/base"))

function ClsBattleAlert:ctor(uid, msg, r, g, b)
    self:InitArgs(uid, msg, r, g, b)
end

function ClsBattleAlert:InitArgs(uid, msg, r, g, b)
    self.msg = msg
    self.r = r or 255
    self.g = g or 255
    self.b = b or 255

    self.args = {uid, msg, r, g, b}
end

function ClsBattleAlert:GetId()
    return "battle_alert"
end

-- 播放
function ClsBattleAlert:gotProtcol()
    local Alert  = require("ui/tools/alert")
    Alert:battleWarning({msg = self.msg, color = ccc3(self.r, self.g, self.b)})
end

return ClsBattleAlert
