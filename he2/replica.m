export Replica

const Replica <- class Replica[obj : ClonableType, numberRequiredReplicas: Integer, isPrimary: Boolean]
  attached var replicas : Array.of[Replica] <- Array.of[Replica].empty
  attached var usedNodes : Array.of[Node] <- Array.of[Node].empty
  attached var home : Node <- locate self

  export operation read -> [ret : ClonableType]
    ret <- obj
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end read

  export operation write[newObj : ClonableType]
    obj <- newObj
    %notify
    unavailable
      home$stdout.putstring["Unavailable primary replica\n"]
    end unavailable
  end write

  export operation registerNode[newUsedNode : Node]
    usedNodes.addUpper[newUsedNode]
  end addUsedNode

  export operation registerReplica[newReplica : Replica]
    replicas.addUpper[newReplica]
  end registerReplica

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
      home$stdout.putstring["REPLICA INFO: \n - IS PRIMARY? " || isPrimary.asString ||
                            " \n - NUMBER OF SECONDARY REPLICAS: " || (replicas.upperbound + 1).asstring
                            ]
      obj.dump
  end dump
end Replica
