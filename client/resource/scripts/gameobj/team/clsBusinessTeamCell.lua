--
-- 队伍列表cell
--

local ui_word           = require("game_config/ui_word")
local music_info        = require("game_config/music_info")
local sailor_info       = require("game_config/sailor/sailor_info")
local port_info         = require("game_config/port/port_info")
local ClsAlert          = require("ui/tools/alert")
local ClsCommonFuns     = require("gameobj/commonFuns")
local nobility_conf     = require("game_config/nobility_data")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")


-- cell 里每个船长的一些UI
local seaman_widget_names = {
    "seaman_level",
    "seaman_name",
    "seaman_head",
    "seaman_bg_me",
    "seaman_bg",
    "seaman_no",
    "title_pic",
    "job_icon",
}

-- 判断是否本人所在队伍
local function checkIsMyTeam(uid, info)
    for k, v in ipairs(info) do
        if v.uid == uid then return true end
    end
    return false
end

-- 主要用于排列称号和玩家名字
local function alignWidget(aim_obj, base_obj)
    local base_pos      = base_obj:getPosition()
    local base_obj_size = base_obj:getSize()
    local aim_pos_x     = base_pos.x - base_obj_size.width/2
    local old_pos       = aim_obj:getPosition()

    aim_obj:setPosition(ccp(aim_pos_x, old_pos.y))
end

--------------------------------- ClsBusinesTeamCell ----------------------------------

local ClsBusinesTeamCell = class("ClsBusinesTeamCell", ClsScrollViewItem)

-- updateUI
function ClsBusinesTeamCell:updateUI(cell_data, panel)
    -- data
    self["my_uid"]       = getGameData():getPlayerData():getUid() or 0
    self["last_time"]    = CCTime:getmillistimeofCocos2d() - 500
    self["m_data"]       = cell_data
    self["m_is_my_team"] = checkIsMyTeam(self.my_uid, cell_data.info)
    -- widget
    self["btn_join"]     = getConvertChildByName(panel, "btn_join")
    self["btn_leave"]    = getConvertChildByName(panel, "btn_leave")
    self["port_name"]    = getConvertChildByName(panel, "port_name")
    self["select_frame"] = getConvertChildByName(panel, "select_frame")
    -- seaman[] 三个包含seaman_widget_names里边定义的东西，队伍里船长头像上那些控件
    self["seaman"]       = {}
    -- expand
    self["expand_win"]   = nil  

    -- seaman 获取每一条中的控件
    for i = 1, 3 do
        self["seaman"][i] = {}
        for k, v in ipairs(seaman_widget_names) do
            self["seaman"][i][v] = getConvertChildByName(panel, v.."_"..i) 
        end
    end

    -- mkUI
    self:mkUi()
end

-- mkUI 初始化UI控件
function ClsBusinesTeamCell:mkUi()
    ------------------------------------------------------------
    -------------------------- 工具方法-------------------------
    -- 获取港口名
    local function getPortName(port_id)               
        if port_id < 1000 then 
            return port_info[port_id].name 
        else
            return ""
        end 
    end

    -- 根据名字的长度转换一下格式
    local function convertNameStr(name_str)
        local len_limit = 7
        local name_len = ClsCommonFuns:utfstrlen(name_str)
        if name_len > len_limit then
            name_str = ClsCommonFuns:utf8sub(name_str, 1, limit_len) .. "..."
        end
        return name_str
    end

    -- 获取头像的相关参数
    local function getHeadIcon(icon)
        local sailor_id = tonumber(icon)
        local icon_str = sailor_info[sailor_id].res
        local star = sailor_info[sailor_id].star
        if star == 6 then
            return icon_str, 0.22
        else
            return icon_str, 0.4
        end
    end

    -- 获取称号
    local function getTitlePic(nobility)
        local nobilityMsg = nobility_conf[nobility] or {}
        local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
        file_name = convertResources(file_name)
        return file_name
    end

    -- 设置一个 seaman
    -- 一个seaman_widget 就是 self.seaman[1(2/3)] 中包含的 seaman_widget_names 的控件集
    local function setSeamanUI(seaman_widget, seaman_data) 
        -- seaman name color 
        if tonumber(seaman_data.name_status) > 0 then 
            seaman_widget["seaman_name"]:setColor(ccc3(dexToColor3B(COLOR_RED)))
        end

        -- seaman name text
        local name_str = convertNameStr(seaman_data.name)
        seaman_widget["seaman_name"]:setText(name_str)
        
        -- seaman bg me
        if seaman_data.uid == self.my_uid then -- 本人
            seaman_widget["seaman_bg_me"]:setVisible(true)
        end
        
        -- seaman level
        seaman_widget["seaman_level"]:setText("Lv."..seaman_data.grade)
        
        -- seaman no 点击邀请
        seaman_widget["seaman_no"]:setVisible(false)
        
        -- seaman head
        local icon_str, icon_scale = getHeadIcon(seaman_data.icon)
        seaman_widget["seaman_head"]:setScale(icon_scale)
        seaman_widget["seaman_head"]:changeTexture(icon_str, UI_TEX_TYPE_LOCAL)
        
        -- job pic
        local role_job_pic = JOB_RES[seaman_data.profession]
        seaman_widget["job_icon"]:changeTexture(role_job_pic, UI_TEX_TYPE_PLIST)
        
        -- title pic
        local title_res = getTitlePic(seaman_data.nobility)
        seaman_widget["title_pic"]:setVisible(true)
        seaman_widget["title_pic"]:changeTexture(title_res, UI_TEX_TYPE_PLIST)
        alignWidget(seaman_widget["title_pic"], seaman_widget["seaman_name"])
    end

    -- 清空一个 seanman 中的东西
    local function clearSeamanUI(seaman_widget)
        for i, name in ipairs(seaman_widget_names) do
            seaman_widget[name]:setVisible(false)
        end
        seaman_widget["seaman_bg"]:setVisible(true)
        -- 是本人所在队伍，把点击邀请文本点亮
        if self.m_is_my_team then 
            seaman_widget["seaman_no"]:setVisible(true)
        end
    end
    -------------------------------------------------------------

    ------------------------ mkUI -------------------------------
    -- 设置队伍港口文本
    local portName = getPortName(self.m_data.port_id)
    self.port_name:setText(portName)

    -- 设置船长头像上的控件
    local seaman_info = self.m_data.info
    for i = 1, 3 do
        if not seaman_info[i] then -- 这个队伍这个位置没人
            clearSeamanUI(self.seaman[i])
        else                       -- 这个位置有人
            setSeamanUI(self.seaman[i], seaman_info[i])
        end
    end

    -- 是本人队伍，就注册离开按钮，而且注册邀请功能，不是就注册加入按钮
    if self.m_is_my_team then
        -- 离开按钮
        self:regLeaveListener()

        for i = 1, 3 do 
            -- 头像位置的事件，有人的话就是扩展面板，没人就是邀请
            self:regSeamanListener(self.seaman[i]["seaman_bg"], i)
        end
    else
        self:regJoinListener()
    end
