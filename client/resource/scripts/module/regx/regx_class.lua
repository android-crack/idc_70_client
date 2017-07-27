
local Regx_Class = {}

function Regx_Class:ctor()
    self.regx = Regx.create()
end

function Regx_Class:compile(pattern)
    if self.pattern == pattern then return end

    if type(pattern) ~= "string" then
        logger.error("Regx compile error. pattern must be string")
    end

    self.pattern = pattern
    self.re = self.regx:compile(pattern)
end

function Regx_Class:replace(str, replace_str)
    if not self.re then
        logger.error("regx hasn't compiled pattern")
        return nil
    end

    return self.regx:replace(self.re, str, replace_str)
end

function Regx_Class:match(str)
    --return true
    if not self.re then
        logger.error("regx hasn't compiled pattern")
        return nil
    end

    return self.regx:match(self.re, str)
end

function Regx_Class:dispose()
    if self.re then
        self.regx:free(self.re)
        self.re = nil
        self.pattern = nil
        self.regx = nil
    end
end

return class("Regx", Regx_Class)
