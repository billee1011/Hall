--SetLogic.lua
local SetLogic = {}
SetLogic.__index = SetLogic

function SetLogic.readSet()  
    --获取打牌类型
    local tempStr = CCUserDefault:sharedUserDefault():getStringForKey("out_type")
    SetLogic.cbGameOutType = 1
    if tempStr ~= "" and tonumber(tempStr) > 0 then
        SetLogic.cbGameOutType = tonumber(tempStr)
    end

    tempStr = CCUserDefault:sharedUserDefault():getStringForKey("sord_type")
    SetLogic.cbGameSordType = 1
    if tempStr ~= "" and tonumber(tempStr) > 0 then
        SetLogic.cbGameSordType = tonumber(tempStr)
    end

    --音乐、音效、语言配置
    SetLogic.cbGameChecks = {}
    for i=1, 3 do
        SetLogic.cbGameChecks[i], tempStr = 1, CCUserDefault:sharedUserDefault():getStringForKey("game_check"..i)
        if tempStr ~= "" then
            SetLogic.cbGameChecks[i] = tonumber(tempStr)
        else
            SetLogic.cbGameChecks[i] = 1
        end  
    end
    
    -- 获取震动设置
    tempStr = CCUserDefault:sharedUserDefault():getStringForKey("shake_check")
    if tempStr ~= "" then
        SetLogic.cbGameShakeChecks = tonumber(tempStr)
    else
        SetLogic.cbGameShakeChecks = 1
    end  
end

function SetLogic.saveSet()  
    CCUserDefault:sharedUserDefault():setStringForKey("out_type", ""..SetLogic.cbGameOutType)
    CCUserDefault:sharedUserDefault():setStringForKey("sord_type", ""..SetLogic.cbGameSordType)
    
    CCUserDefault:sharedUserDefault():setStringForKey("shake_check", ""..SetLogic.cbGameShakeChecks)

    for i,v in ipairs(SetLogic.cbGameChecks) do
        CCUserDefault:sharedUserDefault():setStringForKey("game_check"..i, ""..v)
    end      
end

function SetLogic.getOutCardType()
    return SetLogic.cbGameOutType
end

function SetLogic.getCardOrderType()
    -- 1是自动排序，2是手动排序
    return SetLogic.cbGameSordType
end

function SetLogic.getShakeCheck()
    return SetLogic.cbGameShakeChecks
end

function SetLogic.setOutCardType(ctype)
    SetLogic.cbGameOutType = ctype
end

function SetLogic.setCardOrderType(ctype)
    cclog("SetLogic.setCardOrderType "..ctype)
    SetLogic.cbGameSordType = ctype
end


function SetLogic.setShakeCheck(ctype)
    SetLogic.cbGameShakeChecks = ctype
end

function SetLogic.getGameCheckByIndex(index)
    return SetLogic.cbGameChecks[index]
end

function SetLogic.setGameCheckByIndex(index, cvalue)
    SetLogic.cbGameChecks[index] = cvalue
end

function SetLogic.playGameGroundMusic(source)
    SetLogic.music_path = source or SetLogic.music_path
    
    require("CocosAudioEngine")
    if SetLogic.getGameCheckByIndex(1) == 0 then
        AudioEngine.stopMusic(false)
    elseif not AudioEngine.isMusicPlaying() then
        if SetLogic.music_path then
            AudioEngine.playMusic(SetLogic.music_path, true)
        end
    end    
end

function SetLogic.playBackGroundMusic()
    require("CocosAudioEngine")

    if SetLogic.getGameCheckByIndex(1) ~= 0 and SetLogic.music_path then
        AudioEngine.resumeMusic()
        if not AudioEngine.isMusicPlaying() then
            AudioEngine.playMusic(SetLogic.music_path, true)
        end
    end    
end

function SetLogic.playGameEffect(source)
    if SetLogic.getGameCheckByIndex(2) == 0 then
        return
    end
    require("CocosAudioEngine")
    AudioEngine.playEffect(source)    
end

function SetLogic.playGameShake(t)
    if SetLogic.cbGameShakeChecks == 1 then
        CJni:shareJni():setVibrate(t)
    end  
end

return SetLogic
