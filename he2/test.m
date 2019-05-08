const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 2]
      const testObjReplica <- replicas[0].read
      testObjReplica.setData["Changed"]
      replicas[1].write[testObjReplica]
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
         replicas[i].read.getData
      end for
      PCRFramework.dump
    end initially
end test
