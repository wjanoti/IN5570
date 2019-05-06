export ReplicaType
export ClonableType

const ReplicaType <- typeobject ReplicaType
  operation read -> [o : ClonableType]
  operation write[o : ClonableType]
  operation ping
  operation notify
  operation dump
end ReplicaType

const ClonableType <- typeobject ClonableType
  operation clone -> [o : ClonableType]
  operation dump
end ClonableType
