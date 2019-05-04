export PCRFramework

const PCRFramework <- object PCRFramework
	const here <- (locate self)
  var replicas : Array.of[ReplicaType] <- Array.of[ReplicaType].empty

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

	export operation replicate[X : ClonableType, numberRequiredReplicas: Integer] -> [replicaSet : Array.of[ReplicaType]]
		here$stdout.putstring["Trying to replicate over " || numberRequiredReplicas.asString || " nodes\n"]
		loop
			exit when (here.getActiveNodes.upperbound + 1) >= numberRequiredReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over, waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

    %const objectTypeName <- (typeof X)$name
    % if we already have replicas for objects of this type.
    %if replicasDirectory.lookup[objectTypeName] !== nil then
    %   here$stdout.putstring["Already have replicas for: " || objectTypeName || "\n"]
    %   replicas <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
    %end if

		for i : Integer <- 0 while i <= here.getActiveNodes.upperbound by i <- i + 1
			var clone : ClonableType <- X.clone
      % add the primary replica in the first position of the array.
      if replicas.upperbound < 0 then
        const primary <- PrimaryReplica.create[clone, numberRequiredReplicas]
        here$stdout.putstring["Created primary replica\n"]
        primary.registerNode[here$activenodes[i]$thenode]
        replicas.addUpper[primary]
        fix primary at here$activenodes[i]$thenode
        here$stdout.putstring["Fixed primary replica at " || here$activenodes[i]$thenode$name || "\n"]
      else
        const secondary <- GenericReplica.create[clone, replicas[0]]
        here$stdout.putstring["Created secondary replica\n"]
        replicas.addUpper[secondary]
        fix secondary at here$activenodes[i]$thenode
        replicas[0].registerNode[(locate secondary)]
        here$stdout.putstring["Fixed secondary replica at " || here$activenodes[i]$thenode$name || "\n"]
      end if
		end for
    replicaSet <- replicas
	end replicate

	initially
		here.setNodeEventHandler[NodeEventHandler]
	end initially

end PCRFramework
