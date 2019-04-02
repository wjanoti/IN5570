export Server

const Server <- object Server
  const here <- locate self
  % index of files by peer : fileHash -> Array.of[PeerType]
  var filePeersIndex : Directory <- Directory.create
  % index of file names : fileHash -> fileName
  var fileNamesIndex : Directory <- Directory.create
  % list of current known peers
  var peerList : Directory <- Directory.create

  export operation addPeer[ peer : PeerType ]
    peerList.insert[peer.getId, peer]
  end addPeer

  % register a file belonging to a peer
  export operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]

    if filePeersIndex.lookup[fileHash.asString] == nil then
      filePeers <- Array.of[PeerType].empty
    else
      filePeers <- view filePeersIndex.lookup[fileHash.asString] as Array.of[PeerType]
    end if

    % add peer to peer list
    filePeers.addUpper[peer]
    % update list of
    filePeersIndex.insert[fileHash.asString, filePeers]
    fileNamesIndex.insert[fileHash.asString, fileName]
  end registerFile

  export operation searchFilesByName [ searchTerm : String ]
    const filesPeer <- filePeersIndex.list
    here$stdout.putstring["\nSearch results for: '" || searchTerm || "'\n"]
    for i : Integer <- 0 while i <= filesPeer.upperbound by i <- i + 1
        var fileName : String <- view fileNamesIndex.lookup[filesPeer[i]] as String
        if fileName.str[searchTerm] !== nil then
          here$stdout.putstring[" - " || fileName  || "\n"]
        end if
    end for
  end searchFilesByName

  export operation getFileLocation [ fileHash : Integer ]
    const filePeerList <- view filePeersIndex.lookup[fileHash.asstring] as Array.of[PeerType]
    if filePeerList == nil then
      here$stdout.putstring["File not found\n"]
    else
      for i : Integer <- 0 while i <= filePeerList.upperbound by i <- i + 1
        here$stdout.putstring["- " || filePeerList[i].getId || "\n"]
      end for
    end if

  end getFileLocation

  export operation dump
    here$stdout.putstring["\n==== SERVER INFO ====\n"]
    here$stdout.putstring["\n=> Connected peers:\n"]
    const peerIds <- peerList.list
    for i : Integer <- 0 while i <= peerIds.upperbound by i <- i + 1
        var peer : PeerType <- view peerList.lookup[peerIds[i]] as PeerType
        here$stdout.putstring[peerIds[i] || " @ " || (locate peer)$name || "\n"]
    end for

    here$stdout.putstring["\n=> File names index:\n"]
    const files <- fileNamesIndex.list
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        var fileName : String <- view fileNamesIndex.lookup[files[i]] as String
        here$stdout.putstring[fileName || " -> " || files[i] || "\n"]
    end for

    here$stdout.putstring["\n=> Peer index:\n"]
    const filesPeer <- filePeersIndex.list
    for i : Integer <- 0 while i <= filesPeer.upperbound by i <- i + 1
        var filePeerList : Array.of[PeerType] <- view filePeersIndex.lookup[filesPeer[i]] as Array.of[PeerType]
        var fileName : String <- view fileNamesIndex.lookup[filesPeer[i]] as String
        here$stdout.putstring["File " || fileName  || " can be found in the following peers: "]
        for j : Integer <- 0 while j <= filePeerList.upperbound by j <- j + 1
            here$stdout.putstring[filePeerList[j].getId || " "]
        end for
        here$stdout.putstring["\n"]
    end for

    const peers <- peerList.list
    for i : Integer <- 0 while i <= peers.upperbound by i <- i + 1
        var peer : PeerType <- view peerList.lookup[peers[i]] as PeerType
        peer.dump
        here$stdout.putstring["\n"]
    end for
  end dump

  % process that checks if a node was disconnected.
  process
    loop
      const peerIds <- peerList.list
      for i : Integer <- 0 while i <= peerIds.upperbound by i <- i + 1
        begin
          var peer : PeerType <- view peerList.lookup[peerIds[i]] as PeerType
          peer.ping
          unavailable
            peerList.delete[peerIds[i]]
            here$stdout.putstring["A node was disconnected. There are currently " || here.getActiveNodes.upperbound.asstring || " active peer(s).\n"]
          end unavailable
        end
      end for
      here.delay[Time.create[5, 0]]
    end loop
  end process

  initially
    here$stdout.putstring["SERVER:" || (locate self)$name || "\n"]
    fix self at here
    here$stdout.putstring["SERVER:" || (locate self)$name || "\n"]
    here$stdout.putstring["Starting nopester server...\n"]
  end initially
end Server
