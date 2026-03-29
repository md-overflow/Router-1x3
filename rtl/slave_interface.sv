


interface slave_inf(input bit clk);

  logic [7:0]data_out;
  logic vld_out,read_enb;
  
clocking driver_cb@(posedge clk);
  default input #1 output #1;
  output read_enb;
  input  vld_out,data_out;
  
endclocking

clocking monitor_cb@(posedge clk);
   default input #1 output #1;
   input read_enb,vld_out,data_out;
   
endclocking


modport drv(clocking driver_cb);
modport mon(clocking monitor_cb);

endinterface