// Lab5_tb	  
// testbench for programmable message encryption
// CSE140L     
// Pick a starting sequence;  
// Run lab 4 equivalent to encrypt
module lab5_tb;
   logic       clk               ;		   // advances simulation step-by-step
   logic      init              ;          // init (reset, start) command to DUT
   logic      wr_en             ;          // DUT memory core write enable
   logic [7:0] raddr             ,
              waddr             ,
              data_in           ;
   wire [7:0] data_out          ;
   wire       done              ;          // done flag returned by DUT
   logic [7:0] pre_length        ,          // bytes before first character in message
              msg_padded2[64]   ,		   // original message, plus pre- and post-padding
              msg_crypto2[64]   ,          // encrypted message according to the DUT
              msg_decryp2[64]   ,          // recovered decrypted message from DUT
              dutCapture[32];              // capture dut output
       
   logic [4:0] LFSR_ptrn[6]      ,		   // 6 possible maximal-length 5-bit LFSR tap ptrns
	      LFSR_init         ,		   // NONZERO starting state for LFSR		   
              lfsr_ptrn         ,          // one of 6 maximal length 6-tap shift reg. ptrns
	      lfsr2[64]         ;          // states of program 2 decrypting LFSR         
   // our original American Standard Code for Information Interchange message follows
   // note in practice your design should be able to handle ANY ASCII string
   string     str2;
   int 	     str_len                   ;		   // length of string (character count)
   int fault_count;
   // displayed encrypted string will go here:
   string str_enc2[64]       ;          // decryption program input
   string    str_dec2[64]       ;          // decrypted string will go here
   int 	     ct                        ;
   int lk                        ;		   // counts leading spaces for program 3
   int pat_sel                   ;          // LFSR pattern select

   integer cycleCount = 0;
   logic [7:0] dutCaptAddr = 0;

   // to DUT
   logic       validIn;         // encryptByte  is valid
   logic [7:0] encryptByte;     // an encrypted byte
   logic       decRqst;         // request a decryption
   logic       rst;             // reset signal
   
   // from DUT
   logic       validOut;        // from DUT
   logic [7:0] plainByte;       // from DUT
   
   lab5 dut(.*);
                // your top level design goes here 

   initial begin	 :initial_loop
      integer fd, slen;
      //
      // to use gtkwave or edaplayground (uncomment)
      // the $dumpfile and $dumpvars
      $dumpfile("dump.vcd");
      $dumpvars;

      clk   = 'b0;
      init  = 'b1;
      wr_en = 'b0;

      //
      // if this file is present, read string from this file
      //
      fd = $fopen("str.txt", "r");
      if (fd) begin
	 slen = $fgets(str2, fd);
	 $fclose(fd);
      end else begin
	 str2 = "Hey_Hamm_Look_Im_Picasso";
	 // str2 = "Sometimes_Ill_start_a_sentence_and_I_dont_even_know_where_its_going_I_just_hope_I_find_it_along_the_way";
	 // str2 = "Im_not_superstitious_but_I_am_a_little_stitious";
	 // str2 = "I_knew_exactly_what_to_do_but_in_a_much_more_real_sense_I_had_no_idea_what_to_do";
	 // str2 = "Mr_Watson_come_here_I_want_to_see_you";
	 // str2 = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
      end
      str_len = str2.len     ;
      
      
      if(str_len>(32-7)) begin
	 $display("illegally long string of length %d, truncating to 25 chars.",str_len);
	 str_len=(32-7);
      end

      //    for(int ml=50; ml<64; ml++)
      //      str2[ml] = 8'h7E;
      // the 6 possible (constant) maximal-length feedback tap patterns from which to choose

      LFSR_ptrn[0] = 5'h1E;           //  and check for correct results from your DUT
      LFSR_ptrn[1] = 5'h1D;
      LFSR_ptrn[2] = 5'h1B;
      LFSR_ptrn[3] = 5'h17;
      LFSR_ptrn[4] = 5'h14;
      LFSR_ptrn[5] = 5'h12;

      // set preamble lengths for the program runs (always > 6)
      // ***** choose any value > 6 *****
      pre_length                    = 7;    // values 7 to 12 enforced by test bench
      if(pre_length < 7) begin
	 $display("illegally short preamble length chosen, overriding with 7");
	 pre_length =  7;
      end                       // override < 6 with a legal value

      if(pre_length > 12) begin
	 $display("illegally long preamble length chosen, overriding with 12");
	 pre_length = 12;
      end else
	$display("preamble length = %d", pre_length);

      // select LFSR tap pattern
      // ***** choose any value < 6 *****
      pat_sel =  2;
      if(pat_sel > 5) begin 
	 $display("illegal pattern select chosen, overriding with 3");
	 pat_sel = 3;                         // overrides illegal selections
      end  
      else
	$display("tap pattern %d selected",pat_sel);
      // set starting LFSR state for program -- 
      // ***** choose any 6-bit nonzero value *****
      LFSR_init = 5'h01;                     // for program 2 run
      if(!LFSR_init) begin
	 $display("illegal zero LFSR start pattern chosen, overriding with 6'h01");
	 LFSR_init = 5'h01;                   // override 0 with a legal (nonzero) value
      end
      else
	$display("LFSR starting pattern = %b",LFSR_init);
      $display("original message string length = %d",str_len);
      for(lk = 0; lk<str_len; lk++)
	if(str2[lk]==8'h7E) continue;	       // count leading ~ chars in string
	else break;                          // we shall add these to preamble pad length
      $display("embedded leading 0x7E (~) count = %d",lk);

      // precompute encrypted message
      lfsr_ptrn = LFSR_ptrn[pat_sel];        // select one of the 6 permitted tap ptrns

      // write the three control settings into data_memory of DUT
      lfsr2[0]     = LFSR_init;              // any nonzero value (zero may be helpful for debug)

      $display("run encryption of this original message: ");
      $display("%s",str2)        ;           // print original message in transcript window
      $display();
      $display("LFSR_ptrn = %h, LFSR_init = %h %h",lfsr_ptrn,LFSR_init,lfsr2[0]);

      for(int j=0; j<32; j++) 			   // pre-fill message_padded with ASCII ~ characters
	msg_padded2[j] = 8'h7E;         
      
      for(int l=0; l<str_len; l++)  		   // overwrite up to str_len of these spaces w/ message itself
	msg_padded2[pre_length+l] = byte'(str2[l]); 

      // compute the LFSR sequence
      for (int ii=0;ii<63;ii++) begin :lfsr_loop
	 lfsr2[ii+1] = (lfsr2[ii]<<1)+(^(lfsr2[ii]&lfsr_ptrn));  // roll the rolling code
	 //      $display("lfsr_ptrn %d = %h",ii,lfsr2[ii]);
      end	  :lfsr_loop
      
      // encrypt the message
      for (int i=0; i<pre_length; i++) begin
	 msg_crypto2[i]        = msg_padded2[i] ^ {3'b0, lfsr2[i]};  //{1'b0,LFSR[6:0]};	   // encrypt 7 LSBs
	 $display("LFSR = %h, msg_bit = %h, msg_crypto = %h",lfsr2[i],msg_padded2[i],msg_crypto2[i]);
	 str_enc2[i]           = string'(msg_crypto2[i]);
      end

      for (int i=pre_length; i<32; i++) begin		   
	 msg_crypto2[i]        = msg_padded2[i] ^ {3'b100, lfsr2[i]};  // msb of payload is 1
	 $display("LFSR = %h, msg_bit = %h, msg_crypto = %h",lfsr2[i],msg_padded2[i],msg_crypto2[i]);
	 str_enc2[i]           = string'(8'h7f & msg_crypto2[i]);
      end

      $display("here is the original message with ~ (0x7E) preamble padding");
      for(int jj=0; jj<32; jj++)
	$write("%s", msg_padded2[jj]);
      $display("\n");

      $display("here is the padded and encrypted pattern in ASCII (bit 7 is ignored)");
      for(int jj=0; jj<32; jj++)
	$write("%s", str_enc2[jj]);
      $display("\n");

      $display("here is the padded unencrypted pattern in hex"); 
      for(int jj=0; jj<32; jj++)
	$write(" %h", msg_padded2[jj]);
      $display("\n");
      
      //
      // run decryption program 
      //
      repeat(5)
	@(posedge clk);
      
      validIn <= 'b0;
      decRqst <= 'b0;
      repeat(5)
	@(posedge clk);
      decRqst <= 'b1;
      @(posedge clk);
      decRqst <= 'b0;

      for(int qp=0; qp<32; qp++) begin
	 @(posedge clk);
	 validIn   <= 'b1;                   // turn on memory write enable
	 encryptByte <= msg_crypto2[qp];
	 //      dut.dm1.core[qp+128] <= msg_crypto2[qp];
      end
      @(posedge clk);
      validIn <= 'b0;                   // turn off mem write for rest of simulation
      //    for(int n=64; n<128; n++)
      //	  dut.dm1.core[n] = msg_crypto2[n-64]; //{^msg_crypto2[n-64][6:0],msg_crypto2[n-64][6:0]};
      @(posedge clk) 
	init <= 'b0             ;

      repeat(6) @(posedge clk);              // wait for 6 clock cycles of nominal 10ns each
      wait(done || (cycleCount > 200));                            // wait for DUT's done flag to go high
      if (!done) begin
	 $display("failed - did not fine Done signal");
      end
      
      // check the dut outputs
      for (int n=0; n<pre_length; n++) begin
	 $write("%d bench msg: %s %h %h %s dut msg: %h", 
		n, 
		msg_crypto2[n], str_enc2[n], 
		msg_padded2[n], string'(8'h7f & msg_padded2[n]),
		dutCapture[n]);   
	 $display("    preamble");
      end
      for(int n=pre_length; n<32; n++)	begin
	 $write("%d bench msg: %s %h %h %s dut msg: %h", 
		n, 
		msg_crypto2[n], str_enc2[n], 
		msg_padded2[n], string'(msg_padded2[n]),
		dutCapture[n]);   
	 if(msg_padded2[n]==dutCapture[n]) 
           $display("    very nice!");
	 else 
           $display("      oops!");
      end
      $stop;
   end

   //
   // clock generation
   //
   always begin	
      clk <= 0;
      #10;
      clk <= 1;
      cycleCount <= cycleCount + 1;
      #10;
   end

   //
   // reset generation
   //
   initial begin
      rst <= 0;
      wait(cycleCount == 3);
      rst <= 1;
      wait(cycleCount == 5);
      rst <= 0;
   end

   //
   // capture the DUT output
   // Whenver the DUT  asserts validOut, capture plainByte
   //
   initial begin
      forever begin
	 @(posedge clk);
	 if (validOut) begin
	    dutCapture[dutCaptAddr] <= plainByte;
	    dutCaptAddr <= dutCaptAddr + 1;
	 end
      end
   end

endmodule
