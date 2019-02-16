% this is what a class looks like without using the class keyword
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

const main <- object main
  initially
    const oleks <- Person.create["Oleks"]
    stdout.putstring[oleks.getName || "\n"]
    const eric <- Person.create["Eric"]
    stdout.putstring[eric.getName || "\n"]
  end initially
end main
