
local ClsElementMgr = require("base/element_mgr")
local item_info = require("game_config/propItem/item_info")
local ClsGuildBuffData = class("GuildBuffData")

local BUFF_STATUS = {
	["NEAR_ATK"] = 1,--利刃
	["FAR_ATK"] = 2, --强攻
	["ADD_HP"] = 3, --强体
	["ADD_DEF"] = 4,--坚韧
}

local BUFF_ITEMS_ID = {
	["NEAR_ATK"] = 70,--利刃
	["FAR_ATK"] = 71, --强攻
	["ADD_HP"] = 73, --强体
	["ADD_DEF"] = 72,--坚韧
}

function ClsGuildBuffData:ctor()
	self.m_guild_buff_info = {}
end

function ClsGuildBuffData:askUseItem(item_id)
    GameUtil.callRpc("rpc_server_group_checkpoint_use_item", {item_id, 1})
end

function ClsGuildBuffData:getAllBuffInfo()
	if not self.m_guild_buff_info then
		self.m_guild_buff_info = {}
	end
	return self.m_guild_buff_info
end

function ClsGuildBuffData:setGuildBuffData(buff_list)
    self.m_guild_buff_info = {}
    for k, v in pairs(buff_list) do
        for k2, v2 in pairs(BUFF_ITEMS_ID) do
            if v2 == v.itemId then
                self.m_guild_buff_info[BUFF_STATUS[k2]] = v
            end
        end
    end
    local guild_scene_ui_obj =  ClsElementMgr:get_element("ClsGuildSceneUI")
    if not tolua.isnull(guild_scene_ui_obj) then
        guild_scene_ui_obj:updateBuffUi()
    end
end

function ClsGuildBuffData:getBuffInfoByType(type_n)
	return self:getAllBuffInfo()[type_n]
end

--利刃
function ClsGuildBuffData:getNearAtkBuffInfo()
	local info = self:getBuffInfoByType(BUFF_STATUS.NEAR_ATK)
	return info
end

--强攻
function ClsGuildBuffData:getFarAtkBuffInfo()
	local info = self:getBuffInfoByType(BUFF_STATUS.FAR_ATK)
	return info
end

--强体
function ClsGuildBuffData:getAddHpBuffInfo()
	local info = self:getBuffInfoByType(BUFF_STATUS.ADD_HP)
	return info
end

--坚韧
function ClsGuildBuffData:getAddDefBuffInfo()
	local info = self:getBuffInfoByType(BUFF_STATUS.ADD_DEF)
	return info
end

function ClsGuildBuffData:getBuffStatus()
	return BUFF_STATUS
end

function ClsGuildBuffData:getBuffItemId()
	return BUFF_ITEMS_ID
end

return ClsGuildBuffData