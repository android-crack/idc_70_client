local ClsStateClientReady = class("ClsStateClientReady", require("gameobj/battle/view/base"))

function ClsStateClientReady:ctor()
end

function ClsStateClientReady:InitArgs()
end

function ClsStateClientReady:GetId()
    return "state_client_ready"
end

return ClsStateClientReady
