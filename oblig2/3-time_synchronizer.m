% Time agent
const TimeAgent <- monitor class TimeAgent
  export operation getLocalTime -> [ t : Time ]
      t <- (locate self)$timeOfDay
  end getLocalTime

  export operation getNodeName -> [ n : String ]
    n <- (locate self)$name
  end getNodeName
end TimeAgent

const TimeSynchronizer <- object TimeSynchronizer
  export function timeToSeconds[ t: Time ] -> [ s : Real ]
      s <- t.getSeconds.asreal + (t.getMicroSeconds.asreal/1000000.0)
  end timeToSeconds

  process
    const home <- locate self
    const allNodes <- home$activeNodes
    const timeAgents <- Array.of[TimeAgent].empty[]

    var nodeTimes : Array.of[nodeTimeInfo]
    var aNode : Node
    var agent : TimeAgent
    var requestStartTime : Time
    var requestEndTime : Time
    var nodeTime : Time
    var roundTripTime : Time
    var timeSumSeconds : Real
    var averageTimeSeconds : Real
    var synchTime : Time

    % record to keep node name and time
    const nodeTimeInfo <- record timeElement
      var nodeTime : Time
      var nodeName : String
    end timeElement

    home$stdout.PutString[(allNodes.upperbound + 1).asString || " nodes active.\n"]

    % fix agents at nodes
    for i : Integer <- 0 while i < allNodes.upperbound + 1 by i <- i + 1
      aNode <- allNodes[i]$theNode
      agent <-TimeAgent.create[]
      timeAgents.addUpper[agent]
      fix agent at aNode
      home$stdout.putstring["Agent " || i.asstring || " is at: " || (locate agent)$name ||"\n"]
    end for

    loop
      begin
        timeSumSeconds <- 0.0
        averageTimeSeconds <- 0.0
        nodeTimes <- Array.of[nodeTimeInfo].empty
        % sleep for 10s
        home.delay[Time.create[0, 10000000]]
        home$stdout.putstring["\n"]
        for i : Integer <- 0 while i < timeAgents.upperbound + 1 by i <- i + 1
          agent <- timeAgents[i]
          % get the local time via the remote agent and calculate how long it took
          requestStartTime <- home$timeOfDay
          nodeTime <- agent.getLocalTime
          requestEndTime <- home$timeOfDay
          roundTripTime <- requestStartTime - requestEndTime

          % assuming the request and response times are the same, we subtract half of the RTT to account for the time it took to get the response.
          nodeTime <- nodeTime - (roundTripTime/2)

          nodeTimes.addUpper[nodeTimeInfo.create[nodeTime, agent.getNodeName]]
        end for

        for i : Integer <- 0 while i < nodeTimes.upperbound + 1 by i <- i + 1
            timeSumSeconds <- timeSumSeconds + TimeSynchronizer.timeToSeconds[nodeTimes[i]$nodeTime]
        end for
        home$stdout.putstring["Time sum is : " || timeSumSeconds.asstring || "\n"]

        averageTimeSeconds <- timeSumSeconds/(nodeTimes.upperbound + 1).asreal
        synchTime <- Time.create[averageTimeSeconds.asinteger, 0]
        home$stdout.putstring["Time aver is : " || synchTime.asdate || "\n"]

        unavailable
          (locate self)$stdout.putstring["Couldn't get time, node unavailable\n"]
        end unavailable
      end
    end loop
  end process
end TimeSynchronizer
