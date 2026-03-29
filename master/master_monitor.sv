


class master_monitor extends uvm_monitor;

 `uvm_component_utils(master_monitor)
 
 virtual master_inf.mon vif;
 master_agent_config m_cfg;
 master_trans trans;
 
 
 uvm_analysis_port #(master_trans) monitor_port;
 
extern function new(string name ="master_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task collect_data();

endclass


function master_monitor::new(string name ="master_monitor",uvm_component parent);

super.new(name,parent);

endfunction


//---------------------------build_phase---------------------------------

function void master_monitor::build_phase(uvm_phase phase);

if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",m_cfg))

   `uvm_fatal("m_cfg","set was not done in proper way");
   
   monitor_port=new("monitor_port",this);
   
endfunction

//-----------------------------conncet_phase-----------------------------

function void master_monitor::connect_phase(uvm_phase phase);

vif = m_cfg.vif;

endfunction

//-----------------------------run_phase---------------------------------

task master_monitor::run_phase(uvm_phase phase);

forever
   collect_data();
endtask


task master_monitor::collect_data();


wait(~vif.monitor_cb.busy)
wait(vif.monitor_cb.pkt_valid)


trans=master_trans::type_id::create("trans");


trans.header = vif.monitor_cb.data_in;

trans.payload = new[trans.header[7:2]];
@(vif.monitor_cb);

foreach(trans.payload[i]) begin

   wait(~vif.monitor_cb.busy)
      trans.payload[i] = vif.monitor_cb.data_in;
   @(vif.monitor_cb);
  end
  
  wait(~vif.monitor_cb.busy)
  trans.parity = vif.monitor_cb.data_in;
  repeat(2)
  
  @(vif.monitor_cb);
  
  trans.print();
  
 `uvm_info("debug3",$sformatf("mon_small:%0s",trans.sprint),UVM_NONE)
 
 monitor_port.write(trans);
 
endtask


