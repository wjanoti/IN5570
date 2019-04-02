const nopester <- object nopester
  const here <- (locate self)
  var aNode : Node
  var peerObject : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const peers <- Array.of[PeerType].empty

  operation createPeers [ numberOfPeers : Integer, numberOfFiles : Integer ]
    for i : Integer <- 1 while i <= numberOfPeers by i <- i + 1
      peerObject <- Peer.create["p"||i.asstring, Server ]
      for j : Integer <- 1 while j <= numberOfFiles by j <- j + 1
        if j == 1 then
          peerObject.addFile["p" || i.asstring || "f" || j.asstring, "asd"]
        else
          peerObject.addFile["p" || i.asstring || "f" || j.asstring, here.getTimeOfDay.asstring]
        end if
      end for
      peers.addUpper[peerObject]
    end for
  end createPeers

  initially
    fix Server at here
    % creates and distributes peer objects into the available nodes
    self.createPeers[activeNodes.upperbound, 5]
    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      if aNode !== here then
        peerObject <- peers.removeUpper
        fix peerObject at aNode
        Server.addPeer[peerObject]
      end if
    end for
    Server.dump
  end initially
end nopester
