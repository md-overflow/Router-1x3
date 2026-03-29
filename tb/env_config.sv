

 
class env_config extends uvm_object;

  `uvm_object_utils(env_config)

  int no_of_magent =1;
  
  int no_of_sagent =3;
  
  master_agent_config m_config;
  
  slave_agent_config s_config[];
 
  bit has_master_agent_top=1;
  bit has_slave_agent_top=1;
  bit has_score_board=1;
  bit has_virtual_sequencer=1;
  
  
  
  extern function new(string name = "env_config");
  
endclass

function env_config::new(string name = "env_config");
   
  super.new(name);
  
endfunction


  