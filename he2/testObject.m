export TestObjectClass

const TestObjectClass <- class TestObject [data : String]
  var data : String

  export operation clone -> [cloned: ReplicaType]
      cloned <- TestObjectClass.create[data]
  end clone

  export operation read -> [ ret : Any ]
    ret <- view data as String
  end read

  export operation write [value : Any ]
      data <- view value as String 
  end write
end TestObject
