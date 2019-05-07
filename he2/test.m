const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 2]
      var replicas2 : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 1]
      PCRFramework.dump
    end initially
end test
