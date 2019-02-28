local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext("olleh")
    e:onNext("dlrow")
    e:onComplete()
end)
:elementAtOrDefault(5, "no items")
:subscribe{
    onSuccess = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}