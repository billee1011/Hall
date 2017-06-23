-- 图集及材质缓存管理
-- 加载游戏资源 应按从大到小顺序加载避免峰值过高
Cache = Cache or {}

local FileUtils = require("GameLib/common/FileUtils")

-- 添加图集
function Cache.add(plistName)
    cclog("=============== Cache add plist ===============")
    local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    if type(plistName) == "string" then
        cclog("    Cache load plist: %s.plist", plistName)
        frameCache:addSpriteFramesWithFile(plistName..".plist", plistName..".pvr.ccz")
    elseif type(plistName) == "table" then
        for i,v in ipairs(plistName) do
            cclog("    Cache load plist: %s.plist", v)
            frameCache:addSpriteFramesWithFile(v..".plist", v..".pvr.ccz")
        end
    end
    cclog("===============================================\n")
end

-- 删除图集
function Cache.removePlist(plistName)
    cclog("============= Cache remove plist ==============")
    local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local textureCache = CCTextureCache:sharedTextureCache()
    if type(plistName) == "string" then
        cclog("    Cache remove plist: %s.plist", plistName)
        frameCache:removeSpriteFramesFromFile(plistName..".plist")
        textureCache:removeTextureForKey(plistName..".pvr.ccz")
    elseif type(plistName) == "table" then
        for i,v in ipairs(plistName) do
            cclog("    Cache remove plist: %s.plist", v)
            frameCache:removeSpriteFramesFromFile(v..".plist")
            textureCache:removeTextureForKey(v..".pvr.ccz")
        end
    end
    cclog("===============================================\n")
end

-- 删除材质
function Cache.removeTexture(textureName)
    cclog("============ Cache remove Texture =============")
    local textureCache = CCTextureCache:sharedTextureCache()
    if type(textureName) == "string" then
        cclog("    Cache remove textureName: %s", textureName)
        textureCache:removeTextureForKey(textureName)
    elseif type(textureName) == "table" then
        for i,v in ipairs(textureName) do
            cclog("    Cache remove textureName: %s", v)
            textureCache:removeTextureForKey(v)
        end
    end
    cclog("===============================================\n")
end

-- 输出材质使用情况
function Cache.log(s)
    local t = "================================================================================="
    if s then cclog(string.format("〖 %s 〗", tostring(s))) end
    cclog(t); CCTextureCache:sharedTextureCache():dumpCachedTextureInfo(); cclog(t); cclog("\n")
end

return Cache