const test <- object test
    initially
      % create a time server object
      const ts <- TimeServer.create

      % create 2 replicas
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[ts, 2]

      % print replicas data
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
          stdout.PutString["\TimeServer replica at " || (locate replicas[i])$name || "\n"]
          stdout.PutString[(view replicas[i].read as TimeServer).getTime.asstring || "\n"]
      end for

      replicas[1].write[ts]

      % print replicas data
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
          stdout.PutString["\TimeServer replica at " || (locate replicas[i])$name || "\n"]
          stdout.PutString[(view replicas[i].read as TimeServer).getTime.asstring || "\n"]
      end for

      PCRFramework.dump
    end initially
end test
