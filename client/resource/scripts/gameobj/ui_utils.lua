local baowu_info = require("game_config/collect/baozang_info")
local item_info = require("game_config/propItem/item_info")
local equip_material_info = require("game_config/boat/equip_material_info")

local UiUtils = {} -- 

local scheduler = require("framework.scheduler")

local convertTab = {
    Widget = "UIWidget",
    RootWidget = "UIRootWidget",
    Layout = "UILayout",
    Button = "UIButton",
    CheckBox = "UICheckBox",
    ImageView = "UIImageView",
    Label = "UILabel",
    LabelAtlas = "UILabelAtlas",
    LabelBMFont = "UILabelBMFont",
    ListView = "UIListView",
    LoadingBar = "UILoadingBar",
    ScrollView = "UIScrollView",
    Slider = "UISlider",
    TextField = "UITextField",
    PageView = "UIPageView"
}

local REWARD_TYPE_TO_RES = {
    ["exp"] = {res = "#common_icon_exp.png", scale = 0.75},
    ["silver"] = {res = "#common_icon_coin.png", scale = 0.55},
    ["gold"] = {res = "#common_icon_coin.png", scale = 0.55},
    ["honour"] = {res = "#common_icon_honour.png", scale = 0.9},
    ["royal"] = {res = "#common_icon_honour.png", scale = 0.9},
    ["power"] = {res = "#common_icon_power.png", scale = 0.62},
    ["promote"] = {res = "#bo_load.png", scale = 0.6},
    ["trearuse"] = {res = "#common_item_trearusemap.png", scale = 0.5},
    ["baowu"] = {res = function(id)
        return baowu_info[id].res
    end, scale = 0.6},
    ["item"] = {res = function(id)
        return item_info[id].res
    end, scale = 0.6},
    ["material"] = {res = function(id)
        return equip_material_info[id].res
    end, scale = 0.6},
}

function getRewardRes(type)
    return REWARD_TYPE_TO_RES[type]
end

-- 用法
--local ui = xx:getChildByName("xx")
--convertUIType(ui)

local function defineColorFunc(obj)
    function obj:setUILabelColor(color)
        setUILabelColor(self, color)
    end
end

local define_obj_func = {
    ['Label'] = defineColorFunc,
}

function convertUIType(ui)
    if ui then 
        tolua.cast(ui, convertTab[ui:getDescription()])
        if type(define_obj_func[ui:getDescription()]) == "function" then
            define_obj_func[ui:getDescription()](ui)
        end
    end
end

-- 用于子控件的居中对齐
function alignCenter(children , distance , center_pos)
    local child_template = children[1]
    
    center_pos = center_pos or child_template:getPosition()

    local cx = center_pos.x
    local cy = center_pos.y

    local count = #children
    for index , child in ipairs(children) do
        local i = index - 1
        local x = cx + (i - (count - 1) / 2) * distance
        child:setPosition(ccp(x , cy))
        
    end
end

-- 判断node是否被listview裁减掉，不显示
function isClipping(node , list_view)
    local touch_pos = ccp(node:getTouchStartPos().x, node:getTouchStartPos().y)
    local pos = list_view:getParent():convertToNodeSpace(touch_pos)
    return not (list_view.rect:containsPoint(pos))
end

-- 根据控件的宽度调整左右装饰物的位置
function decorateAdapter(widget , decorate_left , decorate_right)
    local pos = widget:getPosition()
    local width_widget = widget:getContentSize().width
    if decorate_left then
        local width_left = decorate_left:getContentSize().width
        local delta_x_left = (width_left + width_widget) / 2
        decorate_left:setPosition(ccp(pos.x - delta_x_left , pos.y))
    end
    if decorate_right then
        local width_right = decorate_right:getContentSize().width
        local delta_x_right = (width_right + width_widget) / 2
        decorate_right:setPosition(ccp(pos.x + delta_x_right , pos.y))
    end
end

-- 接续json文件返回panel
function createPanelByJson(json_path)
    local ret = GUIReader:shareReader():widgetFromJsonFile(json_path)
    convertUIType(ret)
    return ret
