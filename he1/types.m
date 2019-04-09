export PeerType
export HashAlgorithmType
export ServerType

const PeerType <- typeobject PeerType
  operation getId -> [ id : String ]
  operation addFile [ fileName : String, fileContents : String ]
  operation removeFile [ fileName : String ]
  operation getFileByName [ fileName : String ]-> [ file : String ]
  operation searchFileByName [ fileName : String ] -> [ peers : Array.of[PeerType] ]
  operation updateFile [ oldFileName : String, newFileName : String ]
  operation ping
  operation dump
end PeerType

const ServerType <- typeobject ServerType
  operation addPeer [ peer : PeerType ]
  operation registerFile [ fileName: String, fileHash : Integer, peer : PeerType ]
  operation searchFileByName [ fileName : String ]  -> [ peers : Array.of[PeerType] ]
  operation deregisterFile[ fileName: String, fileHash : Integer, peer : PeerType ]
  operation updateFile[ oldFileName: String, newFileName: String, fileHash : Integer, peer : PeerType ]
  operation dump
end ServerType

const HashAlgorithmType <- typeobject hashAlgorithm
  function hash [ s : String ] -> [ h : Integer ]
end hashAlgorithm
