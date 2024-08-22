#include "sol/sol.hpp"
#include <string>
#include<iostream>
#include<unordered_map>
struct cpp_thing
{
    
    double value;
    /* data */
    std::string hello(){
        return "hello";
    }

    int getId(){
        return this->id;
    }

sol::object call_index(sol::stack_object key,sol::this_state L){
    std::cout<<"index call\n";
    auto mkey_str = key.as<sol::optional<std::string>>();
    const std::string& k = *mkey_str;
    std::cout <<"key "<<k <<"\n";
    auto value = extentions.find(k);
    if(value==extentions.end()){
        std::cout<<"key not found\n";
    }
    //int  v = value.as<int>();
    ///std::cout <<"value "<<v<<"\n";
    return extentions[k];
}
void call_new_index(sol::stack_object key, sol::stack_object value ,sol::this_state L){
      std::cout<<"newindex call\n";
    auto mkey_str = key.as<sol::optional<std::string>>();
    const std::string& k = *mkey_str;
    /** 
    auto mkey_num = key.as<sol::optional<int>>();
    int nk = *mkey_num;
    std::cout <<"key "<<k <<"||"<<nk<<"\n";
    int  v = value.as<int>();
    std::cout <<"value "<<v<<"\n";
    
    */
    extentions.emplace(k,value);
}


    private:
    int id;
    std::unordered_map<std::string,sol::object> extentions;
};


int main(){
    sol::state lua;
    lua.open_libraries(sol::lib::base);

    sol::usertype<cpp_thing>  cpp_thing_type = 
    lua.new_usertype<cpp_thing>("cpp_thing",sol::constructors<cpp_thing()>(),
    sol::meta_function::index,&cpp_thing::call_index,
    sol::meta_function::new_index,&cpp_thing::call_new_index);
    cpp_thing_type["value"]=&cpp_thing::value;
    cpp_thing_type["id"]=sol::readonly_property(&cpp_thing::getId);
    cpp_thing_type["hello"]=&cpp_thing::hello;
    lua.script_file("test.lua");
    return 0;
}