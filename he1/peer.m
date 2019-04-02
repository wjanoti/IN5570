export Peer

const Peer <- class PeerClass [ id : String, server : ServerType ]
    attached const files <- Array.of[FileRecord].empty

    export function getId -> [ res : String ]
      res <- id
    end getId

    export operation addFile [ fileName : String, fileContents: String ]
      files.addUpper[FileRecord.create[fileName, fileContents, hashImplementation.hash[fileName]]]
      server.registerFile[fileName, hashImplementation.hash[fileName], self]
    end addFile

    export operation getFileList -> [ fileList : Array.of[FileRecord] ]
      fileList <- files
    end getFileList

    export operation ping
      %noop
    end ping

    export operation dump
      (locate server)$stdout.putstring["SERVER IS AT:" || (locate server)$name || "\n"]
      (locate server)$stdout.putstring["\n==== PEER INFO ====\n"]
      (locate server)$stdout.putstring["\n=> Peer: " || id || " @ " || (locate self)$name || "\n"]
      var fileList : Array.of[FileRecord] <- self.getFileList
      for i : Integer <- 0 while i <= fileList.upperbound by i <- i + 1
        (locate server)$stdout.putstring[" - " || fileList[i].getFileName || "-" || fileList[i].getFileContents || "\n"]
      end for
    end dump

end PeerClass
