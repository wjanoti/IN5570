export NodeEventHandler

const NodeEventHandler <- class NodeEventHandler[framework: PCRType]
  const here <- locate self
  export operation nodeUp[ n : Node, t : Time ]
    % recheck replicas policies and see if we can fulfill some
    here$stdout.putstring["Node connected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
  end nodeUp

  export operation nodeDown[ n : Node, t : Time ]
    here$stdout.putstring["Node disconnected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
    % redistribute replicas when a node goes down
    % this is not working for some reason
    framework.redistributeReplicas
  end nodeDown
end NodeEventHandler
