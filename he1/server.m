export Server

const Server <- object Server
  const home <- locate self
  var peerList : Array.of[PeerType] <- Array.of[PeerType].empty
  var filesPeerIndex : Directory <- Directory.create
  var fileNamesIndex : Directory <- Directory.create

  export operation addPeer[ peer : PeerType ]
    peerList.addUpper[peer]
  end addPeer

  export operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]
    if filesPeerIndex.lookup[fileHash.asString] == nil then
      filePeers <- Array.of[PeerType].empty
    else
      filePeers <- view filesPeerIndex.lookup[fileHash.asString] as Array.of[PeerType]
    end if
    filePeers.addUpper[peer]
    filesPeerIndex.insert[fileHash.asString, filePeers]
    fileNamesIndex.insert[fileHash.asString, fileName]
  end registerFile

  export operation listAvailableFiles
    const files <- fileNamesIndex.list
    home$stdout.putstring["Available files: \n"]
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        var fileName : String <- view fileNamesIndex.lookup[files[i]] as String
        home$stdout.putstring["  -> " || fileName || "\n"]
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
        home$stdout.putstring["Hash: " || files[i] || " - File name: " || nodesNames || "\n"]
    end for
  end listFiles

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
            home$stdout.putstring["A node was disconnected. There are currently " || home.getActiveNodes.upperbound.asstring || " active peer(s).\n"]
          end unavailable
        end
      end for
      home.delay[Time.create[5, 0]]
    end loop
  end process

  initially
    home$stdout.putstring["Starting nopester server...\n"]
  end initially
end Server
