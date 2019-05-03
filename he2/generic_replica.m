export GenericReplica

const GenericReplica <- class GenericReplica[attached obj : ClonableType, primary: ReplicaType]
  var home : Node <- locate self
  
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

  export operation registerNode[newUsedNode : Node]
    % noop
  end registerNode

  export operation registerReplica[newReplica : ReplicaType]
    % noop
  end registerReplica

  export operation notify
    % noop
  end notify

  export operation ping
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end ping

  export operation dump
      obj.dump
  end dump

  initially
    primary.registerReplica[self]
  end initially
end GenericReplica
