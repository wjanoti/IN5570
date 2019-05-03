export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[obj : ClonableType, numberRequiredReplicas: Integer]
  var replicas : Array.of[ReplicaType] <- Array.of[ReplicaType].empty
  var nodes : Array.of[Node] <- Array.of[Node].empty
  var home : Node <- locate self

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
    nodes.addUpper[newUsedNode]
  end registerNode

  export operation registerReplica[newReplica : ReplicaType]
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
      var nodesNames : String <- ""
      for i : Integer <- 0 while i <= nodes.upperbound by i <- i + 1
        nodesNames <- nodesNames || nodes[i]$name || " - "
      end for
      home$stdout.putstring["REPLICA INFO: \n - TYPE " || (typeof self)$name ||
                            " \n - NUMBER OF SECONDARY REPLICAS: " || (replicas.upperbound + 1).asstring ||
                            " \n - NUMBER OF NODES:" || (nodes.upperbound + 1).asString ||
                            " \n - NODES: " || nodesNames
                            ]
      obj.dump
  end dump
end PrimaryReplica
