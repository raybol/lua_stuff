---@class decision_handler
local decision_handler = {
    logic = nil,
    state = nil,
    decisions = nil,
}

function decision_handler:new(o)
    local obj = o or {}
    setmetatable(obj,self)
    self.__index=self
    return obj
end


---comment
---@param state state
local function logic_func(state)
end

return decision_handler