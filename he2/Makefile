compile:
		ec typedefs.m generic_replica.m primary_replica.m node_event_handler.m pcrframework.m testObject.m test.m
compile_planetlab:
		ec32 typedefs.m generic_replica.m primary_replica.m node_event_handler.m pcrframework.m testObject.m test.m
run:
		emx -R$(host) typedefs.x generic_replica.x primary_replica.x node_event_handler.x pcrframework.x testObject.x test.x
run_planetlab:
		emx32 -R$(host) typedefs.x generic_replica.x primary_replica.x node_event_handler.x pcrframework.x testObject.x test.x
clean:
		rm *.x
