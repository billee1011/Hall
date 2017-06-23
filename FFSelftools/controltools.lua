function createButtonWithOneStatusFrameName(frameName,buttonTag, action)
    buttonTag = buttonTag or 0
    -- 取得放置在FraneCache中的按钮图片
    local l_buttonFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
    local l_buttonScale9 = CCScale9Sprite:createWithSpriteFrame(l_buttonFrame)
    local l_button = CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(l_buttonFrame:getRect().size)
    l_button:setTag(buttonTag)
    -- 设置监听事件
    -- l_button:addTargetWithActionForControlEvents(target, action, CCControlEventTouchUpInside)
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return l_button, l_buttonScale9
end

function createFlickerButtonWithOneStatusFrameName(frameName, buttonTag, action, flickimgs)
    local item, s9Sp = createButtonWithOneStatusFrameName(frameName, buttonTag, action)

    local uis = {}
    for i,v in ipairs(flickimgs) do
        local sprite = CCSprite:createWithSpriteFrameName(v)
        sprite:setPosition(ccp(s9Sp:getContentSize().width / 2, s9Sp:getContentSize().height / 2))
        s9Sp:addChild(sprite, -1)
        table.insert(uis, sprite)
    end
    require("Lobby/Common/AnimationUtil").runFlickerAction(uis[1], true, uis[2])

    return item   
end 

function createButtonTwoStatusWithOneFilePath(path,tag,action)
    tag = tag or 0
    local tmp=CCSprite:create(path)
    local l_buttonScale9=CCScale9Sprite:create(path)
    l_buttonScale9:setPreferredSize(tmp:getContentSize())
    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(tmp:getContentSize())
    l_button:setTouchPriority(kCCMenuHandlerPriority)

    local l_buttonScale9_press=CCScale9Sprite:create(path)
    l_buttonScale9_press:setPreferredSize(tmp:getContentSize())
    l_buttonScale9_press:setColor(ccc3(77,77,77))
    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateHighlighted)
    l_button:setTag(tag)

    local l_buttonScale9_disable=CCScale9Sprite:create(path)
    l_buttonScale9_disable:setPreferredSize(tmp:getContentSize())
    l_buttonScale9_disable:setColor(ccc3(77,77,77))
    l_button:setBackgroundSpriteForState(l_buttonScale9_disable, CCControlStateDisabled)

    l_button:setZoomOnTouchDown(false)

    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return l_button
end

function createButtonWithFilePath(path,tag,action, scale, bgsz)    
    tag = tag or 0
    scale = scale or 1

    -- local tmp=CCSprite:create(path)
    local tmp=loadSprite(path)
    bgsz = bgsz or tmp:getContentSize()

    local l_buttonScale9=loadSprite(path, true)
    l_buttonScale9:setScale(scale)
    l_buttonScale9:setPreferredSize(bgsz)
    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(bgsz)
    l_button:setTag(tag)
    l_button:setTouchPriority(kCCMenuHandlerPriority)
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return l_button
end

function createButtonWithSprite(sprite, s9prite, tag, action)    
    tag = tag or 0

    s9prite:setPreferredSize(sprite:getContentSize())
    local l_button=CCControlButton:create(s9prite)
    l_button:setPreferredSize(sprite:getContentSize())
    l_button:setTag(tag)
    l_button:setTouchPriority(kCCMenuHandlerPriority)
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return l_button
end

function createPressButtonWithTwoStatusFilePath(path,presspath,tag,action)
    local tmp=CCSprite:create(path)
    local l_buttonScale9=CCScale9Sprite:create(path)
    l_buttonScale9:setPreferredSize(tmp:getContentSize())
    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(tmp:getContentSize())
    l_button:setTouchPriority(kCCMenuHandlerPriority)

    local l_buttonScale9_press=CCScale9Sprite:create(presspath)
    l_buttonScale9_press:setPreferredSize(tmp:getContentSize())
    
    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateHighlighted)
    l_button:setTag(tag)
    if path~= presspath then
     l_button:setZoomOnTouchDown(false)
    end
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return l_button
end

function createPressButtonWithFilePathWithTag(path,presspath,tag,action)
    tag = tag or 0
    local button = createPressButtonWithTwoStatusFilePath(path,presspath,tag,action)
    --button:setTag(tag)
    return button
end

