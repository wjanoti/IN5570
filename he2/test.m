const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 3]
      stdout.putstring["Created " || (replicas.upperbound + 1).asString || " replicas"]
      replicas[0].dump
    end initially
end test
