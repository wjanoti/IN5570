const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 2]
      (locate self)$stdout.putstring[(replicas[0] == replicas[0]).asString]
      PCRFramework.dump
    end initially
end test
