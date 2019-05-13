export GenericReplica

const GenericReplica <- class GenericReplica (PrimaryReplica) [primary: ReplicaType]

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      home$stdout.putstring["Unavailable generic replica\n"]
    end unavailable
  end read

  % delegates the write operation to its primary replica.
  export operation write[newobj : ClonableType]
    home$stdout.putstring["Writing on a generic replica\n"]
    const primaryReplica <- framework.getPrimaryReplica[(typeof obj)$name]
    primaryReplica.write[newobj]
    unavailable
      home$stdout.putstring["Unavailable generic replica\n"]
    end unavailable
  end write

  % called by a primary replica when a write happens on them
  export operation notify
    home$stdout.putstring["Replica at " || home$name || " notified\n" ]
    const primaryReplica <- framework.getPrimaryReplica[(typeof obj)$name]
    obj <- primaryReplica.read
    unavailable
      home$stdout.putstring["Unavailable generic replica\n"]
    end unavailable
  end notify

end GenericReplica
