export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[obj : ClonableType, numberRequiredReplicas: Integer, framework: PCRType]

  var pendingUpdates : Integer <- 0

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      (locate self)$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end read

  export operation write[newObj : ClonableType]
    if pendingUpdates > 0 then
      loop
        (locate self)$stdout.putstring[pendingUpdates.asString || " updates pending...\n"]
        exit when pendingUpdates == 0
      end loop
    end if
    (locate self)$stdout.putstring["Writing on a primary replica\n"]
    obj <- newObj
    const replicas <- framework.getGenericReplicas[(typeof newObj)$name]
    pendingUpdates <- replicas.upperbound
    (locate self)$stdout.putstring["Notifying " || (replicas.upperbound.asString) || " replicas \n"]
    for i : Integer <- 1 while i <= replicas.upperbound by i <- i + 1
       replicas[i].notify
       pendingUpdates <- pendingUpdates - 1
       (locate self)$stdout.putstring["Pending notifications " || (pendingUpdates.asString) || "\n"]
    end for

    %must make sure that all replicas update their status before any new updates to the primary copy should happen.
    unavailable
      (locate self)$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end write

  export operation ping
    unavailable
      (locate self)$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end ping

  export operation notify
    % noop
  end notify

  export operation dump
    (locate self)$stdout.putstring["\nPrimary replica at " || (locate self)$name || "\n"]
  end dump

end PrimaryReplica
