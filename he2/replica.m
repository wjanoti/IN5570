
export Replica

const Replica <- class Replica[X : ClonableType]
			attached var replicas : Array.of[replicaType]
			attached var availableNodes : Array.of[node]

			var lock : boolean <- false
			var init : boolean <- false
			var kill : boolean <- false
			var timeStamp : Time <- (locate self)$timeOfDay

			export operation getId -> [repId : Integer]
				repId <- id
			end getId

			export operation getAvailableNodes -> [res : Array.of[node]]
				res <- availableNodes
			end getAvailableNodes

			export operation getReplicas -> [res : Array.of[replicaType]]
				res <- replicas
			end getReplicas

			export operation getN -> [requiredReplicas : Integer]
				requiredReplicas <- N
			end getN

			export operation addAvailableNode[newAvailableNode : Node]
				availableNodes.addUpper[newAvailableNode]
				self.notify[self]

				unavailable
					(locate self)$stdout.putstring["Primary update. Unavailable" || "\n"]
				end unavailable
			end addAvailableNode

			export operation killProcess
				kill <- true
			end killProcess

			export operation cloneMe -> [clone : ClonableType]
				%% Dummy operation: To be able to conform to ClonableType and thereby act as a proxy
			end cloneMe

			export operation update
				%(locate self)$stdout.putstring["Primary update. \n"]
				unavailable
					(locate self)$stdout.putstring["Primary update. Unavailable" || "\n"]
				end unavailable
			end update

			export operation update[primary : replicaType]
				%(locate self)$stdout.putstring["Primary update[primary]. \n"]
				unavailable
					(locate self)$stdout.putstring["Primary update. Unavailable" || "\n"]
				end unavailable
			end update

			export operation setData[newData : Any]
				if lock == false then
					(locate self)$stdout.putstring["Primary setData[1]. \n\tLockdown time: "
					|| (locate self)$timeOfDay.asString || "\n"]
					lock <- true
						timeStamp <- (locate self)$timeOfDay
						myClonable.setData[newData]
						self.notify
					lock <- false
				end if

				unavailable
					(locate self)$stdout.putstring["Primary setData[1]. Unavailable" || "\n"]
				end unavailable
			end setData

			export operation setData[newData : Any, upn : Time]
				%(locate self)$stdout.putstring["Primary setData[2]."]
				if upn > timeStamp then
					self.setData[newData]
				end if

				unavailable
					(locate self)$stdout.putstring["Primary setData[2]. Unavailable" || "\n"]
				end unavailable
			end setData

			export operation getData -> [newData : Any]
				%(locate self)$stdout.putstring["Primary getData." || "\n"]
				newData <- myClonable.getData

				unavailable
					(locate self)$stdout.putstring["Primary getData. Unavailable" || "\n"]
				end unavailable
			end getData

			export operation getData[key : Any] -> [res : Any]
				%(locate self)$stdout.putstring["Primary getData[1]." || "\n"]
				res <- myClonable.getData[key]
			end getData

			export operation ping
				%(locate self)$stdout.putstring["Primary ping."|| "\n"]

				unavailable
					(locate self)$stdout.putstring["Primary ping. Unavailable" || "\n"]
				end unavailable
			end ping

			operation notify
			 % spawn new objects?
				for i : Integer <- 1 while i <= replicas.upperbound by i <- i + 1
					replicas[i].update
				end for
				%(locate self)$stdout.putstring["Primary has notified all replicas. " || "\n"]
			end notify

			operation notify[primary : replicaType]
				for i : Integer <- 1 while i <= replicas.upperbound by i <- i + 1
					replicas[i].update[primary]
				end for
				%(locate self)$stdout.putstring["Primary has notified all replicas[1]. Replicas: "
				%	||replicas.upperbound.asString || ". AvailableNodes: " || availableNodes.upperbound.asString||"\n"]
			end notify

			export operation removeUnavailableReplica
				var i : Integer <- 0
				loop
					exit when i > replicas.upperbound
					begin
						replicas[i].ping
						i <- i + 1
					end
				end loop

				unavailable
					if i !== replicas.upperbound then
						replicas[i] <- replicas.removeUpper
					else
						var throw : replicaType <- replicas.removeUpper
					end if
				%	(locate self)$stdout.putstring["Primary removeUnavailableReplica. Replicas : "
				%		||replicas.upperbound.asString || "\n"]
				end unavailable
			end removeUnavailableReplica

			export operation maintainReplicas
				if (replicas.upperbound + 1) < N then
					if availableNodes.upperbound >= 0  then
						var tmpClone : ClonableType <- myClonable.cloneMe
						replicas.addUpper[OrdinConstructor.create[tmpClone, (replicas.upperbound +1), N, PrimeConstructor, OrdinConstructor]]
						%(locate self)$stdout.putstring["Primary maintainReplicas. Created a Replica. Replicas : "
						%||replicas.upperbound.asString || "\n"]
						fix replicas[replicas.upperbound] at availableNodes[availableNodes.upperbound]
						fix tmpClone at availableNodes[availableNodes.upperbound]
						%(locate self)$stdout.putstring["Primary maintainReplicas. Moved replica to "
						%|| availableNodes[availableNodes.upperbound]$LNN.asString || "\n"]
						%(locate self)$stdout.putstring["replica at node: " ||(locate replicas[replicas.upperbound])$LNN.asString
						%||". Clone at node: "||(locate tmpClone)$LNN.asString|| "\n"]
						var throw : node <- availableNodes.removeUpper
						self.notify[self]
					else
					(locate self)$stdout.putstring["Primary: There is not enough active nodes to maintain the given number of replicas: "
						||N.asString|| " given, only " || ((locate self)$ActiveNodes.upperbound ).asString
						|| " nodes active."|| "\n"]
					end if
				end if
			end maintainReplicas

			export operation initializeDataStructures[reps : Array.of[replicaType], availableN : Array.of[node]]
				self.initReplicas[reps]
				self.initAvailableNodes[availableN]
				(locate self)$stdout.putstring["Primary initializeDataStructures."||"\n"]
				(locate self)$stdout.putstring["\tReplicas: " ||replicas.upperbound.asString
					|| ". AvailableNodes: " || availableNodes.upperbound.asString||"\n\n"]
				if init == false then
					self.notify[self]
					(locate self).setNodeEventHandler[primaryEventHandler.create[self, id, N]]
					(locate self)$stdout.putstring["*** Initialization done. Starting normal process ***"||"\n"]
					init <- true
				end if
			end initializeDataStructures

			operation initReplicas[reps : Array.of[replicaType]]
				replicas <- Array.of[replicaType].create[0]
				for i : Integer <- 0 while i <= reps.upperbound by i <- i + 1
					if reps[i] !== nil then
						replicas.addUpper[reps[i]]
					%(locate self)$stdout.putstring["Primary initializing replicas."||"\n"]
					end if
				end for
			end	initReplicas

			operation initAvailableNodes[availableN : Array.of[node]]
				availableNodes <- Array.of[node].create[(availableN.upperbound + 1)]
				for i : Integer <- 0 while i <= availableN.upperbound by i <- i + 1
					availableNodes[i] <- availableN[i]
					%(locate self)$stdout.putstring["Primary initializing availables."||"\n"]
				end for
			end	initAvailableNodes

			export operation print[msg : String]
				myClonable.print[msg]
			end print

			export operation getInitData[newKeys : Array.of[String], newObjects : Array.of[FilmDataType]]

			end getInitData

			process
				loop
					exit when init == true
					begin
						init <- false
						(locate self)$stdout.putstring["Primary process init "||(locate self)$LNN.asString
						 || "\n"]
						(locate self).delay[Time.create[1, 0]]
					end
				end loop
				var i : Integer <- 0
				loop
					exit when kill == true
					begin
						kill <- false
						if replicas.upperbound < (N - 1) then
							%(locate self)$stdout.putstring["\nPrimary processloop. Available nodes: "
							%|| (replicas.upperbound + 1).asString|| " - Required nodes: "  ||N.asString
							%||" nodes. Open more nodes."||"\n"]
						end if
						%(locate self)$stdout.putstring["\nPrimary processloop. LNN: " ||(locate self)$LNN.asString||"\n"]
						%(locate self)$stdout.putstring["\n\tAvailableNodes.upperbound: " || availableNodes.upperbound.asString
						%|| ". Replicas.upperbound: " || replicas.upperbound.asString ||"\n"]
						(locate self).delay[Time.create[2, 0]]
						%self.ping
						%self.maintainReplicas
					end
				end loop
				unavailable
					(locate self)$stdout.putstring["Primary process. Unavailable" || "\n"]
				end unavailable
				failure
					(locate self)$stdout.putstring["Primary process. Failure. Process." ||"\n"]
				end failure
			end process
end primaryConstructor
