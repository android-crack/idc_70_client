--
-- Author: lzg0496
-- Date: 2016-12-26 11:06:52
-- Function: 

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsMissionPirateQuene = class("ClsMissionPirateQuene", ClsQueneBase)

function ClsMissionPirateQuene:ctor(data)
    self.data = data
end

function ClsMissionPirateQuene:getQueneType()
    return self:getDialogType().mission_pirate_plot
end

function ClsMissionPirateQuene:excTask()
    if type(self.data.plot_func) == "function" then
        self.data.plot_func()
    end
end

return ClsMissionPirateQuene
