const TimeCollector <- object TimeCollector
  process
    const home <- locate self

    % record to keep node name and time
    const nodeTimeInfo <- record timeElement
      var nodeTime : Time
      var nodeName : String
    end timeElement

    const localTimes <- Array.of[nodeTimeInfo].empty

    var there : Node
    var allNodes : NodeList
    var numberOfActiveNodes: Integer

    home$stdout.PutString["Starting on " || home$name || "\n"]
    allNodes <- home.getActiveNodes
    numberOfActiveNodes <- allNodes.upperbound + 1
    home$stdout.PutString[numberOfActiveNodes.asString || " nodes active.\n"]

    for i : Integer <- 0 while i < numberOfActiveNodes by i <- i + 1
      there <- allNodes[i]$theNode
      move TimeCollector to there
      localTimes.addUpper[nodeTimeInfo.create[there$timeOfDay, there$name]]
    end for

    move TimeCollector to home

    for i : Integer <- 0 while i <= localTimes.upperbound by i <- i + 1
      home$stdout.putstring["Node name: " || localTimes[i]$nodeName || "\n"]
      home$stdout.putstring["Local time: " || localTimes[i]$nodeTime.asdate || " (" ||  localTimes[i]$nodeTime.asString || ")\n"]
    end for

    home$stdout.PutString["Done collecting times\n"]
  end process
end TimeCollector
