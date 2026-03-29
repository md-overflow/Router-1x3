


class slave_agent_top extends uvm_env;

 `uvm_component_utils(slave_agent_top)
 
 
 slave_agent_config sconfig[];
 env_config econfig;
 slave_agent sagent[];
 
  extern function new(string name = "slave_agent_top", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  
endclass


  function slave_agent_top::new(string name = "slave_agent_top", uvm_component parent);
          super.new(name,parent);
          
  endfunction
  
  //-----------------------------------build_phase----------------------------------------------------------------------------
  
  function void slave_agent_top::build_phase(uvm_phase phase);
        
   if(!uvm_config_db #(env_config)::get(this,"","env_config",econfig))
      `uvm_fatal("slave_agent_top"," check is the set env_config was done or not");
         
        sconfig = new[econfig.no_of_sagent];
        sagent  = new[econfig.no_of_sagent];
   
   foreach(sagent[i]) begin
     sagent[i]=slave_agent::type_id::create($sformatf("sagent[%0d]",i),this);
     
   	uvm_config_db #(slave_agent_config)::set(this,$sformatf("sagent[%0d]*",i),"slave_agent_config",econfig.s_config[i]);
    end
    
    super.build_phase(phase);
    
   endfunction
     
      