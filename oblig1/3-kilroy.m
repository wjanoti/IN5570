const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there : Node
    var startTime, totalTime : Time
    var all : NodeList
    var theElem : NodeListElement
    var totalTimeSeconds : Real
    var numberOfActiveNodes: Integer

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    numberOfActiveNodes <- all.upperbound + 1
    home$stdout.PutString[numberOfActiveNodes.asString || " nodes active.\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i]$theNode
      move Kilroy to there
      there$stdout.PutString["Kilroy was here\n"]
    end for
    move Kilroy to home
    totalTime <- home.getTimeOfDay - startTime

    % total time in seconds
    totalTimeSeconds <- totalTime.getSeconds.asreal + (totalTime.getMicroSeconds.asreal/1000000.0)
    home$stdout.PutString["Time to visit each node: " || (totalTime / numberOfActiveNodes).asstring || "\n"]

    % how many nodes it would be able to visit per second.
    home$stdout.PutString["Speed (nodes/second): " || (numberOfActiveNodes.asreal / totalTimeSeconds).asstring || "\n"]
    home$stdout.PutString["Back home.  Total time = " || totalTime.asString || "\n"]
  end process
end Kilroy
