const main <- object main

  const here <- locate self
  const otherNodes <- here$activeNodes
  const argObjType <- typeobject argObjType
      operation getSize -> [Integer]
  end argObjType

  % argument object
  const argObj <- object argObj
    attached const arr <- Array.of[Integer].create[50000]

    export operation getSize -> [ size : Integer ]
      size <- arr.upperbound + 1
    end getSize
  end argObj

  % object that's gonna be moved to a different node.
  const remoteObj <- object remoteObj
    export operation doSomething[arg: argObjType, origin: Node]
      (locate self)$stdout.PutString["The attached array in the parameter has : " || arg.getSize.asstring || " elements\n"]
      move arg to origin
    end doSomething
  end remoteObj

  % gets alive nodes (assume that there's at least one) and moves the object that we are gonna invoke there
  export op setUp
    const otherNode <- otherNodes[1]$theNode
    assert otherNode !== here
    move remoteObj to otherNode
    move argObj to otherNode
  end setUp

  process
    self.setUp
    const starttime <- here$timeOfDay
    remoteObj.doSomething[argObj, here]
    const endtime <- here$timeOfDay
    const removeInvocationTime <- endtime - starttime
    stdout.putstring["Remote invokation took: " || removeInvocationTime.asString ||" seconds\n"]
    stdout.PutString["Break even = " || (removeInvocationTime / 32).asString || "\n"]
  end process
end main
