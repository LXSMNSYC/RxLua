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
--]] 
local new = require "RxLua.observable.new"
local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)
    local onComplete = observer.onComplete
    local onError = observer.onError

    local onFinally = self._onFinally
    
    observer.onComplete = function (x)
        pcall(onComplete)
        pcall(onFinally)
    end

    observer.onError = function (x)
        pcall(onError, x)
        pcall(onFinally)
    end
    
    local disposable = self._source:subscribe(observer)
    local dispose = disposable.dispose

    disposable.dispose = function (self)
        dispose(self)
        pcall(onFinally)
    end

    return disposable
end

return function (self, onFinally)
    if(type(onFinally) == "function") then 
        local observable = new()

        observable._source = self 
        observable._onFinally = onFinally
        observable.subscribe = subscribeActual

        return observable
    else 
        HostError("bad argument #2 to 'Observable.doOnFinally' (function expected, got"..type(fn)..")")
    end
end