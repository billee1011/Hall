--LayerDeskRecord.lua
local LayerDeskRecord=class("LayerDeskRecord",function(sz, pos, zindex)
        return require("Lobby/Common/LobbyTableView")
                .createCommonTable(sz, pos, kCCMenuHandlerPriority - zindex)
    end)

local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
local CCButton = require("FFSelftools/CCButton")
local AppConfig = require("AppConfig")

function LayerDeskRecord:initRecord(super, backFunc)
    super:addChild(self)

    FriendGameLogic.getFriendGameTableScores(function(bSucceed)
        backFunc(bSucceed)
        if bSucceed then
            local recorddata = {}
			--FriendGameLogic.record_data[18]
			--tablePrint(FriendGameLogic.record_data[18])
            --数据逻辑处理
            for k,v in pairs(FriendGameLogic.record_data) do
                for j,w in ipairs(v) do
                    w.GameID = k
                    table.insert(recorddata, w)
                end
            end
            table.sort(recorddata, function(a, b) return a.GameBeginTime > b.GameBeginTime end)
            FriendGameLogic.record_data = recorddata
			
            self:setCellSizeFunc(function(t, idx) return 185, 1165 end)
                :setNumberOfCellsFunc(function() return #FriendGameLogic.record_data end)
                :setCreateCellFunc((function(idx) 
                    local info = FriendGameLogic.record_data[idx + 1]
                    return self:createRecordCellItem(info, idx) 
                end))
             
            self:updataTableView()
        end
    end, {18})    
end

--创建item
function LayerDeskRecord:createRecordCellItem(info, idx)
	
    local super = self:getParent():getParent()
    local bgsz = CCSizeMake(1165,170)
    local item = self:createMainItem(info, bgsz, idx)

    --游戏人数
    local playerNum = 2
	for n = 2,4 do
		local key = "FriendNickName_"..n
		if info[key] ~= nil and info[key] ~= ""then 
			playerNum = playerNum + 1 
		else 
			break
		end
	end
--    if info.GameID == 12 then playerNum = 4 end

    --详细信息
    local Util = require("HallUtils")
    local myIndex, myid, ftcolors = nil, require("Lobby/Login/LoginLogic").UserInfo.UserID, {}
    ftcolors[1] = ccc3(127,146,2)
    if info.MasterUserID  ==  myid then
        myIndex = 1
    end

    local names = {info.MasterNickName.."(房主)"}
    local scores = {"："..Util.getScoreStr(info.MasterScore)}
    for i=1,playerNum-1 do
        local name = info["FriendNickName_"..i]
        local score = "："..Util.getScoreStr(info["FriendScore_"..i])
        if not myIndex and info["FriendUserID_"..i]  ==  myid then
            myIndex = 1 + i
        end

        ftcolors[1 + i] = ccc3(127,146,2)
        table.insert(names, name)
        table.insert(scores, score)
    end
    ftcolors[myIndex] = ccc3(250,55,55)

    local poses = {ccp(100, 80), ccp(850, 80), ccp(100, 35), ccp(850, 35)}
	if playerNum == 5 then 
		poses = {ccp(100, 80), ccp(500, 80), ccp(850, 80), ccp(100, 35),ccp(500, 35)}
	end
    for i=1,playerNum do
        self:addLabText(item, names[i]..scores[i], 28, ftcolors[i], poses[i], ccp(0, 0.5))
    end

    local ServerBatchKey = info.ServerBatchKey  --对局号

    item:setAnchorPoint(ccp(0, 0))
    item:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex)

    return item
end

function LayerDeskRecord:createMainItem(info, bgsz, idx)
    local item = CCButton.createWithFrame("lobbyDlg/recorderBorder.png", true, function(tag, target)
        FriendGameLogic.invite_code = info.InviteCode
        FriendGameLogic.game_id = info.GameID

        FriendGameLogic.GetUserFriendTableScoreList(info.FriendTableID, function(data)
            require("Lobby/Record/LayerRecordDetail").put(self:getParent(), self.btn_zIndex + 1, data):show()
        end)
    end, bgsz)
    item:setAnchorPoint(ccp(0, 0))
    item:resetTouchPriorty(kCCMenuHandlerPriority - self.btn_zIndex, false)
    

    --游戏线
    local lineSp = loadSprite("common/horizLine.png")
    lineSp:setPosition(ccp(bgsz.width / 2 + 30, bgsz.height - 55))
    item:addChild(lineSp)

    --游戏序列
    local labNum = CCLabelAtlas:create(""..(idx + 1), AppConfig.ImgFilePath.."num_recorder.png",43,86,string.byte('0'))
    labNum:setPosition(ccp(45, bgsz.height / 2))
    labNum:setAnchorPoint(ccp(0.5, 0.5))
    item:addChild(labNum)    

    --房间
    self:addLabText(item, info.InviteCode.." 房间", 22, ccc3(127,127,127), ccp(100, bgsz.height - 32), ccp(0, 0.5))
    --时间
    self:addLabText(item, "开始时间："..info.GameBeginTime, 22, ccc3(127,127,127), ccp(1120, bgsz.height - 32), ccp(1, 0.5))

    return item
end

