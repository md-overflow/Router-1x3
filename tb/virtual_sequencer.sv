
class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item) ;
   
   
	`uvm_component_utils(virtual_sequencer)

   
  env_config e_cfg;
  
  master_sequencer m_seqr[];
  slave_sequencer  s_seqr[];


 	extern function new(string name = "virtual_sequencer",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
 
endclass

//-------------------------------------------------------------------------------------
  
function virtual_sequencer::new(string name="virtual_sequencer",uvm_component parent);
		super.new(name,parent);
endfunction

  
function void virtual_sequencer::build_phase(uvm_phase phase);
		
	  if(!uvm_config_db #(env_config)::get(this,"","env_config",e_cfg))
     
	   	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
    		  
     super.build_phase(phase);
     
     m_seqr=new[e_cfg.no_of_magent];
     s_seqr=new[e_cfg.no_of_sagent];
     
    		
endfunction
