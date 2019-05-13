const test <- object test
    initially
      % create a name server object
      const ns <- NameServer.create
      ns.insert["A", 1]
      ns.insert["B", 2]

      % create 2 replicas
      var replicas : Array.of[ReplicaType] <- PCRFramework.replicate[ns, 2]

      % print replicas data
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
          stdout.PutString["\nNameserver replica at " || (locate replicas[i])$name || "\n"]
         (view replicas[i].read as NameServer).dump
      end for

      % update the original object
      ns.insert["C", 3]

      % update a replica, in this case a generic replica, which will delegate the write to its primary.
      replicas[1].write[ns]

      % print replicas data again to verify everyone's updated
      for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
          stdout.PutString["\nNameserver replica at " || (locate replicas[i])$name || "\n"]
         (view replicas[i].read as NameServer).dump
      end for

      PCRFramework.dump
    end initially
end test
