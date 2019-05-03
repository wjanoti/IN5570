export ReplicaType
export PCRFrameworkType
export ClonableType

const ReplicaType <- typeobject ReplicaType
  operation read -> [o : ClonableType]
  operation write[o : ClonableType]
  operation ping
  operation dump
  operation notify
  operation registerNode
  operation registerReplica
end ReplicaType

const ClonableType <- typeobject ClonableType
  operation clone -> [o : ClonableType]
  operation dump
end ClonableType

const PCRFrameworkType <- typeobject PCRFrameworkType
  operation replicate[X : t, N : Integer]
  forall t
  suchthat
    t *> typeobject PrimaryReplicaType
      op clone -> [result : t]
    end PrimaryReplicaType
  operation replicas[X : t] -> [Array.of[ReplicaType]]
  forall t
  where
    ReplicaType <- typeobject ReplicaType
      operation read -> [o : t]
      operation write[o : t]
    end ReplicaType
end PCRFrameworkType
