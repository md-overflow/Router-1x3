
class slave_agent_config extends uvm_object;

`uvm_object_utils(slave_agent_config)

     virtual slave_inf vif;
  
     uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  extern function new(string name = "slave_agent_config");
  
endclass


  function slave_agent_config::new(string name = "slave_agent_config");
      super.new(name);
  endfunction