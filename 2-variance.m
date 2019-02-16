const Person <- class Person [ name : String ]
  export function getname -> [ res : String ]
    res <- name
  end getname
end Person

const Student <- class Student ( Person )
  export function ask [ a : String ] -> [ b : Any ]
    b <- a % Nothing but an echo.
  end ask
end Student

const Teacher <- class Teacher ( Person )
  export function ask [ a : Any ] -> [ b : String ]
    b <- "Always pass on what you have learned."
  end ask
end Teacher

const main <- object main
  initially
    % Student does not conform to teacher - this will fail
    const oleks : Teacher <- Student.create["Oleks"]

    % Teacher conforms to Student
    const eric : Student <- Teacher.create["Eric"]
  end initially
end main
