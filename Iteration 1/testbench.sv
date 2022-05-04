// Code your testbench here
// or browse Examples
module tb();
  parameter SIZE = 4;
  parameter MAX_SCORE = 4;
  
  wire [SIZE-1:0] count1; 
  wire direction1;
  reg INIT_c;
  reg [SIZE-1:0] INIT_l;
  reg [1:0] control;
  reg reset, clk; 
  counter c(count1, direction1, INIT_c, INIT_l, control, clk, reset);
  
  wire WINNER1;
  wire LOSER1;
  reg [SIZE-1:0] count2; 
  reg direction2;
  always @(*) count2 = count1;
  always @(*) direction2 = direction1;
  win_lose w_l(WINNER1, LOSER1, count2, direction2, clk, reset);
  
  wire [MAX_SCORE-1:0] w_count1;
  reg WINNER2;
  always @(*) WINNER2 = WINNER1;
  count_signal w(w_count1, WINNER2, clk, reset);
  
  wire [MAX_SCORE-1:0] l_count1; 
  reg LOSER2;
  always @(*) LOSER2 = LOSER1;
  count_signal l(l_count1, LOSER2, clk, reset);
  
  wire GAMEOVER;
  wire [1:0] WHO;
  reg [MAX_SCORE-1:0] w_count2;
  reg [MAX_SCORE-1:0] l_count2;
  always @(*) w_count2 = w_count1;
  always @(*) l_count2 = l_count1;
  game_state g_s(GAMEOVER, WHO, w_count2, l_count2, clk, reset);
  
  bit clear_reset_flag = 0;
  
  always @ (posedge clk) begin
    if (GAMEOVER) begin
      reset = 1;
      clear_reset_flag = 1;
    end
    else if (clear_reset_flag) begin
      reset <= 0;
    end
  end
    
  initial begin
    INIT_c = 1'b0;
    INIT_l = 4'b1000;
    control = 2'b10;
    reset = 1'b0;
    clk = 1'b0;
	#100  INIT_c = 1'b1;
    #5  INIT_c = 1'b0;
    #5  reset = 1'b1;
    #25  reset = 1'b0;
    #20 control = 2'b01;
    #200 reset = 1'b1;
    #5 reset = 1'b0;
  end
  
  always begin
    #1 clk = ~clk;
  end
  
  
  initial begin
    $dumpfile("dump1.vcd"); 
    $dumpvars;
    #1600 $finish;
  end  
endmodule
