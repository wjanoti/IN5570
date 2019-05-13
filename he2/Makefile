compile:
		ec typedefs.m time_server.m name_server.m primary_replica.m  generic_replica.m  node_event_handler.m pcrframework.m name_server_test.m time_server_test.m
compile_planetlab:
		ec32 typedefs.m time_server.m name_server.m primary_replica.m generic_replica.m  node_event_handler.m pcrframework.m name_server_test.x
run_nameserver:
		emx -R$(host) typedefs.x name_server.x primary_replica.x generic_replica.x node_event_handler.x pcrframework.x name_server_test.x
run_nameserver_planetlab:
		emx32 -R$(host) typedefs.x name_server.x primary_replica.x generic_replica.x  node_event_handler.x pcrframework.x name_server_test.x
run_timeserver:
		emx -R$(host) typedefs.x time_server.x primary_replica.x generic_replica.x  node_event_handler.x pcrframework.x time_server_test.x
run_timeserver_planetlab:
		emx32 -R$(host) typedefs.x time_server.x primary_replica.x generic_replica.x  node_event_handler.x pcrframework.x time_server_test.x
clean:
		rm *.x
