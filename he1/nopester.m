% Type objects BEGIN
const PeerType <- typeobject PeerType
  operation addFile [ fileName : String ]
  operation numberOfFiles -> [ n : Integer ]
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

const Peer <- class PeerClass [ server : Node ]
    const serverNode <- server
    const hashImplementation <- djb2
    attached const files <- Array.of[FileRecord].empty

    export operation addFile [ fileName : String ]
      files.addUpper[FileRecord.create[fileName, hashImplementation.hash[fileName]]]
    end addFile

    export operation numberOfFiles -> [ n : Integer ]
      n <- files.upperbound + 1
    end numberOfFiles

    export operation getFiles -> [ fileList : Array.of[FileRecord] ]
      fileList <- files
    end getFiles

    export operation ping
      %noop
    end ping

end PeerClass

const NopesterServer <- object NopesterServer
  const home <- locate self
  var activeNodes : NodeList <- home.getActiveNodes
  var peerList : Array.of[PeerType]
  var aNode : Node
  var peerObject : PeerType
  const testFiles <- { "a.mp3", "b.mp3", "c.mp3", "d.mp3" }

  export operation distributePeers
    stdout.putstring["There are " || activeNodes.upperbound.asstring || " peers...\n"]
    for i : Integer <- 0 while i < activeNodes.upperbound + 1 by i <- i + 1
      aNode <- activeNodes[i].getTheNode
      if aNode !== home then
        peerObject <- Peer.create[home]
        peerObject.addFile[testFiles[i]]
        fix peerObject at aNode
        peerList.addUpper[peerObject]
      end if
    end for
  end distributePeers

  export operation listAvailableFiles
    var peerFileList : Array.of[FileRecord]
    stdout.putstring["Available files\n"]
    for i : Integer <- 0 while i <= peerList.upperbound by i <- i + 1
      if peerList[i] !== nil then
        peerFileList  <- peerList[i].getFiles
        for j : Integer <- 0 while j <= peerFileList.upperbound by j <- j + 1
          stdout.PutString["-" || peerFileList[j].getfileName || "\n"]
        end for
      end if
    end for
  end listAvailableFiles

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
    peerList <- Array.of[PeerType].empty
    stdout.putstring["Starting nopester server...\n"]
    stdout.putstring["There are " || home.getActiveNodes.upperbound.asstring || " active peers \n"]
    self.distributePeers
    self.listAvailableFiles
  end initially
end NopesterServer
