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

local SingleObserver = require "RxLua.observer.single"
local Disposable = require "RxLua.disposable"

local DISPOSED = require "RxLua.disposable.helper.disposed"
local validate = require "RxLua.disposable.helper.validate"

local DetachSingleObserver = class("DetachSingleObserver", SingleObserver, Disposable){
    new = function (self, downstream)
        self._downstream = downstream
    end, 

    dispose = function (self)
        self._downstream = nil 
        self._upstream:dispose()
        self._upstream = DISPOSED
    end,
    isDisposed = function ()
        return self._upstream:isDisposed()
    end,

    onSubscribe = function (self, d)
        if(validate(self._upstream, d)) then 
            self._upstream = d

            self._downstream:onSubscribe(d)
        end 
    end,

    onSuccess = function (self, x)
        self._upstream = DISPOSED

        local downstream = self._downstream 
        if(downstream) then 
            self._downstream = nil 
            downstream:onSuccess(x)
        end 
    end ,

    onSuccess = function (self, x)
        self._upstream = DISPOSED

        local downstream = self._downstream 
        if(downstream) then 
            self._downstream = nil 
            downstream:onError(x)
        end 
    end 

}

local Single 
local SingleDetach 


local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleDetach = class("SingleDetach", Single){
            new = function (self, source)
                self._source = source 
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(DetachSingleObserver(observer))
            end, 
        }
    end 
end

return function (self)
    asyncLoad()
    return SingleDetach(self)
end 