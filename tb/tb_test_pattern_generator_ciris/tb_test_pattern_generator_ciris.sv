`timescale 1 ps/1 ps

parameter BITS_PER_SYMBOL  = 8                               ;
parameter SYMBOLS_PER_BEAT = 3                               ;
parameter DATA_WIDTH       = BITS_PER_SYMBOL*SYMBOLS_PER_BEAT;
parameter INTERLACED       = 3                               ;
parameter HEIGHT           = 800                             ;
parameter WIDTH            = 600                             ;
parameter MODE_BW          = 0                               ;
parameter OFFSET_FRAMES    = 25                              ;
parameter MODE             = 2                               ;
parameter LATENCY          = "ON"                            ;
parameter AVALON_MM        = "ON"                           ;
parameter DW       = 32;
parameter AW       = 16;
parameter REGS_NUM = 4 ;

module tb_test_pattern_generator_ciris ();
  logic                                                clk_i          ;
  logic                                                rst_i          ;
  logic                                                ready_i        ;
  logic                                                valid_o        ;
  logic                                                enable         ;
  logic [                                23:0]         data_o         ;
  logic [                                31:0]         height         ;
  logic [                                31:0]         width          ;
  logic [                                 5:0]         interlaced     ;
  logic [                                 7:0]         offset_frames  ;
  logic [                                23:0]         color_onecolor ;
  logic                                                mode_bw        ;
  logic                                                end_of_video_o ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0]         data_stndrt_o  ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0]         data_offset_o  ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0]         data_grad_o    ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0]         data_onecolor_o;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0]         data_image_o   ;
  logic [                              AW-1:0]         avms_address   ;
  logic [                            DW/8-1:0]         avms_byteenable;
  logic                                                avms_read      ;
  logic [                              DW-1:0]         avms_readdata  ;
  logic                                                avms_write     ;
  logic [                              DW-1:0]         avms_writedata ;
  logic [                        REGS_NUM-1:0]         word_valid_wr_o;
  logic [                        REGS_NUM-1:0][DW-1:0] word           ;
  logic [                        REGS_NUM-1:0][DW-1:0] slv_word_i     ;
  logic [                        REGS_NUM-1:0]         word_valid_rd_o;
  logic                                                vip_ctrl_send_o;


  test_pattern_generator_ciris #(.DATA_WIDTH(DATA_WIDTH)) uut_gen_polos (
    .clk_i           (clk_i          ),
    .rst_i           (rst_i          ),
    .ready_i         (ready_i        ),
    .valid_o         (valid_o        ),
    .end_of_video_o  (end_of_video_o ),
    .data_stndrt_o   (data_stndrt_o  ),
    .data_offset_o   (data_offset_o  ),
    .data_grad_o     (data_grad_o    ),
    .data_imag_o     (data_image_o   ),
    .data_onecolor_o (data_onecolor_o),
    .width_i         (width          ),
    .height_i        (height         ),
    .interlaced_i    (interlaced     ),
    .offset_frames_i (offset_frames  ),
    .color_onecolor_i(color_onecolor ),
    .vip_ctrl_send_o (vip_ctrl_send_o),
    .enable          (enable         ),
    .mode_bw_i       (mode_bw        )
  );

  av_univ_regs uut_av_univ_regs (
    .clk_i          (clk_i          ),
    .reset_n_i      (rst_i          ),
    .avms_address   (avms_address   ),
    .avms_byteenable(avms_byteenable),
    .avms_read      (avms_read      ),
    .avms_readdata  (avms_readdata  ),
    .avms_write     (avms_write     ),
    .avms_writedata (avms_writedata ),
    .word_valid_wr_o(word_valid_wr_o),
    .word_valid_rd_o(word_valid_rd_o),
    .mst_word_o     (word           ),
    .slv_word_i     (slv_word_i     )
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
    .OFFSET_FRAMES(OFFSET_FRAMES))
     uut_mux_gen (
    .clk_i           (clk_i          ),
    .rst_i           (rst_i          ),
    .word_valid_wr_i (word_valid_wr_o),
    .word_valid_rd_i (word_valid_rd_o),
    .word_i          (word           ),
    .data_stndrt_i   (data_stndrt_o  ),
    .data_offset_i   (data_offset_o  ),
    .data_grad_i     (data_grad_o    ),
    .data_onecolor_i (data_onecolor_o),
    .data_image_i    (data_image_o   ),
    .data_o          (data_o         ),
    .enable_o        (enable         ),
    .mode_bw_o       (mode_bw        ),
    .height_o        (height         ),
    .width_o         (width          ),
    .offset_frames_o (offset_frames  ),
    .interlaced_o    (interlaced     ),
    .color_onecolor_o(color_onecolor )
  );

  integer count_1 = 0;
  integer count_2 = 0;
  integer f       = 0;
  integer count_3 = 0;

  task ready_task_1(int i); begin
      while ( count_1 >= 0 ) begin
        if (count_1 <= 807 ) begin
          count_1++;
          ready_i <= 1;
          wait_clk(1);
        end else if (count_1 == 808 ) begin
          ready_i = 0;
          count_1++;
          wait_clk(1);
        end else if ( count_1 > 808 && count_1 < 1608) begin
         avms_address = 16'b0000000000000000;
          avms_writedata = 32'b00000000000000100000010000110011;
          count_1++;
          wait_clk(1);
        end else if (count_1 == 1608) begin
          ready_i <= 1;
          count_1++;
          avms_address = 16'b0000000000000000;
          avms_writedata = 32'b00000000000000100000010000110011;
          wait_clk(1);
        end else if (count_1 < 2008) begin
          ready_on_of(1);
          count_1++;
          wait_clk(1);
        end else if (count_1 == 2008) begin
          ready_i <= 0;
          count_1++;
          avms_address = 16'b0000000000000000;
          avms_writedata = 32'b00000000000000100000100000110011;
          wait_clk(1);
        end else if (count_1 < 2808) begin
          count_1++;
          wait_clk(1);
        end else if (count_1 == 2808) begin
          ready_i <= 1;
          count_1++;
          wait_clk(1);
        end else if (count_1 < 3208) begin
          ready_on_of(1);
          count_1++;
          wait_clk(1);
        end else if (count_1 == 3208) begin
         avms_address = 16'b0000000000000001;
          avms_writedata = 32'b00000000000000000000001110000100;
         ready_i <= 0;
          count_1++;
          wait_clk(1);
        end else if (count_1 < 4008) begin
          count_1++;
          wait_clk(1);
        end else if (count_1 == 4008) begin
          ready_i <= 1;
          count_1++;
          wait_clk(1);
        end else if (count_1 < 4408) begin
          ready_on_of(1);
          count_1++;
          wait_clk(1);
        end else if (count_1 == 4408) begin
          ready_i <= 0;
          count_1++;
          wait_clk(1);
        end else if (count_1 < 5208) begin
          count_1++;
          wait_clk(1);
        end else if ( count_1 == 5208) begin
          ready_i <= 1;
          count_1++;
          wait_clk(1);
        end else if (count_1 < 5608 ) begin
          ready_on_of(1);
          count_1++;
          wait_clk(1);
        end else if (count_1 == 5608) begin
          ready_i <= 1;
          wait_clk(1);
        end
      end
    end endtask : ready_task_1

  task ready_on_of(int i);
    repeat (i)
      wait_clk(5);
    ready_i = ~ready_i;

  endtask : ready_on_of
  task wait_clk(int i);
    repeat (i) @(posedge clk_i);
  endtask : wait_clk

  task ready_random();
    forever #12 ready_i <= $urandom_range(0,1);
  endtask : ready_random

  initial begin
    clk_i = 0;
    rst_i = 1;
    forever #2 clk_i = ~clk_i ;
    ready_random();
  end

  initial begin
    wait_clk(1);
    rst_i = 0;
    wait_clk(1);
    rst_i = 1;
    avms_address = 16'b0000000000000000;
    avms_byteenable = 4'b1111;
    avms_write = '1;
    avms_writedata = 32'b00000000000000010000001000110011;
    avms_read = '0;
    wait_clk(1);
    avms_address = 16'b0000000000000001;
    avms_writedata = 32'b00000000000000000000001100100000;
    wait_clk(1);
    avms_address = 16'b0000000000000010;
    avms_writedata = 32'b00000000000000000000001001011000;
    wait_clk(1);
    avms_address = 16'b0000000000000011;
    avms_writedata = 32'b11111111000000001111111100000011;
    ready_task_1(1);
  end

endmodule


