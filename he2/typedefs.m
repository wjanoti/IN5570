export ReplicaType
export ClonableType
export PCRType

% type for both PrimaryReplica and GenericReplica
const ReplicaType <- typeobject ReplicaType
  operation read -> [o : ClonableType]
  operation write[o : ClonableType]
  operation ping
  operation notify
  operation dump
  operation getNumberRequiredReplicas -> [ ret : Integer ]
end ReplicaType

% type to be conformed by objects cloned by the framework
const ClonableType <- typeobject ClonableType
  operation clone -> [o : ClonableType]
end ClonableType

% framework type
const PCRType <- typeobject PCRType
  operation replicate[X : ClonableType, N : Integer]
  operation redistributeReplicasNodeDown
  operation redistributeReplicasNodeUp
  operation getReplicas[objectTypeName : String] -> [ret : Array.of[ReplicaType]]
  operation getPrimaryReplica[objectTypeName : String] -> [ret : ReplicaType]
  operation dump
end PCRType
