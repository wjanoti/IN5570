export PeerType
export HashAlgorithmType
export FileRecord

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