end

--根据名字获取转换后的子控件
function getConvertChildByName(parent, childName)
    assert(childName, "why get a nil child from widget")
    local child = parent:getChildByName(childName)
    if child then 
        convertUIType(child)
    end
    return child
end

function cocosAddSelfUIParams(self, parent)
    local childs = parent:getChildren()
    local uiChildCount = parent:getChildren():count()
    --print("uiChildCount", uiChildCount)
    for i = 0, uiChildCount - 1 do
        local Widget = childs:objectAtIndex(i)
        tolua.cast(Widget, "UIWidget")
        convertUIType(Widget)
        self[Widget:getName()] = Widget
        --cclog("Widget name %s", Widget:getName())
        --local pos = Widget:getPosition()
        -- cclog("pos x = %s, pos y = %s", pos.x, pos.y)
        local childCount = Widget:getChildren():count()
        if childCount > 0 then
            cocosAddSelfUIParams(self,  Widget)
        end
    end
end


-- 普通的按钮消息自己 addEventListener(button, TOUCH_EVENT_ENDED)
-- button_register 提供 需要 缩放 高亮 音效 等
-- button_register 会覆盖已注册的 TOUCH_EVENT_BEGAN TOUCH_EVENT_ENDED TOUCH_EVENT_CANCELED ！！
-- 至少需要注册一个回调 ,push_callback, cancel_callback可以为nil

--todo:参数太多，以后改小
function button_register(listener, button, release_callback, push_callback,
    move_callback, cancel_callback, release_callback_params, is_sound, move_out_callback)

    local button_scale_diff = 0.06 -- button down small scale --
    local button_opacity_diff = 50 -- body

    assert(button)
    assert(release_callback or push_callback or move_callback or cancel_callback,
        "no event to register!!")

    button:setTouchEnabled(true)

    local function effect() -- 按下的效果
        if button.is_effect then return end
        button:setScaleX(button:getScaleX() - button_scale_diff) -- 缩小
        button:setScaleY(button:getScaleY() - button_scale_diff) -- 缩小
        button:setOpacity(button:getOpacity() - button_opacity_diff) -- 恢复亮度
        button.is_effect = true
    end

    local function noeffect() -- 取消的效果
        if not button.is_effect then return end
        button:setScaleX(button:getScaleX() + button_scale_diff) -- 还原
        button:setScaleY(button:getScaleY() + button_scale_diff) -- 还原
        button:setOpacity(button:getOpacity() + button_opacity_diff)    
        button.is_effect = false
    end    
    
    button:addEventListener(
        function()
            effect() -- 效果
            if push_callback then push_callback(listener) end 

        end, 
        TOUCH_EVENT_BEGAN)

    local function ptinbutton(button)
        -- body
        local pt = button:getTouchMovePos()
        local rect = button:getRect()
        tolua.cast(pt, "CCPoint") --   const CCPoint -> CCPoint
        return rect:containsPoint(pt)
    end

    button:addEventListener(
        function()  
            if not ptinbutton(button) then -- move out          
                --if  not button.is_touch_moved_out then -- 按钮第一次 moved out
                    noeffect() -- 恢复效果  
                    if move_out_callback then move_out_callback(listener) end
                --end
            else -- move in
                --if  button.is_touch_moved_out then -- 按钮第一次 moved in
                    effect() -- 效果  
                --end
                if move_callback then move_callback(listener) end 
            end

        end, 
        TOUCH_EVENT_MOVED)

    button:addEventListener(
        function()
            noeffect() -- 恢复效果 
            if ptinbutton(button) then -- move out          
            --    if release_callback then release_callback(listener,release_callback_params) end 
            else -- move in
                if cancel_callback then cancel_callback(listener) end 
            end
        end, 
        TOUCH_EVENT_CANCELED)

    button:addEventListener(
        function()
            noeffect() -- 恢复效果 
            if release_callback then release_callback(listener,release_callback_params) end 
            if not is_sound then 
                gameAudioManager.playBtnEffect()
            end            
        end, 
        TOUCH_EVENT_ENDED)
end

