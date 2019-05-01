const test <- object test
    initially
      const primaryObject <- TestObject.create["BACON"]
      PCRFramework.replicate[primaryObject, 2]
    end initially
end test
