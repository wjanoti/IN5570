export NodeEventHandler

% this object is responsible for monitoring node events on the framework node.
const NodeEventHandler <- class NodeEventHandler[framework: PCRType]
  const here <- locate self
  export operation nodeUp[ n : Node, t : Time ]
    here$stdout.putstring["Node connected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
    % call framework and tries redistribute replicas on the remaining nodes.
    framework.redistributeReplicasNodeUp
  end nodeUp

  export operation nodeDown[ n : Node, t : Time ]
    here$stdout.putstring["Node disconnected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
    % call framework and tries redistribute replicas on the remaining nodes.
    framework.redistributeReplicasNodeDown
  end nodeDown
end NodeEventHandler
