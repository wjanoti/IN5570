export Peer

const Peer <- class PeerClass
    attached const files <- Array.of[FileRecord].empty

    export operation addFile [ fileName : String ]
      files.addUpper[FileRecord.create[fileName, hashImplementation.hash[fileName]]]
      Server.registerFile[fileName, hashImplementation.hash[fileName], self]
    end addFile

    export operation getFiles -> [ fileList : Array.of[FileRecord] ]
      fileList <- files
    end getFiles

    export operation ping
      %noop
    end ping

end PeerClass
