const test <- object test
    initially
      const testObj <- TestObject.create["BACON"]
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[testObj, 3]
      stdout.putstring[replicas.upperbound.asString || "\n"]
      const testObjReplica <- replicas[0].read
      testObjReplica.setData["Changed"]
      replicas[0].write[testObjReplica]
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
         replicas[i].read.getData
      end for
    end initially
end test
