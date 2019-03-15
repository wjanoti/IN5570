const main <- object main
  initially
    stdout.putstring[djb2.hash["a.mp3"].asString || "\n"]
    stdout.putstring[djb2.hash["a.\\m3"].asString || "\n"]
  end initially
end main
