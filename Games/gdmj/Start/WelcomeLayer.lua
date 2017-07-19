require("CocosExtern")

local CommonInfo = require("gdmj/GameDefs").CommonInfo

local WelcomeLayer = class("WelcomeLayer", function()
	return CCLayer:create()
end)

function WelcomeLayer:init()
    local function onEnter()
    	local winSize = CCEGLView:sharedOpenGLView():getFrameSize()
	    local glview =CCEGLView:sharedOpenGLView()
	    if(glview~=nil) then
	        glview:setFrameSize(math.max(winSize.width,winSize.height), math.min(winSize.width,winSize.height))
	        CJni:shareJni():changeOrientation(false)
	    end
	    CCDirector:sharedDirector():getOpenGLView():setDesignResolutionSize(CommonInfo.View_Width, CommonInfo.View_Height, kResolutionExactFit)

    	local pBackgroundSprite=CCSprite:create(require("AppConfig").ImgFilePathName .. "popup_bg.jpg")
	    pBackgroundSprite:setPosition(ccp(0, 0))--OpenGL的坐标系起点为左下角
	    pBackgroundSprite:setAnchorPoint(ccp(0,0))
	    self:addChild(pBackgroundSprite)
    end

	local function onExit()

    end

    local function onNodeEvent(event)
	    if event == "enter" then
	        onEnter()
	    elseif event == "exit" then
	        onExit()
	    end
	end

	self:registerScriptHandler(onNodeEvent)
end

function WelcomeLayer.create()
	local layer = WelcomeLayer.new()
	layer:init()
	return layer
end

function WelcomeLayer.createScene()
	local scene = CCScene:create()
	scene:addChild(WelcomeLayer.create())
	return scene
end

return WelcomeLayer