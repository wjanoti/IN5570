export TimeServer

const TimeServer <- class TimeServer

  const home <- locate self
  const allNodes <- home$activeNodes
  const timeAgents <- Array.of[TimeAgent].empty[]
  % record to keep node name and time
  const nodeTimeInfo <- record timeElement
    var nodeTime : Time
    var nodeName : String
  end timeElement
  var nodeTimes : Array.of[nodeTimeInfo]
  var aNode : Node
  var agent : TimeAgent
  var requestStartTime : Time
  var requestEndTime : Time
  var nodeTime : Time
  var roundTripTime : Time
  var timeSumSeconds : Real
  var timeSumMicroseconds : Real
  var averageTimeSeconds : Real
  var synchTime : Time
  % Time agent
  const TimeAgent <- monitor class TimeAgent
    export operation getLocalTime -> [ t : Time ]
        t <- (locate self)$timeOfDay
    end getLocalTime

    export operation getNodeName -> [ n : String ]
      n <- (locate self)$name
    end getNodeName
  end TimeAgent

  export function timeToSeconds[ t: Time ] -> [ s : Real ]
      s <- t.getSeconds.asreal + (t.getMicroSeconds.asreal/1000000.0)
  end timeToSeconds

  export operation clone -> [clone : ClonableType]
     clone <- self
  end clone

  export operation getTime -> [t : Time]
    % fix agents at nodes
    for i : Integer <- 0 while i < allNodes.upperbound + 1 by i <- i + 1
      aNode <- allNodes[i]$theNode
      agent <- TimeAgent.create[]
      timeAgents.addUpper[agent]
      fix agent at aNode
    end for

    timeSumSeconds <- 0.0
    timeSumMicroseconds <- 0.0
    nodeTimes <- Array.of[nodeTimeInfo].empty
    % query agents every minute
    for i : Integer <- 0 while i < timeAgents.upperbound + 1 by i <- i + 1
      agent <- timeAgents[i]
      % get the local time via the remote agent and calculate how long it took
      requestStartTime <- home$timeOfDay
      nodeTime <- agent.getLocalTime
      requestEndTime <- home$timeOfDay
      % used to take into account the response time from the agent, assuming that request and response take about the same time.
      roundTripTime <- requestEndTime - requestStartTime
      timeSumSeconds <- timeSumSeconds + nodeTime.getSeconds.asreal + (roundTripTime.getSeconds.asreal/2.0)
      timeSumMicroseconds <- timeSumMicroseconds + nodeTime.getMicroSeconds.asreal + (roundTripTime.getMicroSeconds.asreal/2.0)
      nodeTimes.addUpper[nodeTimeInfo.create[nodeTime, agent.getNodeName]]
    end for

    const numberOfTimeSamples <- nodeTimes.upperbound + 1
    % average of collected times
    synchTime <- Time.create[(timeSumSeconds/numberOfTimeSamples.asreal).asinteger, (timeSumMicroseconds/numberOfTimeSamples.asreal).asinteger]
    t <- synchTime
    unavailable
      (locate self)$stdout.putstring["Couldn't get time, node unavailable\n"]
    end unavailable
  end getTime

end TimeServer
