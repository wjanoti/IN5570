const PCRType <- typeobject PCRType
  operation replicate[X : t, N : Integer]
    forall t
    suchthat
      t *> typeobject objectType
              op clone -> [result : t]
           end objectType

  operation replicas[X : t] -> [Array.of[ReplicaType]]
    forall t
    where
      ReplicaType <- typeobject replicaType
                        operation read -> [o : t]
                        operation write[o : t]
                    end replicaType
end PCRType
