module lab5_dp #(parameter DW=8, AW=8, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: output logic [7:0] encryptByte, // encrypted byte output
// TODO  output logic foundOne, // found one matching LFSR solution
// TODO: ... 
// TODO: input logic 	      clk, // clock signal 
// TODO: input logic 	      rst           // reset
   );
   


   logic [   lfsr_bitwidth-1:0] start;       // the seed value
   logic [   DW-1:0] 	    pre_len  = 'd7;  // preamble (~) length is fixed to 7 bytes         

   logic [8-1:0] 	       byteCount;


   //
   // FIFO
   // This fifo takes data from the outside (testbench) and captures it
   // Your logic reads from this fifo.
   //
   logic [7:0] 		       fInEncryptByte;  // data from the input fifo
   fifo fm (.rdDat(fInEncryptByte), .valid(fInValid),
	    .wrDat(encryptByte), .push(validIn),
	    .pop(getNext), .clk(clk), .rst(rst));
   

   // TODO:
   // TODO: detect preambleDone
   // TODO:
   
   // TODO:
   // TODO: detect packet end (i.e. 32 bytes have been processed)
   // TODO:
	
   // TODO: you might want to have 6 different sets of LFSR_state
   // TODO: signals, one belonging to each of six different possible
   // TODO: LFSRs.
   // TODO: for example: 
   // TODO:   logic [4:0] LFSR_state[6];
   // TODO:
   // TODO: and for each LFSR, keep a sticky bit 
   // TODO: (e.g. logic [5:0] match;)
   // TODO: that assumes the LFSR works, and on each
   // TODO: successive byte of the preamble, either remains
   // TODO: set or get's reset (and never set again).
   // TODO: At the end of 7 bytes of premable, you should have
   // TODO: only one of the six lfsr's still decoding premable bytes
   // TODO: correctly.
   // TODO:
   // TODO: Instantiate 6 LFSRs here (one for each of the 6 possible
   // TODO: polynomials (taps)).
   // TODO:
   // TODO: for example:
   // TODO: lfsr5b l0 (.clk ,
   // TODO:            .en   (lfsr_en),      // advance LFSR on rising clk
   // TODO:            .init (load_LFSR),    // initialize LFSR
   // TODO:            .taps(5'h1E)  , 	     // tap pattern
   // TODO:            .start , 	     // starting state for LFSR
   // TODO:            .state(LFSR_state[0]));	  // LFSR state = LFSR output 
   // TODO: lfsr5b l1 ( . . . );
   // TODO: lfsr5b l2 ( . . . );
   // TODO: lfsr5b l3 ( . . . );
   // TODO: lfsr5b l4 ( . . . );
   // TODO: lfsr5b l5 ( . . . );
				
   //
   // sticky bit logic to find matching LFSR
   //
   logic [5:0] match;   // match status for each lfsr
   always @(posedge clk) begin 
      if(rst) begin 
	 match <= 6'h3F;
      end else begin  
	 // TODO: for each of the 6 LFSRS
	 // TODO: maintain a match bit
	 // TODO: need to check for matches during the
	 // TODO: preamble.  One way to determine we
	 // TODO: are processing the preamble is
	 // TODO: fInValid & getNext & ~payload // processing a preamble byte
	 // TODO:
	 // TODO: OR
	 // TODO:
	 // TODO: you can create a signal from your controller
	 // TODO: that says we are processing a preamble byte
	 // TODO:
	 // TODO: if(.. processing a preamble byte .. ) begin
	 // TODO:    sticky bit logic for match[0], match[1], ... match[5]
	 // TODO: end 
	 end 
      end 
   end 


   

   // TODO: write an expression for plainByte
   // TODO: for example:
   // TODO: assign plainByte = {         };
   // TODO: write an expression for the starting seed (the start value)
   // TODO: for the LFSRs.  You should be able to figure this out based on
   // TODO: the value of the first encrypted byte and the knowledged that
   // TODO: the unencrypted value is the preamble byte.


	
   //
   // byte counter - count the number of bytes processed
   //
   always_ff @(posedge clk) begin 
      if (rst) begin
	 byteCount <= 'd0;
	 end else begin
	    if(incByteCount) begin 
	       byteCount <= byteCount + 'd1; 
	    end else begin 
	       byteCount <= byteCount;
	    end 
	 end
   end 	
		
   
	
endmodule // lab5_dp

