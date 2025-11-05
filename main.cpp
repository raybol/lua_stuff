#include "sol/sol.hpp"
#include <string>
#include <iostream>
#include <unordered_map>

struct cpp_thing
{
    cpp_thing(int n) : id(n) {};
    double value;

    std::string hello() { return "hello"; }
    int getId() { return this->id; }

    // --- Coroutine management ---
    void addCoroutine(const std::string &name, sol::function func, sol::this_state L)
    {
        sol::state_view lua(L);
        original_functions[name] = func;
        createCoroutine(name, lua);
    }

    sol::variadic_results resumeCoroutine(const std::string &name, sol::variadic_args va, sol::this_state L)
    {
        sol::state_view lua(L);
        auto it = coroutines.find(name);
        if (it == coroutines.end())
            return sol::variadic_results{}; // empty if missing

        sol::coroutine &co = it->second;
        sol::protected_function_result result = co(va);

        if (!result.valid())
        {
            sol::error err = result;
            coroutines.erase(it);
            std::string msg = "Coroutine '" + name + "' crashed: ";
            msg += err.what();
            throw std::runtime_error(msg);
        }

        // If coroutine finished, automatically restart
        if (co.status() != sol::call_status::yielded)
        {
            createCoroutine(name, lua);
            sol::coroutine &new_co = coroutines[name];
            result = new_co(va); // optionally resume immediately
            if (!result.valid())
            {
                sol::error err = result;
                coroutines.erase(name);
                std::string msg = "Coroutine '" + name + "' crashed on restart: ";
                msg += err.what();
                throw std::runtime_error(msg);
            }
        }

        // Return all yielded values
        return sol::variadic_results(std::move(result));
    }

    void clearCoroutines() { coroutines.clear(); }

    sol::object call_index(sol::stack_object key, sol::this_state L)
    {
        sol::state_view lua(L);
        auto mkey_str = key.as<sol::optional<std::string>>();
        if (!mkey_str)
            return sol::make_object(lua, sol::lua_nil);
        const std::string &k = *mkey_str;

        auto co_it = coroutines.find(k);
        if (co_it != coroutines.end())
        {
            auto callable = [this, k](sol::variadic_args va, sol::this_state s) -> sol::variadic_results
            {
                try
                {
                    return this->resumeCoroutine(k, va, s);
                }
                catch (const std::exception &e)
                {
                    std::cerr << e.what() << "\n"; // concise stack trace
                    return sol::variadic_results{};
                }
            };
            return sol::make_object(lua, callable);
        }

        auto ext_it = extensions.find(k);
        if (ext_it != extensions.end())
            return ext_it->second;

        std::cout << "key not found: " << k << "\n";
        return sol::make_object(lua, sol::lua_nil);
    }

    void call_new_index(sol::stack_object key, sol::stack_object value, sol::this_state L)
    {
        auto mkey_str = key.as<sol::optional<std::string>>();
        const std::string &k = *mkey_str;
        extensions.emplace(k, value);
    }

private:
    int id;
    std::unordered_map<std::string, sol::object> extensions;
    std::unordered_map<std::string, sol::coroutine> coroutines;
    std::unordered_map<std::string, sol::function> original_functions;
    std::unordered_map<std::string, sol::thread> threads;

    void createCoroutine(const std::string &name, sol::state_view lua)
    {
        auto func_it = original_functions.find(name);
        if (func_it == original_functions.end())
            return;
        sol::function func = func_it->second;

        sol::coroutine co;
        auto thread_it = threads.find(name);

        if (thread_it != threads.end())
        {
            co = sol::coroutine(thread_it->second.state(), func);
        }
        else
        {
            sol::thread thread = sol::thread::create(lua);
            co = sol::coroutine(thread.state(), func);
            threads[name] = thread;
        }

        coroutines[name] = co;
    }
};

int main()
{
    sol::state lua;
    lua.open_libraries(sol::lib::base, sol::lib::coroutine);

    sol::usertype<cpp_thing> cpp_thing_type =
        lua.new_usertype<cpp_thing>("cpp_thing", sol::constructors<cpp_thing(int)>(),
                                    sol::meta_function::index, &cpp_thing::call_index,
                                    sol::meta_function::new_index, &cpp_thing::call_new_index);
    cpp_thing_type["value"] = &cpp_thing::value;
    cpp_thing_type["id"] = sol::readonly_property(&cpp_thing::getId);
    cpp_thing_type["hello"] = &cpp_thing::hello;
    cpp_thing_type["addCoroutine"] = &cpp_thing::addCoroutine;

    lua.safe_script(R"(
    function _yield(...)
        return coroutine.yield(...)
    end
)",
                    sol::script_pass_on_error);

    auto t1 = cpp_thing(1);
    t1.value = 10;
    lua["thing1"] = t1;

    auto t2 = cpp_thing(2);
    t2.value = 15;
    lua["thing2"] = t2;
    lua.script_file("./scripts/test2.lua");
    return 0;
}