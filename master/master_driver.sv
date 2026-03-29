



class master_driver extends uvm_driver #(master_trans);

`uvm_component_utils(master_driver)

master_agent_config ma_cfg;

virtual master_inf.drv vif;


extern function new(string name = "master_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task send_to_dut(master_trans m_trans);

endclass

function master_driver::new(string name = "master_driver",uvm_component parent);

  super.new(name,parent);
  
endfunction


//-------------------------------build_phase-------------------------------------


function void master_driver::build_phase(uvm_phase phase);

if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",ma_cfg))

   `uvm_fatal("mconfig","set was not done properly");
   //$display("%p",seq_item_port);
   
endfunction


//-------------------------------connect_phase------------------------------------


function void master_driver::connect_phase(uvm_phase phase);

vif = ma_cfg.vif;

endfunction


//-------------------------------run_phase----------------------------------------


task master_driver::run_phase(uvm_phase phase);

@(vif.driver_cb);
vif.driver_cb.resetn<=1'b0;
@(vif.driver_cb);
vif.driver_cb.resetn<=1'b1;

forever
    begin
    
    //$display("%p",seq_item_port);
   seq_item_port.get_next_item(req);
   send_to_dut(req);
   
   `uvm_info("debug2",$sformatf("drv_small:%0s",req.sprint),UVM_NONE)
   
   seq_item_port.item_done(); 
   //$display("%p",seq_item_port);
    
    
    end
endtask

task master_driver::send_to_dut(master_trans m_trans);
   
   m_trans.print();
   
   //$display("jdndnfienein");
   
    
   wait(~vif.driver_cb.busy)
        
      vif.driver_cb.pkt_valid <=1'b1;
      vif.driver_cb.data_in <=m_trans.header;
      
      @(vif.driver_cb);
      foreach(m_trans.payload[i]) begin
      
         wait(~vif.driver_cb.busy)
             vif.driver_cb.data_in<=m_trans.payload[i];
             @(vif.driver_cb);
      end
   vif.driver_cb.pkt_valid <=1'b0;
   vif.driver_cb.data_in <=m_trans.parity;
    @(vif.driver_cb);
endtask