-- 使一个ui模板居中并适应屏幕，仅适用于横屏
function dialog_middle(widget, no_move_y)

    local size = widget:getSize();
    local width, height = size.width, size.height;
    logger.info("==== width and height : ", width, height);
    local s = display.height / height;
    if s<1 then -- 判断高度是否超出手机屏幕
        widget:setScaleY( widget:getScaleY() * s ); -- 缩小ui模板
        widget:setScaleX( widget:getScaleX() * s );
        width, height = width * s, height * s;
    end

    local oldpos = widget:getPosition();
    local x, y = oldpos.x, oldpos.y;
    x = display.width/2 - width/2; -- x 方向居中 
    if not no_move_y then -- 部分界面不需要 y 方向居中
        y = display.height/2 - height/2
    end
    widget:setPosition( ccp(x, y) );
end


function button_unregister(btn)
    if tolua.isnull(btn) then return end
    btn:removeEventListener(TOUCH_EVENT_BEGAN)
    btn:removeEventListener(TOUCH_EVENT_CANCELED)
    btn:removeEventListener(TOUCH_EVENT_ENDED)
    btn:removeEventListener(TOUCH_EVENT_MOVED)
end

local RESOURCE_ACTION_TIME = 0.7 -- 资源动画的特效时间
local NUMBER_JUMP_DELTA = 0.5 -- 根据要求，不能超过特效时间 0.5 秒

-- 数字跳动速度
local function numberJumpSpeed(delta, time)
    local t 
    if time then
        t = time
    else
        t =  0.25 * (1 + math.log10(math.abs(delta / 10))) -- 对数模拟
        if t > RESOURCE_ACTION_TIME + NUMBER_JUMP_DELTA then 
            t = RESOURCE_ACTION_TIME + NUMBER_JUMP_DELTA
        end         
    end 
    return delta / t -- 每秒的数字滚动数
end



-- 图标大小跳动动画

