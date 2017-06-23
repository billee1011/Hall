--region NewFile_1.lua
--Author : user
--Date   : 2015/5/15
--此文件由[BabeLua]插件自动生成



--endregion
require("CocosExtern")
require("GameLib/gamelib/CGameLib")

local WebRequest = require("GameLib/common/WebRequest")
local SAFEATOI = WebRequest.SAFEATOI
local SAFESTRING = WebRequest.SAFESTRING
local GameLibSink = require("bull/GameLibSink")
local ShowPicLayer = class("ShowPicLayer", function ()
   return CCLayerColor:create(ccc4(0, 0, 0, 0))
end)

function ShowPicLayer:init()
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self.DIALOGTIME = 0.3
    self:registerScriptHandler(onNodeEvent)
	
    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return self:onTouchBegan(x, y)
        elseif eventType == "moved" then
             self:onTouchMoved(x, y)
        elseif eventType == "ended" then
             self:onTouchEnded(x, y)
        end
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)
end

function ShowPicLayer:onExit()
    
end

function ShowPicLayer:ShowPic()
    local faceSprite = require("FFSelftools/CCUserFace").create(self.nUserDBID, self.cbSex,self.wFaceID, self.cbFaceChangeIndex,"resources/personalinf",CCSizeMake(300,300),GameLibSink.m_gameLib);
	local pImgFace = require ("FFSelftools/CCClickableImage").create(faceSprite)

    self:addChild(pImgFace)

    local winSize = CCDirector:sharedDirector():getWinSize()

    pImgFace:setPosition(ccp(winSize.width*0.5,winSize.height*0.5));
    pImgFace:setScale(0)
    local pSeq= CCEaseExponentialOut:create(CCScaleTo:create(self.DIALOGTIME,1))
    local pTarget = CCTargetedAction:create(pImgFace, pSeq);
    local pFadeTo =CCFadeTo:create(self.DIALOGTIME, 80);
    local pColorGray =CCTargetedAction:create(self, pFadeTo);
    local arr = CCArray:create()
    arr:addObject(pColorGray)
    arr:addObject(pTarget)
	self:runAction(CCSpawn:create(arr))
end

function ShowPicLayer:onEnter()
	local winSize = CCDirector:sharedDirector():getWinSize()
    self:ShowPic()
end

function ShowPicLayer:palyRemoveAction()
    -- body
    local action =CCScaleTo:create(self.DIALOGTIME,0.00)
   
    local pFadeTo =CCFadeTo:create(self.DIALOGTIME,0);
    local pColorGray =CCTargetedAction:create(self, pFadeTo);

    local array1 =CCArray:create()
    array1:addObject(pColorGray)
    array1:addObject(CCRemoveSelf:create(true))

    self:runAction(CCSequence:create(array1))
end

function ShowPicLayer:onTouchBegan(x, y)
    self:palyRemoveAction()
    return true
end

function ShowPicLayer:onTouchMoved(x, y)
    
end

function ShowPicLayer:onTouchEnded(x, y)
   
end

function ShowPicLayer.create(nUserDBID, cbSex, wFaceID, cbFaceChangeIndex)

    local layer = ShowPicLayer:new()
 
    if nil == layer then
        return nil
    end
    layer.nUserDBID = nUserDBID
    layer.cbSex = cbSex
    layer.wFaceID = wFaceID
    layer.cbFaceChangeIndex = cbFaceChangeIndex

    layer:init()
    return layer
end

return ShowPicLayer