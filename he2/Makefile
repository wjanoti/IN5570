compile:
		ec typedefs.m replica.m pcrframework.m testObject.m test.m
compile_planetlab:
		ec32 typedefs.m pcrframework.m test.m
run:
		emx -R$(host) typedefs.x replica.x pcrframework.x testObject.x test.x
run_planetlab:
		emx32 -R$(host) typedefs.x pcrframework.x replicable_obj.x test.x
clean:
		rm *.x
