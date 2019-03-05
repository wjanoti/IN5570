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
    initially
      for i : Integer <- 1 while i < 5 by i <- i + 1
        const aProcess <- object aProcess
          const number <- i
          process
            barrier.enter
            stdout.putstring["Process " || number.asstring || " has passed the barrier. \n"]
          end process
        end aProcess
      end for
    end initially
end main
