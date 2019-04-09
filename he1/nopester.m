const nopester <- object nopester
  const here <- (locate self)
  var aNode : Node
  var aPeer : PeerType
  var peerObject : PeerType
  var p1, p2, p3, p4, p5 : PeerType
  var activeNodes : NodeList <- (locate self).getActiveNodes
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

    % distribute the peers among the nodes, we assume that there are 3 nodes running (1 for the server and 2 for the peers)
    for i : Integer <- 0 while i <= activeNodes.upperbound by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      % we consider the node we run this program the server and don't want any peer objects here.
      if aNode !== here then
        %  partition peers over 2 nodes (3 in one and 2 in the other)
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

  % p1 downloads a file (p4f1) from p4 and saves it under p4f1.downloaded
  export operation testDownloadFileAvailableInSinglePeer
    stdout.putstring["\nTest case 1: download a file available in a single peer\n"]
    const fileName <- "p4f1"
    const availablePeers <- p1.searchFileByName[fileName]
    for i : Integer <- 0 while i <= availablePeers.upperbound by i <- i + 1
      begin
        const downloadFileContent <- availablePeers[i].getFileByName[fileName]
        if downloadFileContent !== nil then
          p1.addFile[fileName || ".downloaded", downloadFileContent]
        end if
        unavailable
          stdout.putstring["Couldn't download file from peer\n"]
        end unavailable
      end
    end for
  end testDownloadFileAvailableInSinglePeer

  export operation testDownloadFileAvailableInMultiplePeers
    stdout.putstring["\nTest case 2: download a file that is available in multiple peers\n"]
    const fileName <- "p3f0"
    const availablePeers <- p1.searchFileByName[fileName]
    for i : Integer <- 0 while i <= availablePeers.upperbound by i <- i + 1
      begin
        const downloadFileContent <- availablePeers[i].getFileByName[fileName]
        if downloadFileContent !== nil then
          p1.addFile[fileName || ".downloaded", downloadFileContent]
        end if
        unavailable
          stdout.putstring["Couldn't download file from peer\n"]
        end unavailable
      end
    end for
  end testDownloadFileAvailableInMultiplePeers

  export operation testPeerRemovesFile
    stdout.putstring["\nTest case 3: peer notifies that file is no longer available\n"]
    p4.removeFile["p4f2"]
  end testPeerRemovesFile

  export operation testPeerUpdatesFile
    stdout.putstring["\nTest case 4: peer updates a file\n"]
    p2.updateFile["p2f1", "p2f1.updated"]
  end testPeerUpdatesFile

  initially
    loop
      exit when activeNodes.upperbound = 2
      activeNodes <- here.getActiveNodes
      if activeNodes.upperbound < 2 then
        stdout.putstring["There neeeds to be at least 3 active nodes to run this program, waiting for a node to connect...\n"]
        here.delay[Time.create[3, 0]]
      end if
    end loop
    % creates peers and adds files
    self.setup
  end initially

  process
    % dumps initial state
    server.dump

    self.testDownloadFileAvailableInSinglePeer
    server.dump

    self.testDownloadFileAvailableInMultiplePeers
    server.dump

    self.testPeerRemovesFile
    server.dump

    self.testPeerUpdatesFile
    server.dump
  end process
end nopester
