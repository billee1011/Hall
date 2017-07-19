--GameEntrance.lua
local GameEntrance = {}

function GameEntrance.run(hallControl,logonIP,logonPort,webRoot,gametype)
	--print("zjh.GameEntrance.run()")
	local gameLibSink = require("gdmj/GameLibSink"):new(hallControl)
	gameLibSink:run(logonIP,logonPort,webRoot,gametype)
	return gameLibSink
end

return GameEntrance