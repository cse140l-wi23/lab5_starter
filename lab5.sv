// Lab 5
// CSE140L
// for use by registered cse140L students and staff only.
// All rights reserved.
module lab5 #(parameter DW=8, AW=8, byte_count=2**AW, lfsr_bitwidth=5)(
    output logic [7:0] plainByte,
    output logic       validOut,
    input logic        validIn,   // assert when there is a byte to encrypt
    input logic [7:0]  encryptByte,
    input logic	       clk, 
		       decRqst,
    output logic       done,
    input logic        rst);
   


   // TODO: declare the wires that are *outputs* of the control and datapath that are not
   // TODO: primary outputs module lab5.

   // TODO: you can use the "logic" type or "wire" type
   // TODO: for example, if your datapath has an output taps_en.
   // TODO: wire taps_en;  // load the taps
   
   //
   // datapath
   // This instantiates your datapath block. the .* says that all the ports on your block connect to wires
   // at this level with the same name. For example, if you block as an input called taps_en,
   // that port will connect to a wire called taps_en.  This is the same thing as saying
   // .taps_en(taps_en)  but a lot more concise.
   // 
   lab5_dp dp (.*);
   
   //
   // control
   // Instantiated your statemachine (control logic).
   seqsm sm (.*);

endmodule // lab5

