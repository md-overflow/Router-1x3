


class slave_trans extends uvm_sequence_item;

 `uvm_object_utils(slave_trans)
 
 rand bit [4:0] no_of_delay;
 bit [7:0]header,parity;
 bit [7:0]payload[];
 bit valid_out,read_enb;
 
 
 extern function new(string name = "slave_trans");
 extern function void do_print(uvm_printer printer);
 endclass
 
 function slave_trans::new(string name = "slave_trans");
     super.new(name);
 endfunction
 
 
  //----------------------------------
 
function void slave_trans::do_print(uvm_printer printer);
 
 printer.print_field("header",this.header,8,UVM_BIN);
 
 foreach(payload[i])
     printer.print_field($sformatf("payload[%0d]",i) , this.payload[i] ,8 ,UVM_DEC);
         
 printer.print_field( "parity",this.parity,8,UVM_DEC);
 
endfunction