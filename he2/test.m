const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[Replica] <- PCRFramework.replicate[testObj, 2]
    end initially
end test
