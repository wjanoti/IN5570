export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[obj : ClonableType, numberRequiredReplicas: Integer, framework: PCRType]

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      (locate self)$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end read

  export operation write[newObj : ClonableType]
    (locate self)$stdout.putstring["Writing on a primary replica\n"]
    obj <- newObj
    const replicas <- framework.getGenericReplicas[(typeof newObj)$name]
    (locate self)$stdout.putstring["Notifying " || (replicas.upperbound.asString) || " replicas \n"]
    for i : Integer <- 1 while i <= replicas.upperbound by i <- i + 1
       replicas[i].notify
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
    %(locate self)$stdout.putstring["Primary has notified all replicas. " || "\n"]
  end notify

  export operation dump
    (locate self)$stdout.putstring["\nPrimary replica at " || (locate self)$name || "\n"]
  end dump

end PrimaryReplica
