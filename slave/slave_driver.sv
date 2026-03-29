

class slave_driver extends uvm_driver;

`uvm_component_utils(slave_driver)

  virtual slave_inf.drv vif;
  slave_agent_config s_config;

extern function new(string name = "slave_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task send_to_dut(slave_trans trans1);

endclass

function slave_driver::new(string name = "slave_driver",uvm_component parent);

  super.new(name,parent);
  
endfunction

function void slave_driver::build_phase(uvm_phase phase);
 super.build_phase(phase);
 
 if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",s_config))
 
    `uvm_fatal("s_config","set was not in proper way");
    
endfunction


//-----------------------------------------------------------------------------

function void slave_driver::connect_phase(uvm_phase phase);
 vif=s_config.vif;

endfunction
 
//----------------------------------------------------------------------------

 
 task slave_driver::run_phase(uvm_phase phase);
 
 //super.run_phase(phase);
 
 forever
    begin
 
    seq_item_port.get_next_item(req);
    send_to_dut(req);
    seq_item_port.item_done();
    
 end
 endtask
 
 //------------------------------------------------
 
 task slave_driver::send_to_dut(slave_trans trans1);
 
 @(vif.driver_cb);
 wait(vif.driver_cb.vld_out)
 @(vif.driver_cb);
 
 vif.driver_cb.read_enb<=1'b1;
 
 wait(~vif.driver_cb.vld_out)
 @(vif.driver_cb);
 
 vif.driver_cb.read_enb<=1'b0;
 
 endtask
 
 
 