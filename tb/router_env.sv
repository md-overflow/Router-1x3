

class router_env extends uvm_env;

  `uvm_component_utils(router_env)
  
  master_agent_top m_agent;
  
  slave_agent_top s_agent;
  
  env_config econfig;
  
  virtual_sequencer v_seqr;
  
  scoreboard  scr; 
  
  extern function new(string name = "router_env",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  
endclass

  function router_env::new(string name = "router_env",uvm_component parent);
       super.new(name,parent);
  endfunction
  
    
//---------------------------------------------------build_phase----------------------------------------------------------
  
  
function void router_env::build_phase(uvm_phase phase);
       
       if(!uvm_config_db #(env_config)::get(this,"","env_config",econfig))
           
           `uvm_fatal("ENV","get econfig was not working see once set");
           
       super.build_phase(phase);
       
       
       
       if(!econfig.has_master_agent_top)
           `uvm_error("ENV","has_master_agent_top");
           
       m_agent = master_agent_top::type_id::create("m_agent",this);
       
       
       
       if(!econfig.has_slave_agent_top)
            `uvm_error("ENV","has_slave_agent_top");
            
       s_agent = slave_agent_top::type_id::create("s_agent",this);
       
       
       
       if(!econfig.has_virtual_sequencer)
            `uvm_error("ENV","has_virtual_sequencer");
            
       v_seqr = virtual_sequencer::type_id::create("v_seqr",this);
       
       
       if(!econfig.has_score_board)
            `uvm_error("ENV","has_score_board");
            
       scr = scoreboard::type_id::create("scr",this);
   
endfunction
   
function void router_env::connect_phase(uvm_phase phase);

  if(econfig.has_virtual_sequencer)
      begin
          if(econfig.has_master_agent_top)
          begin
             for(int i=0 ; i<econfig.no_of_magent ; i++)
                v_seqr.m_seqr[i]=m_agent.magent[i].seqr;
          end
          if(econfig.has_slave_agent_top)
          begin
             for(int i=0 ; i<econfig.no_of_sagent ; i++)
                v_seqr.s_seqr[i]=s_agent.sagent[i].seqr;
          end
      end
      
   if(econfig.has_score_board)
     begin
        m_agent.magent[0].mon.monitor_port.connect(scr.m_fifo.analysis_export);
        
     foreach(m_agent.magent[i])
        begin
        s_agent.sagent[i].mon.monitor_port.connect(scr.s_fifo[i].analysis_export);
        end
     end
      
endfunction


                

       