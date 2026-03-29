



class base_seq extends uvm_sequence #(master_trans);

 `uvm_object_utils(base_seq)
 
 extern function new(string name = "base_seq");
  
endclass

function base_seq::new(string name = "base_seq");

  super.new(name);
  
endfunction

//==================================================================================================================
 
//-----------------------------------------------small_seq---------------------------------------------------------

//==================================================================================================================

class small_seq extends base_seq ;

 `uvm_object_utils(small_seq)
 
 bit [1:0]address;
 
  extern function new(string name = "small_seq");
  extern task body();
  
endclass

function small_seq::new(string name ="small_seq");

  super.new(name);
  
endfunction


task small_seq::body();

if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",address))
    `uvm_fatal("address","check the set was done correct or not");

   req = master_trans::type_id::create("req");
   
   start_item(req);
  
                  // assert(req.randomize());
                  //assert(req.randomize() with {header[7:2] inside {[23:1]};});
   
   assert(req.randomize() with {header[1:0] == address;header[7:2] inside {[1:15]};});
    `uvm_info("debug1",$sformatf("seq_me:%0s",req.sprint),UVM_NONE);
   finish_item(req);


 
endtask



//==================================================================================================================
 
//-----------------------------------------------medium_seq---------------------------------------------------------

//==================================================================================================================



class medium_seq extends base_seq ;

 `uvm_object_utils(medium_seq)
 
 bit [1:0]address;
 
  extern function new(string name = "medium_seq");
  extern task body();
  
endclass

function medium_seq::new(string name ="medium_seq");

  super.new(name);
  
endfunction


task medium_seq::body();

if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",address))
    `uvm_fatal("address","check the set was done correct or not");

   req = master_trans::type_id::create("req");
   
   start_item(req);
  
                  // assert(req.randomize());
                  //assert(req.randomize() with {header[7:2] inside {[16:32]};});
   
   assert(req.randomize() with {header[1:0]==address;header[7:2] inside {[16:31]};});
   
   `uvm_info("debug1",$sformatf("seq_me:%0s",req.sprint),UVM_NONE);
   
   finish_item(req);


 
endtask

 
//==================================================================================================================
 
//-----------------------------------------------large_seq---------------------------------------------------------

//==================================================================================================================



class large_seq extends base_seq ;

 `uvm_object_utils(large_seq)
 
 bit [1:0]address;
 
  extern function new(string name = "large_seq");
  extern task body();
  
endclass

function large_seq::new(string name ="large_seq");

  super.new(name);
  
endfunction


task large_seq::body();

if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",address))
    `uvm_fatal("address","check the set was done correct or not");

   req = master_trans::type_id::create("req");
   
   start_item(req);
  
                  // assert(req.randomize());
                  //assert(req.randomize() with {header[7:2] inside {[41:60]};});
   
   assert(req.randomize() with {header[1:0]==address;header[7:2] inside {[32:63]};});
    `uvm_info("debug1",$sformatf("seq_me:%0s",req.sprint),UVM_NONE);
   finish_item(req);


 
endtask
































//-----------------------------medium_seq------------------------------
/*
class medium_seq extends base_seq ;

`uvm_object_utils(medium_seq)

bit[1:0]address;

extern function new(string name = "medium_seq");
extern task body();
  
endclass

function medium_seq::new(string name ="medium_seq");
  super.new();  
endfunction

 task medium_seq::body();

if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"address",address))
    `uvm_fatal("address","check the set was done correct or not");

 req = master_trans::type_id::create("req");
 start_item(req);
 assert(req.randomize() with {header[1:0] == address;header[7:2] inside {[24:45]};});
 finish_item(req);
 

endtask
*/

//------------------------------large_seq-------------------------------------------
/*
class large_seq extends base_seq;
 
 `uvm_object_utils(large_seq);

bit[1:0]address;

extern function new(string name = "large_seq");
extern task body();

endclass

function large_seq::new(string name ="large_seq");
  super.new();
endfunction

task large_seq::body();

   
if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"address",address))
    `uvm_fatal("address","check the set was done correct or not");

 req = master_trans::type_id::create("req");
 start_item(req);
 assert(req.randomize() with {header[1:0] == address;header[7:2] inside {[30:50]};});
 finish_item(req);
  

endtask

*/

//---------------------------------------------------------------------------------------------------------------------





   
   
   
   
   
  
   
   
