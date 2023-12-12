module test_pattern_generator_ciris_top #(
  parameter BITS_PER_SYMBOL  = 8    ,
  parameter SYMBOLS_PER_BEAT = 3    ,
  parameter DATA_WIDTH       = 24   ,
  parameter INTERLACED       = 3    ,
  parameter HEIGHT           = 600  ,
  parameter WIDTH            = 800  ,
  parameter MODE_BW          = 0    ,
  parameter OFFSET_FRAMES    = 25   ,
  parameter MODE             = 2    ,
  parameter LATENCY          = "ON" ,
  parameter AVALON_MM        = "OFF",
  parameter DW               = 32   ,
  parameter AW               = 16   ,
  parameter REGS_NUM         = 4
) (
  input                         clk_i          ,
  input                         rst_i          ,
  ///сигналы шины Avalon-mm
  input                         ready_i        ,
  input        [        AW-1:0] avms_address   ,
  input        [      DW/8-1:0] avms_byteenable,
  input                         avms_read      ,
  input                         avms_write     ,
  input        [        DW-1:0] avms_writedata ,
  output logic [        DW-1:0] avms_readdata  ,
  /// выходные сигнлалы гернератора полос
  output       [DATA_WIDTH-1:0] data_o         ,
  output                        valid_o        ,
  output                        sop_o          ,
  output                        eop_o
);

  typedef struct packed
  {
    logic                  valid;
    logic [DATA_WIDTH-1:0] data ;
    logic                  sop  ;
    logic                  eop  ;
    logic                  ready;
  } av_st;
  av_st encoder;

  typedef struct packed
  {
    logic                  valid        ;
    logic                  end_of_video ;
    logic [DATA_WIDTH-1:0] data         ;
    logic [          31:0] width        ;
    logic [          31:0] height       ;
    logic                  interlaced   ;
    logic                  vip_ctrl_send;
    logic                  ready        ;
  } gen_polos_strct;
  gen_polos_strct gen;

  ///

  logic                          vip_ctrl_busy    ;
  logic [DATA_WIDTH-1:0]         data_stndrt      ;
  logic [DATA_WIDTH-1:0]         data_offset      ;
  logic [DATA_WIDTH-1:0]         data_onecolor    ;
  logic [DATA_WIDTH-1:0]         data_grad        ;
  logic [DATA_WIDTH-1:0]         data_imag        ;
  logic                          enable           ;
  logic                          mode_bw          ;
  logic [           7:0]         offset_frames    ;
  logic [          23:0]         color_onecolor   ;
  logic [  REGS_NUM-1:0][DW-1:0] word_mux         ;
  logic [  REGS_NUM-1:0]         word_valid_wr    ;
  logic [  REGS_NUM-1:0]         word_valid_rd    ;
  logic                          handshake_gen_mux;
  logic                          handshake_mux_gen;


  ///

