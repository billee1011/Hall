local GlobalMsg = {}
GlobalMsg.__index = GlobalMsg

GlobalMsg.LOGIN_TYPE_NULL = 0
GlobalMsg.LOGIN_TYPE_ACCOUNT = 1
GlobalMsg.LOGIN_TYPE_QQ = 2
GlobalMsg.LOGIN_TYPE_PLATFORM = 3

function GlobalMsg:initDefaultData()
	--读取现有的文件配置
	self.m_nMusicVol = C2dxEx:getIntegerForKey("szmjMusicVol", 30)
	self.m_nEffectVol = C2dxEx:getIntegerForKey("szmjEffectVol", 80)
	self.m_bIsMusicOpen = C2dxEx:getIntegerForKey("szmjIsMusicOpen", 1) == 1
	self.m_bIsEffectOpen = C2dxEx:getIntegerForKey("szmjIsEffectOpen", 1) == 1
	self.m_bIsVibratorOpen = C2dxEx:getIntegerForKey("szmjIsVibratorOpen", 1) == 1
	self.m_bIsLuangeOpen = C2dxEx:getIntegerForKey("szmjIsLuangeOpen", 0) == 1
end

function GlobalMsg:getDateNow()
	return os.date("%Y") .. "-" .. os.date("%m") .. "-" .. os.date("%d")
end

function GlobalMsg:setMusicVol(musicVol)
	if (self.m_nMusicVol == musicVol) then
		return
	end
	self.m_nMusicVol = musicVol
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjMusicVol", musicVol)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:getMusicVol()
	return self.m_nMusicVol
end

function GlobalMsg:setEffectVol(effectVol)
	if (self.m_nEffectVol == effectVol) then
		return
	end
	self.m_nEffectVol = effectVol
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjEffectVol",
			effectVol)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:getEffectVol()
	return self.m_nEffectVol
end

function GlobalMsg:isMusicOpen()
	return self.m_bIsMusicOpen
end

function GlobalMsg:setMusicOpen(isopen)
	if (self.m_bIsMusicOpen == isopen) then
		return
	end
	self.m_bIsMusicOpen = isopen;
    local open = 1
    if (isopen == false) then
        open = 0
    end
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjIsMusicOpen", open)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:isEffectOpen()
	return self.m_bIsEffectOpen
end

function GlobalMsg:setEffectOpen(isopen)
	if (self.m_bIsEffectOpen == isopen) then
		return
	end
	self.m_bIsEffectOpen = isopen
    local open = 1
    if (isopen == false) then
        open = 0
    end
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjIsEffectOpen", open)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:isLuangeOpen()
	return self.m_bIsLuangeOpen
end

function GlobalMsg:setLuangeOpen(isopen)
	if (self.m_bIsLuangeOpen == isopen) then
		return
	end
	self.m_bIsLuangeOpen = isopen
    local open = 1
    if (isopen == false) then
        open = 0
    end
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjIsLuangeOpen", open)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:isFirstIn(nUserDBID)
    return C2dxEx:getIntegerForKey(string.format("szmjIsFirstIn_%d", nUserDBID), 1) == 1
end

function GlobalMsg:setFirstIn(nUserDBID, nFirstIn)
    CCUserDefault:sharedUserDefault():setIntegerForKey(string.format("szmjIsFirstIn_%d", nUserDBID), nFirstIn)
    CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:isVibratorOpen()
	return self.m_bIsVibratorOpen
end

function GlobalMsg:setVibratorOpen(isopen)
	if (self.m_bIsVibratorOpen == isopen) then
		return
	end
	self.m_bIsVibratorOpen = isopen
    local open = 1
    if (isopen == false) then
        open = 0
    end
	CCUserDefault:sharedUserDefault():setIntegerForKey("szmjIsVibratorOpen", open)
	CCUserDefault:sharedUserDefault():flush()
end

function GlobalMsg:new()
    local store = nil

    return function(self)
        if store then return store end
        local o =  {}
        setmetatable(o, self)
        self.__index = self

        o.m_nMusicVol = 0
    	o.m_nEffectVol = 0
    	o.m_bIsMusicOpen = false
    	o.m_bIsEffectOpen = false
    	o.m_bIsVibratorOpen = false
        o:initDefaultData()
    	
        store = o
        return o
    end
end

GlobalMsg.instance = GlobalMsg:new() 

return GlobalMsg