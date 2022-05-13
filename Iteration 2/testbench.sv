program test(game_io.test g_if);  
  initial begin
    g_if.testClk.INIT_c <= 1'b0;
    g_if.testClk.INIT_l <= 4'b1000;
    g_if.testClk.control <= 2'b10;
    g_if.testClk.reset <= 1'b0;
    #100  g_if.testClk.INIT_c <= 1'b1;
    #5  g_if.testClk.INIT_c <= 1'b0;
    #5  g_if.testClk.reset <= 1'b1;
    #25  g_if.testClk.reset <= 1'b0;
    #20 g_if.testClk.control <= 2'b01;
    #200 g_if.testClk.reset <= 1'b1;
    #5 g_if.testClk.reset <= 1'b0;
    #1200 $finish;
  end
  
  initial begin
    control_assertion: assert property(control);
    init_assertion: assert property(init);
    reset_assertion: assert(g_if.testClk.reset <= 1);
  end
  property control;
    @(g_if.testClk) g_if.testClk.control <= 2'b11;
  endproperty
  property init;
    @(g_if.testClk) g_if.testClk.INIT_c <= 1;
  endproperty
  property reset;
    @(g_if.testClk) g_if.testClk.reset <= 1;
  endproperty
endprogram