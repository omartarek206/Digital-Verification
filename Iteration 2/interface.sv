interface game_io(input bit clk);
  parameter SIZE = 4;
  parameter MAX_SCORE = 4;
  
  logic [1:0] control = 00;
  logic [SIZE-1:0] INIT_l;
  logic INIT_c;			
  bit reset;
  logic [SIZE-1:0] count = 0, direction;
  logic WINNER = 0, LOSER = 0;
  logic [MAX_SCORE-1:0] w_count = 0, l_count = 0; 
  logic GAMEOVER = 1'b0; 
  logic [1:0] WHO = 2'b00;
  bit clr_reset = 0;

  clocking counterClk @(posedge clk);
  	output direction;
    inout count;
    input control, INIT_l, INIT_c, reset;
  endclocking
  clocking winLoseClk @(posedge clk);
    inout WINNER, LOSER;
  	input count, direction, reset;
  endclocking
  clocking countSignalClk @(posedge clk);
    inout w_count, l_count;
    input WINNER, LOSER, reset;
  endclocking
  clocking gameStateClk @(posedge clk);
    output WHO;
    inout GAMEOVER;
    input w_count, l_count, reset;
  endclocking
  clocking contClk @(posedge clk);
    inout reset;
    inout clr_reset;
    input GAMEOVER, WHO;
  endclocking
  clocking testClk @(posedge clk);
    default input #3ns output #2ns;
    inout reset, count, direction, WINNER, LOSER,
    	  w_count, l_count, control, INIT_l, INIT_c;
    input WHO, GAMEOVER;
  endclocking
  
  modport counter(clocking counterClk);
  modport win_lose(clocking winLoseClk);
  modport count_signal(clocking countSignalClk);
  modport game_state(clocking gameStateClk);
  modport cont(clocking contClk);
  modport test(clocking testClk);
endinterface : game_io
