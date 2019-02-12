const barrier <- monitor object barrierObj

  % variable to keep track of how many processes are waiting.
  var counter : Integer <- 0

  const c : Condition <- Condition.create

  export operation enter
    if counter < 4 then
      counter <- counter + 1
      stdout.putstring["One process entered the barrier. There are " || counter.asstring || " processes waiting\n"]
      wait c
    end if
    % notify waiting processes
    loop
      exit when counter == 0
      counter <- counter - 1
      signal c
      stdout.putstring["A process has been released.\n"]
    end loop

  end enter

end barrierObj

const main <- object main
    const innerObject <- object innerObject
      const p1 <- object p1
        process
          barrier.enter
        end process
      end p1
      const p2 <- object p2
        process
          barrier.enter
        end process
      end p2
      const p3 <- object p3
        process
          barrier.enter
        end process
      end p3
      const p4 <- object p4
        process
          barrier.enter
        end process
      end p4
      const p5 <- object p5
        process
          barrier.enter
        end process
      end p5
    end innerObject
end main
