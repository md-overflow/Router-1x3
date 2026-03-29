

package router_pkg;

	import uvm_pkg::*;
 
	`include "uvm_macros.svh"
 
`include "master_trans.sv"
`include "master_agent_config.sv"
`include "slave_agent_config.sv"
`include "env_config.sv"

`include "slave_trans.sv"
`include "master_driver.sv"
`include "master_seqs.sv"
`include "master_monitor.sv"
`include "master_sequencer.sv"
`include "master_agent.sv"
`include "master_agent_top.sv"



`include "slave_driver.sv"
`include "slave_monitor.sv"
`include "slave_seqs.sv"
`include "slave_sequencer.sv"
`include "slave_agent.sv"
`include "slave_agent_top.sv"


`include "virtual_sequencer.sv"
`include "virtual_seqs.sv"
`include "scoreboard.sv"

`include "router_env.sv"

`include "router_test.sv"

endpackage
