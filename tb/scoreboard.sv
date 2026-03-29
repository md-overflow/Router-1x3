


class scoreboard extends uvm_scoreboard;

  
	`uvm_component_utils(scoreboard)
   
   master_trans mtrans;
   slave_trans strans;
   
   env_config e_cfg;
   
   uvm_tlm_analysis_fifo #(master_trans) m_fifo;
   uvm_tlm_analysis_fifo #(slave_trans) s_fifo[];


 	extern function new(string name = "scoreboard",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void compare(master_trans m_trans,slave_trans s_trans);
 
 
 
 covergroup router_S;
 
 ADDER    : coverpoint mtrans.header[1:0]{
                                          bins address0 ={0};
                                          bins address1 ={1};
                                          bins address2 ={2};
                                          }
                                          
 PAYLOAD  : coverpoint mtrans.header[7:2]{
                                          bins small_S  = {[1:16]};
                                          bins medium_S = {[17:35]};
                                          bins large_S  = {[36:63]};
                                          }
 ERROR    : coverpoint mtrans.error{
                                      bins correct  = {0};
                                      bins wrong_D  = {1};
                                      
                                   }
                                   
 endgroup
 
 //--------------------
 
 covergroup router_D;
 
 ADDER_D    : coverpoint strans.header[1:0]{
                                          bins address0  ={0};
                                          bins address1  ={1};
                                          bins address2  ={2};
                                          }
                                          
 PAYLOAD_D  : coverpoint strans.header[7:2]{
                                           bins small_D  = {[1:16]};
                                           bins medium_D = {[17:35]};
                                           bins large_D  = {[36:63]};
                                          }
 endgroup
 
 
 
endclass

//-------------------------------------------------------------------------------------
  
function scoreboard::new(string name="scoreboard",uvm_component parent);
		super.new(name,parent);
   
   router_S = new();
   router_D = new();
   
endfunction

  
function void scoreboard::build_phase(uvm_phase phase);
		
	  if(!uvm_config_db #(env_config)::get(this,"","env_config",e_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
    		 super.build_phase(phase);
		
   s_fifo = new[e_cfg.no_of_sagent];
   
   m_fifo = new("m_fifo",this);
   
   foreach(s_fifo[i])
   s_fifo[i]=new($sformatf("s_fifo[%d]",i),this);
    		
endfunction

//-----------------------------------------------------------------------------------


task scoreboard::run_phase(uvm_phase phase);

    fork
        // First forever loop for handling write transactions
        forever begin
            m_fifo.get(mtrans);
            if (mtrans != null) begin
                mtrans.print();
                router_S.sample();
            end else begin
                $display("Warning: mtrans is null after get.");
            end
        end

        // Second forever loop for handling read transactions
        forever begin
            fork: A
                // Read from client 0
                begin 
                    s_fifo[0].get(strans);
                    if (strans != null) begin
                        strans.print();
                        router_D.sample();
                        if (mtrans != null) 
                            compare(mtrans, strans);
                    end else begin
                        $display("Warning: strans[0] is null after get.");
                    end
                end

                // Read from client 1
                begin 
                    s_fifo[1].get(strans);
                    if (strans != null) begin
                        strans.print();
                        router_D.sample();
                        if (mtrans != null) 
                            compare(mtrans, strans);
                    end else begin
                        $display("Warning: strans[1] is null after get.");
                    end
                end


                begin 
                    s_fifo[2].get(strans);
                    if (strans != null) begin
                        strans.print();
                        router_D.sample();
                        if (mtrans != null) 
                            compare(mtrans, strans);
                    end else begin
                        $display("Warning: strans[2] is null after get.");
                    end
                end
            join_any
            disable A; // Disable all forks in this block after one finishes
        end
    join
endtask







/*
    forever
         begin
            fork
              begin
              m_fifo.get(mtrans);
              mtrans.print;
              router_S.sample();
              end
              
              begin:A
              fork
                 begin
                    s_fifo[0].get(strans);
                    strans.print;
                    router_D.sample();
                 end
                 begin
                    s_fifo[1].get(strans);
                    strans.print;
                    router_D.sample();
                 end
                 begin
                    s_fifo[2].get(strans);
                    strans.print;
                    router_D.sample();
                 end
              join_any
              
              disable fork;
              
              end
              
              compare(mtrans,strans);
              
              join
            end
endtask
*/

function void scoreboard::compare(master_trans m_trans,slave_trans s_trans);

  if(m_trans.header == s_trans.header)
  $display("header comparison was sucess");
  else
  $display("header comparison was failed");

  if(m_trans.payload == s_trans.payload)
  $display("payload comparison was sucess");
  else
  $display("payload comparison was failed");
  
  if(m_trans.parity == s_trans.parity)
  $display("parity comparison was sucess");
  else
  $display("parity comparison was failed");
  
endfunction

















