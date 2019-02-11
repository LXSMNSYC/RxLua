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

local class = require "Rx.utils.meta.class"

local Disposable = require "Rx.disposable"
local Observer = require "Rx.observer"

local Action = require "Rx.functions.action"
local Consumer = require "Rx.functions.consumer"
local Predicate = require "Rx.functions.predicate"

local BadArgument = require "Rx.utils.badArgument"
local ProtocolViolation = require "Rx.utils.protocolViolation"
local CompositeException = require "Rx.utils.compositeException"

local DISPOSED = require "Rx.disposable.helper.disposed"

local validate = require "Rx.disposable.helper.validate"

return class ("DisposableLambdaObserver", Disposable, Observer){
    new = function (self, actual, onSubscribe, onDispose)
        BadArgument(Observer.instanceof(actual, Observer), 1, "Observer")
        BadArgument(Consumer.instanceof(onSubscribe, Consumer), 2, "Consumer")
        BadArgument(Action.instanceof(onDispose, Action), 2, "Action")

        self.downstream = actual 
        self._onSubscribe = onSubscribe
        self._onDispose = onDispose
    end,

    onSubscribe = function (self, disposable) 
        local try, catch = pcall(function ()
            self._onSubscribe:accept(disposable)
        end)

        if(not catch) then 
            disposable:dispose()
            self.upstream = DISPOSED
            EMPTY.error(self.downstream, catch)
            return
        end 

        if(validate(self.upstream, disposable)) then 
            self.upstream = disposable
            self.downstream:onSubscribe(disposable)
        end 
    end,

    onNext = function (self, x)
        self.downstream:onNext(x)
    end, 

    onError = function (self, t)
        if(self.upstream ~= DISPOSED) then 
            self.upstream = DISPOSED
            self.downstream:onError(t)
        else 
            error(t)
        end
    end,

    onComplete = function (self) 
        if(self.upstream ~= DISPOSED) then 
            self.upstream = DISPOSED
            self.downstream:onComplete(t)
        end
    end,

    isDisposed = function(self)
        return self.upstream:isDisposed()
    end,

    dispose = function(self)
        local d = self.upstream 

        if(d ~= DISPOSED) then 
            self.upstream = DISPOSED
            local try, catch = pcall(function ()
                self._onDispose:run()
            end)

            if(try) then 
                d:dispose()
            else 
                error(catch)
            end 
        end 
    end 
}