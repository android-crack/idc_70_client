--
-- Author: Ltian
-- Date: 2016-11-30 20:49:57
--
require("lfs")

local DEFAULT_PATH  = CCFileUtils:sharedFileUtils():getWritablePath()
local game_file_root_root   = string.format("%sdhh.game.qtz.com", DEFAULT_PATH)

local pic_type_table = {
    "jpeg",
    "png",
    "tiff"
}

local clsNetRes = class("clsNetRes")
function clsNetRes:ctor(...)
    self.is_downing = false
    self.file_path = game_file_root_root
    self.quene = {}

    self:initFolder()
    -- self:downNetRes("http://img4.duitang.com/uploads/item/201412/10/20141210201542_n5Vhe.thumb.224_0.jpeg", "aaa", "jpg", function (error, dir)
    --  print("ok", error, dir)
    -- end)
    -- self:downNetRes("http://img4.duitang.com/uploads/item/201412/10/20141210201542_n5Vhe.thumb.224_0.jpeg", "aaa1", "jpg", function ( error, dir)
    --  print("ok", error, dir)
    -- end)
    -- self:downNetRes("http://img4.duitang.com/uploads/item/201412/10/20141210201542_n5Vhe.thumb.224_0.jpeg", "aaa2", "jpg", function ( error, dir)
    --  print("ok", error, dir)
    -- end)

 --    require("framework.scheduler").performWithDelayGlobal(function()
 --            self:downNetRes("http://wx.qlogo.cn/mmhead/PiajxSqBRaEKxTWXUmdCCpVWiazTqUGoUGvxvKykoZEN0E5j8n8dDiaeQ/46", "aada", "png", function (error, dir)
 --        print("ok", error, dir)
 --    end)
 --    self:downNetRes("http://img4.duitang.com/uploads/item/201412/10/20141210201542_n5Vhe.thumb.224_0.jpeg", "aaada1", "jpg", function ( error, dir)
 --        print("ok", error, dir)
 --    end)
 --    self:downNetRes("http://img4.duitang.com/uploads/item/201412/10/20141210201542_n5Vhe.thumb.224_0.jpeg", "aazza2", "jpg", function ( error, dir)
 --        print("ok", error, dir)
 --    end)
 --        end , 5)
end

function clsNetRes:configFolder(file_dir)
    local root_dir_file = lfs.attributes(string.format("%s/%s", game_file_root_root, file_dir))
    if not root_dir_file then
        lfs.mkdir(game_file_root_root)
    end

    self.file_path = string.format("%s/%s", self.file_path, file_dir)
end

function clsNetRes:initFolder()
    local root_dir_file = lfs.attributes(game_file_root_root)
    if not root_dir_file then
        lfs.mkdir(game_file_root_root)
    end
end

local function readImgType(head)
    local pic_type = ""
    if head == 255 then
        pic_type = "jpeg"
    elseif head == 137 then
        pic_type = "png"
    elseif head == 71 then
        pic_type = "gif"
    elseif head == 73 or firstByte == 77 then
        pic_type = "tiff"
    end
    return pic_type
end

function clsNetRes:doGetNetRes()
    if #self.quene == 0 then return end
    local quene = table.remove(self.quene, 1)
    local url, file_name, file_type, callback = quene.url, quene.file_name, quene.file_type, quene.callback
    local dest_file = string.format("%s/%s", self.file_path, file_name)

    --把老的文件都删了
    self.is_downing = true
    local exist_img = self:findindir(file_name)
    for i,v in ipairs(exist_img) do
        os.remove(v)
    end
    
    local function requestHandler( event )
        local ok = ( event.name == "completed" )
        local request = event.request
        if #self.quene == 0 then
            self.is_downing = false
        end
        if not ok then
            if request then
                request:release()
            end
        
            callback(-1)
            return
        end

        local code = request:getResponseStatusCode()
        if code == 200 then
            local str = request:getResponseDataLua()
            local head = string.byte(str, 1)
            local img_type = readImgType(head)
            request:saveResponseData(dest_file.."."..img_type) 
            callback(0, dest_file)
        else
            callback(-1)
        end
        request:release()
        
    end
    
    local request = network.createHTTPRequest( requestHandler, url, "GET" ) --下载文件
    request:setTimeout( 10 )
    request:start()
end

function clsNetRes:downNetRes(url, file_name, file_type, callback)
    if GTab.IS_VERIFY then  -- 不下载直接返回失败
        if type(callback) == "function" then
            callback(-1)
        end
        return
    end
    local url = string.gsub(url, "\\", "/")
    local quene_item = {}
    quene_item.url = url
    quene_item.file_name = file_name
    quene_item.file_type = file_type
    quene_item.callback = function(error, dir)
        callback(error, dir)
        self:doGetNetRes()
    end

    self.quene[#self.quene + 1] = quene_item
    if not self.is_downing then
        self:doGetNetRes()  
    end
end

function clsNetRes:findindir(name)
    local pic_tab = {}
    for i,v in ipairs(pic_type_table) do
        local pic_name = self.file_path.."/"..name.."."..v
        pic_name = string.gsub(pic_name, "\\", "/")

        file_info = lfs.attributes(pic_name)
        if file_info then
            pic_tab[#pic_tab + 1] = pic_name
        end
    end
    if #pic_tab > 0 then
        print("文件存在==============")
    end
    return pic_tab
end

return clsNetRes