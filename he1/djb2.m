export djb2
export hashAlgorithm

const hashAlgorithm <- typeobject hashAlgorithm
  function hash [ s : String ] -> [ h : Integer ]
end hashAlgorithm

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
