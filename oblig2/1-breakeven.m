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

% object that's gonna be moved to a different node.
const remoteObj <- object remoteObj
  % operation that accesses the internal array in the argument object remotely.
  export operation callRemote[arg: Argument]
    const arraySize <- arg.getArraySize
  end callRemote

  % operation that accesses the internal array in the argument object locally (by visit).
  export operation callByVisit[arg: Argument, origin: Node]
    const arraySize <- arg.getArraySize
    move arg to origin
  end callByVisit
end remoteObj

const main <- object main
  const here <- locate self
  const otherNodes <- here$activeNodes
  % array sizes to be tested
  const argArraySizes <- {50, 100, 500, 1000, 10000}
  var argObj : Argument
  var otherNode : Node
  var starttime : Time
  var endtime : Time

  % gets alive nodes (assume that there's at least one) and fixes the object that we are gonna invoke there.
  export op setUp
    assert otherNodes.upperbound >= 1
    otherNode <- otherNodes[1]$theNode
    fix remoteObj at otherNode
  end setUp

  % helper function to convert a Time object to seconds
  export function timeToSeconds[ t: Time ] -> [ s : Real ]
      s <- t.getSeconds.asreal + (t.getMicroSeconds.asreal/1000000.0)
  end timeToSeconds

  process
    self.setUp

    % runs every test scenario for each array size
    for i : Integer <- 0 while i < argArraySizes.upperbound + 1 by i <- i + 1
      argObj <- Argument.create[argArraySizes[i]]

      stdout.putstring["\nArray size => " || argArraySizes[i].asstring || "\n"]
      % calculate the cost of the remote call without moving the parameter.
      starttime <- here$timeOfDay
      remoteObj.callRemote[argObj]
      endtime <- here$timeOfDay
      const removeInvocationTime <- endtime - starttime
      const removeInvocationSeconds <-  self.timeToSeconds[removeInvocationTime]
      stdout.putstring[" => Remote invocation: " || removeInvocationSeconds.asstring || " seconds\n"]

      move argObj to otherNode

      % calculate the cost of the remote call by visit.
      starttime <- here$timeOfDay
      remoteObj.callByVisit[argObj, here]
      endtime <- here$timeOfDay
      const callByVisitInvocationTime <- endtime - starttime
      const callByVisitInvocationSeconds <- self.timeToSeconds[callByVisitInvocationTime]
      stdout.putstring[" => Call by visit invocation: " || callByVisitInvocationSeconds.asstring || " seconds\n"]

      stdout.putstring["Breaks even when number of callbacks >= " || ((callByVisitInvocationSeconds/removeInvocationSeconds) - 1.0).asString || "\n"]
    end for
  end process
end main