end


-- 注册离开按钮
function ClsBusinesTeamCell:regLeaveListener()
    self.btn_join:setVisible(false)

    self.btn_leave:setVisible(true)
    self.btn_leave:setPressedActionEnabled(true)
    self.btn_leave:addEventListener(function()
        if CCTime:getmillistimeofCocos2d() - self.last_time < 500 then -- 防止点击过快
            ClsAlert:warning({msg = ui_word.TEAM_BTN_CLICK_TIP})
            return
        end

        self.last_time = CCTime:getmillistimeofCocos2d()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        -- 离开队伍
        getGameData():getTeamData():askLeaveTeam(self.m_data.id)

    end, TOUCH_EVENT_ENDED)
end

-- 注册加入按钮
function ClsBusinesTeamCell:regJoinListener()
    self.btn_leave:setVisible(false)

    self.btn_join:setVisible(true)
    self.btn_join:setPressedActionEnabled(true)
    self.btn_join:addEventListener(function()
        if CCTime:getmillistimeofCocos2d() - self.last_time < 500 then -- 防止点击过快
                ClsAlert:warning({msg = ui_word.TEAM_BTN_CLICK_TIP})
            return
        end

        self.last_time = CCTime:getmillistimeofCocos2d()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        -- join 队伍
        getGameData():getTeamData():toEnterOtherTeam(self.m_data.port_id, function()
            getGameData():getTeamData():askJoinTeam(self.m_data.id)
        end) 

    end, TOUCH_EVENT_ENDED)
end

-- 要跳其他港口之前提示提示羽毛钻石的扣除
function ClsBusinesTeamCell:showCostTipAndJoin(format_str, arg1, arg2)
    local is_enough, cost = getGameData():getTeamData():checkCostIsEnough()
    if is_enough then
        local tips = string.format(format_str, arg1, arg2)
        ClsAlert:showGoToTeamPortTips(tips, cost, function() 
            getGameData():getTeamData():askJoinTeam(self.m_data.id)
        end)
    else
        local parent_list  = getUIManager():get("ClsPortTeamUI"):getListUi()
        ClsAlert:showJumpWindow(DIAMOND_NOT_ENOUGH_GOSHOP, parent_list, {need_cash = cost, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE,})
    end
end

-- 注册头像位置的事件
function ClsBusinesTeamCell:regSeamanListener(bg_widget, i)

    local function openExpandPanelFunc()      --弹开面板的方法
        local select_uid = self.m_data.info[i].uid
        local lead_uid   = self.m_data.leader
        self.expand_win  = self:openExpandPanel(select_uid)
        if self.expand_win then 
            self.expand_win:setPosition(bg_widget:convertToWorldSpace(ccp(0,-28)))
        end
    end

    local function openInvitePanelFunc()      --打开邀请的方法
        local main = getUIManager():get("ClsPortTeamUI")
        if not tolua.isnull(main) then
            getUIManager():create("gameobj/team/clsFriendInvite")
        end
    end

    --有人弹开面板,没人打开邀请
    if self.m_data.info[i] then
        -- 这里的人是自己 不注册事件 
        if self.my_uid == self.m_data.info[i].uid then return end 

        bg_widget:addEventListener(openExpandPanelFunc, TOUCH_EVENT_ENDED)
    else 
        bg_widget:addEventListener(openInvitePanelFunc, TOUCH_EVENT_ENDED)
    end

    bg_widget:setTouchEnabled(true)
end

function ClsBusinesTeamCell:onTouchBegan(x, y)
    -- 随便摸哪关掉扩展面板
     getUIManager():close("ClsTeamExpandWin")
end

-- 创建那个扩展面板
function ClsBusinesTeamCell:openExpandPanel(select_uid)
    if self.expand_win and not tolua.isnull(self.expand_win) then
        getUIManager():close("ClsTeamExpandWin")
        self.expand_win = nil
        return nil
     end

    local window = getUIManager():create("gameobj/team/clsTeamExpandWin", nil, {
        ["select_uid"] = select_uid,
        ["item"]       = self,
    })    

    return window
end

return ClsBusinesTeamCell