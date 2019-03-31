const nopester <- object nopester
  const here <- (locate self)
  var aNode : Node
  var peerObject : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const p1Files : ImmutableVector.of[String] <- { "1.mp3", "2.mp3", "3.mp3", "4.mp3", "5.mp3" }
  const p2Files : ImmutableVector.of[String] <- { "6.mp3", "7.mp3", "8.mp3", "9.mp3", "10.mp3" }

  initially
  stdout.putstring[(typeof p1Files)$name || "\n"]
    fix Server at here
    % creates and distributes peer objects into the available nodes
    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      stdout.putstring["=> INFO: " || aNode$name || "\n"]
      if aNode !== here then
        peerObject <- Peer.create["p"||i.asstring, Server ]
        var files : ImmutableVector.of[String]
        if i = 1 then
          files <- p1Files
        else
          files <- p2Files
        end if
        for j : Integer <- 0 while j <= files.upperbound by j <- j + 1
            peerObject.addFile[files[j]]
        end for
        fix peerObject at aNode
        Server.addPeer[peerObject]
      end if
    end for
    Server.dump
  end initially
end nopester
