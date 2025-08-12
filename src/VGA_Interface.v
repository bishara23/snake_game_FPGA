// VGA_interface.v


module VGA_Interface (
    input  wire        clk,          // 100 Mhz system clock
    input  wire        rstn,         // async, active-low reset
    input  wire [11:0] pixel_color,  
    output reg  [3:0]  vgaRed,
    output reg  [3:0]  vgaGreen,
    output reg  [3:0]  vgaBlue,
    output reg         Hsync,
    output reg         Vsync,
    output reg  [10:0] XCoord,       // down-sampled by 8
    output reg  [10:0] YCoord        // down-sampled by 8
);


  // parameters for 800X600 72Hz (according to the theoretical background)
  localparam H_TOTAL    = 1040;
  localparam H_SYNC_START = 856;
  localparam H_SYNC_END   =  976;
  localparam H_VISIBLE  =  800;

  localparam V_TOTAL    =  666;
  localparam V_SYNC_START =  637;
  localparam V_SYNC_END   =  643;
  localparam V_VISIBLE  =  600;


  // pixel clock divider
  reg pix_clk_div;
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      pix_clk_div <= 1'b0;
    else
      pix_clk_div <= ~pix_clk_div;
  end
  wire pix_clk = pix_clk_div;

  // horizontal and vertical counters
  reg [10:0] hcount;
  reg [9:0]  vcount;
  always @(posedge pix_clk or negedge rstn) begin
    if (!rstn) begin
      hcount <= 0;
      vcount <= 0;
    end else begin
      if (hcount == H_TOTAL-1) begin
        hcount <= 0;
        if (vcount == V_TOTAL-1)
          vcount <= 0;
        else
          vcount <= vcount + 1;
      end else
        hcount <= hcount + 1;
    end
  end

  // generate sync pulses and RGB/coord registers
  wire in_hsync = (hcount >= H_SYNC_START) && (hcount < H_SYNC_END);
  wire in_vsync = (vcount >= V_SYNC_START) && (vcount < V_SYNC_END);
  wire visible  = (hcount < H_VISIBLE)   && (vcount < V_VISIBLE);

  always @(posedge pix_clk or negedge rstn) begin
    if (!rstn) begin
      Hsync   <= 1'b1; 
      Vsync   <= 1'b1;
      vgaRed   <= 4'h0;
      vgaGreen <= 4'h0;
      vgaBlue  <= 4'h0;
      XCoord   <= 0;
      YCoord   <= 0;
    end else begin
      Hsync <= ~in_hsync; //not because active low pulse
      Vsync <= ~in_vsync;

      // blanking: output color only when visible
      if (visible) begin
        vgaRed   <= pixel_color[11:8];
        vgaGreen <= pixel_color[7:4];
        vgaBlue  <= pixel_color[3:0];
      end else begin
        vgaRed   <= 4'h0;
        vgaGreen <= 4'h0;
        vgaBlue  <= 4'h0;
      end

      // down-sample coords by 8  100X75 (8X8) pixel block
      XCoord <= hcount >> 3;
      YCoord <= vcount >> 3;
    end
  end

endmodule
