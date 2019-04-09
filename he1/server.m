export Server

const Server <- object Server
  const here <- locate self
  % index of files by peer : fileHash -> Array.of[PeerType]
  var filePeersIndex : Directory <- Directory.create
  % index of file names : fileHash -> fileName
  var fileNamesIndex : Directory <- Directory.create
  % list of current registered peers
  var peerList : Directory <- Directory.create

  % adds a new peer connected to the server.
  export operation addPeer[ peer : PeerType ]
    peerList.insert[peer.getId, peer]
  end addPeer

  % register a file belonging to a peer.
  export operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]
    var fileNames : Array.of[String]

    % update the index of peers that have this file
    if filePeersIndex.lookup[fileHash.asString] == nil then
      filePeers <- Array.of[PeerType].empty
    else
      filePeers <- view filePeersIndex.lookup[fileHash.asString] as Array.of[PeerType]
    end if
    filePeers.addUpper[peer]
    filePeersIndex.insert[fileHash.asString, filePeers]

    % update the index of file names
    if fileNamesIndex.lookup[fileHash.asString] == nil then
      fileNames <- Array.of[String].empty
    else
      fileNames <- view fileNamesIndex.lookup[fileHash.asString] as Array.of[String]
    end if
    fileNames.addUpper[fileName]
    fileNamesIndex.insert[fileHash.asString, fileNames]
  end registerFile

  export operation deregisterFile[ fileName : String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]
    var fileNames : Array.of[String]
    var updatedFileNames : Array.of[String] <- Array.of[String].empty
    var updatedFilePeers : Array.of[PeerType] <- Array.of[PeerType].empty

    fileNames <- view fileNamesIndex.lookup[fileHash.asString] as Array.of[String]
    if fileNames !== nil then
      % convoluted way to remove an element from the array
      % I just copy everyone except the one I want to remove to a new one.
      for i : Integer <- 0 while i <= fileNames.upperbound by i <- i + 1
        if fileNames[i] != fileName then
            updatedFileNames.addUpper[fileNames[i]]
        end if
      end for
      fileNamesIndex.insert[fileHash.asString, updatedFileNames]
    end if

    filePeers <- view filePeersIndex.lookup[fileHash.asString] as Array.of[PeerType]
    if filePeers !== nil then
      % convoluted way to remove an element from the array
      % I just copy everyone except the one I want to remove to a new one.
      for i : Integer <- 0 while i <= filePeers.upperbound by i <- i + 1
        if filePeers[i] !== peer  then
            updatedFilePeers.addUpper[filePeers[i]]
        end if
      end for
      filePeersIndex.insert[fileHash.asString, updatedFilePeers]
    end if
  end deregisterFile

  export operation updateFile[ oldFileName: String, newFileName : String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]
    var fileNames : Array.of[String]
    var updatedFileNames : Array.of[String] <- Array.of[String].empty
    var updatedFilePeers : Array.of[PeerType] <- Array.of[PeerType].empty

    fileNames <- view fileNamesIndex.lookup[fileHash.asString] as Array.of[String]
    if fileNames !== nil then
      for i : Integer <- 0 while i <= fileNames.upperbound by i <- i + 1
        if fileNames[i] == oldFileName then
            updatedFileNames.addUpper[newFileName]
        else
           updatedFileNames.addUpper[fileNames[i]]
        end if
      end for
      fileNamesIndex.insert[fileHash.asString, updatedFileNames]
    end if
  end updateFile

  % searchs for a file by name and return a list of peers that have that file
  export operation searchFileByName [ searchTerm : String ] -> [ peers : Array.of[PeerType] ]
    const fileHashes <- fileNamesIndex.list
    for i : Integer <- 0 while i <= fileHashes.upperbound by i <- i + 1
        var fileNames :  Array.of[String] <- view fileNamesIndex.lookup[fileHashes[i]] as Array.of[String]
        for j : Integer <- 0 while j <= fileNames.upperbound by j <- j + 1
          % if the file name contains the searched term
          if fileNames[j].str[searchTerm] !== nil then
            peers <- view filePeersIndex.lookup[fileHashes[i]] as Array.of[PeerType]
          end if
        end for
    end for
  end searchFileByName

  % prints system state, server indexes and peers info
  export operation dump
    here$stdout.putstring["\n==== GLOBAL STATE BEGIN ====\n"]
    here$stdout.putstring["\n=> Connected peers:\n"]
    const peerIds <- peerList.list
    for i : Integer <- 0 while i <= peerIds.upperbound by i <- i + 1
        begin
          var peer : PeerType <- view peerList.lookup[peerIds[i]] as PeerType
          here$stdout.putstring[peerIds[i] || " @ " || (locate peer)$name || "\n"]
          unavailable
            here$stdout.putstring["Peer unavailable.\n"]
          end unavailable
        end
    end for

    here$stdout.putstring["\n=> File/Names index:\n"]
    const files <- fileNamesIndex.list
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        var fileNames : Array.of[String] <- view fileNamesIndex.lookup[files[i]] as Array.of[String]
        here$stdout.putstring[files[i] || " ->"]
        for j : Integer <- 0 while j <= fileNames.upperbound by j <- j + 1
            here$stdout.putstring[" " || fileNames[j]]
        end for
        here$stdout.putstring["\n"]
    end for

    here$stdout.putstring["\n=> Files/Peers index:\n"]
    const hashList <- filePeersIndex.list
    for i : Integer <- 0 while i <= hashList.upperbound by i <- i + 1
        var filePeerList : Array.of[PeerType] <- view filePeersIndex.lookup[hashList[i]] as Array.of[PeerType]
        here$stdout.putstring[hashList[i] || " -> "]
        for j : Integer <- 0 while j <= filePeerList.upperbound by j <- j + 1
            begin
              here$stdout.putstring[" " || filePeerList[j].getId || " @ " || (locate filePeerList[j])$name || " "]
              unavailable
                here$stdout.putstring["Peer unavailable.\n"]
              end unavailable
            end
        end for
        here$stdout.putstring["\n"]
    end for

    const peers <- peerList.list
    for i : Integer <- 0 while i <= peers.upperbound by i <- i + 1
        begin
          var peer : PeerType <- view peerList.lookup[peers[i]] as PeerType
          peer.dump
          here$stdout.putstring["\n"]
          unavailable
            here$stdout.putstring["Peer unavailable.\n"]
          end unavailable
        end
    end for
    here$stdout.putstring["\n==== GLOBAL STATE END ====\n"]
  end dump

  % process that checks every 5 seconds if a node has been disconnected.
  process
    loop
      const peerIds <- peerList.list
      for i : Integer <- 0 while i <= peerIds.upperbound by i <- i + 1
        begin
          var peer : PeerType <- view peerList.lookup[peerIds[i]] as PeerType
          peer.ping
          unavailable
            peerList.delete[peerIds[i]]
            here$stdout.putstring["A node was disconnected. There are currently " || (peerList.list.upperbound + 1).asString || " active peer(s).\n"]
          end unavailable
        end
      end for
      here.delay[Time.create[5, 0]]
    end loop
  end process

  initially
    % fix the server object on the starting node
    fix self at here
  end initially
end Server
