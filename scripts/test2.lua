print(thing1.id)
print(thing2.id)

local function f()
    print("print ext func")
end

local function coro()
    print("part1")
    --coroutine.yield()
    _yield()
    print("part2")
end

local function coro2()
    local v =1
    while true do
        if v==3 then
            v.h.j=0
            print(hv)
        end
        print(v)
        v=v+1
        _yield()
    end
end

local function coro3(self)
    print(self.id)
    _yield()
end

local function coro4(self,number)
    _yield(number+1,number+2)
end

thing1.func = f
f()
thing1.func()
thing1:addCoroutine("coro",coro)
thing1:addCoroutine("coro2",coro2)
thing1:addCoroutine("coro3",coro3)
thing1:addCoroutine("coro4",coro4)

thing2:addCoroutine("coro3",coro3)

local n =1
local k=0
n,k=thing1:coro4(n)
n,k=thing1:coro4(n)
n,k=thing1:coro4(n)
n,k=thing1:coro4(n)
print(n)
print(k)
thing1.coro()--1
thing1:coro3()
thing1:coro()--2
thing1:coro()--1
thing1:coro()--2
thing1:coro()--1
thing1:coro()
thing1:coro()
thing2:coro3()
thing2:coro3()
thing2:coro3()
thing2:coro3()

