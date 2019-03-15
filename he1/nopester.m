const NopesterServer <- object NopesterServer
  initially
  end initially
  process
    const serverNode <- locate self
    var activeNodes : NodeList
    var availablePeers : Array.of[Peer] <- Array.of[Peer].empty
    var activePeerNode : Node

    serverNode$stdout.putstring["Starting Nopester server on " || serverNode$name || "\n"]

    loop
      exit when serverNode$activeNodes.upperbound > 1
      begin
        serverNode$stdout.putstring["\nWaiting for peers.."]
        serverNode.delay[Time.create[5, 0]]
      end
    end loop

    activeNodes <- serverNode$ActiveNodes
    serverNode$stdout.putstring["Active nodes " || activeNodes.upperbound.asstring || "\n"]

    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      activePeerNode <- activeNodes[i]$theNode
      serverNode$stdout.putstring["Current node " || activePeerNode$name || "\n"]
      if activePeerNode !== serverNode then
        serverNode$stdout.putstring["Fixing peer at " || activePeerNode$name || "\n"]
        fix availablePeers[i] at activePeerNode
      end if
    end for

    for i : Integer <- 0 while i <= availablePeers.upperbound by i <- i + 1
      availablePeers[i].ping
    end for

  end process
end NopesterServer
