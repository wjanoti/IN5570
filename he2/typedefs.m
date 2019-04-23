export PrimaryReplicaType
export ReplicaType
export PCRFrameworkType

const PrimaryReplicaType <- typeobject PrimaryReplicaType
    operation read -> [o : Any]
    operation write[o : Any]
    operation notify
    operation clone -> [cloned : ReplicaType]
end PrimaryReplicaType

const ReplicaType <- typeobject ReplicaType
    operation read -> [o : Any]
    operation write[o : Any]
end ReplicaType

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
