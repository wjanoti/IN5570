export PCRFramework


const TestObject <- class TestObject [data : String]

  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation dump
    (locate self)$stdout.putstring["DATA: " || data || " - LOCATION :" || (locate self)$name || "\n"]
  end dump
end TestObject

const PCRFramework <- object PCRFramework
	const here <- (locate self)
	var replicas : Array.of[ClonableType] <- Array.of[ClonableType].empty

	% event handler for disconnecting/connecting nodes.
	const NodeEventHandler <- object NodeEventHandler
		export operation nodeUp[ n : Node, t : Time ]
			here$stdout.putstring["Node connected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
		end nodeUp

		export operation nodeDown[ n : Node, t : Time ]
			here$stdout.putstring["Node disconnected. " || (here.getActiveNodes.upperbound + 1).asString || " node(s) running.\n"]
			% redistribute replicas whena node goes down
			here$stdout.putstring["Redistributing replicas... \n"]
		end nodeDown
	end NodeEventHandler

	export operation replicate[ X : ClonableType, numberOfReplicas: Integer ]
		here$stdout.putstring["Trying to replicate over " || numberOfReplicas.asString || " nodes\n"]
		loop
			exit when (here.getActiveNodes.upperbound + 1) >= numberOfReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over, waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

		for i : Integer <- 0 while i <= here.getActiveNodes.upperbound by i <- i + 1
			var clone : ClonableType <- X	.clone
			replicas.addUpper[clone]
			fix replicas[replicas.upperbound] at here.getActiveNodes.getElement[i].getTheNode
		end for

		for i : Integer <- 0 while i <= replicas.upperbound by i <- i + 1
			(view replicas[i] as TestObject).dump
		end for
	end replicate

	export operation replicas -> [ Array.of[ReplicaType] ]
	end replicas

	initially
		here.setNodeEventHandler[NodeEventHandler]
	end initially

end PCRFramework
