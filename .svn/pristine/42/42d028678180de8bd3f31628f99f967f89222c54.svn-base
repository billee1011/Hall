require "lfs"
require("CocosExtern")

CCUserFace = CCUserFace or {}
CCUserFace.__index = CCUserFace

CCUserFace.RECEIVENEWFACE     = "CCUserFace_RecvNewFace"
CCUserFace.DEFAULT_FACE_PATH  = "default_%s.png"
CCUserFace.DEFAULT_FACE_SIZE  = CCSizeMake(132,132)
CCUserFace.DEFAULT_FACE_SEXN  = {"man", "woman"}
CCUserFace.DEFAULT_FACE_SEX   = 2

CCUserFace.DEFAULT_DBPATH         = "CCUserFace/"
CCUserFace.DEFAULT_DBFILE         = "CCUSerFace.db"
CCUserFace.DEFAULT_DBFULLPATH     = CJni:shareJni():getStoragePath() .. CCUserFace.DEFAULT_DBPATH
CCUserFace.DEFAULT_DBFULLFILENAME = CCUserFace.DEFAULT_DBFULLPATH .. CCUserFace.DEFAULT_DBFILE

CCUserFace.EXPIRED                = 86400 -- 24小时过期

-- 新建
function CCUserFace.new()
    CCUserFace.load()
    return CCSprite:create()
end

-- 创建目录
function CCUserFace.mkdir(path)
    if not C2dxEx:isFileExist(path) then
        return lfs.mkdir(path)
    end
    return true
end

-- 循环创建目录
function CCUserFace.recursiveMkdir(path)
    path = string.gsub(path, "\\", "/")
    local lastDir = nil
    while true do
        local split = string.find(path, "/")
        if(split == nil) then return end
        local dir = string.sub(path, 1, split - 1)
        path = string.sub(path, split + 1)
        lastDir = lastDir and (lastDir .. "/" .. dir) or dir
        CCUserFace.mkdir(lastDir)
    end
end

-- 读取本地存储
function CCUserFace.load()
    if CCUserFace.db then return end
    CCUserFace.recursiveMkdir(CCUserFace.DEFAULT_DBFULLPATH)
    if C2dxEx:isFileExist(CCUserFace.DEFAULT_DBFULLFILENAME) then
        local ok, ge = pcall(function()
            CCUserFace.db = loadstring(C2dxEx:getFileData(CCUserFace.DEFAULT_DBFULLFILENAME))()
        end)
        if ok then return end
    end
    CCUserFace.db = {}
end

-- 存储数据至本地
function CCUserFace.save()
    if not CCUserFace.db then return end
    table.save(CCUserFace.DEFAULT_DBFULLFILENAME, CCUserFace.db)
    return true
end

-- 格式化微信地址为132*132尺寸地址, /0结尾的地址替换/0为/132，否则直接添加/132
function CCUserFace.formatUrl(url)
    if string.sub(url, -2, -1) == "/0" then
        return string.sub(url, 1, -2) .. "132"
    else
        return url .. "/132"
    end
end

-- 检查本地记录数据是否存在和过期
function CCUserFace.isExpired(nUserDBID)
    if CCUserFace.db and CCUserFace.db[nUserDBID] then
        -- 判定文件是否存在
        local extName = CCUserFace.db[nUserDBID].ext == 1 and "PNG" or "JPG"
        if C2dxEx:isFileExist(string.format( "%s%s.%s", CCUserFace.DEFAULT_DBFULLPATH, tostring(nUserDBID), extName)) then
            return (os.time() >= CCUserFace.db[nUserDBID].exp)
        else
            CCUserFace.db[nUserDBID] = nil
            return true, nil
        end
    else
        return true, nil
    end
end

-- 设置图像显示(内部调用)
function CCUserFace._setFrame(sprite, nUserDBID)
    if not sprite then return false end
    sprite.nUserDBID = nUserDBID
    local rect = CCRectMake(0, 0, CCUserFace.DEFAULT_FACE_SIZE.width, CCUserFace.DEFAULT_FACE_SIZE.height)
    local extName = CCUserFace.db[nUserDBID].ext == 1 and "PNG" or "JPG"
    local imgFrame = CCSpriteFrame:create(
        string.format( "%s%s.%s", CCUserFace.DEFAULT_DBFULLPATH, tostring(nUserDBID), extName ),
    rect)
    if imgFrame then
        sprite:setDisplayFrame(imgFrame)
        return true
    end
    return false
end

