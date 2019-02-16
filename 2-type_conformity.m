% think of Java interfaces
const SimpleCollection <- typeobject SimpleCollection
  operation add [ String ] -> [ Boolean ]
  % param names can be omitted
  function contains [ String ] -> [ Boolean ]
  operation remove [ name : String ] -> [ res : Boolean ]
end SimpleCollection

% this object has to implement all operations defined in SimpleCollection
const set : SimpleCollection <- object set
  export operation add [ name : String ] -> [ res: Boolean ]
    res <- True
  end add

  export function contains [ name : String ] -> [ res: Boolean ]
    res <- True
  end contains

  export operation remove [ name : String ] -> [ res : Boolean ]
    res <- True
  end remove

  % you can define extra operations on the object as long as you implement
  % all the operations defined in the typeobject
  export operation test
    stdout.putstring["test"]
  end test
end set

const main <- object main
  initially
    stdout.putstring[set.contains["x"].asString || "\n"]
  end initially
end main
