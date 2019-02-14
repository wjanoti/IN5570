const sharedBuffer <- monitor object sharedBuffer

  % limit of items in the array at any given moment.
  const maxBufferSize : Integer <- 2
  const data <- Array.of[Integer].empty
  const c <- Condition.create

  % helper function to get how many elements are in the array
  op count -> [i: Integer]
    if data.empty then
      i <- 0
    else
      i <- (data.upperbound.abs - data.lowerbound.abs) + 1
    end if
  end count

  export op produce[value : Integer]
    if self.count == maxBufferSize then
      stdout.putstring["Buffer is full. Producer is waiting...\n"]
      wait c
    end if

    data.addUpper[value]
    signal c
    stdout.putstring["One item has been PRODUCED => " || value.asstring || ". Buffer size is: " || self.count.asstring || "\n"]
  end produce

  export op consume -> [i : Integer]
    if !data.empty then
      i <- data.removeLower
      stdout.putstring["One item has been CONSUMED => " || i.asstring || ". Buffer size is: " || self.count.asstring || "\n"]
      signal c
    else
      stdout.putstring["Buffer is empty. Consumer is waiting...\n"]
      wait c
    end if
  end consume
end sharedBuffer

const producer <- object producer
  process
    for i : Integer <- 1 while i < 31 by i <- i + 1
       sharedBuffer.produce[i]
        if i # 3 == 0 then
        % sleep for 100ms -> 100000 microsecs.
        (locate self).delay[Time.create[0, 100000]]
      end if
    end for
  end process
end producer

const consumer <- object consumer
  var consumedItensCount : Integer <- 0
  process
    loop
      var consumedItem : Integer <- sharedBuffer.consume
      consumedItensCount <- consumedItensCount + 1
      if consumedItensCount == 5 then
        consumedItensCount <- 0
        (locate self).delay[Time.create[0, 100000]]
      end if
    end loop
  end process
end consumer
