export Server

const Server <- object Server
  const here <- locate self
  var peerList : Array.of[PeerType] <- Array.of[PeerType].empty
  % file hash -> peer
  var filesPeerIndex : Directory <- Directory.create
  % file hash -> file name
  var fileNamesIndex : Directory <- Directory.create

  export operation addPeer[ peer : PeerType ]
    peerList.addUpper[peer]
  end addPeer

  % register a file belonging to a peer
  export operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]

    if filesPeerIndex.lookup[fileHash.asString] == nil then
      filePeers <- Array.of[PeerType].empty
    else
      filePeers <- view filesPeerIndex.lookup[fileHash.asString] as Array.of[PeerType]
    end if

    % add peer to peer list
    filePeers.addUpper[peer]
    % update list of
    filesPeerIndex.insert[fileHash.asString, filePeers]
    fileNamesIndex.insert[fileHash.asString, fileName]
  end registerFile

  export operation listAvailableFiles
    const files <- fileNamesIndex.list
    here$stdout.putstring["Available files: \n"]
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        var fileName : String <- view fileNamesIndex.lookup[files[i]] as String
        here$stdout.putstring["  -> " || fileName || "\n"]
    end for
  end listAvailableFiles

  export operation listFiles
    const files <- filesPeerIndex.list
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        const pList <- view filesPeerIndex.lookup[files[i]] as Array.of[PeerType]
        var nodesNames : String <- ""
        for j : Integer <- 0 while j <= pList.upperbound by j <- j + 1
            nodesNames <- nodesNames || (locate pList[j])$name || " - "
        end for
        here$stdout.putstring["Hash: " || files[i] || " - File name: " || nodesNames || "\n"]
    end for
  end listFiles

  export operation dump
    here$stdout.putstring["\n==== SERVER INFO ====\n"]
    here$stdout.putstring["\n=> Connected peers:\n"]
    for i : Integer <- 0 while i <= peerList.upperbound by i <- i + 1
      if peerList[i] !== nil then
        here$stdout.putstring[(peerList[i]).getId || " @ " || (locate peerList[i])$name || "\n"]
      end if
    end for

    here$stdout.putstring["\n=> File index:\n"]
    const files <- fileNamesIndex.list
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        var fileName : String <- view fileNamesIndex.lookup[files[i]] as String
        here$stdout.putstring[fileName || " -> " || files[i] || "\n"]
    end for

    here$stdout.putstring["\n=> Peer index:\n"]
    const filesPeer <- filesPeerIndex.list
    for i : Integer <- 0 while i <= filesPeer.upperbound by i <- i + 1
        var filePeerList : Array.of[PeerType] <- view filesPeerIndex.lookup[filesPeer[i]] as Array.of[PeerType]
        var fileName : String <- view fileNamesIndex.lookup[filesPeer[i]] as String
        here$stdout.putstring["File " || fileName  || " can be found in the following peers:\n"]
        for j : Integer <- 0 while j <= filePeerList.upperbound by j <- j + 1
          here$stdout.putstring[filePeerList[j].getId || "\n"]
        end for
    end for

    for i : Integer <- 0 while i <= peerList.upperbound by i <- i + 1
      if peerList[i] !== nil then
        peerList[i].dump
      end if
    end for
  end dump

  % process that checks if a node was disconnected.
  process
    loop
      for i : Integer <- 0 while i <= peerList.upperbound by i <- i + 1
        begin
          if peerList[i] !== nil then
            peerList[i].ping
          end if
          unavailable
            peerList.setElement[i, nil]
            here$stdout.putstring["Peer list size " || peerList.upperbound.asString || "\n"]
            here$stdout.putstring["A node was disconnected. There are currently " || here.getActiveNodes.upperbound.asstring || " active peer(s).\n"]
            self.dump
          end unavailable
        end
      end for
      here.delay[Time.create[5, 0]]
    end loop
  end process

  initially
    fix self at here
    here$stdout.putstring["Starting nopester server...\n"]
  end initially
end Server
