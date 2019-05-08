export GenericReplica

const GenericReplica <- class GenericReplica[replicatedObject : ClonableType, primary: ReplicaType, framework: PCRType]
  var home : Node

  export operation read -> [ret : ClonableType]
    ret <- replicatedObject
    unavailable
      (locate self)$stdout.putstring["Unavailable generic replica\n"]
    end unavailable
  end read

  export operation write[newReplicatedObject : ClonableType]
    (locate self)$stdout.putstring["Writing on a generic replica\n"]
    const primaryReplica <- framework.getPrimaryReplica[(typeof replicatedObject)$name]
    primaryReplica.write[newReplicatedObject]
    unavailable
      (locate self)$stdout.putstring["Unavailable generic replica\n"]
    end unavailable
  end write

  % called by a primary replica
  export operation notify
    (locate self)$stdout.putstring["Replica at " || (locate self)$name || " notified\n" ]
    const primaryReplica <- framework.getPrimaryReplica[(typeof replicatedObject)$name]
    replicatedObject <- primaryReplica.read
    unavailable
      (locate self)$stdout.putstring["Unavailable generic replica\n"]
      % remove from framework
    end unavailable
  end notify

  export operation ping
     % noop
  end ping

  export operation dump
    (locate self)$stdout.putstring["\nGeneric replica at " || (locate self)$name || "\n"]
  end dump

end GenericReplica
