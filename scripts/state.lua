---@class state
local state ={
    a=0,
    b=1
}

function state:new(o)
    local obj = o or {}
    setmetatable(obj,self)
    self.__index=self
    return obj
end

return state