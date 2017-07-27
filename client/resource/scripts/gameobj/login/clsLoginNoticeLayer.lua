-- 登录前公告

local ClsBaseView = require("ui/view/clsBaseView")
local ClsLoginNoticeLayer = class("ClsLoginNoticeLayer", ClsBaseView)

-------------------------------------------------------------------------------------
local ClsLoginNoticeItem = class("ClsLoginNoticeItem", require("ui/view/clsScrollViewItem"))


-------------------------------------------------------------------------------------------
function ClsLoginNoticeLayer:getViewConfig(...)
    return {
        name =  "ClsLoginNoticeLayer",   
        type =  UI_TYPE.NOTICE,   
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

function ClsLoginNoticeLayer:onEnter()
    self:mkUi()
end

function ClsLoginNoticeLayer:mkUi()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/login_notice.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    self.title_text = getConvertChildByName(self.panel, "title_text")
    self.btn_notice = getConvertChildByName(self.panel, "btn_notice")

    local ClsScrollView = require("ui/view/clsScrollView")

    local notice_path = "game_config/announce_config"
    if STOP_SVR_ANNOUNCE then
        notice_path = "game_config/announce_stop_config"
    end
    local notice_config = require(notice_path)
    self.title_text:setText(notice_config[1].content)

    local len = #notice_config

    self.list_width = 420
    self.list_height = 198

    self.story_des_view = ClsScrollView.new(self.list_width + 8, self.list_height, true, nil, {is_fit_bottom = true})
    self.story_des_view:setPosition(ccp(267, 165))
    self:addWidget(self.story_des_view)

    local cells = {}
    local list_h = 0
    for i = 2, len do
        local cur_info = notice_config[i]
        local align = ui.TEXT_ALIGN_LEFT
        if cur_info.right == 1 then
            align = ui.TEXT_ALIGN_RIGHT
        end
        local label = createBMFont({text = cur_info.content, anchor=ccp(0,0), fontFile = FONT_COMMON, size = 16, align = align, 
            width = self.list_width, color = ccc3(dexToColor3B(COLOR_BROWN))})
        local rect = label:getContentSize()
        if string.len(cur_info.content) <= 0 then
            rect.width = self.list_width
            rect.height = 25
        else
            rect.height = rect.height + 8
            if cur_info.rich and string.len(cur_info.rich) > 0 then --使用富文本
                label = createRichLabel("$(c:COLOR_BROWN)".. cur_info.rich, self.list_width, rect.height, 16, 2, nil, false)
            end
        end
        local cell = ClsLoginNoticeItem.new(CCSize(rect.width, rect.height))
        cells[#cells + 1] = cell
        cell:addCCNode(label)
    end
    self.story_des_view:addCells(cells)

    self.btn_notice:setPressedActionEnabled(true)
    self.btn_notice:addEventListener(function()
        self:close()
    end,TOUCH_EVENT_ENDED)
end

function ClsLoginNoticeLayer:onExit()  -- 释放
    -- UnLoadPlist(self.plist_tab)
    ReleaseTexture(self)
end

return ClsLoginNoticeLayer