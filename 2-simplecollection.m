const SimpleCollection <- typeobject SimpleCollection
  operation add [ String ] -> [ Boolean ]
  function contains [ String ] -> [ Boolean ]
  operation remove [ name : String ] -> [ res : Boolean ]
end SimpleCollection

const set : SimpleCollection <- object set
  var data : Array.of[String] <- Array.of[String].empty

  export operation add [ name : String ] -> [ res: Boolean ]
    data.addUpper[name]
  end add

  export function contains [ name : String ] -> [ res: Boolean ]
    res <- false
    for i : Integer <- data.lowerbound while i <= data.upperbound by i <- i + 1
      if data[i] = name then
        res <- true
      end if
    end for
  end contains

  export operation remove [ name : String ] -> [ res : Boolean ]
    var tmp : String
    res <- false
    if self.contains[name] then
      if data[data.upperbound] = name then
        tmp <- data.removeupper[]
      else
        if data[data.lowerbound] = name then
          tmp <- data.removelower[]
        else
          var indexToRemove : Integer <- self.getIndex[name]
          var left : Array.of[String] <- data.getElement[data.lowerbound, indexToRemove]
          var right : Array.of[String] <- data.getElement[indexToRemove + 1, data.upperbound - indexToRemove]
          data <- left.catenate[right]
        end if
      end if
      res <- true
    end if
  end remove

  export function getIndex [ name : String ] -> [ index : Integer ]
    index <- -1
    if self.contains[name] then
      for i : Integer <- data.lowerbound while i <= data.upperbound by i <- i + 1
        if data[i] = name then
          index <- i
          exit
        end if
      end for
    end if
  end getIndex

  export operation print
    for i : Integer <- data.lowerbound while i <= data.upperbound by i <- i + 1
        stdout.putstring[data[i] || " ¦ "]
    end for
    stdout.putstring["\n"]
  end print
end set

const main <- object main
  initially
    stdout.putstring[set.add["a"].asstring || "\n"]
    stdout.putstring[set.add["b"].asstring || "\n"]
    stdout.putstring[set.add["c"].asstring || "\n"]
    stdout.putstring[set.add["d"].asstring || "\n"]
    set.print
    stdout.putstring[set.remove["b"].asstring || "\n"]
    stdout.putstring[set.remove["a"].asstring || "\n"]
    stdout.putstring[set.remove["d"].asstring || "\n"]
    set.print
  end initially
end main
