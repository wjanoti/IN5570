export TestObject
export Bacon

const TestObject <- class TestObject [data : String]
  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation dump
    (locate self)$stdout.putstring["DATA: " || data || "\n"]
  end dump
end TestObject

const Bacon <- class Bacon [data : String]
  export operation clone -> [cloned: ClonableType]
      cloned <- TestObject.create[data]
  end clone

  export operation dump
    (locate self)$stdout.putstring["DATA: " || data || "\n"]
  end dump
end Bacon
