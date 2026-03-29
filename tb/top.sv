

module top;

   import router_pkg::*;
   import uvm_pkg::*;
   
   bit clk;
   
   always begin
      #5 clk=~clk;
   end
   
   
    master_inf vif(clk);
    slave_inf  vif0(clk);
    slave_inf  vif1(clk);
    slave_inf  vif2(clk);
    
    
router_top DUV(.clock(clk),.data_in(vif.data_in),.resetn(vif.resetn),.pkt_valid(vif.pkt_valid),.err(vif.error),.busy(vif.busy),
                                         .data_out_0(vif0.data_out),.data_out_1(vif1.data_out),.data_out_2(vif2.data_out),
                                         .vld_out_0(vif0.vld_out),.vld_out_1(vif1.vld_out),.vld_out_2(vif2.vld_out),
                                         .read_enb_0(vif0.read_enb),.read_enb_1(vif1.read_enb),.read_enb_2(vif2.read_enb) ); 
                                         


             
   initial begin                       
     uvm_config_db #(virtual master_inf)::set(null,"*","vif",vif);
     uvm_config_db #(virtual slave_inf)::set(null,"*","vif0",vif0);
     uvm_config_db #(virtual slave_inf)::set(null,"*","vif1",vif1);
     uvm_config_db #(virtual slave_inf)::set(null,"*","vif2",vif2);
     run_test();
   end


property busy_check;
 @(posedge clk) $rose(vif.pkt_valid)|=>vif.busy;
endproperty


property stable_data;
 @(posedge clk) vif.busy |=> $stable(vif.data_in);
endproperty


property valid_signal;
 @(posedge clk) $rose(vif.pkt_valid) |-> ##3(vif0.vld_out|vif1.vld_out|vif2.vld_out);
endproperty


property rd_enb1;
@(posedge clk) vif0.vld_out|->##[1:29]vif0.read_enb;
endproperty


property rd_enb2;
@(posedge clk) vif1.vld_out|->##[1:29]vif1.read_enb;
endproperty


property rd_enb3;
@(posedge clk) vif2.vld_out|->##[1:29]vif2.read_enb;
endproperty


property rd_enb_low1;
@(posedge clk) $fell(vif0.vld_out) |=> $fell(vif0.read_enb);
endproperty


property rd_enb_low2;
@(posedge clk) $fell(vif1.vld_out) |=> $fell(vif1.read_enb);
endproperty



property rd_enb_low3;
@(posedge clk) $fell(vif2.vld_out) |=> $fell(vif2.read_enb);
endproperty


C1: assert property(stable_data);
C2: assert property(busy_check); 
C3: assert property(rd_enb1);
C4: assert property(rd_enb2);
C5: assert property(rd_enb3);
C6: assert property(rd_enb_low1);
C7: assert property(rd_enb_low2);
C8: assert property(rd_enb_low3);




endmodule
  


    
   