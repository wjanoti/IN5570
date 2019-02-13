const barrier <- monitor object barrierObj

  % how many processes should be held at the barrier.
  const maxProcesses : Integer <- 4

  % variable to keep track of how many processes are currently waiting.
  var counter : Integer <- 0

  const c : Condition <- Condition.create

  export operation enter[objectName:String]
    stdout.putstring["A process from object " || objectName || " has entered the barrier.\n"]

    % notify waiting processes
    if counter == maxProcesses then
      loop
        exit when counter == 0
        counter <- counter - 1
        signal c
        stdout.putstring["A process has been released. \n"]
      end loop
    end if

    counter <- counter + 1
    stdout.putstring["There are " || counter.asstring || " processes waiting\n"]
    wait c
  end enter

end barrierObj

% main program
const main <- object main
  process
    % process creation, 3 times, 4 processes
    for i : Integer <- 0 while i < 3 by i <- i + 1
      const innerObject <- object innerObject
        const p1 <- object p1
          process
            barrier.enter[nameof self]
          end process
        end p1
        const p2 <- object p2
          process
            barrier.enter[nameof self]
          end process
        end p2
        const p3 <- object p3
          process
            barrier.enter[nameof self]
          end process
        end p3
        const p4 <- object p4
          process
            barrier.enter[nameof self]
          end process
        end p4
      end innerObject
    end for
  end process
end main