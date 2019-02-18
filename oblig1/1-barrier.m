const barrier <- monitor object barrierObj
  % how many processes should wait at the barrier.
  const maxProcesses : Integer <- 4

  % how many processes are currently waiting.
  var currentWaitingProcesses : Integer <- 0

  const c : Condition <- Condition.create

  export operation enter
    stdout.putstring["A process has entered the barrier.\n"]

    % the thread could do some real work here, for example.

    % if there were already 3 processes waiting release them
    if currentWaitingProcesses == maxProcesses - 1 then
      loop
        exit when currentWaitingProcesses == 0
        signal c
        currentWaitingProcesses <- currentWaitingProcesses - 1
        stdout.putstring["A process has been released. \n"]
      end loop
      % otherwise wait for the others.
    else
      currentWaitingProcesses <- currentWaitingProcesses + 1
      stdout.putstring["There are " || currentWaitingProcesses.asstring || " processes waiting\n"]
      wait c
    end if
  end enter
end barrierObj

% main program
const main <- object main
    % processes creation.
    const process1 <- object process1
      process
        barrier.enter
      end process
    end process1

    const process2 <- object process2
      process
        barrier.enter
      end process
    end process2

    const process3 <- object process3
      process
        barrier.enter
      end process
    end process3

    const process4 <- object process4
      process
        barrier.enter
      end process
    end process4
end main
