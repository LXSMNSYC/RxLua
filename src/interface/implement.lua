--[[
    Reactive Extensions for Lua
	
    MIT License
    Copyright (c) 2019 Alexis Munsayac
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]  

local is = require "RxLua.src.interface.is"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (interface, class, methods)
    local context = debug.getinfo(1).name 
    badArgument(is(interface), 1, context, "Interface")
    badArgument(type(class) == "table", 1, context, "table", type(class))
    badArgument(type(methods) == "table", 1, context, "table", type(methods))

    local implements = class._implements or {}

    if(not implements[interface]) then 
        local t = {}

        if(methods) then 
            for k, v in pairs(methods) do
                t[k] = v
            end 
        end

        implements[interface] = t
    end 

    class._implements = implements
end 