parameter SIZE = 4;
parameter MAX_SCORE = 4;

module counter(game_io.counter g_if);
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
  initial g_if.count <= (g_if.INIT_c ? g_if.INIT_l : 0); 
  // direction <= 0 if g_if.dut.counting up, else 1
  always @(g_if.control) begin
    g_if.direction <= g_if.control[1]; 	
  end
  always @(posedge g_if.clk) begin
    if (g_if.reset) begin			    // Synchronous active High reset
      g_if.count <= (g_if.INIT_c ? g_if.INIT_l : 4'b0000);
    end
    else if (g_if.INIT_c) begin		// Load value
      g_if.count <= g_if.INIT_l;
    end
    else begin
      case (g_if.control)
        2'b00	: g_if.count <= g_if.count + 1;
        2'b01	: g_if.count <= g_if.count + 2;
        2'b10	: g_if.count <= g_if.count - 1;
        2'b11	: g_if.count <= g_if.count - 2;
        default	: g_if.count <= g_if.count + 1;
      endcase
    end
  end
endmodule


module win_lose(game_io.win_lose g_if);
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
  bit [SIZE-1:0] winner_check = -1, loser_check = 0;
  always @(posedge g_if.clk) begin
    if (g_if.reset || g_if.WINNER || g_if.LOSER) begin
      g_if.WINNER <= 1'b0;	
      g_if.LOSER  <= 1'b0;
    end
    // direction is checked to avoid setting WINNER or LOSER in case of overflow 
    else if (g_if.count == winner_check & g_if.direction == 0) begin
      g_if.WINNER <= 1'b1; 
    end
    else if (g_if.count == loser_check & g_if.direction == 1) begin
      g_if.LOSER  <= 1'b1;
    end
  end
endmodule


module count_signal(game_io.count_signal g_if);
  /*
   * Module `count_signal`
   *
   * Outputs:
   * signal_count -> n-bit register, incremented whenever the signal is high.
   *
   * Inputs:
   * signal -> 1-bit register
   */
  always @(posedge g_if.clk) begin
    if (g_if.reset) begin				  // Synchronous active high reset 
      g_if.w_count <= 0;
      g_if.l_count <= 0;
    end
    else if (g_if.WINNER) begin
      g_if.w_count <= g_if.w_count + 1;
  	end
    else if (g_if.LOSER) begin
      g_if.l_count <= g_if.l_count + 1;
  	end
  end
endmodule

module game_state(game_io.game_state g_if);
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
  bit [MAX_SCORE-1:0] win_check = -1;   // Winning value
  always @ (posedge g_if.clk) begin
    if (g_if.GAMEOVER || g_if.reset) begin
      g_if.GAMEOVER <= 1'b0;	
      g_if.WHO <= 2'b00;
    end
    if (g_if.w_count == win_check) begin
      g_if.GAMEOVER <= 1'b1;
      g_if.WHO <= 2'b10;
    end
    else if (g_if.l_count == win_check) begin
      g_if.GAMEOVER <= 1'b1;
      g_if.WHO <= 2'b01;
    end
  end
endmodule

module cont(game_io.cont g_if);
/*
   * Module `game_state`
   *
   * Description:
   * This ensures the game keeps on continuing.
   *
   * Outputs:
   * clr_reset -> 1-bit control signal to lower reset after one clock cycle.
   * reset
   * 
   * Inputs:
   * GAMEOVER -> 1-bit reister indicating the end of the game.
   * clr_reset -> 1-bit control signal to lower reset after one clock cycle.
   */
  always @(posedge g_if.clk) begin
    if (g_if.clr_reset && g_if.GAMEOVER) begin
      g_if.reset <= 0;
    end
    else if (g_if.GAMEOVER) begin
      g_if.reset <= 1;
      g_if.clr_reset = 1;
    end
    else begin
      g_if.clr_reset = 0;
    end
  end
endmodule