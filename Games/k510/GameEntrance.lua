--GameEntrance.lua
local GameEntrance = {}

function GameEntrance.run(hallControl,logonIP,logonPort,webRoot)
	local gameLibSink = require("k510/GameLibSink"):new(hallControl)
	gameLibSink:run(logonIP,logonPort,webRoot)
	return gameLibSink
end

return GameEntrance