
class master_agent_top extends uvm_env;

    `uvm_component_utils(master_agent_top)
    
    env_config econfig;
    
    //master_agent_config mconfig;
    
    master_agent magent[];
    
   extern function new(string name = "master_agent_top",uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   
endclass

function master_agent_top::new(string name = "master_agent_top",uvm_component parent);
    
    super.new(name,parent);
endfunction


//-----------------------------------------build_phase---------------------------------------------------------

function void master_agent_top::build_phase(uvm_phase phase);

  super.build_phase(phase);
  
  if(!uvm_config_db #(env_config)::get(this,"","env_config",econfig))
  
     `uvm_fatal("master_top","get econfig was not working see once set")
     
    magent=new[econfig.no_of_magent];
    
    foreach(magent[i])
    magent[i] = master_agent::type_id::create($sformatf("magent[%0d]",i),this);
    
  uvm_config_db #(master_agent_config)::set(this,"*","master_agent_config",econfig.m_config);
  
endfunction


 
  