export PCRFramework

const PCRFramework <- object PCRFramework
	const here <- (locate self)
  var replicas : Array.of[ReplicaType]
	var replicasDirectory : Directory <- Directory.create

	export operation replicate[X : ClonableType, numberRequiredReplicas: Integer] -> [replicaSet : Array.of[ReplicaType]]
		const objectTypeName <- (typeof X)$name
		loop
			exit when here.getActiveNodes.upperbound >= numberRequiredReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over (" || numberRequiredReplicas.asString  || " required), waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

    % if we already have replicas for objects of this type.
    if replicasDirectory.lookup[objectTypeName] !== nil then
       here$stdout.putstring["\nAlready have " || ((view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]).upperbound + 1).asString || " replicas for: " || objectTypeName || "\n"]
       replicas <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
	  else
			 here$stdout.putstring["\nFirst time replicating: " || objectTypeName || "\n"]
			 replicas <- Array.of[ReplicaType].empty
		   replicasDirectory.insert[objectTypeName, replicas]
    end if

		for i : Integer <- 0 while i < numberRequiredReplicas by i <- i + 1
			var clone : ClonableType <- X.clone
			var replica : ReplicaType
      if replicas.upperbound < 0 then
				% add the primary replica in the first position of the array
        replica <- PrimaryReplica.create[clone, numberRequiredReplicas, PCRFramework]
        here$stdout.putstring["\nCreated primary replica\n"]
      else
        replica <- GenericReplica.create[clone, replicas[0], PCRFramework]
        here$stdout.putstring["\nCreated generic replica\n"]
      end if

			% try to fix the replica in an available node that doesn't already have an replica of that object
			% this might not replicate the number of replicas requested due to the requirements, but will try on each available node.
			for j : Integer <- 0 while j <= here$activenodes.upperbound by j <- j + 1
			  here$stdout.putstring["\nTrying to move replica to: " || here$activenodes[j]$thenode$name || "\n"]
				% don't fix replicas on the framework node.
			  if here$activenodes[j]$thenode !== here then
					if self.nodeHasReplica[here$activenodes[j]$thenode, objectTypeName] == True then
						here$stdout.putstring["\nThere is already a replica of type " || objectTypeName || " in this node: " || here$activenodes[j]$thenode$name || "\n"]
					else
						replicas.addUpper[replica]
						replicasDirectory.insert[objectTypeName, replicas]
						fix replica at here$activenodes[j]$thenode
						here$stdout.putstring["\nFixed replica at " || here$activenodes[j]$thenode$name || "\n"]
						exit
					end if
				end if
			end for

		end for
		replicasDirectory.insert[objectTypeName, replicas]
    replicaSet <- replicas
	end replicate

  export operation getGenericReplicas[objectTypeName : String] -> [ret : Array.of[ReplicaType]]
	   ret <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
	end getGenericReplicas

	export operation getPrimaryReplica[objectTypeName : String] -> [ret : ReplicaType]
		 const replicaList <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
		 ret <- replicaList[0]
	end getPrimaryReplica

  % checks if a given node already has a replica of a given object
  operation nodeHasReplica [currentNode: Node, objectTypeName: String] -> [ret : Boolean]
		const replicaList <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
		for i : Integer <- 0 while i <= replicaList.upperbound by i <- i + 1
			 if currentNode == (locate replicaList[i]) then
			 		ret <- True
					return
       end if
		end for
		ret <- False
	end nodeHasReplica

	% rearrange replicas when a node goes down
  export operation redistributeReplicas
	here$stdout.putstring["Redistributing replicas... \n"]

		const replicaTypes <- replicasDirectory.list
		for i : Integer <- 0 while i <= replicaTypes.upperbound by i <- i + 1
			const replicaList <- view replicasDirectory.lookup[replicaTypes[i]] as Array.of[ReplicaType]
		 	for j : Integer <- 0 while j <= replicaList.upperbound by j <- j + 1
				begin
				  replicaList[j].ping
					unavailable
						 if j == 0 then
						 	here$stdout.putstring["\nA primary replica has been lost\n"]
						 end if
					end unavailable
				end
			end for
		end for
	end redistributeReplicas

	export operation dump
		const replicaTypes <- replicasDirectory.list
		for i : Integer <- 0 while i <= replicaTypes.upperbound by i <- i + 1
		   const objReplicas <- view replicasDirectory.lookup[replicaTypes[i]] as Array.of[ReplicaType]
			 here$stdout.putstring["\nFramework has " || (objReplicas.upperbound + 1).asString || " replicas of " || (typeof objReplicas[i].read)$name || "\n"]
			 for j : Integer <- 0 while j <= objReplicas.upperbound by j <- j + 1
			 		here$stdout.putstring["\n - " || (typeof objReplicas[j])$name || " @ " || (locate objReplicas[j])$name || "\n"]
			 end for
		end for
	end dump

	initially
		here.setNodeEventHandler[NodeEventHandler.create[self]]
	end initially

end PCRFramework
