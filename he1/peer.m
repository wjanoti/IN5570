export Peer

const Peer <- class PeerClass [ id : String, server : ServerType ]
    attached var files : Directory <- Directory.create

    export function getId -> [ res : String ]
      res <- id
    end getId

    export operation addFile [ fileName : String, fileContents: String ]
      var fileContentsHash : Integer <- hashImplementation.hash[fileContents]
      files.insert[fileName, fileContents]
      server.registerFile[fileName, fileContentsHash, self]
    end addFile

    export operation getFileByName [ fileName : String ] -> [ file : String ]
      file <- view files.lookup[fileName] as String
    end getFileByName

    export operation searchFileByName [ fileName : String ] -> [ peers : Array.of[PeerType] ]
      peers <- server.searchFileByName[fileName]
    end searchFileByName

    export operation ping
      %noop
    end ping

    export operation dump
      (locate server)$stdout.putstring["\n=> Peer: " || id || " @ " || (locate self)$name || "\n"]
      const fileNames <- files.list
      for i : Integer <- 0 while i <= fileNames.upperbound by i <- i + 1
        var fileContents : String <- view files.lookup[fileNames[i]] as String
        (locate server)$stdout.putstring[" - " || fileNames[i] || " -> " || fileContents || "\n"]
      end for
    end dump

end PeerClass
