const TimeCollector <- object TimeCollector
  process
    const home <- locate self
    var there : Node
    var allNodes : NodeList
    var numberOfActiveNodes: Integer
    const localTimes <- Array.of[Time].empty
    const nodeNames <- Array.of[String].empty

    home$stdout.PutString["Starting on " || home$name || "\n"]
    allNodes <- home.getActiveNodes
    numberOfActiveNodes <- allNodes.upperbound + 1
    home$stdout.PutString[numberOfActiveNodes.asString || " nodes active.\n"]

    for i : Integer <- 0 while i < numberOfActiveNodes by i <- i + 1
      there <- allNodes[i]$theNode
      move TimeCollector to there
      localTimes.addUpper[there$timeOfDay]
      nodeNames.addUpper[there$name]
    end for

    move TimeCollector to home

    for i : Integer <- 0 while i <= nodeNames.upperbound by i <- i + 1
      home$stdout.putstring["Node name: " || nodeNames[i] || "\n"]
      home$stdout.putstring["Local time: " || localTimes[i].asString || "\n"]
    end for

    home$stdout.PutString["Done collecting times"]
  end process
end TimeCollector
