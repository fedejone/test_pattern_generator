module mux_test_pattern_generator_ciris #(
  parameter DW            = 32   ,
  parameter DATA_WIDTH    = 24   ,
  parameter REGS_NUM      = 4    ,
  parameter AVALON_MM     = "OFF",
  parameter INTERLACED    = 3    ,
  parameter HEIGHT        = 600  ,
  parameter WIDTH         = 800  ,
  parameter OFFSET_FRAMES = 25   ,
  parameter MODE          = 1
) (
  input                                 clk_i           , // Clock
  input                                 rst_i           , // Asynchronous reset active low
  input        [  REGS_NUM-1:0]         word_valid_wr_i ,
  input        [  REGS_NUM-1:0][DW-1:0] word_i          ,
  input        [  REGS_NUM-1:0]         word_valid_rd_i ,
  input        [DATA_WIDTH-1:0]         data_stndrt_i   ,
  input        [DATA_WIDTH-1:0]         data_offset_i   ,
  input        [DATA_WIDTH-1:0]         data_grad_i     ,
  input        [DATA_WIDTH-1:0]         data_onecolor_i ,
  input        [DATA_WIDTH-1:0]         data_image_i    ,
  input                                 handshake_i     ,
  ////
  output logic                          handshake_o     ,
  output logic [DATA_WIDTH-1:0]         data_o          ,
  output logic                          enable_o        ,
  output logic                          mode_bw_o       ,
  output logic [          31:0]         height_o        , // поменял разрядность
  output logic [          31:0]         width_o         , // поменял разрядность
  output logic [           7:0]         offset_frames_o ,
  output logic [           5:0]         interlaced_o    ,
  output logic [          23:0]         color_onecolor_o
);

  logic [4:0] reg_mode     ;
  logic [4:0] handshake_reg;

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_reg_mode
    if(~rst_i) begin
      reg_mode <= '0;
    end else if (handshake_i) begin
      reg_mode <= word_i[0][16:9];
    end
  end

always_ff @(posedge clk_i or negedge rst_i) begin : proc_handshake_reg
  if(~rst_i) begin
    handshake_reg <= '0;
  end else begin
    handshake_reg <= word_i[0][16:9] ;
  end
end

always_ff @(posedge clk_i or negedge rst_i) begin : proc_handshake_o
  if(~rst_i) begin
    handshake_o <= '0;
  end else if (handshake_reg !== word_i[0][16:9]) begin
    handshake_o <= '1 ;
  end else if (handshake_i) begin
    handshake_o <= '0;
  end
end

  always_ff @(posedge clk_i or negedge rst_i) begin
    if( ~rst_i ) begin
      enable_o <= '1;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 1 ) begin
      enable_o <= word_i [0][0] ;
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_height_o
    if( ~rst_i ) begin
      height_o <= HEIGHT;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 4 ) begin
      height_o <= word_i[2] ;
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_width_o
    if( ~rst_i ) begin
      width_o <= WIDTH;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 2 ) begin
      width_o <= word_i[1];
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_interlaced_o
    if(~rst_i) begin
      interlaced_o <= INTERLACED;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 8 ) begin
      interlaced_o <= word_i[3][7:0];
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_offset_frames_o
    if( ~rst_i ) begin
      offset_frames_o <= OFFSET_FRAMES;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 1) begin
      offset_frames_o <= word_i[0][8:1] ;
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_color_onecolor_o
    if( ~rst_i ) begin
      color_onecolor_o <= 'h0000FF;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 1 ) begin
      color_onecolor_o <= word_i[3][31:8] ;
    end
  end

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_mode_bw_o
    if( ~rst_i ) begin
      mode_bw_o <= 0;
    end else if ( AVALON_MM == "ON" && word_valid_wr_i == 1 ) begin
      mode_bw_o <= word_i[0][17];
    end
  end

  always_comb begin 
    if ( AVALON_MM == "ON" ) begin
      casex (reg_mode)
        5'bx1000 : data_o = data_grad_i;
        5'bx0100 : data_o = data_image_i;
        5'bx0010 : data_o = data_offset_i;
        5'bx0001 : data_o = data_stndrt_i;
        default  : data_o = data_onecolor_i;
      endcase
    end else
    case ( MODE ) 
      1       : data_o = data_grad_i;
      2       : data_o = data_image_i;
      3       : data_o = data_offset_i;
      4       : data_o = data_stndrt_i;
      default : data_o = data_onecolor_i;
    endcase
  end


endmodule
