export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[obj : ClonableType, numberRequiredReplicas: Integer, framework: PCRType]

  var home : Node <- locate self

  % number of generic replicas left to notify after a write
  var pendingUpdates : Integer <- 0

  % gets the object wrapped in this replica
  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      home$stdout.putstring["Primary replica unavailable\n"]
    end unavailable
  end read

  % updates the object wrapped in this replica and notifies generic replicas.
  export operation write[newObj : ClonableType]
    if pendingUpdates > 0 then
      loop
        home$stdout.putstring[pendingUpdates.asString || " updates pending...\n"]
        exit when pendingUpdates == 0
      end loop
    end if

    home$stdout.putstring["Writing on a primary replica\n"]
    obj <- newObj

    self.notify

    unavailable
      home$stdout.putstring["Primary replica unavailable\n"]
    end unavailable
  end write

  export operation ping
    % noop
  end ping

  % notify generic replicas to update
  export operation notify
    const replicas <- framework.getReplicas[(typeof obj)$name]
    pendingUpdates <- replicas.upperbound
    home$stdout.putstring["Notifying " || (replicas.upperbound.asString) || " replicas \n"]
    % starts from 1 because the primary replica is always in the first position (0) in the replica array.
    for i : Integer <- 1 while i <= replicas.upperbound by i <- i + 1
      replicas[i].notify
      pendingUpdates <- pendingUpdates - 1
      home$stdout.putstring["Pending notifications " || (pendingUpdates.asString) || "\n"]
    end for
  end notify

  export operation getNumberRequiredReplicas -> [ ret : Integer ]
    ret <- numberRequiredReplicas
  end getNumberRequiredReplicas

  % debug
  export operation dump
    home$stdout.putstring["\n" || (typeof self)$name || " at " || home$name || "\n"]
  end dump

end PrimaryReplica
