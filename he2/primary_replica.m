export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[attached obj : ClonableType, numberRequiredReplicas: Integer]
  var nodes : Array.of[Node] <- Array.of[Node].empty
  var home : Node

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end read

  export operation write[newObj : ClonableType]
    obj <- newObj
    %notify
    %must make sure that all replicas update their status before any new updates to the primary copy should happen.
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end write

  export operation ping
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end ping

  export operation notify
    % spawn new objects?
    %(locate self)$stdout.putstring["Primary has notified all replicas. " || "\n"]
  end notify

  export operation dump
    (locate self)$stdout.putstring["\nPrimary replica at " || (locate self)$name || "\n"]
  end dump
end PrimaryReplica
