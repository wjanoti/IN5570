const PrimGen <- class PrimGen
  var a: Array.of[Boolean]
  var currentIndex : Integer <- 2

  operation calculateSieve
    for i : Integer <- 2 while i <= 10 by i <- i + 1
      if a[i] then
        for j : Integer <- i*i while j <= 100 by j <- j + i
          a[j] <- false
        end for
      end if
    end for
  end calculateSieve

  export operation next -> [ res : Integer ]
    if a[currentIndex] then
      res <- currentIndex
      currentIndex <- currentIndex # 99 + 2
    else
      currentIndex <- currentIndex # 99 + 2
      res <- self.next
    end if
  end next

  export operation count -> [ res : Integer ]
    var count : Integer <- 0
    for i : Integer <- 2 while i <= 100 by i <- i + 1
      if a[i] then
        count <- count + 1
      end if
    end for
    res <- count
  end count

  initially
    a <- Array.of[Boolean].create[99]
    a.slideTo[2]
    self.calculateSieve
  end initially
end PrimGen

const main <- object main
  initially
    const primeGen <- PrimGen.create[]
    var numberOfPrimes : Integer <- 0
    for i : Integer <- 0 while i < 36 by i <- i + 1
      stdout.putstring[primeGen.next.asstring || "\n"]
    end for
    stdout.putstring["There are " || primeGen.count.asstring || " prime numbers between 2 and 100\n"]
  end initially
end main
