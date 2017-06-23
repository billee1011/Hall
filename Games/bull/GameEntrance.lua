--GameEntrance.lua
--require("HallControl")

local GameEntrance = {}

--CCFileUtils:sharedFileUtils():addSearchPath("Hall/dbl/dblResources/")

function GameEntrance.run(hallControl,logonIP,logonPort,webRoot)
	cclog("GameEntrance game bull fsdf")
	local gameLibSink = require("bull/GameLibSink"):new(hallControl)
	gameLibSink:run(logonIP,logonPort,webRoot)
	return gameLibSink
end

return GameEntrance