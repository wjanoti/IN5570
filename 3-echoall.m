const main <- object main
  var input : String <- ""
  const home : Node <- locate self
  var all : NodeList <- home$activenodes
  var elem : NodeListElement
  var friend : Node

  function trunclast [ i : String ] -> [ o : String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end trunclast

  function readline -> [ o : String ]
    o <- self.trunclast [ stdin.getstring ]
  end readline

  operation propagateMessage [ msg : String ]
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      elem <- all[i]
      friend <- elem$thenode
      friend$stdout.putstring[msg || "\n"]
    end for

    % handler for when a node is unavailable, like a catch in a try catch.
    unavailable
      (locate self)$stdout.putstring["Couldn't contact node\n"]
    end unavailable
  end propagateMessage

  initially
    loop
      input <- self.readline
      exit when input = "exit"
      self.propagateMessage[input]
    end loop
  end initially

end main
