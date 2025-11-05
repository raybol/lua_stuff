---@class TABLE_OBJECT
TABLE_OBJECT ={
    a=1
}

function TABLE_OBJECT:new(o)
    local obj = o or {}
    setmetatable(obj,self)
    self.__index=self
    return obj
end

function TABLE_OBJECT.__call()
    print("functor")
end

local function run()
    local tob1= TABLE_OBJECT:new()
    tob1()
end

run()