const Person <- object PersonCreator

  const PersonType <- typeobject PersonType
      function getName -> [ res : String ]
  end PersonType

  export function getSignature -> [ r : Signature ]
      r <- PersonType
  end getSignature

  export operation create [ name: String ] -> [ ret : PersonType ]
      ret <- object Person
        export function getName -> [ res : String ]
           res <- name
        end getName
      end Person
  end create

end PersonCreator

% not really inheritance, we just copy the operations inside the Teacher class...
const Teacher <- immutable object Teacher

  const TeacherType <- typeobject TeacherType
    operation getname -> [ res : String ]
    operation getposition -> [ res : String ]
  end TeacherType


  export operation create [ name : String, position: String ] -> [ res : TeacherType ]
    res <- object Teacher

      export operation getName -> [ res : String ]
        res <- name
      end getName

      export operation getposition -> [ res : String ]
        res <- position
      end getposition

    end Teacher
  end create

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
