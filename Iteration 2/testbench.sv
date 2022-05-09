module test(game_io.test g_if, input clk);
//   bit clear_reset_flag = 0;
//   always @(posedge clk) begin
//     if (g_if.GAMEOVER) begin
//       g_if.reset <= 1;
//       clear_reset_flag = 1;
//     end
//     else if (clear_reset_flag) begin
//       g_if.reset <= 0;
//     end
//   end
    
  always @(posedge clk) begin
    g_if.INIT_c = 1'b0;
    g_if.INIT_l = 4'b1000;
    g_if.control = 2'b10;
    g_if.reset = 1'b0;
	#100  g_if.INIT_c = 1'b1;
    #5  g_if.INIT_c = 1'b0;
  end
  
endmodule
