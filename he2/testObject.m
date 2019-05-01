export TestObject

const TestObject <- class TestObject [data : String]

  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation dump
    (locate self)$stdout.putstring["DATA: " || data || " - LOCATION :" || (locate self)$name || "\n"]
  end dump
end TestObject
