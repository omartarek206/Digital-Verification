// Code your design here
parameter SIZE = 4;
parameter MAX_SCORE = 4;
module counter(
  count, direction,
  INIT_c, INIT_l,
  control, clk, reset);
  /*
   * Module `counter`
   *
   * Outputs:
   * count -> n-bit register carrying current count.
   * direction -> 1 bit equals 1 if count is being incremented, 0 else.
   *
   * Inputs:
   * INIT_c -> 1-bit control signal for Loading (1 load, 0 no load).
   * INIT_l -> n-bit value to be loaded into counter.
   * control -> 2-bit Specifies counting step and direction. 
   */
  output reg [SIZE-1:0] count; 
  output reg direction;			// Count direction
  input wire INIT_c;			// Load control
  input wire [SIZE-1:0] INIT_l;	// Load value
  input wire [1:0] control;
  input wire clk, reset;
  initial count = (INIT_c)? INIT_l : 0; 
  assign direction = control[1]; // direction = 0 if counting up, else 1
  
  always @(posedge clk) begin
    if (reset) begin		// Synchronous active High reset
      count = (INIT_c ? INIT_l : 4'b0000);
    end
    else if (INIT_c) begin	// Load value
      count = INIT_l;
    end
    else begin
      case (control)
        2'b00	: count = count + 1;
        2'b01	: count = count + 2;
        2'b10	: count = count - 1;
        2'b11	: count = count - 2;
        default	: count = count + 1;
      endcase
    end
  end
endmodule


module win_lose(
  WINNER, LOSER,
  count, direction,
  clk, reset
);
  /*
   * Module `win_lose`
   *
   * Outputs:
   * WINNER -> 1-bit register, high if all count bits are ones.
   * LOSER -> 1-bit register, high if count bits are all zeroes.
   * 
   * Inputs:
   * count ->  n-bit register carrying a count from 0 to 2^n -1.
   * direction -> 1 bit equals 1 if count is being incremented, 0 else.
   */
  output reg WINNER;
  output reg LOSER;
  input wire [SIZE-1:0] count;
  input wire direction;
  input wire clk, reset;
  bit [SIZE-1:0] winner_check = -1; 
  bit [SIZE-1:0] loser_check = 0;
  
  always @(posedge clk) begin
    if (reset || WINNER || LOSER) begin
      WINNER = 1'b0;	
      LOSER  = 1'b0;
    end
    // direction is checked to avoid setting WINNER or LOSER in case of overflow 
    else if (count == winner_check & direction == 0) begin
      WINNER = 1'b1; 
    end
    else if (count == loser_check & direction == 1) begin
      LOSER  = 1'b1;
    end
  end
endmodule


module count_signal(
  signal_count, signal,
  clk, reset
);
  /*
   * Module `count_signal`
   *
   * Outputs:
   * signal_count -> n-bit register, incremented whenever the signal is high.
   *
   * Inputs:
   * signal -> 1-bit register
   */
  output reg [MAX_SCORE-1:0] signal_count; 
  input wire signal;
  input wire clk, reset;
  initial signal_count = 0;
  
  always @(posedge clk) begin
    if (reset) begin	// Synchronous active high reset 
      signal_count = 0;
    end
  	else if (signal) begin
      signal_count = signal_count + 1;
  	end
  end
endmodule

module game_state(
  GAMEOVER, WHO,
  w_count, l_count,
  clk, reset  
);
  /*
   * Module `game_state`
   *
   * Outputs:
   * GAMEOVER -> 1-bit reister indicating the end of the game.
   * WHO -> 2-bit register that indicates who won the game.
   * 
   * Inputs:
   * w_count -> n-bit register carrying WINNER's count.
   * l_count -> n-bit register carrying LOSER's count.
   */
  output reg GAMEOVER;
  output reg [1:0] WHO;
  input wire [MAX_SCORE-1:0] w_count;
  input wire [MAX_SCORE-1:0] l_count;
  input clk, reset;
  
  initial WHO = 2'b00;
  initial GAMEOVER = 1'b0;
  bit [MAX_SCORE-1:0] win_check = -1; // Winning value
  
  always @ (posedge clk) begin
    if (GAMEOVER || reset) begin
      GAMEOVER = 1'b0;	
      WHO = 2'b00;
    end
    if (w_count == win_check) begin
      GAMEOVER = 1'b1;
      WHO = 2'b10;
    end
    else if (l_count == win_check) begin
      GAMEOVER = 1'b1;
      WHO = 2'b01;
    end
  end
endmodule
