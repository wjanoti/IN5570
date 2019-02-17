const nameround <- object nameround
  initially
    const home : Node <- locate self
    var all : NodeList <- home$activenodes
    var elem : NodeListElement
    var friend : Node

    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      elem <- all[i]
      friend <- elem$thenode
      stdout.putstring[friend$name || "\n"]
    end for
  end initially
end nameround
