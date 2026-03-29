 


interface master_inf(input bit clk);

   logic [7:0]data_in;
   logic resetn,pkt_valid,error,busy;


clocking driver_cb@(posedge clk);
   
   default input #1 output #1;
   
   output pkt_valid,resetn,data_in;
   input busy;
   
endclocking

clocking monitor_cb@(posedge clk);
  
   default input #1 output #1;
   
   input pkt_valid,resetn,data_in,busy;
   
endclocking


modport drv(clocking driver_cb);
modport mon(clocking monitor_cb);

endinterface