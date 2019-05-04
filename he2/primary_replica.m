export PrimaryReplica

const PrimaryReplica <- class PrimaryReplica[attached obj : ClonableType, numberRequiredReplicas: Integer]
  var secondaryReplicas : Array.of[ReplicaType] <- Array.of[ReplicaType].empty
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
    secondaryReplicas.addUpper[newReplica]
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
     for i : Integer <- 0 while i <= secondaryReplicas.upperbound by i <- i + 1
        secondaryReplicas[i].dump
     end for
      %var nodesNames : String <- ""
      %for i : Integer <- 0 while i <= nodes.upperbound by i <- i + 1
    %    nodesNames <- nodesNames || nodes[i]$name || " - "
    %  end for
    %  home$stdout.putstring["REPLICA INFO: \n - TYPE " || (typeof self)$name ||
    %                        " \n - NUMBER OF SECONDARY REPLICAS: " || (secondaryReplicas.upperbound + 1).asstring ||
    %                        " \n - NUMBER OF NODES:" || (nodes.upperbound + 1).asString ||
    %                        " \n - NODES: " || nodesNames || "\n"
    %                        ]
     %obj.dump
  end dump
end PrimaryReplica
