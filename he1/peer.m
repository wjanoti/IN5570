export Peer

const Peer <- class PeerClass [ id : String, server : ServerType ]
    attached var files : Directory <- Directory.create

    export function getId -> [ res : String ]
      res <- id
    end getId

    % adds a file in the peer and registers it into the server
    export operation addFile [ fileName : String, fileContents: String ]
      var fileContentsHash : Integer <- hashImplementation.hash[fileContents]
      files.insert[fileName, fileContents]
      server.registerFile[fileName, fileContentsHash, self]
    end addFile

    % let the server know that the file is no longer available
    export operation removeFile [ fileName : String ]
      const fileContents <- view files.lookup[fileName] as String
      files.delete[fileName]
      server.updateFile[fileName, hashImplementation.hash[fileContents], self]
    end removeFile

    % delivers a file from the peer
    export operation getFileByName [ fileName : String ] -> [ file : String ]
      file <- view files.lookup[fileName] as String
    end getFileByName

    % searchs for a file by name on the server
    export operation searchFileByName [ fileName : String ] -> [ peers : Array.of[PeerType] ]
      peers <- server.searchFileByName[fileName]
    end searchFileByName

    % used by the process that checks if a peer has been disconnected
    export operation ping
      %noop
    end ping

    % prints object state
    export operation dump
      (locate server)$stdout.putstring["\n=> Peer: " || id || " @ " || (locate self)$name || "\n"]
      const fileNames <- files.list
      for i : Integer <- 0 while i <= fileNames.upperbound by i <- i + 1
        var fileContents : String <- view files.lookup[fileNames[i]] as String
        (locate server)$stdout.putstring[" - " || fileNames[i] || " -> " || fileContents || "\n"]
      end for
    end dump
end PeerClass
