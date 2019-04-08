const nopester <- object nopester
  const here <- (locate self)
  var aNode : Node
  var aPeer : PeerType
  var peerObject : PeerType
  var p1, p2, p3, p4, p5 : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const peers <- Array.of[PeerType].empty
  const testFiles  <- {
    "Quick zephyrs blow vexing daft Jim",
    "Sphinx of black quartz judge my vow",
    "Hick dwarves jam blitzing foxy quip",
    "Vamp fox held quartz duck just by wing",
    "My jocks box get hard unzip quiver flow",
    "Kvetching flummoxed by job W. zaps Iraq",
    "Two driven jocks help fax my big quiz",
    "Five quacking zephyrs jolt my wax bed",
    "The five boxing wizards jump quickly",
    "Pack my box with five dozen liquor jugs"
  }

  % creates a peer and add files on it.
  operation createPeer [ name : String, files : ImmutableVector.of[String] ] -> [ newPeer : PeerType ]
      peerObject <- Peer.create[name, Server]
      for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        % file names will have the following convention: peer name + "f" + file number, e.g. p1f1
        peerObject.addFile[name || "f" || i.asstring, files[i]]
      end for
      newPeer <- peerObject
  end createPeer

  % creates 5 peers and adds a set of files on each of them
  operation setup
    fix Server at here
    p1 <- self.createPeer["p1", testFiles.getSlice[0, 3]]
    peers.addUpper[p1]
    p2 <- self.createPeer["p2", testFiles.getSlice[2, 3]]
    peers.addUpper[p2]
    p3 <- self.createPeer["p3", testFiles.getSlice[4, 3]]
    peers.addUpper[p3]
    p4 <- self.createPeer["p4", testFiles.getSlice[6, 3]]
    peers.addUpper[p4]
    p5 <- self.createPeer["p5", testFiles.getSlice[7, 3]]
    peers.addUpper[p5]

    % distribute the peers among the nodes
    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      % we consider the node we run this program the server and don't want any peer objects here.
      if aNode !== here then
        if i == 1 then
          loop
            exit when peers.upperbound == 2
            aPeer <- peers.removeUpper
            fix aPeer at aNode
            Server.addPeer[aPeer]
          end loop
        else
          loop
            exit when peers.upperbound == -1
            aPeer <- peers.removeUpper
            fix aPeer at aNode
            Server.addPeer[aPeer]
          end loop
        end if
      end if
    end for
  end setup

  initially
    self.setup
    %const possiblePeers <- p2.searchFileByName["p1f1"]
    %for i : Integer <- 0 while i <= possiblePeers.upperbound by i <- i + 1
    %  begin
    %    const downloadedFile <- possiblePeers[i].getFileByName["p1f1"]
    %    if downloadedFile !== nil  then
    %      p2.addFile["p1f1.downloaded", downloadedFile]
    %    end if
    %    unavailable
    %      stdout.putstring["Couldn't get file from peer\n"]
    %    end unavailable
    %  end
    %end for

    %Server.dump
  end initially
end nopester
