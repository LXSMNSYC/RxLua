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

local class = require "RxLua.utils.meta.class"

local Disposable = require "RxLua.disposable"
local SingleObserver = require "RxLua.observer.single"

local BiConsumer = require "RxLua.functions.biconsumer"

local BadArgument = require "RxLua.utils.badArgument"

local setOnce = require "RxLua.disposable.helper.setOnce"
local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"

local DISPOSED = require "RxLua.disposable.helper.disposed"

return class ("BiConsumerSingleObserver", Disposable, SingleObserver){
    new = function (self, onCallback)
        BadArgument(BiConsumer.instanceof(onCallback, BiConsumer), 1, "BiConsumer")
        
        self._onCallback = onCallback
    end,

    onSubscribe = function (self, disposable) 
        setOnce(self, disposable)
    end,
    
    onSuccess = function (self, x)
        local try, catch = pcall(function ()
            dispose(self)

            self._onCallback:accept(x, nil)
        end)

        if(not try) then 
            error(catch)
        end 
    end,
    
    onError = function (self, t)
        local try, catch = pcall(function ()
            dispose(self)

            self._onCallback:accept(nil, t)
        end)

        if(not try) then 
            error(catch)
        end 
    end,

    dispose = function (self)
        dispose(self)
    end,

    isDisposed = function (self)
        return isDisposed(self)
    end

}