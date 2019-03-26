const nopester <- object nopester
  const home <- (locate self)
  var aNode : Node
  var peerObject : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const testFiles <- { "a.mp3", "b.mp3", "c.mp3", "d.mp3", "e.mp3", "f.mp3" }

  initially
    for i : Integer <- 0 while i < activeNodes.upperbound + 1 by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      if aNode !== home then
        peerObject <- Peer.create
        peerObject.addFile[testFiles[i]]
        fix peerObject at aNode
        Server.addPeer[peerObject]
      end if
    end for
    Server.listAvailableFiles
  end initially
end nopester
