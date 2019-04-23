export PCRFramework

const PCRFramework <- object PCRFramework
	const here <- (locate self)
	var availableNodes : NodeList <- here.getActiveNodes
	var replicas : Array.of[ReplicaType]

	const NodeEventHandler <- object NodeEventHandler
		export operation nodeUp[ n : Node, t : Time ]
			here$stdout.putstring["Node connected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
		end nodeUp
		export operation nodeDown[ n : Node, t : Time ]
			here$stdout.putstring["Node disconnected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
		end nodeDown
	end NodeEventHandler

	export operation replicate [ primaryObject : PrimaryReplicaType, numberOfReplicas: Integer ]
		here$stdout.putstring["Trying to replicate over " || numberOfReplicas.asString || " nodes\n"]
		loop
			exit when (here.getActiveNodes.upperbound + 1) >= numberOfReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over, waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop
	end replicate

	export operation replicas -> [ Array.of[ReplicaType] ]
	end replicas

	export operation getAvailableNodes -> [ nodes : NodeList ]
		nodes <- here.getActiveNodes
	end getAvailableNodes

	initially
		here.setNodeEventHandler[NodeEventHandler]
		unavailable
			here$stdout.putstring["Framework unavailable.\n"]
		end unavailable
	end initially

end PCRFramework
