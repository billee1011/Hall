--LayerVoice.lua
local AppConfig = require("AppConfig") 
local GameLibSink = require("bull/GameLibSink")
local SetLogic = require("Lobby/Set/SetLogic")

require("GameLib/common/common")
require("GameLib/gamelib/room/GameCmds")


local LayerVoice=class("LayerVoice",function()
        return CCLayer:create()
    end)

function LayerVoice:setPlayerPos()
	local  basePos = GameLibSink.sDeskLayer.m_aclsPlayer[1].allPlayerPos
	if not basePos or not YVIMTool._inst then return end
	
	YVIMTool._inst.playerPos   = {
		ccp(basePos[1][2].x + 90,basePos[1][2].y + 130),
		ccp(basePos[2][2].x + 104,basePos[2][2].y + 130),
		ccp(basePos[3][2].x + 116,basePos[3][2].y + 130),
		ccp(basePos[4][2].x + 120,basePos[4][2].y + 130),
		ccp(basePos[5][2].x + 110,basePos[5][2].y + 130),
   }
end
function LayerVoice:init()
    -- YVIM 初始化
    if GameLibSink.game_lib and GameLibSink.game_lib:getMyself() then
        local m,c = GameLibSink.game_lib:getMyself(),YVIMTool._inst
        local udbid, uid = m:getUserDBID(), m:getUserID()
        if not c then
            YVIMTool._inst = YVIMTool:init()
            c = YVIMTool._inst
            c:doEvent(0, udbid)
        end
        c.playerPos   = {
			ccp(250, 160),
			ccp(1225,405),
			ccp(1127,602),
			ccp(270,602),
			ccp(155,405)
        }
        c.recordList  = {}
        c.isUpload    = true
        c.isRecording = false
        c.isPlaying   = false
        c.nPlayCount  = 0   --播放计时

        -- 语音按钮
        local vButton = CCControlButton:create(loadSprite("public/btnGameVoice1.png", true))
        vButton:setPreferredSize(CCSizeMake(69,71))
        vButton:setBackgroundSpriteForState(loadSprite("public/btnGameVoice2.png", true), CCControlStateHighlighted)
        vButton:setPosition(ccp(AppConfig.DESIGN_SIZE.width - 50, 80))
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
        bg:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2, 255))
        vPanel1:addChild(bg)
        local mic = loadSprite("common/mic.png")
        mic:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2-30, 260))
        vPanel1:addChild(mic)
        for i = 1, 5 do
            local v = loadSprite(string.format("common/volume%d.png",i))
            v:setAnchorPoint(ccp(0,0))
            v:setPosition((ccp(AppConfig.DESIGN_SIZE.width/2+10, 190 + i*20)))
            vPanel1:addChild(v)
            vPanel1["volume"..i] = v
        end
        local tip = loadSprite("common/tip_cancel.png")
        tip:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2, 190))
        vPanel1:addChild(tip)
        vPanel1:setVisible(false)
        
        -- 取消录音面板
        local vPanel2 = CCLayer:create()
        self:addChild(vPanel2)
        c.vPanel2 = vPanel2
        local bg =  loadSprite("common/voice_border_bg.png",true)
        bg:setPreferredSize(CCSizeMake(188,172))
        bg:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2, 255))
        vPanel2:addChild(bg)
        local arrow =  loadSprite("common/arrow_cancel.png")
        arrow:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2-10, 265))
        vPanel2:addChild(arrow)
        local tip =  loadSprite("common/tip_cancel2.png")
        tip:setPosition(ccp(AppConfig.DESIGN_SIZE.width/2, 190))
        vPanel2:addChild(tip)
        vPanel2:setVisible(false)
        
        -- 声音图标
        local voiceIcon = loadSprite("common/voiceIcon.png")
        voiceIcon:setVisible(false)
        self:addChild(voiceIcon)
        c.voiceIcon = voiceIcon
        
        -- 播放列表轮询 0.5秒1次
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.5))
        arr:addObject(CCCallFunc:create(function()
            local c = YVIMTool._inst
            if c and #c.recordList > 0 and (not c.isPlaying) then
                local r = GameLibSink.game_lib._gameRoom
                local uid = r.m_mySelf:getUserID()
                local record = c.recordList[#c.recordList]

                for k, v in pairs(record) do
                    local index = GameLibSink.game_lib:getUser(k):getUserChair()
					local chair = GameLibSink.sDeskLayer:PosFromChair(index)
				  -- local chair = GameLibSink.game_lib:getRelativePos(index) + 1 --require("phz/Game/GameLogic"):getInstance():SwitchViewChairID(index)
                    c.voiceIcon:setFlipX(true)
                    c.voiceIcon:setPosition(c.playerPos[chair])
                    c.voiceIcon:setVisible(true)
                
                    SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
                    c.isPlaying = true
                    c:doEvent(7, v)
                    c.nPlayCount = 1
                    break
                end
                table.remove(c.recordList)
            elseif c.isPlaying then                        
                c.nPlayCount = c.nPlayCount + 1
                if c.nPlayCount >= 90 then
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
    local glib = GameLibSink.game_lib
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