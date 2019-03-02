
const main <- object main

  % argument object
  const argObj <- object argObj
    const arr <- Array.of[Integer].create[50000]
    initially
      (locate self)$stdout.putstring["Array variable is at: " || (locate arr)$name || "\n"]
    end initially
  end argObj

  % object that's gonna be moved to a different node.
  const remoteObj <- object remoteObj
    export operation doSomething[arg: Any, origin: Node]
      (locate self)$stdout.putstring["Arg comes from: " || (locate arg)$name || "\n"]
      move arg to origin
    end doSomething
  end remoteObj

  process
    const here <- locate self
    const all <- here$activeNodes
    var there : Node

    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      const aNode <- all[i]$theNode
      if aNode !== here and aNode$name != here$name then
       there <- all[i]$theNode
      end if
    end for

    move remoteObj to there
    move argObj to there

    const starttime <- here$timeOfDay
    remoteObj.doSomething[argObj, here]
    const endtime <- here$timeOfDay
    stdout.putstring["Remote invokes took "||(endtime-starttime).asString||" seconds\n"]
    stdout.putstring["remote obj is in " || (locate remoteObj)$name || "\n"]
  end process
end main
