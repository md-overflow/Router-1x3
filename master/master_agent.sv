

  
  
  
class master_agent extends uvm_agent; 
    
    `uvm_component_utils(master_agent)
    
 master_monitor mon;
 master_driver driv;
 master_sequencer seqr;
 master_agent_config mconfig;
 
 extern function new(string name = "master_agent",uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);
 
 endclass
 
 function master_agent::new(string name ="master_agent", uvm_component parent);
 
  super.new(name,parent);
  
  endfunction
  
//-----------------------------------build_phase-------------------------------------------
  
function void master_agent::build_phase(uvm_phase phase);
 
 super.build_phase(phase);
 
  if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",mconfig))
     
     `uvm_fatal("CONFIG","cannot get() mconfig from uvm_config_db. Have you set() it?");
        
   mon = master_monitor::type_id::create("mon",this);
   
   if(mconfig.is_active==UVM_ACTIVE)
    begin
   
   seqr = master_sequencer::type_id::create("seqr",this);
   driv = master_driver::type_id::create("driv",this);
   
  end

endfunction
   
//------------------------------------connect_phase--------------------------------------------


function void master_agent::connect_phase(uvm_phase phase);

		if(mconfig.is_active==UVM_ACTIVE)
		begin
		driv.seq_item_port.connect(seqr.seq_item_export);
      
  		end
endfunction
 