export GenericReplica

const GenericReplica <- class GenericReplica[attached obj : ClonableType, primary: ReplicaType]
  var home : Node

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end read

  export operation write[newObj : ClonableType]
    % delegate to primary
    %notify
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end write

  export operation notify
    % noop
  end notify

  export operation ping
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end ping

  export operation dump
    (locate self)$stdout.putstring["\nGeneric replica at " || (locate self)$name || "\n"]
  end dump

end GenericReplica
