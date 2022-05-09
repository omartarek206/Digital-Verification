interface game_io(input clk);
  parameter SIZE = 4;
  parameter MAX_SCORE = 4;
  
  logic [1:0] control;
  logic [SIZE-1:0] INIT_l;
  logic INIT_c;			
  bit reset;
  logic [SIZE-1:0] count = 0, direction;
  logic WINNER = 0, LOSER = 0;
  logic [MAX_SCORE-1:0] w_count = 0, l_count = 0; 
  logic GAMEOVER = 1'b0; 
  logic [1:0] WHO = 2'b00;
  bit clr_reset = 0;
//   clocking testClk @(posedge clk);
//     output control, output INIT_l,
//     output INIT_c, output reset,
//     inout count, inout direction,
//     inout WINNER, inout LOSER,
//     inout w_count, inout l_count,
//     input WHO, input GAMEOVER
//   endclocking

  modport counter(
  	output count, output direction,
    input control, input INIT_l,
    input INIT_c,
    input reset, input clk
  );
  modport win_lose(
    output WINNER, output LOSER,
  	input count, input direction,
    input reset, input clk
  );
  modport count_signal(
    output w_count, output l_count,
    input WINNER, input LOSER,
    input reset, input clk
  );
  modport game_state(
    output WHO, output GAMEOVER, 
    input w_count, input l_count,
    input reset, input clk
  );
  modport cont(
    output reset,
    inout clr_reset,
    input GAMEOVER, input WHO,
    input clk
  );
  modport test(
    output control, 
    output INIT_l, output INIT_c, 
    inout reset,
    inout count, inout direction,
    inout WINNER, inout LOSER,
    inout w_count, inout l_count,
    input WHO, input GAMEOVER
  );
endinterface : game_io
