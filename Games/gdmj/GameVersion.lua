require("CocosExtern")

local GameVersion = class("GameVersion")

function GameVersion:ctor()
    self.version = "1.0.1"    
end

return GameVersion