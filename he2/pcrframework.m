export PCRFramework

const PCRFramework <- object PCRFramework

	const here <- (locate self)
  var replicas : Array.of[ReplicaType]
	var replicasDirectory : Directory <- Directory.create

  % main functionality of the framework, replicates and fix replicas in nodes.
	export operation replicate[X : ClonableType, numberRequiredReplicas: Integer] -> [replicaSet : Array.of[ReplicaType]]
		const objectTypeName <- (typeof X)$name
		loop
			exit when here.getActiveNodes.upperbound >= numberRequiredReplicas
			begin
				here$stdout.putstring["Not enough nodes to replicate the object over (" || (numberRequiredReplicas + 1).asString  || " required), waiting for more nodes to connect...\n"]
				here.delay[Time.create[3, 0]]
			end
		end loop

    % initialize the directory with an empty array
	  replicas <- Array.of[ReplicaType].empty
    replicasDirectory.insert[objectTypeName, replicas]

    % clone and fix replicas on nodes, the first position on the array of replicas is ALWAYS the primary replica.
		for i : Integer <- 0 while i < numberRequiredReplicas by i <- i + 1
			var clone : ClonableType <- X.clone
			var replica : ReplicaType

      if replicas.upperbound < 0 then
				% add the primary replica in the first position of the array
        replica <- PrimaryReplica.create[clone, numberRequiredReplicas, PCRFramework]
      else
        replica <- GenericReplica.create[clone, numberRequiredReplicas, PCRFramework, replicas[0]]
      end if

			% try to fix the replica at an available node that doesn't already have an replica of that object
			for j : Integer <- 0 while j <= here$activenodes.upperbound by j <- j + 1
				% don't fix replicas on the framework node.
			  if here$activenodes[j]$thenode !== here then
          % checks if we DON'T already have a replica of a given type on the node
					if self.nodeHasReplica[here$activenodes[j]$thenode, objectTypeName] == False then
						replicas.addUpper[replica]
						replicasDirectory.insert[objectTypeName, replicas]
						fix replica at here$activenodes[j]$thenode
						exit
					end if
				end if
			end for
		end for
    % update framework's replica directory
		replicasDirectory.insert[objectTypeName, replicas]
    replicaSet <- replicas
	end replicate

  % get list of generic replicas
  export operation getReplicas[objectTypeName : String] -> [ret : Array.of[ReplicaType]]
	   ret <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
	end getReplicas

  % get the primary replica of a given type name
	export operation getPrimaryReplica[objectTypeName : String] -> [ret : ReplicaType]
		 const replicaList <- view replicasDirectory.lookup[objectTypeName] as Array.of[ReplicaType]
		 ret <- replicaList[0]
	end getPrimaryReplica

  % checks if a given node already has a replica of a given object type
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
  export operation redistributeReplicasNodeUp
		const replicaTypes <- replicasDirectory.list
		for i : Integer <- 0 while i <= replicaTypes.upperbound by i <- i + 1
      const replicaObjectType <- replicaTypes[i]
		  var replicaList : Array.of[ReplicaType] <- view replicasDirectory.lookup[replicaObjectType] as Array.of[ReplicaType]
      if (replicaList.upperbound + 1) < replicaList[0].getNumberRequiredReplicas then
          const newReplica <- GenericReplica.create[replicaList[0].read, replicaList[0].getNumberRequiredReplicas, self, replicaList[0]]
          for k : Integer <- 0 while k <= here$activenodes.upperbound by k <- k + 1
            if here$activenodes[k]$thenode !== here then
              if self.nodeHasReplica[here$activenodes[k]$thenode, replicaObjectType] == False then
                replicaList.addUpper[newReplica]
                replicasDirectory.insert[replicaObjectType, replicaList]
                fix newReplica at here$activenodes[k]$thenode
                exit
              end if
            end if
          end for
      end if
    end for
    self.dump
	end redistributeReplicasNodeUp

	% rearrange replicas when a node goes down
  export operation redistributeReplicasNodeDown
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
             var newReplica : ReplicaType
             % primary replica node unavailable
						 if j == 0 then
               here$stdout.putstring["\nA primary replica has been lost\n"]
             	 newReplica <- PrimaryReplica.create[
                            replicaList[replicaList.upperbound].read,
                            replicaList[replicaList.upperbound].getNumberRequiredReplicas,
                            self]
             else
               % generic replica node unavailable
               here$stdout.putstring["\nA generic replica has been lost\n"]
               newReplica <- GenericReplica.create[replicaList[0].read, replicaList[0].getNumberRequiredReplicas, self, replicaList[0]]
             end if

             for k : Integer <- 0 while k <= here$activenodes.upperbound by k <- k + 1
               if here$activenodes[k]$thenode !== here then
                 if self.nodeHasReplica[here$activenodes[k]$thenode, replicaObjectType] == False then
                   if (typeof newReplica)$name = "agenericreplicatype" then
                    replicaList.addUpper[newReplica]
                   else
                    replicaList.setElement[0, newReplica]
                   end if
                   replicasDirectory.insert[replicaObjectType, replicaList]
                   fix newReplica at here$activenodes[k]$thenode
                   exit
                 end if
               end if
              end for
					end unavailable
				end
			end for
		end for
    self.dump
	end redistributeReplicasNodeDown

  % remove an unavailable generic replica from the framework
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

  % debug
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
    % set up the node event handlers defined in node_event_handler.m
		here.setNodeEventHandler[NodeEventHandler.create[self]]
	end initially

end PCRFramework
