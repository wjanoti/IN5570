% Argument object
const TimeAgent <- class TimeAgent
  export operation getLocalTime -> [ t : Time ]
    t <- (locate self)$timeOfDay
  end getLocalTime
end TimeAgent

const TimeSynchronizer <- object TimeSynchronizer
  process
    const home <- locate self
    const allNodes <- home$activeNodes
    var aNode : Node
    var agent : TimeAgent

    % record to keep node name and time
    const nodeTimeInfo <- record timeElement
      var nodeTime : Time
      var nodeName : String
    end timeElement

    home$stdout.PutString["Starting on " || home$name || "\n"]
    home$stdout.PutString[(allNodes.upperbound + 1).asString || " nodes active.\n"]

    for i : Integer <- 0 while i < allNodes.upperbound + 1 by i <- i + 1
      agent <- TimeAgent.create[]
      aNode <- allNodes[i]$theNode
      fix agent at aNode
      home$stdout.putstring["Agent is at: " || (locate agent)$name ||"\n"]
      home$stdout.putstring["Time at " || aNode$name || " : " || agent.getLocalTime.asstring || "\n"]
    end for
  end process
end TimeSynchronizer
