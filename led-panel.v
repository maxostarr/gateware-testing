`default_nettype none

module top(
  input CLK,
  input BTN,
  output LED3,
  output reg CL,
  output reg LA,
  output BL,
  output A0,
  output A1,
  output A2,
  output A3,
  output A4,
  output reg R0,
  output reg R1,
  output reg G0,
  output reg G1,
  output reg B0,
  output reg B1,
  output X0,
  output X1
);
  reg blanking;
  wire clk30;
  wire pllLock;
  wire iBtn;
  reg [4:0] address;
  reg [5:0] xPos;
  reg [1:0] state;
  wire [5:0] timeSignal;
  wire [4:0] y1AndTime;
  wire [4:0] xOrTime;
  wire mainPll_lock_wire;
  wire mainPll_clkOut_wire;
  wire [5:0] timeCounter_counter_wire;


  initial begin
    state = 0;
  end

  assign clk30 = mainPll_clkOut_wire;
  assign pllLock = mainPll_lock_wire;
  assign timeSignal = timeCounter_counter_wire;

  PLL mainPll(
    .clkIn(CLK),
    .lock(mainPll_lock_wire),
    .clkOut(mainPll_clkOut_wire)
  );

  SlowCounter timeCounter(
    .clk(clk30),
    .counter(timeCounter_counter_wire)
  );
  assign iBtn = ~BTN;
  assign LED3 = pllLock;
  assign A0 = address[0];
  assign A1 = address[1];
  assign A2 = address[2];
  assign A3 = address[3];
  assign A4 = address[4];
  assign X0 = 0;
  assign X1 = 0;
  assign y1AndTime = address & (timeSignal[4:0]);
  assign xOrTime = xPos | (timeSignal);
  assign BL = (~blanking) | (~BTN);
  always @(posedge clk30) begin
    case (state)
      0 : begin
        address <= 0;
        xPos <= 0;
        R0 <= 0;
        R1 <= 0;
        G0 <= 0;
        G1 <= 0;
        B0 <= 0;
        B1 <= 0;
        blanking <= 1'b1;
        state <= 1;
      end

      1 : begin
        LA <= 1'b0;
        blanking <= 1'b1;
        G0 <= ((xOrTime[4:0]) ^ (y1AndTime)) == xPos[4:0];
        G1 <= ((xOrTime[4:0]) ^ (y1AndTime)) == xPos[4:0];
        CL <= 1'b1;
        state <= 2;
      end

      2 : begin
        CL <= 1'b0;
        if (xPos == 63) begin
          LA <= 1'b1;
          state <= 3;
        end
        else begin
          state <= 1;
        end
        xPos <= xPos + 1;
      end

      3 : begin
        address <= address + 1;
        blanking <= 1'b0;
        state <= 1;
      end

      default : begin
        state <= 0;
      end
    endcase
  end
endmodule

module SlowCounter(
  input clk,
  output reg [5:0] counter
);
  reg [21:0] divider;
  initial begin
    divider = 4194303;
  end

  always @(posedge clk) begin
    if (divider == 0) begin
      counter <= counter + 1;
    end
    divider <= divider - 1;
  end
endmodule

module PLL(
  input clkIn,
  output lock,
  output clkOut
);
  wire pll_PLLOUTCORE_wire;
  wire pll_LOCK_wire;
  wire pll_PLLOUTGLOBAL_wire;


  assign clkOut = pll_PLLOUTGLOBAL_wire;
  assign lock = pll_LOCK_wire;

  SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'b0000),
    .DIVF(7'b1001111),
    .DIVQ(3'b101),
    .FILTER_RANGE(3'b001),
    .ENABLE_ICEGATE(1'b0)
  ) pll (
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clkIn),
    .PLLOUTCORE(pll_PLLOUTCORE_wire),
    .LOCK(pll_LOCK_wire),
    .PLLOUTGLOBAL(pll_PLLOUTGLOBAL_wire)
  );

endmodule