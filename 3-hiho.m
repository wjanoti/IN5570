% Tests process creation, monitors, conditions and process switching.
const initialObject <- object initialObject
  process
    const newObj <- object innerObject

      % all operations inside the monitor object are mutex'd
      const monObj <- monitor object MonitorObject
        var flip : Integer <- 0
        const c : Condition <- Condition.create

        export operation hi
          if flip = 0 then
            wait c
          end if
          stdout.putstring["hi\n"]
          flip <- 0
          signal c
        end hi

        export operation ho
          if flip != 0 then
            wait c
          end if
          stdout.putstring["ho\n"]
          flip <- 1
          signal c
        end ho
      end MonitorObject

      export operation hi
        monObj.hi
      end hi

      process
        loop
          monObj.ho
        end loop
      end process

    end innerObject

    loop
      newObj.hi
    end loop

  end process
end initialObject
