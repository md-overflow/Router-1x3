  
  
  
class slave_agent extends uvm_agent;
    
    `uvm_component_utils(slave_agent)
    
 slave_monitor mon;
 slave_driver driv;
 slave_sequencer seqr;
 slave_agent_config sconfig;
 
 extern function new(string name = "slave_agent",uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);
 
 endclass
 
 function slave_agent::new(string name = "slave_agent", uvm_component parent);
 
  super.new(name,parent);
  
  endfunction
  
  //-----------------------------------build_phase-------------------------------------------
  
function void slave_agent::build_phase(uvm_phase phase);
 
  if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sconfig))
  
    `uvm_fatal("SAGENT","slave_agent_config set was not done in proper way"); 
    
   super.build_phase(phase);
   
   mon = slave_monitor::type_id::create("mon",this);
   
   if(sconfig.is_active == UVM_ACTIVE) begin
   
   seqr = slave_sequencer::type_id::create("seqr",this);
   driv = slave_driver::type_id::create("driv",this);
   
   end
   
endfunction

//-----------------------------------connect_phase-------------------------------------------

function void slave_agent::connect_phase(uvm_phase phase);
    if(sconfig.is_active == UVM_ACTIVE)
    driv.seq_item_port.connect(seqr.seq_item_export);
    
endfunction
 