function createButtonWithSingleFile(szFile,nState,tag,action)
    tag = tag or 0
    local pSprite = CCSprite:create(szFile)
    local nWidth = pSprite:getContentSize().width / nState
    local nHeight = pSprite:getContentSize().height
    local pScal9Normal=CCScale9Sprite:create(szFile,CCRectMake(0,0,nWidth,nHeight))
    local pRetButton=CCControlButton:create(pScal9Normal)
    pRetButton:setPreferredSize(CCSizeMake(nWidth,nHeight))
    pRetButton:setTag(tag)
    --设置其他状态
    local pScal9Press=CCScale9Sprite:create(szFile,CCRectMake(nWidth,0,nWidth,nHeight))
    pRetButton:setBackgroundSpriteForState(pScal9Press, CCControlStateHighlighted)
    if(nState > 2) then
       --CCSpriteFrame* pFrameDisable=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szDisableFrameName)
       local pScal9Disable=CCScale9Sprite:create(szFile,CCRectMake(nWidth * 2,0,nWidth,nHeight))
       pRetButton:setBackgroundSpriteForState(pScal9Disable, CCControlStateDisabled)
    end
    --设置监听事件
    pRetButton:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    pRetButton:setTouchPriority(kCCMenuHandlerPriority)
    return pRetButton
end

function createButtonWithFrameName(szNormalFrameName,szPressFrameName,szDisableFrameName,tag,action)
    tag = tag or 0
    local pFrameNormal=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szNormalFrameName)
    local pScal9Normal=CCScale9Sprite:createWithSpriteFrame(pFrameNormal)
    local pRetButton=CCControlButton:create(pScal9Normal)
    pRetButton:setPreferredSize(pFrameNormal:getRect().size)
    pRetButton:setTag(tag)
    --设置其他状态
    local pFramePress=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szPressFrameName)
    local pScal9Press=CCScale9Sprite:createWithSpriteFrame(pFramePress)
    pRetButton:setBackgroundSpriteForState(pScal9Press, CCControlStateHighlighted)
    local pFrameDisable=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szDisableFrameName)
    local pScal9Disable=CCScale9Sprite:createWithSpriteFrame(pFrameDisable)
    pRetButton:setBackgroundSpriteForState(pScal9Disable, CCControlStateDisabled)
    --设置监听事件
    pRetButton:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)

    return pRetButton
end

function createButtonWithTitleFrame(frameName,title,buttonTag,action)
    buttonTag = buttonTag or 0
    --取得放置在FraneCache中的按钮图片
    local l_buttonFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
    local l_buttonScale9=CCScale9Sprite:createWithSpriteFrame(l_buttonFrame)
    local l_button=CCControlButton:create(title, "Arial", 25)
    l_button:setBackgroundSprite(l_buttonScale9)
    l_button:setBackgroundSpriteForState(l_buttonScale9, CCControlStateNormal)
    l_button:setPreferredSize(l_buttonFrame:getRect().size)
    l_button:setTag(buttonTag)
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)    

    return l_button
end

function createButtonWithTitle(title,buttonTag,action)
    buttonTag = buttonTag or 0
    local l_button=CCControlButton:create(title, "Arial", 25)
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside)     

    l_button:setTag(buttonTag)
    return l_button
end

function createButtonWithThreeStatusFilePath(path,presspath,disablepath,buttonTag,action)
    buttonTag = buttonTag or 0
	local tmp=CCSprite:create(path)
	local l_buttonScale9=CCScale9Sprite:create(path)
	l_buttonScale9:setPreferredSize(tmp:getContentSize())

    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(tmp:getContentSize())
    
    local l_buttonScale9_press=CCScale9Sprite:create(presspath)
    l_buttonScale9:setPreferredSize(tmp:getContentSize())
    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateSelected)
    
    local l_buttonScale9_disable=CCScale9Sprite:create(disablepath)
    l_buttonScale9_disable:setPreferredSize(tmp:getContentSize())
    l_button:setBackgroundSpriteForState(l_buttonScale9_disable, CCControlStateDisabled)
    
    l_button:setZoomOnTouchDown(false)
    
    --设置监听事件
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside) 

    l_button:setTag(buttonTag)
    return l_button
end


--创建按钮，三种状态在同一张图片的
--hongfa
function createBtnWidthFile3(path,action)
    local sprite= CCSprite:create(path)
    local texture = sprite:getTexture()
    local rect = sprite:getTextureRect()

    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width/3
    local height = rect.size.height

    local normal = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
    local rectFrame =CCRectMake(x , y , width, height)

    local l_buttonScale9=CCScale9Sprite:create(path,rectFrame)
    l_buttonScale9:setPreferredSize(rectFrame.size)

    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(rectFrame.size)

    rect.origin.x =rect.origin.x + width
    local  l_buttonScale9_press=CCScale9Sprite:create(path, rectFrame)
    l_buttonScale9:setPreferredSize(rectFrame.size)

    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateSelected)
    l_button:addHandleOfControlEvent(function() 
        require("Lobby/Set/SetLogic").playGameEffect(require("AppConfig").SoundFilePathName.."button_effect"..require("AppConfig").SoundFileExtName) 
        if action ~= nil then
            action()
        end
    end, CCControlEventTouchUpInside) 

    return l_button
end

function putControltools(super, btn, pos, zindex)
    btn:setPosition(pos)
    super:addChild(btn, zindex)
    btn:setTouchPriority(kCCMenuHandlerPriority - zindex)

    return btn
end