av_univ_regs #(
  .DW      (DW      ),
  .AW      (AW      ),
  .REGS_NUM(REGS_NUM)
) uut_av_univ_reg (
  .clk_i          (clk_i          ),
  .reset_n_i      (rst_i          ),
  .avms_address   (avms_address   ),
  .avms_byteenable(avms_byteenable),
  .avms_read      (avms_read      ),
  .avms_readdata  (avms_readdata  ),
  .avms_write     (avms_write     ),
  .avms_writedata (avms_writedata ),
  .word_valid_wr_o(word_valid_wr  ),
  .mst_word_o     (word_mux       ),
  .slv_word_i     (               ),
  .word_valid_rd_o(word_valid_rd  )
);  


  mux_test_pattern_generator_ciris #(
    .DW           (DW           ),
    .DATA_WIDTH   (DATA_WIDTH   ),
    .REGS_NUM     (REGS_NUM     ),
    .AVALON_MM    (AVALON_MM    ),
    .WIDTH        (WIDTH        ),
    .HEIGHT       (HEIGHT       ),
    .INTERLACED   (INTERLACED   ),
    .MODE         (MODE         ),
    .OFFSET_FRAMES(OFFSET_FRAMES)
  ) uut_mux_test_pattern_generator_ciris (
    .clk_i           (clk_i            ),
    .rst_i           (rst_i            ),
    .word_valid_wr_i (word_valid_wr    ),
    .word_i          (word_mux         ),
    .word_valid_rd_i (word_valid_rd    ),
    .data_stndrt_i   (data_stndrt      ),
    .data_offset_i   (data_offset      ),
    .data_grad_i     (data_grad        ),
    .data_onecolor_i (data_onecolor    ),
    .data_image_i    (data_imag        ),
    .data_o          (gen.data         ),
    .enable_o        (enable           ),
    .mode_bw_o       (mode_bw          ),
    .height_o        (gen.height       ),
    .width_o         (gen.width        ),
    .offset_frames_o (offset_frames    ),
    .interlaced_o    (gen.interlaced   ),
    .color_onecolor_o(color_onecolor   ),
    .handshake_i     (handshake_gen_mux),
    .handshake_o     (handshake_mux_gen)
  );

  test_pattern_generator_ciris #(.DATA_WIDTH(DATA_WIDTH)) uut_test_pattern_generator_ciris (
    .clk_i           (clk_i            ),
    .rst_i           (rst_i            ),
    .ready_i         (gen.ready        ),
    .enable          (enable           ),
    .mode_bw_i       (mode_bw          ),
    .height_i        (gen.height       ),
    .width_i         (gen.width        ),
    .interlaced_i    (gen.interlaced   ),
    .offset_frames_i (offset_frames    ),
    .color_onecolor_i(color_onecolor   ),
    .valid_o         (gen.valid        ),
    .end_of_video_o  (gen.end_of_video ),
    .data_stndrt_o   (data_stndrt      ),
    .data_offset_o   (data_offset      ),
    .data_grad_o     (data_grad        ),
    .data_onecolor_o (data_onecolor    ),
    .data_imag_o     (data_imag        ),
    .vip_ctrl_send_o (gen.vip_ctrl_send),
    .handshake_i     (handshake_mux_gen),
    .handshake_o     (handshake_gen_mux)
  );

  alt_vipvfr131_common_control_packet_encoder #(
    .BITS_PER_SYMBOL (BITS_PER_SYMBOL ),
    .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT)
  ) uut_gen_polos_encoder (
    .clk          (clk_i            ),
    .rst          (~rst_i           ),
    .din_ready    (gen.ready        ),
    .din_valid    (gen.valid        ),
    .din_data     (gen.data         ),
    .dout_ready   (encoder.ready    ),
    .dout_valid   (encoder.valid    ),
    .dout_sop     (encoder.sop      ),
    .dout_eop     (encoder.eop      ),
    .dout_data    (encoder.data     ),
    .end_of_video (gen.end_of_video ),
    .width        (gen.width        ),
    .height       (gen.height       ),
    .interlaced   (gen.interlaced   ),
    .vip_ctrl_send(gen.vip_ctrl_send),
    .vip_ctrl_busy(vip_ctrl_busy    )
  );

  generate
    if ( LATENCY == "ON" ) begin

      alt_vipvfr131_common_stream_output #(.DATA_WIDTH(DATA_WIDTH)) uut_gen_polos_output (
        .clk       (clk_i        ),
        .rst       (~rst_i        ),
        .dout_ready(ready_i      ),
        .dout_valid(valid_o      ),
        .dout_data (data_o       ),
        .dout_sop  (sop_o        ),
        .dout_eop  (eop_o        ),
        .int_ready (encoder.ready),
        .int_valid (encoder.valid),
        .int_data  (encoder.data ),
        .int_sop   (encoder.sop  ),
        .int_eop   (encoder.eop  ),
        .enable    (1'b1         ),
        .synced    (             )
      );
    end else begin
      assign encoder.ready = ready_i;
      assign valid_o       = encoder.valid;
      assign data_o        = encoder.data;
      assign sop_o         = encoder.sop;
      assign eop_o         = encoder.eop;
    end
  endgenerate

endmodule