local function _makeScaleAction(old_scale)
    local old_scale = old_scale or 0.7 -- 原始缩放率

    --local scale_diff = {0.25, -0.22, 0.18, -0.15, 0.15, -0.0} -- 跳动6次
    local scale_diff = {0.19, -0.17, 0.15, -0.12, 0.12, -0.0} -- 跳动6次
    local scale_time = {0.1, 0.2, 0.15, 0.15, 0.15, 0.25} -- 每次跳动的时间占比（相对于1秒）

    assert(#scale_diff==#scale_time)

    local array = CCArray:create() 
    for i=1, #scale_diff do
        local scale = CCScaleTo:create(RESOURCE_ACTION_TIME * scale_time[i], old_scale + scale_diff[i])
        array:addObject(scale)
    end
    local action = CCSequence:create(array)
    return action 
end


local acts = nil --动作池
local size = 3 --容量
function makeScaleAction(old_scale)

    if not acts then
        acts = {}
        for i=1,size do
            local act = _makeScaleAction()
            act:retain() -- 动作池，需要保持引用。这个retain只会调用一次
            acts[i] = act
        end
    end

    local found = nil
    for i,act in ipairs(acts) do
        local retainCount = act:retainCount()
        if retainCount==1 then 
            found = act
            break
        end
    end
    if not found then 
        found = _makeScaleAction() -- 暂无空闲，新建
        logger.info("==== not enough act in buff")
    end
    return found
end


local GRAY_TAG = 1229
-- 变灰(cocostudio UIWidget用)
function turnGray(widget, res, useFrame, isTurn)
    local innerNode = widget:getContainerNode()
    if innerNode:getChildByTag(GRAY_TAG) then
        return
    end

    local graySprite = nil
    if useFrame then
        graySprite = CCGraySprite:createWithSpriteFrameName(res)
    else
        graySprite = CCGraySprite:create(res)
    end
    
    graySprite:setNormal(false)
    graySprite:setVisible(true)
    if isTurn then
        graySprite:setScaleX(-1)
    end
    innerNode:addChild(graySprite, 0, GRAY_TAG)
end

function removeGray(widget)
    local innerNode = widget:getContainerNode()
    local grayChild = innerNode:getChildByTag(GRAY_TAG)
    if grayChild then
        innerNode:removeChild(grayChild, true)
    end
end

--------------------------------------------------------------------------


----------------------------------------------------------------scrollEffectBetween

--保存待update的节点
local tableCbData = {}
--setmetatable(tableCbData, {__mode="k"}) 

local timerHandel = nil --定时器，只创建一个
local interval = 0.03 --更新时间间隔

local function tick(dt)
    local bAny = false --是否有动作
    for id, cbData in pairs(tableCbData) do

        cbData.valueCurrent = cbData.valueSpeed * dt + cbData.valueCurrent -- 增减

        local bEnd --是否到达终止值

        if (cbData.valueSpeed>=0) == (cbData.valueCurrent>=cbData.valueTo) then
            bEnd = true
        end
        local callback = cbData.callback --
        local endcallback = cbData.endcallback -- 
        if bEnd then
            if endcallback then
                endcallback()
            end

            cbData.valueCurrent = cbData.valueTo --限制
            --tableCbData[id] = nil
            cbData.callback = nil --释放引用
            cbData.endcallback = nil

        end
        if callback then
            callback(toint(cbData.valueCurrent))
        end
        bAny = true
    end

    if not bAny then -- not any
        if timerHandel then
            scheduler.unscheduleGlobal(timerHandel)
            timerHandel = nil
        end
    end

end





--为了简明，通过id去区分兵分派
--只支持整数
--valueFrom 起始值，可以不传入，可以是负数，支持 +- 运算即可，不要传字符串的数字！！
--valueFrom 为nil的时候，默认从0开始或者从上一次滚动到的值开始
--由于存在user:setGold()等操作，上一次滚动到的值不应该也不需要用户保存；由tableCbData通过id保存
--id 可以是任意类型，最好是字符串，也用来记录上一次的数值
--valueTo 终止值
--callback 滚动到一个值的回调（valueTo-valueFrom/时间）


--考虑到短时间多次被调用的情况：
--因为只有一个定时器，改变的只是递增/减的间隔，效率基本一致
--最多的情况下会同时存在3个需要effect的节点（金钱，粮仓，gem）
--经验证，对帧率的影响可以忽略

function scrollEffectBetween(id, callback, valueTo, valueFrom, endcallback, time) 

    --assert(id) -- 可以改为不传id
    --assert(valueTo)
    --assert(callback)
    if not id then --非法
        return
    end

    --insert one
    --data
    local cbData = tableCbData[id] --从已经注册过的记录中找上一次
    if not cbData then
        cbData = { -- 新建
            endcallback = nil, --
            callback = nil, --滚动到某个数值的回调
            valueFrom = nil, --起始值
            valueCurrent = nil, --当前值
            valueTo = nil, --终止值
        } 
        tableCbData[id] = cbData -- 记录
    end

    --数据重新初始化
    cbData.endcallback = endcallback
    cbData.callback = callback
    cbData.valueTo = valueTo or 0


    cbData.valueFrom = valueFrom or (cbData.valueCurrent or 0 )
    cbData.valueCurrent = cbData.valueFrom

    cbData.valueSpeed = numberJumpSpeed(cbData.valueTo - cbData.valueFrom, time)

    if not timerHandel then --假如定时器已经停止
        timerHandel = scheduler.scheduleGlobal(tick, interval, false)
    end

    local function tostop()
        tableCbData[id] = nil
    end
    return tostop

end

--清理所有

function scrollEffectClearAll()
    if timerHandel then
        scheduler.unscheduleGlobal(timerHandel)
        timerHandel = nil    
        tableCbData = {}
    end
end

function scrollEffectClearById(id)
    if timerHandel then
        scheduler.unscheduleGlobal(timerHandel)
        timerHandel = nil    
        tableCbData[id] = nil
    end
end


-- 分辨率适配
function resolutionFix(widget)
    local CONFIG_SCREEN_HEIGHT = 540
    local dy = (display.height - CONFIG_SCREEN_HEIGHT)
    if dy == 0 then
        return
    end

    local function fixResolution(widget)
        local array = widget:getChildren()
        local count = array:count()
        if count == 0 then 
            return
        else
            for i = 0, count - 1 do
                local child = array:objectAtIndex(i)
                tolua.cast(child, "UIWidget") -- CCObject->UIWidget
                convertUIType(child)
                
                local childPosition = ccp(child:getPosition().x, child:getPosition().y)
                child:setPosition(ccpAdd(childPosition, ccp(0, dy)))
            end
        end
    end
    fixResolution(widget)
end


----------------------------------------------------ccscale9spriteToProgress

--使一个ccsprite节点加入 setPercentage 函数
--为了简洁，不考虑反方向
--@rotale 大图的时候，纹理可能旋转了
local function ccspriteToProgress(vn, rotale)
    assert(vn)
    --考虑之前的暴力tolua.cast，所以函数使用前先判断
    assert(vn.getTextureRect)
    assert(vn.setTextureRect)
    assert(vn.setContentSize)


    local oldtexrect = vn:getTextureRect()
    local size = CCSizeMake(oldtexrect.size.width, oldtexrect.size.height)

    function vn:setPercentage(percentage)
        local texrect = CCRectMake(oldtexrect.origin.x, oldtexrect.origin.y,  
            oldtexrect.size.width*percentage/100, oldtexrect.size.height)

        vn:setTextureRect(texrect, rotale, texrect.size)
        vn:setContentSize(size)
    end
end

--使一个ccscale9sprite节点加入 setPercentage 函数
--为了简洁，不考虑反方向
local function ccscale9spriteToProgress(vn, inset, oldsize)
    inset = inset or 9
    local scale9Sprite = vn
    scale9Sprite:setInsetLeft(inset)
    scale9Sprite:setInsetTop(inset)
    scale9Sprite:setInsetRight(inset)
    scale9Sprite:setInsetBottom(inset)

    --为了简明，ui编辑器制定的锚点必须是 0.5, 0.5
    scale9Sprite:setAnchorPoint(ccp(0, 0.5)) -- .----
    scale9Sprite:setPosition(ccp(-oldsize.width/2, 0)) 
    --function vn:setPercentage(percentage) --这里操作无效
     
end

--图片“变成”进度条
--
--@image传入类型uiimageview
--@reverse反向
--@scale9enable支持圆角
--@inset 宫格定义 默认9
function progress_from_image(image, rotale, scale9enable, inset)
    inset = inset or 8



    if not scale9enable then
        local vn = image:getValidNode()
        tolua.cast(vn, "CCSprite") --
        ccspriteToProgress(vn, rotale)
        function image:setPercentage(percentage)
            if percentage<0 then percentage=0 end
            if percentage>100 then percentage=100 end
            vn:setPercentage(percentage)
        end
    else
        
--[[
        local vn = image:getValidNode()
        tolua.cast(vn, "CCSprite") --假如控件在编辑器的时候使用了九宫格
        assert(vn.getTextureRect) -- 考虑之前的暴力tolua.cast

        local texrect = vn:getTextureRect() 
        --local size = vn:getContentSize() --取出不准确

        local oldsize = CCSizeMake(texrect.size.width, texrect.size.height) --变成scale9之前先记录大小！！

        

        --变成scale9
        image:setScale9Enable(true)
        local vn = image:getValidNode()
        tolua.cast(vn, "CCScale9Sprite") --
        --image:setSize(oldsize)--保证大小和原来一致

        ]]

        image:setScale9Enable(true)
        local vn = image:getValidNode()
        --这里必须确保控件（UIImageView）使用了scale9sprite
        tolua.cast(vn, "CCScale9Sprite") --假如控件在编辑器的时候使用了九宫格
        assert(vn.getPreferredSize) -- 考虑之前的暴力tolua.cast
        --local oldsize = vn:getContentSize() --取出不准确
        local oldsize = vn:getPreferredSize()--CCSizeMake(texrect.size.width, texrect.size.height) --变成scale9之前先记录大小！！
                
        ccscale9spriteToProgress(vn, inset, oldsize)

        local oldScalex = image:getScaleX() 
        local oldScaley = image:getScaleY() 
        local size9widthmin = inset+inset

        function image:setPercentage(percentage)
            
            if percentage<0 then percentage=0 end
            if percentage>100 then percentage=100 end

            local neww = oldsize.width*percentage/100 --不考虑负的百分比
            local newh = oldsize.height

            --判断是否使用scale来表示            
            --print(oldsize.width/size9widthmin)    

            
            if neww<size9widthmin then --太小的进度，宫格没法展现，需要用scale

                if percentage<3 then
                --  percentage = 3
                end

                --vn:setPreferredSize(CCSizeMake(size9widthmin, newh)) --无效
                image:setSize(CCSizeMake(size9widthmin, newh))

                local scalex = oldScalex*(percentage/100)*oldsize.width/size9widthmin --之后用scale来模拟 
                vn:setScaleX(scalex) 

                local scaley = 1
                --为了视觉效果，这里需要对y也操作一下
                scaley = 0.8+0.8*percentage/7
                if scaley>1 then
                    scaley = 1
                end
                vn:setScaleY(oldScaley*scaley)   

            else

                vn:setScaleX(oldScalex)  
                vn:setScaleY(oldScaley)  

                --vn:setPreferredSize(CCSizeMake(neww,newh))  --无效
                image:setSize(CCSizeMake(neww, newh))
            end

        end
    end
    return image
end



DOCK_RIGHT_TOP = 1 --右上
DOCK_RIGHT = 2 -- 右中
DOCK_RIGHT_BOTTOM = 3 --右下
DOCK_LEFT_TOP = 4 -- 左上
DOCK_LEFT = 5 -- 左中
DOCK_LEFT_BOTTOM = 6 --左下
DOCK_TOP = 7 --正上
DOCK_BOTTOM = 8 --正下
DOCK_CENTER = 9 --正中

-- refer: 参照系，不传默认是ui:getParent()
function dock(ui, dockKind, refer, offsetX, offsetY)
    if not refer then refer = ui:getParent() end

    local psize = refer:getContentSize()
    local w = math.min(psize.width, display.width)
    local h = math.min(psize.height, display.height)

    local size = ui:getContentSize()
    local x
    local y

    if dockKind == DOCK_RIGHT_TOP then
        x = w - size.width
        y = h - size.height
    elseif dockKind == DOCK_RIGHT then
        x = w - size.width
        y = h / 2
    elseif dockKind == DOCK_RIGHT_BOTTOM then
        x = w - size.width
        y = 0
    elseif dockKind == DOCK_LEFT_TOP then
        x = 0
        y = h - size.height
    elseif dockKind == DOCK_LEFT then
        x = 0
        y = h / 2
    elseif dockKind == DOCK_LEFT_BOTTOM then
        x = 0
        y = 0
    elseif dockKind == DOCK_TOP then
        x = w / 2
        y = h - size.height
    elseif dockKind == DOCK_BOTTOM then
        x = w / 2
        y = 0
    elseif dockKind == DOCK_CENTER then
        x = w / 2
        y = h / 2
    end

    -- fix self anchorPoint
    local ap = ui:getAnchorPoint()
    x = x + ap.x * size.width
    y = y + ap.y * size.height
    
    -- fix refer anchorPoint
    local pap = refer:getAnchorPoint()
    x = x - pap.x * w
    y = y - pap.y * h


    -- fix offset
    if offsetX then x = x + offsetX end
    if offsetY then y = y + offsetY end

    local p = ccp(x, y)

    local parent = ui:getParent()
    if parent ~= refer then
        local p2 = refer:getRenderer():convertToWorldSpace(p)
        local p3 = parent:getRenderer():convertToNodeSpace(p2)
        ui:setPosition(p3)
    else
        ui:setPosition(p)
    end
end

--ui模板中取出的控件没有performWithDelay方法(相对于display.newNode)
function UiUtils.performWithDelay(node, callback, delay)
    local delay = CCDelayTime:create(delay)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    node:runAction(sequence)
    return sequence
end


--ui模板中取出的UILabelBMFont换行
--@width 宽度
--@uilb 必须是UILabelBMFont类型
function UiUtils.UILabelBMFont_setWidth(uilb, width)
    assert( "UILabelBMFont" == convertTab[ uilb:getDescription() ] )
    local lb = uilb:getValidNode()
    tolua.cast(lb,"CCLabelBMFont")
    lb:setWidth(width)
    lb:setLineBreakWithoutSpace(true) -- 目的是？
end

--@ str 源字符串
--@ 每行宽度 （一个中文算两个字符宽）
function getMultiLineStr(str,splitLen)
    if not splitLen then return str end
    if type(splitLen) ~= "number" then return str end
    if splitLen <= 0 then return str end
    splitLen = math.floor(splitLen)

    local retStr = ""
    local totalLen = #str
    local curPos = 1
    local nextSplit = splitLen
    while ( nextSplit <= totalLen ) do
        retStr = retStr .. string.sub(str,curPos,nextSplit) .. "\n"
        curPos = nextSplit + 1
        nextSplit = curPos + splitLen - 1
    end
    nextSplit = totalLen

    retStr = retStr .. string.sub(str,curPos, nextSplit) .. "\n"
    return retStr
end

--时间显示 time:秒
function getTime2Str(time)
    local timeStr = ""
    local d
    local h
    local m

    if time < 60 then
        timeStr = T("小于1分钟")
    elseif time < 3600 then
        m = math.floor(time / 60)
        timeStr = string.format(T("%s分钟"), m)..T("之前")
    elseif time < 86400 then
        h = math.floor(time / 3600)
        time = time % 3600
        m = math.floor(time / 60)
        timeStr = string.format(T("%s小时%s分钟"), h, m)..T("之前")
    else
        d = math.floor(time / 86400)
        timeStr = string.format(T("%s天"), d)..T("之前")
    end

    return timeStr
end

function registerUIWidgetNodeEvent(widget)
    local renderer = tolua.cast(widget:getRenderer(), "CCNode")
    local handler = function(event)
        if event == "enter" and widget.onEnter then
            widget:onEnter()
        elseif event == "exit" and widget.onExit then
            widget:onExit()
        elseif event == "enterTransitionFinish" and widget.onEnterTransitionFinish then
            widget:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" and widget.onExitTransitionStart then
            widget:onExitTransitionStart()
        elseif event == "cleanup" and widget.onCleanup then
            widget:onCleanup()
        end
    end
    renderer:registerScriptHandler(handler)
end

local function initItemNodeParams(params1, params2)
    params1.nameX = params2.nameX or 50
    params1.nameY = params2.nameY or 0
    params1.nameSize = params2.nameSize or 16
    params1.nameScale = params2.nameScale or 1
    params1.nameFile = params2.nameFile or FONT_CFG_1
    params1.nameColor = params2.nameColor or COLOR_CREAM_STROKE
     
    params1.amountX = params2.amountX or 50
    params1.amountY = params2.amountY or 0
    params1.amountSize = params2.amountSize or 16
    params1.amountScale = params2.amountScale or 1
    params1.amountFile = params2.amountFile or FONT_CFG_1
    params1.amountColor = params2.amountColor or COLOR_GREEN
    params1.amountPrefixStr = params2.amountPrefixStr or "x"
    params1.amountSuffixStr = params2.amountSuffixStr or ""
    if params1.ignoreNumX then
        params1.amountPrefixStr = ""
    end
end

function UiUtils.mkItemNode(params)--{res,scale,opacity,name,nameSize,nameFile,nameColor,nameX,nameY,amount,amountSize,amountFile,amountColor,ignoreNumX,amountX,amountY}
    initItemNodeParams(params, params)
    local node=display.newSprite()
    local opacity = params.opacity or 255
    local icon = nil
    if params.ship then
        local boat_info = require("game_config/boat/boat_info")
        local resID = boat_info[params.res].armature
        local resArmature = "armature/ship/"..resID.."/"..resID..".ExportJson"
        armatureManager:addArmatureFileInfo(resArmature)
        icon = CCArmature:create(resID)
        icon:getAnimation():playByIndex(0)
        node:addChild(icon)
    else
        icon=display.newSprite(params.res)
        icon:setAnchorPoint(ccp(0, 0.5))
        node:addChild(icon)
    end

    if params.scale then 
        icon:setScale(params.scale) 
    end

    local nodeSize = CCSizeMake(icon:getContentSize().width*icon:getScale(), icon:getContentSize().height*icon:getScale())
    local nodeCx = nodeSize.width/2
    local nodeCy = nodeSize.height/2

    node:setContentSize(nodeSize)

    icon:setPosition(ccp(nodeCx, nodeCy))

    if params.name then
        node.nameLabel=createBMFont({text =params.name,opacity=opacity,anchor=ccp(0,0.5),fontFile = params.nameFile, size = params.nameSize,
            color = ccc3(dexToColor3B(params.nameColor))})
        node.nameLabel:setPosition(ccp(nodeCx + params.nameX, nodeCy + params.nameY))
        node.nameLabel:setScale(params.nameScale)
        node:addChild(node.nameLabel)
    end

    if params.amount then
        local amountStr = (params.amountPrefixStr)..params.amount..(params.amountSuffixStr)
        node.amountLabel=createBMFont({text =amountStr,opacity=opacity,anchor=ccp(0,0.5),fontFile = params.amountFile, size = params.amountSize,
            color = ccc3(dexToColor3B(params.amountColor))})
        node.amountLabel:setPosition(ccp(nodeCx + params.amountX, nodeCy + params.amountY))
        node.amountLabel:setScale(params.amountScale)
        node:addChild(node.amountLabel)
    end
    icon:setOpacity(opacity)
    node.icon = icon

    return node
end

--单个奖励项
-- type：奖励类型，即REWARD_TYPE_TO_RES的key，如果没有该类型，新增到REWARD_TYPE_TO_RES列表即可
-- id：奖励项的id，如果没有id，则可不设置
-- amount：奖励的数量，如果不想显示数量，则可不设置
-- 其它参数请参考initItemNodeParams
function UiUtils.mkCurrencyItemNode(params)
    local node = nil

    local res_info = REWARD_TYPE_TO_RES[params.type]
    if not res_info then
        return nil
    end
    local res = nil
    if type(res_info.res) == "function" then
        res = res_info.res(params.id)
    else
        res = res_info.res
    end

    params.res = res
    params.scale = params.scale or res_info.scale

    node = UiUtils.mkItemNode(params)

    return node
end

--列表奖励项
-- row_num：行数，和col_num互斥，两者只能选一个，从上到下开始排列
-- col_num：列数，和row_num互斥，两者只能选一个，从左到右开始排列
-- row_gap：行间距
-- col_gap：列间距
-- rewards：奖励数据列表，每个元素的参考见mkCurrencyItemNode的参数
-- 其它参数请参考initItemNodeParams
function UiUtils.mkCurrencyItemNodeList(params)
    local node = CCNode:create()

    local reward_node = nil
    local reward_nodes = {}
    local reward_node_init_x = 0
    local reward_node_init_y = 0
    local reward_node_x = 0
    local reward_node_y = 0
    local row_num = params.row_num
    local col_num = params.col_num
    local row_gap = params.row_gap or 60
    local col_gap = params.col_gap or 35
    local rewards = params.rewards
    for k,v in ipairs(rewards) do
        if row_num then
            reward_node_x = reward_node_init_x + math.floor((k-1) / row_num) * row_gap
            reward_node_y = reward_node_init_y - math.floor((k-1) % row_num) * col_gap
        elseif col_num then
            reward_node_x = reward_node_init_x + math.floor((k-1) % col_num) * col_gap
            reward_node_y = reward_node_init_y - math.floor((k-1) / col_num) * row_gap
        end
        initItemNodeParams(v, params)
        reward_node = UiUtils.mkCurrencyItemNode(v)
        reward_node:setPosition(reward_node_x, reward_node_y)
        reward_nodes[#reward_nodes + 1] = reward_node
        node:addChild(reward_node)
    end

    return node, reward_nodes
end

return UiUtils
