export ReplicaType
export ClonableType
export PCRType

const ReplicaType <- typeobject ReplicaType
  operation read -> [o : ClonableType]
  operation write[o : ClonableType]
  operation ping
  operation notify
  operation dump
  operation getNumberRequiredReplicas -> [ ret : Integer ]
end ReplicaType

const ClonableType <- typeobject ClonableType
  operation clone -> [o : ClonableType]
  operation getData
  operation setData[newData: String]
end ClonableType

const PCRType <- typeobject PCRType
  operation replicate[X : ClonableType, N : Integer]
  operation redistributeReplicas
  operation getGenericReplicas[objectTypeName : String] -> [ret : Array.of[ReplicaType]]
  operation getPrimaryReplica[objectTypeName : String] -> [ret : ReplicaType]
  operation dump
end PCRType
