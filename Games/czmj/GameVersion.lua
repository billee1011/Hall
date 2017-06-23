require("CocosExtern")

local GameVersion = class("GameVersion")

function GameVersion:ctor()
    self.version = "1.0.49"    
end

return GameVersion