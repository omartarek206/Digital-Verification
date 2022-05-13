parameter SIZE = 4;
parameter MAX_SCORE = 4;

module counter(game_io.counter g_if);
  /*
     * Module `counter`
     *
     * Description:
     * Changes the count after each clock and outputs the direction of counting      * (up or down) and the current count.
     *
     * Outputs:
     * count -> n-bit register carrying current g_if.dut.count.
     * direction -> 1 bit equals 1 if g_if.dut.count is being incremented, 0 else.
     *
     * Inputs:
     * INIT_c -> 1-bit control signal for Loading (1 load, 0 no load).
     * INIT_l -> n-bit value to be loaded into g_if.dut.counter.
     * control -> 2-bit Specifies counting step and direction. 
     */
  initial g_if.counterClk.count <= (g_if.counterClk.INIT_c ? g_if.counterClk.INIT_l : 0); 
  // direction <= 0 if g_if.counterClk.dut.counting up, else 1
  always @(g_if.counterClk.control) begin
    g_if.counterClk.direction <= g_if.counterClk.control[1]; 	
  end
  always @(g_if.counterClk) begin
    if (g_if.counterClk.reset) begin			// Synchronous active High reset
      g_if.counterClk.count <= (g_if.counterClk.INIT_c ? g_if.counterClk.INIT_l : 4'b0000);
    end
    else if (g_if.counterClk.INIT_c) begin		// Load value
      g_if.counterClk.count <= g_if.counterClk.INIT_l;
    end
    else begin
      case (g_if.counterClk.control)
        2'b00	: g_if.counterClk.count <= g_if.counterClk.count + 1;
        2'b01	: g_if.counterClk.count <= g_if.counterClk.count + 2;
        2'b10	: g_if.counterClk.count <= g_if.counterClk.count - 1;
        2'b11	: g_if.counterClk.count <= g_if.counterClk.count - 2;
        default	: g_if.counterClk.count <= g_if.counterClk.count + 1;
      endcase
    end
  end
endmodule


module win_lose(game_io.win_lose g_if);
  /*
     * Module `win_lose`
     *
     * Description:
     * Outputs high on all winner bits when all input count bits are high and        * low on all LOSER bits whenever all count bits are low.
     *
     * Outputs:
     * WINNER -> 1-bit register, high if all g_if.dut.count bits are ones.
     * LOSER -> 1-bit register, high if g_if.dut.count bits are all zeroes.
     * 
     * Inputs:
     * g_if.dut.count ->  n-bit register carrying a g_if.dut.count from 0 to 2^n -1.
     * direction -> 1 bit equals 1 if g_if.dut.count is being incremented, 0 else.
     */
  bit [SIZE-1:0] winner_check = -1, loser_check = 0;
  always @(g_if.winLoseClk) begin
    if (g_if.winLoseClk.reset || g_if.winLoseClk.WINNER || g_if.winLoseClk.LOSER) begin
      g_if.winLoseClk.WINNER <= 1'b0;	
      g_if.winLoseClk.LOSER  <= 1'b0;
    end
    // direction is checked to avoid setting WINNER or LOSER in case of overflow 
    else if (g_if.winLoseClk.count == winner_check & g_if.winLoseClk.direction == 0) begin
      g_if.winLoseClk.WINNER <= 1'b1; 
    end
    else if (g_if.winLoseClk.count == loser_check & g_if.winLoseClk.direction == 1) begin
      g_if.winLoseClk.LOSER  <= 1'b1;
    end
  end
endmodule


module count_signal(game_io.count_signal g_if);
  /*
     * Module `count_signal`
     *
     * Description:
     * Receives a signal (WINNER in case of w and LOSER in case of l) and the 	      * output of the module is incremented whenever the input signal is high.
     *
     * Outputs:
     * signal_count -> n-bit register, incremented whenever the signal is high.
     *
     * Inputs:
     * signal -> 1-bit register
     */
  always @(g_if.countSignalClk) begin
    if (g_if.countSignalClk.reset) begin				// Synchronous active high reset 
      g_if.countSignalClk.w_count <= 0;
      g_if.countSignalClk.l_count <= 0;
    end
    else if (g_if.countSignalClk.WINNER) begin
      g_if.countSignalClk.w_count <= g_if.countSignalClk.w_count + 1;
    end
    else if (g_if.countSignalClk.LOSER) begin
      g_if.countSignalClk.l_count <= g_if.countSignalClk.l_count + 1;
    end
  end
endmodule

module game_state(game_io.game_state g_if);
  /*
     * Module `game_state`
     *
     * Description:
     * Takes both counts, and declares the owner of whichever signal that 		      * reaches the preset limit first as winner. 
     *
     * Outputs:
     * GAMEOVER -> 1-bit reister indicating the end of the game.
     * WHO -> 2-bit register that indicates who won the game.
     * 
     * Inputs:
     * w_g_if.dut.count -> n-bit register carrying WINNER's g_if.dut.count.
     * l_g_if.dut.count -> n-bit register carrying LOSER's g_if.dut.count.
     */
  bit [MAX_SCORE-1:0] win_check = -1; // Winning value
  always @ (g_if.gameStateClk) begin
    if (g_if.gameStateClk.reset) begin
      g_if.gameStateClk.GAMEOVER <= 1'b0;	
      g_if.gameStateClk.WHO <= 2'b00;
    end
    else if (g_if.gameStateClk.w_count == win_check) begin
      g_if.gameStateClk.GAMEOVER <= 1'b1;
      g_if.gameStateClk.WHO <= 2'b10;
    end
    else if (g_if.gameStateClk.l_count == win_check) begin
      g_if.gameStateClk.GAMEOVER <= 1'b1;
      g_if.gameStateClk.WHO <= 2'b01;
    end
  end
endmodule

module cont(game_io.cont g_if);
  /*
   * Module `game_state`
   *
   * Description:
   * Restarts game after a winner a is reached (GAMEOVER is set.)
   *
   * Outputs:
   * clr_reset -> 1-bit control signal to lower reset after one clock cycle.
   * reset
   * 
   * Inputs:
   * GAMEOVER -> 1-bit reister indicating the end of the game.
   * clr_reset -> 1-bit control signal to lower reset after one clock cycle.
   */
  always @(g_if.contClk) begin
    if (g_if.contClk.GAMEOVER) begin
      g_if.contClk.reset <= 1;
      g_if.contClk.clr_reset <= 1;
    end
    else if (g_if.contClk.clr_reset) begin
      g_if.contClk.reset <= 0;
      g_if.contClk.clr_reset <= 0;
    end
    else begin
      g_if.contClk.clr_reset <= 0;
    end
  end
endmodule
