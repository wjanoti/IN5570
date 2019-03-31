export hashImplementation

% http://www.cse.yorku.ca/~oz/hash.html
const hashImplementation : HashAlgorithmType <- object djb2
  export operation hash [ s : String ] -> [ h : Integer ]
    h <- 5381
    for i : Integer <- 0 while i <= s.upperbound by i <- i + 1
       h <- (h * 33) + s[i].ord
    end for
    h <- h.abs
  end hash
end djb2