function LayerDeskRecord:initDetail(super, data)
    --列表
    self:setCellSizeFunc(function(t, idx) return 82, 1176 end)
        :setNumberOfCellsFunc(function() return #data end)
        :setCreateCellFunc((function(idx) 
            local info = data[idx + 1]
            return self:createDetailCellItem(info, idx) 
        end))
    super:addChild(self) 
    self:updataTableView()  

	local playerNum = 2
	local tb = data[1]
	for n = 2,4 do
		if tb ~= nil and tb["FriendNickName_"..n] ~= nil and tb["FriendNickName_"..n] ~= ""then
			playerNum = playerNum + 1
		else
			break
		end
	end
	cclog("ren shu:"..playerNum)
    self:initDetailTitle(super, data,playerNum)
    return self  
end

--创建item
function LayerDeskRecord:createDetailCellItem(info, idx)
    local item = CCLayerColor:create(ccc4(247, 241, 229, 255), 1176, 82)
    item:setPosition(ccp(2, 0))
    if idx % 2 ~= 0 then
        item:setColor(ccc3(234, 219, 190))
    end

    --游戏人数
    local playerNum = 2
	for n = 2,4 do
		local key = "FriendNickName_"..n
		if info[key] ~= nil and info[key] ~= "" then 
			playerNum = playerNum + 1 
		else 
			break
		end
	end
   -- if FriendGameLogic.game_id == 12 then playerNum = 4 end

    --游戏序列
    local labNum = CCLabelAtlas:create(tostring(idx + 1), AppConfig.ImgFilePath.."num_roomrecorder.png",32,34,string.byte('+'))
    labNum:setPosition(ccp(35, 40))
    labNum:setAnchorPoint(ccp(0.5, 0.5))
    item:addChild(labNum)    

    --时间
    self:addLabText(item, info.GameBeginTime, 24, ccc3(48,48,48), ccp(195, 40), ccp(0.5, 0.5))

    --详细信息
    local Util = require("HallUtils")
    self:addLabText(item, Util.getScoreStr(info.MasterScore), 24, ccc3(48,48,48), ccp(410, 40), ccp(0.5, 0.5))
    for i=1,playerNum - 1 do
        local score = Util.getScoreStr(info["FriendScore_"..i])
        self:addLabText(item, score, 24, ccc3(48,48,48), ccp(410 + 110 * i, 40), ccp(0.5, 0.5))
    end

    local playBtn = CCButton.put(item, CCButton.createCCButtonByFrameName("lobbyDlg/btn_recorder_play1.png", 
            "lobbyDlg/btn_recorder_play2.png", "lobbyDlg/btn_recorder_play1.png", function()			
            FriendGameLogic.getGamePlayRecord(0, info["ServerBatchKey"], function(gamedata)
				if gamedata["Action"]["roomInfo"]["Cnt"] == nil then
					require("HallUtils").showWebTip("数据格式不对")
					return
				end
				
                require("bull/GamePlayLogic").getInstance():replaceMainScence(gamedata)
                end)
            end), ccp(980, 40), self.btn_zIndex)
    
    --分享按钮
    local shareBtn = CCButton.put(item, CCButton.createCCButtonByFrameName("lobbyDlg/btn_recorder_share1.png", 
            "lobbyDlg/btn_recorder_share2.png", "lobbyDlg/btn_recorder_share1.png", function()
                FriendGameLogic.createReplayCode(info["ServerBatchKey"], FriendGameLogic.game_id, FriendGameLogic.invite_code)
            end), ccp(1105, 40), self.btn_zIndex)

    item:setAnchorPoint(ccp(0, 0))

    if AppConfig.ISAPPLE then
       playBtn:setVisible(false)   
       shareBtn:setVisible(false)       
    end

    return item
end

function LayerDeskRecord:initDetailTitle(super, data,playerNum)
    self:addLabText(super, "局数", 24, ccc3(48,48,48), ccp(85, 565), ccp(0.5, 0.5)) 
    self:addLabText(super, "开始时间", 24, ccc3(48,48,48), ccp(245, 565), ccp(0.5, 0.5))
    self:addLabText(super, data[1].MasterNickName, 24, ccc3(48,48,48), ccp(460, 565), ccp(0.5, 0.5))

    for i=1,playerNum - 1 do
        local name = data[1]["FriendNickName_"..i] --255,150,0
        self:addLabText(super, name, 24, ccc3(48,48,48), ccp(460 + 110 * i, 565), ccp(0.5, 0.5))
    end

    return self  
end

function LayerDeskRecord:addLabText(item, msg, ftsz, ftcolor, pos, anchorpos)
    local labItem = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, ftsz)
    labItem:setColor(ftcolor)  
    labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
    labItem:setAnchorPoint(anchorpos)     
    labItem:setPosition(pos)
    item:addChild(labItem)    
end

function LayerDeskRecord.putRecord(super, zindex, backFunc) --获取最终的战绩
    local layer = LayerDeskRecord.new(CCSizeMake(super.bgsz.width-100, super.bgsz.height-110), ccp(50, 30), zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1
    layer:initRecord(super, backFunc)
    return layer
end

function LayerDeskRecord.putDetail(super, zindex, data)--获取详细的对局信息
	cclog("LayerDeskRecord.putDetail")
    local layer = LayerDeskRecord.new(CCSizeMake(super.bgsz.width-104, super.bgsz.height-126), ccp(52, 32), zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1
    layer:initDetail(super, data)
    return layer
end

 return LayerDeskRecord