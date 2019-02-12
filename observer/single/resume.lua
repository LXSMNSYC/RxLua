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

local BadArgument = require "RxLua.utils.badArgument"

local replace = require "RxLua.disposable.helper.replace"

return class ("ResumeSingleObserver", SingleObserver){
    new = function (self, disposable, observer)
        BadArgument(Disposable.instanceof(disposable, Disposable), 1, "Disposable")
        BadArgument(SingleObserver.instanceof(observer, SingleObserver), 2, "SingleObserver")
        
        self._parent = disposable
        self._downstream = observer
    end,

    onSubscribe = function (self, disposable) 
        replace(self._parent, disposable)
    end,
    
    onSuccess = function (self, x)
        self._downstream:onSuccess(x)
    end,
    
    onError = function (self, t)
        self._downstream:onError(t)
    end
}