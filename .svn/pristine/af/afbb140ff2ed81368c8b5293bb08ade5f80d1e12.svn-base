--SendCMD.lua
require("GameLib/common/common")
local GameDefs = require("bull/GameDefs")
local SendCMD = {}
SendCMD.__index = SendCMD


--开始游戏
function SendCMD.sendCMD_PO_RESTART()       --无内容 只向服务器发命令
    local gameLib = require("bull/GameLibSink").game_lib
  --  gameLib:sendReadyCmd()  
	gameLib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_READY ,nil,0)
end

--对当前的牌不感兴趣
function SendCMD.sendCMD_PO_PASS()      -- 长度为nSize的BYTE数组
	-- local ba = require("ByteArray").new()
 --    ba:writeInt(1)
 --    ba:setPos(1)
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.MJ_CMD_PASS,nil,0)
end

--出牌
function SendCMD.sendCMD_PO_OUTCARD(bMj)   -- 长度为nSize的BYTE数组
	local ba = require("ByteArray").new()
    ba:writeByte(bMj)
    ba:setPos(1)
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.MJ_CMD_OUT,ba:getBuf(),ba:getLen())
end

--吃牌
function SendCMD.sendCMD_PO_EAT(nEatCmd)
    --require("bull/desk/public/GameCfg").SortMjList(vEatCase)
    require("bull/GameLibSink").game_lib:sendGameCmd(nEatCmd,nil,0)
end

--碰牌
function SendCMD.sendCMD_PO_PENG()      --无内容 只向服务器发命令
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.MJ_CMD_PENG ,nil,0)
end

--杠牌
function SendCMD.sendCMD_PO_GANG(nCard,nType)
	local ba = require("ByteArray").new()
    ba:writeByte(nType)
    ba:writeByte(0)
    ba:writeByte(nCard)
    ba:writeByte(nCard)
    ba:writeByte(nCard)
    ba:writeByte(nCard)
    cclog("SendCMD.sendCMD_PO_GANG nType="..nType.."  nCard="..nCard)
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.MJ_CMD_GANG ,ba:getBuf(),ba:getLen())
end

--胡牌
function SendCMD.sendCMD_PO_HU()
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.MJ_CMD_HU ,nil,0)
end

--听牌(不用处理)
function SendCMD.sendCMD_PO_TING()      --不用处理该命令
	local ba = require("ByteArray").new()
    ba:writeInt(1)
    ba:setPos(1)
    require("bull/GameLibSink").game_lib:sendGameCmd(GameDefs.PO_TING ,ba:getBuf(),ba:getLen())
end

--通知服务器某玩家开始托管
function SendCMD.sendCMD_PO_ROBOTPLAYSTART()  
      --无内容 只向服务器发命令
    local CS_Message = require("bull/desk/public/CS_Message")
    require("bull/GameLibSink").game_lib:sendGameCmd(CS_Message.MJ_CMD_AUTOOUT ,nil,0)
end

--通知服务器某玩家取消了托管
function SendCMD.sendCMD_PO_ROBOTPLAYCANCEL()       --无内容 只向服务器发命令
    local CS_Message = require("bull/desk/public/CS_Message")
    require("bull/GameLibSink").game_lib:sendGameCmd(CS_Message.MJ_CMD_Cancel_AutoOut ,nil,0)
end

return SendCMD