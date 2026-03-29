





class slave_seq extends uvm_sequence #(slave_trans);

 `uvm_object_utils(base_seq)
 
 extern function new(string name = "slave_seq");
  
endclass

function slave_seq::new(string name = "slave_seq");

  super.new(name);
  
endfunction


//------------------------------------------------------


class delay_seq extends slave_seq ;

 `uvm_object_utils(delay_seq)
 
  extern function new(string name = "delay_seq");
  extern task body();
  
endclass

function delay_seq::new(string name ="delay_seq");

  super.new();
  
endfunction

task delay_seq::body();

   req = slave_trans::type_id::create("req");
   start_item(req);
   assert(req.randomize() with {no_of_delay<29;});
   
   finish_item(req);
   
endtask

//---------------------------------------------------------------------

/*
class delay_seq1 extends slave_seq ;

 `uvm_object_utils(delay_seq1)
 
  extern function new(string name = "delay_seq1");
  extern task body();
  
endclass

function delay_seq1::new(string name ="delay_seq1");

  super.new();
  
endfunction

task delay_seq1::body();

   req = slave_trans::type_id::create("req");
   start_item(req);
   assert(req.randomize() with {no_of_delay==29;});
   finish_item(req);
   
endtask
*/