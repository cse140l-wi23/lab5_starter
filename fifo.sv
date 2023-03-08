//
// Bryan Chin UCSD - 2023
// for use with cse140L only
// all rights reserved
//
module fifo #(parameter SZ=256, WIDTH=8)
   (
    output logic [WIDTH-1:0] rdDat,
    output logic       valid,
    input logic [WIDTH-1:0] wrDat,
    input logic        push,
    input logic        pop,
    input 	       clk,
    input 	       rst);


   logic [$clog2(SZ):0] raddr;
   logic [$clog2(SZ):0] waddr;
   logic [WIDTH-1:0] 	mem[SZ];
   
   logic 		empty;
   logic 		full;

   assign empty = (raddr == waddr);
   assign full =  (raddr[$clog2(SZ)] != waddr[$clog2(SZ)]) & (raddr[$clog2(SZ)-1:0] == waddr[$clog2(SZ)-1:0]);
   assign valid = !empty;
   assign rdDat = mem[raddr];
   always @(posedge clk) begin
      if (rst) begin
	 raddr <= 'd0;
	 waddr <= 'd0;
      end else begin
	 if (push & !full) begin
	    mem[waddr] <= wrDat;
	    waddr <= (waddr + 1) % SZ;
	 end
	 if (pop & !empty) begin
	    raddr <= (raddr + 1) % SZ;
	 end
      end // else: !if(rst)
   end
endmodule // fifo
