



class virtual_sequence extends uvm_sequence #(uvm_sequence_item);

	`uvm_object_utils(virtual_sequence)
 
 virtual_sequencer v_seqr;
 master_sequencer m_seqr[];
 slave_sequencer s_seqr[];
 env_config e_cfg;
 
   extern function new(string name="virtual_sequence");
   extern task body();
   
endclass
 

//--------------------

function virtual_sequence::new(string name="virtual_sequence");
    super.new(name);
    
endfunction

//-------------------------------------------------------------------------------------------------------------

task virtual_sequence::body();

   if(!uvm_config_db #(env_config)::get(null,get_full_name(),"env_config",e_cfg))
       `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
 
     m_seqr= new[e_cfg.no_of_magent];
     s_seqr= new[e_cfg.no_of_sagent];
     
 assert($cast(v_seqr,m_sequencer)) else
    begin
    `uvm_error("body","error in $cast");
    end
    
 foreach(m_seqr[i])
    m_seqr[i]=v_seqr.m_seqr[i];
 foreach(s_seqr[i])
    s_seqr[i]=v_seqr.s_seqr[i];
    
endtask


//=====================================================================================================================

//-------------------------------------------small_vseq----------------------------------------------------------------

//=====================================================================================================================
 
 
class small_vseq extends virtual_sequence;

    `uvm_object_utils(small_vseq)
    
    bit[1:0]address;
    small_seq s_seq;
    delay_seq d_seq;
    
    extern function new(string name = "small_vseq");
    extern task body();
    
endclass


function small_vseq::new(string name = "small_vseq");
     super.new();
endfunction

task small_vseq::body();
     super.body();
     
     if(!uvm_config_db #(bit[1:0])::get(null,get_full_name,"bit[1:0]",address))
        `uvm_fatal("address","check the set was done correct or not");
        
     s_seq = small_seq::type_id::create("s_seq");
     d_seq = delay_seq::type_id::create("d_seq");
     
     fork
         begin
            s_seq.start(m_seqr[0]);
         end
         
         begin
            if(address==2'b00)
            d_seq.start(s_seqr[0]);
            if(address==2'b01)
            d_seq.start(s_seqr[1]);			
            if(address==2'b10)
            d_seq.start(s_seqr[2]);
         end 
     join
endtask

//=====================================================================================================================

//-------------------------------------------medium_vseq---------------------------------------------------------------

//=====================================================================================================================
 
 
class medium_vseq extends virtual_sequence;

   `uvm_object_utils(medium_vseq)
   
   bit[1:0]address;
  medium_seq m_seq;
  delay_seq d_seq;
  
  extern function new(string name = "medium_vseq");
  extern task body();
  
endclass

function medium_vseq::new(string name = "medium_vseq");
   super.new(name);
endfunction

task medium_vseq::body();
super.body();

    if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",address))
        `uvm_fatal("address","check the set was done correct or not");
	
	m_seq = medium_seq::type_id::create("m_seq");
	d_seq = delay_seq::type_id::create("d_seq");
	
	fork
	    begin
	       m_seq.start(m_seqr[0]);
	    end
	    
		begin
		   if(address==2'b00)
		   d_seq.start(s_seqr[0]);
		   if(address==2'b01)
		   d_seq.start(s_seqr[1]);
		   if(address==2'b10)
		   d_seq.start(s_seqr[2]);
        end
	join
	
endtask

//=====================================================================================================================

//-------------------------------------------large_vseq---------------------------------------------------------------

//=====================================================================================================================
 
class large_vseq extends virtual_sequence;

    `uvm_object_utils(large_vseq)
	
	bit[1:0]address;
	large_seq l_seq;
	delay_seq d_seq;
 
 extern function new(string name = "large_vseq");
  extern task body();
  
endclass

function large_vseq::new(string name = "large_vseq");
   super.new(name);
endfunction

task large_vseq::body();

super.body();
 
 
	
	if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",address))
	   `uvm_fatal("address","check the set was done correct or not");
       
	   
	l_seq = large_seq::type_id::create("l_seq");
	d_seq = delay_seq::type_id::create("d_seq");
	
	fork
	    begin
	       l_seq.start(m_seqr[0]);
	    end
	    
		begin
		   if(address==2'b00)
		   d_seq.start(s_seqr[0]);
		   if(address==2'b01)
		   d_seq.start(s_seqr[1]);
		   if(address==2'b10)
		   d_seq.start(s_seqr[2]);
        end
	join

endtask










  
