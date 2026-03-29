  
class master_trans extends uvm_sequence_item;

 `uvm_object_utils(master_trans)
 
 rand bit[7:0] header,payload[];
      bit[7:0] parity;      
      bit error;
      
      constraint addr{header[1:0] != 2'b11;}
      constraint valid_lenght{header[7:2] != 0;}
      constraint size{payload.size == header[7:2];}
      
 extern function new(string name = "master_trans");
 extern function void post_randomize();
 extern function void do_print(uvm_printer printer);
 
 endclass
 //------------------------------------------------------------------------------------------
 
 function master_trans::new(string name = "master_trans");
      super.new(name);
 endfunction
 
 //---------------------------------------post_randomize------------------------------------
 
 function void master_trans::post_randomize();
     parity = header ^0;
     foreach(payload[i])
         parity = parity^payload[i];
 endfunction
 
 
 //---------------------------------------do_print-------------------------------------------
 
 
 function void master_trans::do_print(uvm_printer printer);
         
         printer.print_field( "header",this.header,8,UVM_BIN);
         
         foreach(payload[i])
             printer.print_field($sformatf("payload[%0d]",i) , this.payload[i] ,8 ,UVM_DEC);
         
         printer.print_field( "parity",this.parity,8,UVM_DEC);
 endfunction
