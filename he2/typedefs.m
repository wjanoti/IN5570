export ReplicaType
export ClonableType

const ReplicaType <- typeobject ReplicaType
  operation read -> [o : ClonableType]
  operation write[o : ClonableType]
  operation registerNode[newUsedNode : Node]
  operation registerReplica[newReplica : ReplicaType]
  operation ping
  operation notify
  operation dump
end ReplicaType

const ClonableType <- typeobject ClonableType
  operation clone -> [o : ClonableType]
  operation dump
end ClonableType
