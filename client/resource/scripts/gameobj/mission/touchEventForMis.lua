local ui_word = require("game_config/ui_word")
--函数调用参数的意义和服务端协商

-- local info = {
--     [content] = {
--         [1] = '$(c:COLOR_GREEN)$(miscall:["SKIP_VIEW","shipyard", "tab_store"]|【造船厂】)',
--         [2] = '$(c:COLOR_GREEN)$(miscall:["SKIP_VIEW","shipyard"]|【造船厂】)',
--     }
-- }

local function skipView(...)
    local para_1 = arg[1]
    local para_2 = arg[2]
end

local touchEvent = {
	["SKIP_VIEW"] = skipView,--跳转界面
}

return { touchEvent = touchEvent}
