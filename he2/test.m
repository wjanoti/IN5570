const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 2]
      for i : Integer <- 0  while i <= replicas.upperbound by i <- i + 1
          replicas[i].dump
      end for
    end initially
end test
