--2016/09/02
--create by wmh0497
--页面基类
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsTestItem = class("testItem", ClsScrollViewItem)
--初始化数据
function ClsTestItem:init()
    self.test_log = "12345"
end
--不参与重用的，只有不是每个cell都一样的时候，才用这个加内容
function ClsTestItem:initUI()
    if self.m_is_widget then
        self:addChild(UIWidget:create())
    else
        self:addChild(display.newSprite())
    end
end
function ClsTestItem:updateUI(cell_date, cell_ui)
    local text_lab = cell_ui.text_lab
    if text_lab.setText then
        text_lab:setText("key = " .. cell_date.key)
    else
        text_lab:setString("key = " .. cell_date.key)
    end
end

local testView = class("testView", ClsBaseView)

function testView:getViewConfig(...)
    return {
        name = "testView2",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function testView:onEnter()
    --cocosStudio的， is_fit_bottom = true是滑动到底部时最后一个cell在底下，而不是在顶上
    local score_view = ClsScrollView.new(200, 215, true, function()
            local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/test_btn.json")
            cell_ui.text_lab = getConvertChildByName(cell_ui, "giveup_text")
            return cell_ui
        end, {is_fit_bottom = true})
    score_view:setPosition(ccp(200, 200))
    self:addWidget(score_view)
    
    local cells = {}
    for i = 1, 20 do
        cells[i] = ClsTestItem.new(CCSize(200, 40), {key = i})
    end
    score_view:addCells(cells)
    
    --非cocosStudio, 需要传入参数is_widget = false
    local score_view2 = ClsScrollView.new(400, 215, true, function()
            local cell_ui = self:createButton({image = "#common_btn_blue1.png", text = "66666"})
            cell_ui.text_lab = cell_ui:getTitleLabel()
            cell_ui:setPosition(ccp(100, 0))
            return cell_ui
        end, {is_widget = false})
    score_view2:setPosition(ccp(400, 200))
    self:addChild(score_view2)
    
    local cells = {}
    for i = 1, 20 do
        cells[i] = ClsTestItem.new(CCSize(200, 40), {key = i}, {is_widget = false})
    end
    score_view2:addCells(cells)
    score_view2:regTouch(self) --非cocosStudio需要向ui注册触摸事件
    
end

return testView