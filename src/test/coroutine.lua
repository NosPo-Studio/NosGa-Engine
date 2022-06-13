local co = coroutine.create(function(t1) 
    print("CR")
    print(t1)
end)

coroutine.resume(co, 12)