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
local new = require "RxLua.maybe.new"

local dispose = require "RxLua.disposable.dispose"
local isDisposed = require "RxLua.disposable.isDisposed"

local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)
    local index = self._targetIndex

    local upstream

    return self._source:subscribe({
        onSubscribe = function (d)
            upstream = d
            pcall(observer.onSubscribe, d)
        end,
        onNext = function (x)
            index = index - 1
            if(index == 0) then 
                pcall(observer.onSuccess, x)
                upstream:dispose()
                done = true 
            end
        end,
        onError = observer.onError,
        onComplete = observer.onComplete
    })
end

local Assert = require "RxLua.utils.assert"
return function (self, index)
    if
        Assert(type(index) == "number", "bad argument #2 to 'Observable.elementAt' (number expected, got"..type(fn)..")") and
        Assert(index >= 1, "'Observable.elementAt': index out of bounds (index: "..index..")")
    then 
        local maybe = new()
        maybe._source = self
        maybe._targetIndex = index
        maybe.subscribe = subscribeActual
        return maybe
    end
end