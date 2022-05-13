module top;
  bit clk = 0;
  always #10 clk = ~clk;
  game_io g_if(clk);
  
  counter dutCounter(g_if.counter);
  win_lose dutWinLose(g_if.win_lose);
  count_signal dutCountSignal(g_if.count_signal);
  game_state dutGameState(g_if.game_state);
  cont dutCont(g_if.cont);
  test tb(g_if.test);
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end  
endmodule