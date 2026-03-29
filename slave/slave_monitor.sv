





class slave_monitor extends uvm_monitor;

 `uvm_component_utils(slave_monitor)
 
 virtual slave_inf.mon vif;
 slave_agent_config sconfig;
 uvm_analysis_port #(slave_trans) monitor_port;
 
extern function new(string name ="slave_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task collect_data();

endclass


function slave_monitor::new(string name ="slave_monitor",uvm_component parent);

super.new(name,parent);

endfunction


//---------------------------build_phase---------------------------------

function void slave_monitor::build_phase(uvm_phase phase);

if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sconfig))


   `uvm_fatal("s_cfg","set was not done in proper way");
   
   monitor_port=new("monitor_port",this);
   
endfunction

//-----------------------------conncet_phase-----------------------------

function void slave_monitor::connect_phase(uvm_phase phase);

vif = sconfig.vif;

endfunction

//-----------------------------run_phase---------------------------------

task slave_monitor::run_phase(uvm_phase phase);

forever
   collect_data();
endtask

//------------------------------------------------------------------------

task slave_monitor::collect_data();

  slave_trans trans;
  
  trans=slave_trans::type_id::create("trans");
  
  wait(vif.monitor_cb.read_enb ==1)
  @(vif.monitor_cb);
  
  trans.header =vif.monitor_cb.data_out;
  
  trans.payload=new[trans.header[7:2]];
  @(vif.monitor_cb);
  
  foreach(trans.payload[i])
    begin
    trans.payload[i]=vif.monitor_cb.data_out;
    @(vif.monitor_cb);
    end
  trans.parity =vif.monitor_cb.data_out;
  
  trans.print();
  monitor_port.write(trans);
  endtask
  
  