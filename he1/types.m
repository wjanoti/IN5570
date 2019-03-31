export PeerType
export HashAlgorithmType
export FileRecord
export ServerType

const PeerType <- typeobject PeerType
  operation getId -> [ id : String ]
  operation addFile [ fileName : String ]
  operation getFileList -> [ fileList : Array.of[FileRecord] ]
  operation ping
  operation dump
end PeerType

const ServerType <- typeobject ServerType
  operation addPeer[ peer : PeerType ]
  operation registerFile[ fileName: String, fileHash : Integer, peer : PeerType ]
  operation listAvailableFiles
  operation listFiles
  operation dump
end ServerType

const HashAlgorithmType <- typeobject hashAlgorithm
  function hash [ s : String ] -> [ h : Integer ]
end hashAlgorithm

const FileRecord <- record FileRecord
  var fileName : String
  var fileHash : Integer
end FileRecord
