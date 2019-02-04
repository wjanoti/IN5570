const Person <- class Person [ name : String ]
  export function getname -> [ res : String ]
    res <- name
  end getname
end Person

const main <- object main
  initially
    const oleks <- Person.create["Oleks"]
    stdout.putstring[oleks.getName || "\n"]
    const eric <- Person.create["Eric"]
    stdout.putstring[eric.getName || "\n"]
  end initially
end main
