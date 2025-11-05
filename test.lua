print("start")
cpp_thing_ext = cpp_thing:new()

--ext.new_field = 4
function cpp_thing.bye()
    return "bye"
end

print("extention")
ext = cpp_thing.new()
print(cpp_thing_ext.hello)
print("break1")

cpp_thing_ext.nu= function() return "ognu" end
ext.nu = function() return "nunu" end
ext.hello = function() return "bye" end
print("break2")
print(cpp_thing_ext:hello())
print(ext:hello())
print(cpp_thing_ext.bye())
print(ext:nu())
print(cpp_thing_ext.nu())
print(cpp_thing_ext.hello)
print(ext:hello())
print(ext:bye())
ext.bye = function() return "hello" end
print(ext:bye())
cpp_thing_ext.value=1
ext.value =10
--cpp_thing.value =100
--cpp_thing.value=4
print(cpp_thing_ext.value)
print(ext.value)
print(cpp_thing_ext.value)

print("done")