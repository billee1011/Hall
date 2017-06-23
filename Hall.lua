require "lfs"

debugMode = true    -- 调试模式(cclog打印输出)
lanMode = true      -- 内网模式

-- 内网模式自动打开调试模式
debugMode = debugMode or lanMode

cc2file = function(...)
    local str = ccprint(...)
    if debugMode then
        local function mkdir(path)
            if not C2dxEx:isFileExist(path) then
                return lfs.mkdir(path)
            end
            return true
        end

        local function recursiveMkdir(path)
            path = string.gsub(path,"\\","/")
            local lastDir = nil
            while true do
                local split = string.find(path,"/")
                if(split == nil) then
                    return
                end
                local dir = string.sub(path,1,split - 1)
                path = string.sub(path,split + 1)
                lastDir = (lastDir == nil) and dir or (lastDir .. "/" ..dir)
                mkdir(lastDir)
            end
        end
        
        local storagePath = CJni:shareJni():getStoragePath() .. "log/"
        recursiveMkdir(storagePath)
        
        if not DebugLogFile then
            f = io.open(storagePath.."debug.log", "w")
            f:write(string.format("\n[ Logfile Start at %s ]\n\n", os.date("%c")))
            f:flush(); f:close()
            DebugLogFile = io.open(storagePath.."debug.log", "a")
        end
        
        DebugLogFile:write(str.."\r")
        DebugLogFile:flush()
    end
end

ccprint = function(...)
    if type(...) ~= "nil" then
        local str = ""
            str = string.format(...)
            local platform = CCApplication:sharedApplication():getTargetPlatform()
            if platform == kTargetIphone or platform == kTargetIpad then
                CJni:shareJni():showMessageBox(str)
            else
                print(str)
            end
        return str
    end
end

cclog = function(...)
    if debugMode then
        ccprint(...)
    end
end

ccerr = function(msg)
    if debugMode and type(msg) ~= "nil" then
        cc2file("[ Error Message at %s ]\n%s" , os.date("%c"), msg)
        local c = CCDirector:sharedDirector():getRunningScene()
        if c then
            local d = c.dLayer
            if d then
                local s = d.dTxt:getString()
                d.dTxt:setString(s.."\n"..msg)
            else
                local dLayer = CCLayerColor:create(ccc4(255, 0, 0, 100),1,1)
                c:addChild(dLayer)
                c.dLayer = dLayer
                local dTxt = CCLabelTTF:create(msg, "", 24)
                dTxt:setHorizontalAlignment(kCCTextAlignmentLeft)
                dTxt:setAnchorPoint(ccp(0,0))
                dTxt:setPosition(ccp(20,20))
                dLayer:addChild(dTxt)
                dLayer.dTxt = dTxt
            end
            d = c.dLayer
            local size = d.dTxt:getContentSize()
            d:setContentSize(CCSizeMake(size.width+40, size.height+40))
            d:stopAllActions()
            local a = CCArray:create()
            a:addObject(CCBlink:create(0.5,3))
            a:addObject(CCDelayTime:create(10))
            a:addObject(CCCallFuncN:create(function(s)
                s:getParent().dLayer = nil
                s:removeFromParentAndCleanup(true)
            end))
            d:runAction(CCSequence:create(a))
        end
    end
end

--- for CCLuaEngine traceback
__G__TRACKBACK__ = function(msg)
    local message = msg
    local msg = debug.traceback(msg, 3)
    ccprint(msg)
    ccerr(msg)
    return msg
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 300)
	collectgarbage("setstepmul", 5000)
	require("LobbyControl").start()
end


        
xpcall(main, __G__TRACKBACK__)