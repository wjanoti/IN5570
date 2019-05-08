export TestObject

const TestObject <- class TestObject [data : String]
  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation getData
    (locate self)$stdout.putstring["DATA: " || data || "\n"]
  end getData

  export operation setData[newData : String]
     data <- newData
  end setData
end TestObject
