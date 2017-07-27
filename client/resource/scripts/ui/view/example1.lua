--2016/09/02
--create by wmh0497

local ClsBaseView = require("ui/view/clsBaseView")
local testView = class("testView", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function testView:getViewConfig()
    return {
        -- name = "testView",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end
--页面创建时调用
function testView:onEnter(index)
    self.m_plist_tab = {}
    LoadPlist(self.m_plist_tab)
    
    local btn = self:createButton({image = "#common_btn_blue1.png", text = "66666", x = 200, y = 200})
    btn:regCallBack(function()
            getUIManager():close("testView") --页面关闭
        end)
    self:addChild(btn)
    
    --cocosStudio的json内容
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/test_btn.json")
    --self.m_bg_spr = getConvertChildByName(panel,"xxx")
    self:addWidget(panel)
    
    
end

function testView:updateView()
    return true
end
function testView:printInfo(...)
    print("printInfo---------", ...)
    return true
end

function testView:preClose(...)
    print("删除ui节点相关--------------")
end

function testView:onExit(...)
    print("---------onExit")
    UnLoadPlist(self.m_plist_tab)
end
return testView

--ui使用代码：
-- getUIManager():create("ui/view/testView", nil, 111,22,333)--创建
-- getUIManager():isLive("testView")--判断页面是否存在
-- local view_obj = getUIManager():get("testView") --获取对应的对象