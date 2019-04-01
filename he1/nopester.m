const nopester <- object nopester
  const here <- (locate self)
  var aNode : Node
  var peerObject : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const p1Files : ImmutableVector.of[String] <- { "file1.mp3", "file2.mp3", "file3.mp3", "file4.mp3", "file5.mp3" }
  const p2Files : ImmutableVector.of[String] <- { "file6.mp3", "file7.mp3", "file8.mp3", "file9.mp3", "file5.mp3" }

  initially
    fix Server at here
    % creates and distributes peer objects into the available nodes
    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      aNode <- activeNodes[i].getTheNode
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
    Server.getFileLocation[hashImplementation.hash["ss.mp3"]]
  end initially
end nopester
