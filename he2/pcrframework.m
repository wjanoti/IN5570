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

	  replicas <- Array.of[ReplicaType].empty
    replicasDirectory.insert[objectTypeName, replicas]

    % clone and fix replicas on nodes, the first position on the array of replicas is ALWAYS the primary replica.
		for i : Integer <- 0 while i < numberRequiredReplicas by i <- i + 1
			var clone : ClonableType <- X.clone
			var replica : ReplicaType
      if replicas.upperbound < 0 then
				% add the primary replica in the first position of the array
        replica <- PrimaryReplica.create[clone, numberRequiredReplicas, PCRFramework]
        here$stdout.putstring["\nCreated primary replica nrr " || replica.getNumberRequiredReplicas.asString || "\n"]
      else
        replica <- GenericReplica.create[clone, replicas[0], PCRFramework]
        here$stdout.putstring["\nCreated generic replica nrr " || replica.getNumberRequiredReplicas.asString || "\n"]
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
      const replicaObjectType <- replicaTypes[i]
		  var replicaList : Array.of[ReplicaType] <- view replicasDirectory.lookup[replicaObjectType] as Array.of[ReplicaType]
		 	for j : Integer <- 0 while j <= replicaList.upperbound by j <- j + 1
				begin
				  replicaList[j].ping
					unavailable
             % remove lost replica from directory
             self.removeReplica[replicaObjectType, j]
             replicaList <- view replicasDirectory.lookup[replicaObjectType] as Array.of[ReplicaType]
						 if j == 0 then
               here$stdout.putstring["\nA primary replica has been lost, TODO: elect a new primary replica\n"]
             else
               const newGenericReplica <- GenericReplica.create[replicaList[0].read, replicaList[0], self]
               for k : Integer <- 0 while k <= here$activenodes.upperbound by k <- k + 1
                 if here$activenodes[k]$thenode !== here then
                   if self.nodeHasReplica[here$activenodes[k]$thenode, replicaObjectType] == True then
                     here$stdout.putstring["\nThere is already a replica of type " || replicaObjectType || " in this node: " || here$activenodes[k]$thenode$name || "\n"]
                   else
                     replicaList.addUpper[newGenericReplica]
                     replicasDirectory.insert[replicaObjectType, replicaList]
                     fix newGenericReplica at here$activenodes[k]$thenode
                     here$stdout.putstring["\nFixed replica at " || here$activenodes[k]$thenode$name || "\n"]
                     exit
                   end if
                 end if
                end for
						 end if
					end unavailable
				end
			end for
		end for
    self.dump
	end redistributeReplicas

  operation removeReplica[type: String, index: Integer]
    const tmpReplicaList <- Array.of[ReplicaType].empty
    const replicaList <- view replicasDirectory.lookup[type] as Array.of[ReplicaType]
    % primary
    tmpReplicaList.addUpper[replicaList[0]]
    for i : Integer <- 1 while i <= replicaList.upperbound by i <- i + 1
       if i != index then
        tmpReplicaList.addUpper[replicaList[i]]
       end if
    end for
    replicasDirectory.insert[type, tmpReplicaList]
  end removeReplica

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
