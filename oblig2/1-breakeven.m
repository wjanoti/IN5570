% Argument object
const Argument <- class Argument[ arraySize : Integer ]
  attached var arr : Array.of[Integer]

  % Simple operation to be called by the remote object.
  export operation getArraySize -> [ n : Integer]
    n <- arr.upperbound + 1
  end getArraySize

  initially
    arr <- Array.of[Integer].create[arraySize]
  end initially
end Argument

% Object that's gonna be moved to a different node.
const remoteObj <- object remoteObj
  % Operation that accesses the internal array in the argument object remotely.
  export operation callRemote[arg: Argument]
    (locate self)$stdout.PutString["The attached array in the parameter object has : " || arg.getArraySize.asstring || " elements\n"]
  end callRemote

  % Operation that accesses the internal array in the argument object by visit.
  export operation callByVisit[arg: Argument, origin: Node]
    (locate self)$stdout.PutString["The attached array in the parameter object has : " || arg.getArraySize.asstring || " elements\n"]
    move arg to origin
  end callByVisit
end remoteObj

const main <- object main
  const here <- locate self
  const otherNodes <- here$activeNodes
  const argObj <- Argument.create[10000]
  var otherNode : Node
  var starttime : Time
  var endtime : Time

  % gets alive nodes (assume that there's at least one) and moves the object that we are gonna invoke there
  export op setUp
    otherNode <- otherNodes[1]$theNode
    move remoteObj to otherNode
  end setUp

  process
    self.setUp

    % call the remote object without moving the parameter.
    starttime <- here$timeOfDay
    remoteObj.callRemote[argObj]
    endtime <- here$timeOfDay
    const removeInvocationTime <- endtime - starttime
    const removeInvocationSeconds <- removeInvocationTime.getSeconds.asreal + (removeInvocationTime.getMicroSeconds.asreal/1000000.0)
    stdout.putstring["Array size = " || argObj.getArraySize.asstring || "\n"]
    stdout.putstring[" => Remote invocation: " || removeInvocationSeconds.asstring || " seconds\n"]

    % call the remote object by visit
    move argObj to otherNode
    starttime <- here$timeOfDay
    remoteObj.callByVisit[argObj, here]
    endtime <- here$timeOfDay
    const callByVisitInvocationTime <- endtime - starttime
    const callByVisitInvocationSeconds <- (callByVisitInvocationTime.getSeconds.asreal + (callByVisitInvocationTime.getMicroSeconds.asreal/1000000.0))
    stdout.putstring[" => Call by visit invocation: " || callByVisitInvocationSeconds.asstring || " seconds\n"]

    stdout.putstring["Break-even: ~ " || ((callByVisitInvocationSeconds/removeInvocationSeconds) - 1.0).asString || " calls \n"]
  end process
end main
