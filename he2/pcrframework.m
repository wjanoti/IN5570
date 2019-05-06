export PCRFramework

const PCRFramework <- object PCRFramework
	const here <- (locate self)
  var replicas : Array.of[ReplicaType] <- Array.of[ReplicaType].empty
	var replicasDirectory : Directory <- Directory.create

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
		loop
			exit when (here.getActiveNodes.upperbound + 1) >= numberRequiredReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over (" || numberRequiredReplicas.asString  || " required), waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

    const objectTypeName <- (typeof X)$name
    % if we already have replicas for objects of this type.
    if replicasDirectory.lookup[objectTypeName] !== nil then
       here$stdout.putstring["Already have " || ((view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]).upperbound + 1).asString || " replicas for: " || objectTypeName || "\n"]
       replicas <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
	  else
			 here$stdout.putstring["First time replicating: " || objectTypeName || "\n"]
		   replicasDirectory.insert[objectTypeName, Array.of[ReplicaType].empty]
    end if

		for i : Integer <- 0 while i < numberRequiredReplicas by i <- i + 1
			var clone : ClonableType <- X.clone
      % add the primary replica in the first position of the array.
      if replicas.upperbound < 0 then
        const primary <- PrimaryReplica.create[clone, numberRequiredReplicas]
        here$stdout.putstring["Created primary replica\n"]
        replicas.addUpper[primary]
        fix primary at here$activenodes[i]$thenode
        here$stdout.putstring["Fixed primary replica at " || here$activenodes[i]$thenode$name || "\n"]
      else
        const generic <- GenericReplica.create[clone, replicas[0]]
        here$stdout.putstring["Created generic replica\n"]
        replicas.addUpper[generic]
        fix generic at here$activenodes[i]$thenode
        here$stdout.putstring["Fixed generic replica at " || here$activenodes[i]$thenode$name || "\n"]
      end if
		end for
		replicasDirectory.insert[objectTypeName, replicas]
    replicaSet <- replicas
	end replicate

	export operation dump
		const replicaTypes <- replicasDirectory.list
		for i : Integer <- 0 while i <= replicaTypes.upperbound by i <- i + 1
		   const objReplicas <- view replicasDirectory.lookup[replicaTypes[i]] as Array.of[ReplicaType]
			 for j : Integer <- 0 while j <= objReplicas.upperbound by j <- j + 1
			 		  objReplicas[j].dump
			 end for
		end for
	end dump

	initially
		here.setNodeEventHandler[NodeEventHandler]
	end initially

end PCRFramework
