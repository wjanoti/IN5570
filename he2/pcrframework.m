export PCRFramework

const TestObject <- class TestObject [data : String]
  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation dump
    (locate self)$stdout.putstring["DATA: " || data || " - LOCATION :" || (locate self)$name || "\n"]
  end dump
end TestObject

%================================

const PCRFramework <- object PCRFramework
	const here <- (locate self)
  const replicasDirectory <- Directory.create
  var replicas : Array.of[Replica] <- Array.of[Replica].empty

	% event handler for disconnecting/connecting nodes.
	const NodeEventHandler <- object NodeEventHandler
		export operation nodeUp[ n : Node, t : Time ]
			here$stdout.putstring["Node connected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
		end nodeUp

		export operation nodeDown[ n : Node, t : Time ]
			here$stdout.putstring["Node disconnected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
			% redistribute replicas when a node goes down
			here$stdout.putstring["Redistributing replicas... \n"]
		end nodeDown
	end NodeEventHandler

	export operation replicate[X : ClonableType, numberRequiredReplicas: Integer] -> [Array.of[Replica]]
		here$stdout.putstring["Trying to replicate over " || numberRequiredReplicas.asString || " nodes\n"]
		loop
			exit when (here.getActiveNodes.upperbound + 1) >= numberRequiredReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over, waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

    const objectTypeName <- (typeof X)$name
    var primaryReplica : Replica <- nil
    % if we already have replicas for objects of this type.
    if replicasDirectory.lookup[objectTypeName] !== nil then
       here$stdout.putstring["Already have replicas for: " || objectTypeName || "\n"]
       replicas <- view replicasDirectory.lookup[objectTypeName] as Array.of[Replica]
       primaryReplica <- replicas[0]
    end if

		for i : Integer <- 0 while i <= here.getActiveNodes.upperbound by i <- i + 1
			var clone : ClonableType <- X.clone
      if replicas.upperbound < 0 then
        replicas.addUpper[Replica.create[clone, numberRequiredReplicas, True]]
        replicas[0].addUsedNode[here$activenodes[i]$thenode]
        fix replicas[0] at here$activenodes[i]$thenode
        replicas[0].dump
      else
        replicas.addUpper[Replica.create[clone, numberRequiredReplicas, False]]
        fix replicas[replicas.upperbound] at here$activenodes[i]$thenode
      end if
		end for

	end replicate


	initially
		here.setNodeEventHandler[NodeEventHandler]
	end initially

end PCRFramework
