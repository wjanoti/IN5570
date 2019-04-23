export replicableObject

const replicableObject <- object replicableObject
  operation read -> [o : Any]
  end read
  operation write[o : Any]
  end write
  operation notify
  end notify
  operation clone -> [cloned : ReplicaType]
    cloned <- object myClone
      clone <- replicaClass.create[nrOfClones, frameWork, myObject.cloneMe, monitorObject]
    end myClone
  end clone
end replicableObject
