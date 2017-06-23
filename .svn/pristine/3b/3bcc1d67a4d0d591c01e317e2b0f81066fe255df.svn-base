--LogoLayer.lua
local AppConfig = require("AppConfig")
require("CocosExtern")
local LogoLayer=class("LogoLayer",function()
        return CCLayer:create()
    end) 

function LogoLayer:init(exitHandle)
    local AppConfig = require("AppConfig")

    local winSize = AppConfig.WIN_SIZE      
    local pDirector = CCDirector:sharedDirector()
    local glview = CCEGLView:sharedOpenGLView()
    if(glview~=nil) then
        glview:setFrameSize(math.max(winSize.width,winSize.height),math.min(winSize.width,winSize.height))
        CJni:shareJni():changeOrientation(false)
    end
    CCDirector:sharedDirector():getOpenGLView():setDesignResolutionSize(AppConfig.SCREEN.CONFIG_WIDTH,
                 AppConfig.SCREEN.CONFIG_HEIGHT,kResolutionExactFit)

	local function onNodeEvent(event)
        if event =="exit" then
            exitHandle()
        end
    end

    self:registerScriptHandler(onNodeEvent)

	local bg = CCSprite:create("GameLogo.png") or CCSprite:create("GameLogo.jpg")
    if bg == nil then 
        cclog("找不到特殊GameLog")
        bg = CCSprite:create("logo.jpg") or CCSprite:create("bentlogo.png")
    end
	if bg == nil then
		self:runAction(CCRemoveSelf:create(true))
	else
		local winSize = CCDirector:sharedDirector():getWinSize()
        if AppConfig.ISIOS then
            bg = CCSprite:create("logo.jpg")
            bg:setPosition(ccp(winSize.width / 2,winSize.height / 2))
            self:addChild(bg)		
            bg:setOpacity(0)
            local function removeSelf()
                self:removeFromParentAndCleanup(true)
            end
            local actionA =CCArray:create()
            actionA:addObject(CCFadeIn:create(1))
            actionA:addObject(CCDelayTime:create(1))
            actionA:addObject(CCFadeOut:create(1))
            actionA:addObject(CCCallFunc:create(removeSelf))
            bg:runAction(CCSequence:create(actionA))
        else
            bg = CCSprite:create("bentlogo.png")
            local bg2 = CCSprite:create("bentxt.png")
            bg:setPosition(ccp(winSize.width / 2 - 260,winSize.height / 2 ))
            bg2:setPosition(ccp(winSize.width / 2 + 320,winSize.height / 2 - 5))
            self:addChild(bg)
            self:addChild(bg2)
            bg:setOpacity(0)
            bg2:setOpacity(0)
            local function removeSelf()
                self:removeFromParentAndCleanup(true)
            end
            local actionA =CCArray:create()
            actionA:addObject(CCFadeIn:create(1))
            actionA:addObject(CCDelayTime:create(1))
            actionA:addObject(CCFadeOut:create(1))
            actionA:addObject(CCCallFunc:create(removeSelf))
            bg:runAction(CCSequence:create(actionA))
            local actionB =CCArray:create()
            actionB:addObject(CCFadeIn:create(1))
            actionB:addObject(CCDelayTime:create(1))
            actionB:addObject(CCFadeOut:create(1))
            actionB:addObject(CCCallFunc:create(removeSelf))
            bg2:runAction(CCSequence:create(actionB))
        end
	end
end

function LogoLayer.create(exitHandle)
	local layer = LogoLayer.new()
	layer:init(exitHandle)
	return layer
end

function LogoLayer.createScene(exitHandle)
	local scene = CCScene:create()
	local layer = LogoLayer.create(exitHandle)
	scene:addChild(layer)
	return scene
end

return LogoLayer