-- 更新本地的记录数据, 如果 sprite 为空则仅后台刷新图像数据
function CCUserFace.update(sprite, nUserDBID)
    if nUserDBID then
        -- 手动增加精灵引用计数以免回调完成前被释放掉
        if sprite then sprite:retain() end
        local WebRequest = require("GameLib/common/WebRequest")
        -- 如果记录数据未过期
        if not CCUserFace.isExpired(nUserDBID) then
            if CCUserFace._setFrame(sprite, nUserDBID) then sprite:release() return end
        end
        -- 如果记录数据已过期或图像不存在则更新数据
        local szData = string.format("UserID=%d", nUserDBID)
        -- 向服务器获取用户头像的微信地址
        WebRequest.getWebData(
            -- 获取微信地址回调
            function(isSucceed,tag,data)
                local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
                if isvilad and code == 0 then
                    if #table >= 1 then
                        -- 创建记录集
                        if not CCUserFace.db[nUserDBID] then CCUserFace.db[nUserDBID] = {} end
                        CCUserFace.db[nUserDBID].exp = os.time()
                        -- 如果微信地址存在且无变化
                        if CCUserFace.db[nUserDBID].url == table[1].Face then
                            if sprite and imgFrame then
                                -- 更新记录的过期时间戳
                                CCUserFace.db[nUserDBID].exp = os.time() + CCUserFace.EXPIRED
                                -- 更新图像
                                if CCUserFace._setFrame(sprite, nUserDBID) then sprite:release() return end
                            end
                        end
                        -- 如果微信地址有变化或图像不存在，则下载图像数据至本地保存为图片
                        WebRequest.getWebData(
                            -- 读取到图像数据回调
                            function(isSucceed, tag, data)
                                if string.len(data) > 0 then
                                    local ext = (string.sub(data, 1, 8) == "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A") and 1 or 2
                                    local extName = (ext == 1) and "PNG" or "JPG"
                                    local imgFile = string.format( "%s%s.%s", CCUserFace.DEFAULT_DBFULLPATH, tostring(nUserDBID), extName )
                                    if C2dxEx:isFileExist(imgFile) then os.remove(imgFile) end
                                    -- 写入文件
                                    local f = io.open(imgFile, "wb+")
                                    f:write(data);f:flush(); f:close()
                                    -- 更新记录数据
                                    CCUserFace.db[nUserDBID].url = table[1].Face
                                    CCUserFace.db[nUserDBID].exp = os.time() + CCUserFace.EXPIRED
                                    CCUserFace.db[nUserDBID].ext = ext
                                    CCUserFace.save()
                                    -- 更新图像
                                    CCUserFace._setFrame(sprite, nUserDBID)
                                end
                                if sprite then sprite:release() end
                            end,
                        CCUserFace.formatUrl(table[1].Face), nil, nUserDBID, false, true)
                    end
                end
            end,
        require("Domain").WebRoot.."GetFace.aspx", szData, nUserDBID, true, true)
    end
end

-- 创建默认头像
function CCUserFace.createDefault(_, faceSize, cbSex)
    local sexName = {"man", "woman"}
    local rect = CCRectMake(0, 0, CCUserFace.DEFAULT_FACE_SIZE.width, CCUserFace.DEFAULT_FACE_SIZE.height)
    local userFace = CCUserFace.new()
    userFace.size  = faceSize or CCUserFace.DEFAULT_FACE_SIZE
    userFace.sex   = ((cbSex == 1) or (nil == cbSex)) and 1 or CCUserFace.DEFAULT_FACE_SEX
    userFace.data  = string.format(CCUserFace.DEFAULT_FACE_PATH, CCUserFace.DEFAULT_FACE_SEXN[userFace.sex])
    userFace:setDisplayFrame(CCSpriteFrame:create(userFace.data, rect))
    userFace:setScaleX(userFace.size.width / userFace:getContentSize().width)
    userFace:setScaleY(userFace.size.height / userFace:getContentSize().height)
    return userFace
end

-- 创建指定DBID, sex, faceSize大小的头像
function CCUserFace.create(nUserDBID, faceSize, cbSex)
    local userFace = CCUserFace.createDefault(_, faceSize, cbSex)
    CCUserFace.update(userFace, nUserDBID)
    return userFace
end

-- 克隆头像(为兼容旧接口)
function CCUserFace.clone(faceSp, faceSize)
    local cbSex = faceSp and faceSp.sex or CCUserFace.DEFAULT_FACE_SEX
    local userFace = CCUserFace.createDefault(_, faceSize, cbSex)
    if faceSp and faceSp.nUserDBID then
        CCUserFace.update(userFace, faceSp.nUserDBID)
    end
    return userFace
end

CCUserFace.load()

return CCUserFace