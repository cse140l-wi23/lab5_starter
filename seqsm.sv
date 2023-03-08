module seqsm #(parameter DW=8, AW=8, byte_count=2**AW) 
   (
// TODO: define your outputs and inputs
    input logic clk,
    input logic rst
    );


   // TODO: define your states
   // TODO: here is one suggestion, but you can implmenet any number of states
   // TODO: you like
   // TODO: typedef enum {
   // TODO:		 Idle, LoadLFSR, ProcessPreamble, Decrypt, Done
   // TODO:		 } states_t;
   // TODO: for example
   // TODO:  1: Idle -> 
   // TODO:  2: LoadLFSR ->
   // TODO:  3: ProcessPreamble (and select LFSR)
   // TODO:  4: Decrypt
   // TODO:  5: Done

   // TODO: implement your state machine
   // TODO:
   // TODO: // sequential part
   // TODO: always_ff @(posedge clk) begin 
   // TODO:     . . .
   // TODO: end
   // TODO:
   // TODO: // combinatorial part
   // TODO: always_comb begin
   // TODO:     . . .
   // TODO: end
endmodule // seqsm
