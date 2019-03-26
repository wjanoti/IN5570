% Type objects BEGIN
const PeerType <- typeobject PeerType
  operation addFile [ fileName : String ]
  operation getFiles -> [ fileList : Array.of[FileRecord] ]
  operation ping
end PeerType

const HashAlgorithmType <- typeobject hashAlgorithm
  function hash [ s : String ] -> [ h : Integer ]
end hashAlgorithm

const FileRecord <- record FileRecord
  var fileName : String
  var fileHash : Integer
end FileRecord
% Type objects END

% http://www.cse.yorku.ca/~oz/hash.html
const djb2 <- object djb2
  export operation hash [ s : String ] -> [ h : Integer ]
    % hash seed
    h <- 5381
    for i : Integer <- 0 while i <= s.upperbound by i <- i + 1
       h <- ((h * 32) + h) + s[i].ord
    end for
    h <- h.abs
  end hash
end djb2


const NopesterServer <- object NopesterServer
  const home <- locate self
  var peerList : Array.of[PeerType] <- Array.of[PeerType].empty
  var filesIndex : Directory <- Directory.create

  export operation addPeer[ peer : PeerType ]
    peerList.addUpper[peer]
  end addPeer

  export operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
    var filePeers : Array.of[PeerType]
    if filesIndex.lookup[fileHash.asString] == nil then
      filePeers <- Array.of[PeerType].empty
    else
      filePeers <- view filesIndex.lookup[fileHash.asString] as Array.of[PeerType]
    end if
    filePeers.addUpper[peer]
    filesIndex.insert[fileHash.asString, filePeers]
  end registerFile

  export operation listAvailableFiles
    var peerFileList : Array.of[FileRecord]
    stdout.putstring["Available files\n"]
    for i : Integer <- 0 while i <= peerList.upperbound by i <- i + 1
      if peerList[i] !== nil then
        peerFileList  <- peerList[i].getFiles
        for j : Integer <- 0 while j <= peerFileList.upperbound by j <- j + 1
          stdout.PutString["-" || peerFileList[j].getfileName || "@" || (locate peerList[i])$name || "\n"]
        end for
      end if
    end for
  end listAvailableFiles

  export operation listFiles
    const files <- filesIndex.list
    for i : Integer <- 0 while i <= files.upperbound by i <- i + 1
        const pList <- view filesIndex.lookup[files[i]] as Array.of[PeerType]
        var nodesNames : String <- ""
        for j : Integer <- 0 while j <= pList.upperbound by j <- j + 1
            nodesNames <- nodesNames || (locate pList[j])$name || " - "
        end for
        stdout.putstring["Hash: " || files[i] || " - File name: " || nodesNames || "\n"]
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
            stdout.putstring["A node was disconnected. There are currently " || home.getActiveNodes.upperbound.asstring || " active peer(s).\n"]
          end unavailable
        end
      end for
      home.delay[Time.create[5, 0]]
    end loop
  end process

  initially
    stdout.putstring["Starting nopester server...\n"]
  end initially
end NopesterServer


const Peer <- class PeerClass [ server : Node ]
    const serverNode <- server
    const hashImplementation <- djb2
    attached const files <- Array.of[FileRecord].empty

    export operation addFile [ fileName : String ]
      files.addUpper[FileRecord.create[fileName, hashImplementation.hash[fileName]]]
      NopesterServer.registerFile[fileName, hashImplementation.hash[fileName], self]
    end addFile

    export operation getFiles -> [ fileList : Array.of[FileRecord] ]
      fileList <- files
    end getFiles

    export operation ping
      %noop
    end ping

end PeerClass

const test <- object test
  const home <- (locate self)
  var aNode : Node
  var peerObject : PeerType
  const activeNodes <- (locate self).getActiveNodes
  const testFiles <- { "a.mp3", "b.mp3", "c.mp3", "d.mp3", "e.mp3", "f.mp3" }

  initially
    for i : Integer <- 0 while i < activeNodes.upperbound + 1 by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      if aNode !== home then
        peerObject <- Peer.create[home]
        peerObject.addFile["a.mp3"]
        fix peerObject at aNode
        NopesterServer.addPeer[peerObject]
      end if
    end for
    NopesterServer.listFiles
  %  NopesterServer.listAvailableFiles
  end initially
end test
