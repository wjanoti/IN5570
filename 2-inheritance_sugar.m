const Person <- class Person [ name : String ]
  export function getName -> [ res: String ]
    res <- name
  end getName
end Person

const Teacher <- class Teacher ( Person ) [ position : String ]
  export function getPosition -> [ res : String ]
    res <- position
  end getPosition
end Teacher

const main <- object main
  initially
    const oleks <- Person.create["Oleks"]
    stdout.putstring[oleks.getName || "\n"]

    const eric <- Teacher.create["Eric", "Professor"]
    stdout.putstring[eric.getName || "\n"]
    stdout.putstring[eric.getPosition || "\n"]
  end initially
end main
