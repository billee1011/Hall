--LayerVoice.lua
local AppConfig = require("AppConfig")
local GameDefs = require("k510/GameDefs") 
local GameLibSink = require(GameDefs.CommonInfo.GameLib_File)
local SetLogic = require("Lobby/Set/SetLogic")

require("GameLib/common/common")
require("GameLib/gamelib/room/GameCmds")

local CommonInfo = GameDefs.CommonInfo

local LayerVoice=class("LayerVoice",function()
        return CCLayer:create()
    end)

function LayerVoice:init()
    if GameLibSink.game_lib and GameLibSink.game_lib:getMyself() then
        -- YVIM 初始化
        local m,c = GameLibSink.game_lib:getMyself(),YVIMTool._inst
        local udbid, uid = m:getUserDBID(), m:getUserID()
        if not c then
            YVIMTool._inst = YVIMTool:init()
            c = YVIMTool._inst
            c:doEvent(0, udbid)
        end
        c.playerPos   = {
            ccp(146,150),
            ccp(CommonInfo.View_Width - 142, 400),
            ccp(CommonInfo.View_Width - 234, CommonInfo.View_Height - 42),
            ccp(140, 400),
        }
        c.recordList  = {}
        c.isUpload    = true
        c.isRecording = false
        c.isPlaying   = false
        c.nPlayTimer  = 0   --播放计时
        
        -- 语音按钮
        local vButton = CCControlButton:create(loadSprite("czpdk/yuyinbtn.png", true))
        vButton:setPreferredSize(CCSizeMake(69,71))
        vButton:setBackgroundSpriteForState(loadSprite("czpdk/yuyinbtn2.png", true), CCControlStateHighlighted)
        vButton:setPosition(ccp(CommonInfo.View_Width - 60, 80))
        self:addChild(vButton)
        c.voiceButton = vButton
        vButton:addHandleOfControlEvent(self.record,       CCControlEventTouchDown)
        vButton:addHandleOfControlEvent(self.stopRecord,   CCControlEventTouchUpInside)
        vButton:addHandleOfControlEvent(self.stopRecord,   CCControlEventTouchUpOutside)
        vButton:addHandleOfControlEvent(self.stopRecord,   CCControlEventTouchCancel)
        vButton:addHandleOfControlEvent(self.showtip,      CCControlEventTouchDragInside)
        vButton:addHandleOfControlEvent(self.showtip2,     CCControlEventTouchDragOutside)
        vButton:setTouchPriority(kCCMenuHandlerPriority - 5)
        
        -- 正常录音面板
        local vPanel1 = CCLayer:create()
        self:addChild(vPanel1)
        c.vPanel1 = vPanel1
        local bg =  loadSprite("common/voice_border_bg.png",true)
        bg:setPreferredSize(CCSizeMake(188,172))
        bg:setPosition(ccp(CommonInfo.View_Width/2, 285))
        vPanel1:addChild(bg)
        local mic = loadSprite("common/mic.png")
        mic:setPosition(ccp(CommonInfo.View_Width/2-30, 290))
        vPanel1:addChild(mic)
        for i = 1, 5 do
            local v = loadSprite(string.format("common/volume%d.png",i))
            v:setAnchorPoint(ccp(0,0))
            v:setPosition((ccp(CommonInfo.View_Width/2+10, 220 + i*20)))
            vPanel1:addChild(v)
            vPanel1["volume"..i] = v
        end
        local tip = loadSprite("common/tip_cancel.png")
        tip:setPosition(ccp(CommonInfo.View_Width/2, 220))
        vPanel1:addChild(tip)
        vPanel1:setVisible(false)
        
        -- 取消录音面板
        local vPanel2 = CCLayer:create()
        self:addChild(vPanel2)
        c.vPanel2 = vPanel2
        local bg =  loadSprite("common/voice_border_bg.png",true)
        bg:setPreferredSize(CCSizeMake(188,172))
        bg:setPosition(ccp(CommonInfo.View_Width/2, 285))
        vPanel2:addChild(bg)
        local arrow =  loadSprite("common/arrow_cancel.png")
        arrow:setPosition(ccp(CommonInfo.View_Width/2-10, 290))
        vPanel2:addChild(arrow)
        local tip =  loadSprite("common/tip_cancel2.png")
        tip:setPosition(ccp(CommonInfo.View_Width/2, 220))
        vPanel2:addChild(tip)
        vPanel2:setVisible(false)
        
        -- 声音图标
        local voiceIcon = loadSprite("czpdk/voiceIcon.png")
        voiceIcon:setVisible(false)
        self:addChild(voiceIcon)
        c.voiceIcon = voiceIcon
        
        -- 播放列表轮询 0.5秒1次
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.5))
        arr:addObject(CCCallFunc:create(function()
            local c = YVIMTool._inst
            if c and (not c.isPlaying) and #c.recordList > 0 then
                -- cclog("current record list count: %d", #c.recordList)
                local r = require(CommonInfo.GameLib_File).game_lib._gameRoom
                local uid = r.m_mySelf:getUserID()
                local record = c.recordList[1]
                local vx, vy = record.player.userInfoframe:getPosition()
                vx, vy = vx + 56, vy + 56
                YVIMTool._inst.voiceIcon:setPosition(ccp(vx, vy))
                YVIMTool._inst.voiceIcon:setVisible(true)
                SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
                c.isPlaying = true
                c:doEvent(7, record.url)
                c.nPlayTimer = 0
                table.remove(c.recordList, 1)
            elseif c.isPlaying then
                c.nPlayTimer = c.nPlayTimer + 1
                if c.nPlayTimer >= 90 then
                    c:doEvent(4, "")
                    c.isPlaying = false
                    c.nPlayCount = 1
                    c.voiceIcon:setVisible(false)
                    if SetLogic.getGameCheckByIndex(1) ~= 0 then
                        SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
                    end
                end
            end
        end))
        self:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    end
end

function LayerVoice.record()
    -- cclog("YVIM start recording ...")
    local c = YVIMTool._inst
    if SetLogic.getGameCheckByIndex(1) ~= 0 then
        SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
    end
    c.vPanel1:setVisible(true)
    c.vPanel2:setVisible(false)
    c.isRecording = true
    c.isUpload = true
    c:doEvent(1, "")
end

function LayerVoice.stopRecord()
    -- cclog("YVIM stoped recording ...")
    local c = YVIMTool._inst
    if SetLogic.getGameCheckByIndex(1) ~= 0 then
        SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
    end
    c.vPanel1:setVisible(false)
    c.vPanel2:setVisible(false)
    c.isRecording = false
    c:doEvent(2, "")
end

function LayerVoice.uploadRecord(url)
    local glib = require(CommonInfo.GameLib_File).game_lib
    local room = glib._gameRoom
    -- cclog(string.format("YVIM recording uploaded ! speaker:%s url:%s ", room.m_mySelf:getUserID(), url))
    room:sendChat(string.format('@VOICE|%s',url), false)
end

function LayerVoice.uploadRecordErr(msg)
    cclog("YVIM recording upload error msg: " .. msg)
end

function LayerVoice.showtip()
    local c = YVIMTool._inst
    if c.isRecording then
        c.vPanel1:setVisible(true)
        c.vPanel2:setVisible(false)
        c.isUpload = true
    end
end

function LayerVoice.showtip2()
    local c = YVIMTool._inst
    if c.isRecording then
        c.vPanel1:setVisible(false)
        c.vPanel2:setVisible(true)
        c.isUpload = false
    end
end

function LayerVoice.create()
    local layer = LayerVoice.new()
    layer:init()
    return layer
end

-- DO NOT modify the function blow
function onIMRecording(volume)
    local v = math.ceil(volume/20)
    v = v > 5 and 5 or v
    for i = 1, 5 do
        local s = YVIMTool._inst.vPanel1["volume"..i]
        if s then
            s:setVisible(false)
            if i <= v then s:setVisible(true) end
        end
    end
end

function onIMStopRecord(t, path)
    LayerVoice.stopRecord()
    -- time limit: the voice less than 0.5 sec do not upload
    if t > 500 and YVIMTool._inst.isUpload then
        YVIMTool._inst:doEvent(5, "")
    end
end

function onIMUpload(result, msg, url)
    if result == 0 then
        LayerVoice.uploadRecord(url)
    else
        LayerVoice.uploadRecordErr(msg)
    end
end

function onIMStopPlay()
    YVIMTool._inst.isPlaying = false
    YVIMTool._inst.voiceIcon:setVisible(false)
    if SetLogic.getGameCheckByIndex(1) ~= 0 then
        SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
    end
end

return LayerVoice