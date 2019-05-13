export NameServer

const NameServer <- class NameServer

  var dir : Directory <- Directory.create

	export operation clone -> [clone : ClonableType]
    const tmpNameServer <- NameServer.create
    const keys <- dir.list
    for i : Integer <- 0 while i <= keys.upperbound by i <- i + 1
       tmpNameServer.insert[keys[i], dir.lookup[keys[i]]]
    end for
    clone <- tmpNameServer
	end clone

	export operation lookup[name : String] -> [obj : Any]
    obj <- dir.lookup[name]
	end lookup

  export operation insert[name: String, obj: Any]
    dir.insert[name, obj]
  end insert

  export operation dump
    const keys <- dir.list
    for i : Integer <- 0 while i <= dir.list.upperbound by i <- i + 1
       (locate self)$stdout.putstring[keys[i] || " -> " || (view dir.lookup[keys[i]] as Integer).asString || "\n"]
    end for
  end dump
end NameServer
